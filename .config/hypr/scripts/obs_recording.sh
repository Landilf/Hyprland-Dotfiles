#!/usr/bin/env bash

set -euo pipefail

recordings_dir="${RECORDINGS_DIR:-/home/landilf/Recordings}"
scene_monitor="${OBS_SCENE_MONITOR:-Monitor}"
collection="${OBS_COLLECTION:-}"
profile="${OBS_PROFILE:-}"

# Local timer state for Waybar.
# We can't always rely on obs-cmd to provide an updating duration/timecode, so we
# persist the recording start epoch and derive an elapsed timer from it.
state_dir="${XDG_RUNTIME_DIR:-/tmp}/obs_recording"
state_start_file="${state_dir}/start_epoch"

state_get_start() {
	[ -f "$state_start_file" ] || return 1
	local v
	v="$(cat "$state_start_file" 2>/dev/null || true)"
	[[ "$v" =~ ^[0-9]+$ ]] || return 1
	printf "%s" "$v"
}

state_set_start_now() {
	mkdir -p "$state_dir" >/dev/null 2>&1 || true
	date +%s >"$state_start_file" 2>/dev/null || true
}

state_set_start() {
	# $1: epoch seconds
	local v="${1:?}"
	[[ "$v" =~ ^[0-9]+$ ]] || return 1
	mkdir -p "$state_dir" >/dev/null 2>&1 || true
	printf "%s\n" "$v" >"$state_start_file" 2>/dev/null || true
}

state_clear() {
	rm -f "$state_start_file" >/dev/null 2>&1 || true
}

notify() {
	# best-effort notifications (don't assume a notification daemon is running)
	local msg="$1"
	notify-send "OBS" "$msg" >/dev/null 2>&1 || true
	hyprctl notify 1 3500 0 "$msg" >/dev/null 2>&1 || true
}

obs_is_running() {
	pgrep -x obs >/dev/null 2>&1 || pgrep -x .obs-wrapped >/dev/null 2>&1
}

source_obs_cmd_env() {
	# obs-cmd supports OBS_WEBSOCKET_URL env var.
	# Keep secrets out of git.
	local env_file="$HOME/.config/hypr/scripts/obs_cmd.env"
	if [ -f "$env_file" ]; then
		set -a
		. "$env_file"
		set +a
	fi

	# Either provide OBS_WEBSOCKET_URL directly, or provide components:
	#   OBS_WS_HOST, OBS_WS_PORT, OBS_WS_PASSWORD
	: "${OBS_WEBSOCKET_URL:=}"
	: "${OBS_WS_HOST:=127.0.0.1}"
	: "${OBS_WS_PORT:=4455}"
	: "${OBS_WS_PASSWORD:=}"

	if [ -z "$OBS_WEBSOCKET_URL" ] && [ -n "$OBS_WS_PASSWORD" ]; then
		# URL-encode password so it can safely live in the URL path.
		enc_pw="$(python3 - <<'PY'
import os, urllib.parse
pw = os.environ.get("OBS_WS_PASSWORD","")
print(urllib.parse.quote(pw, safe=""))
PY
)"
		OBS_WEBSOCKET_URL="obsws://${OBS_WS_HOST}:${OBS_WS_PORT}/${enc_pw}"
		export OBS_WEBSOCKET_URL
	fi
}

obs_cmd() {
	source_obs_cmd_env
	# Prefer explicit websocket URL (obs-websocket v5).
	if [ -n "$OBS_WEBSOCKET_URL" ]; then
		obs-cmd -w "$OBS_WEBSOCKET_URL" "$@"
	else
		obs-cmd "$@"
	fi
}

obs_cmd_ready() {
	obs_cmd info >/dev/null 2>&1
}

wait_while() {
	# wait_while <predicate-fn> <timeout-seconds>
	local fn="${1:?}"
	local timeout="${2:?}"
	local start
	start="$(date +%s)"
	while "$fn"; do
		(( $(date +%s) - start >= timeout )) && return 1
		sleep 0.1
	done
	return 0
}

wait_until() {
	# wait_until <predicate-fn> <timeout-seconds>
	local fn="${1:?}"
	local timeout="${2:?}"
	local start
	start="$(date +%s)"
	while ! "$fn"; do
		(( $(date +%s) - start >= timeout )) && return 1
		sleep 0.1
	done
	return 0
}

format_elapsed() {
	local start now diff h m s
	start="$1"
	now="$(date +%s)"
	diff=$((now - start))
	((diff < 0)) && diff=0
	h=$((diff / 3600))
	m=$(((diff % 3600) / 60))
	s=$((diff % 60))
	if ((h > 0)); then
		printf "%d:%02d:%02d" "$h" "$m" "$s"
	else
		printf "%02d:%02d" "$m" "$s"
	fi
}

is_recording() {
	# Prefer explicit boolean output, but also respect exit code if that's how obs-cmd signals it.
	local out rc
	out="$(obs_cmd recording status-active 2>/dev/null)" || rc=$?
	rc="${rc:-0}"
	out="$(printf "%s" "$out" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | xargs 2>/dev/null || true)"
	case "$out" in
		true|1|yes|y|active) return 0 ;;
		false|0|no|n|inactive)
			# Definite inactive -> clear any stale local timer.
			state_clear
			return 1
			;;
	esac
	return "$rc"
}

status() {
	is_recording || exit 1
	local out tc dur_ms pretty start now sec h m s
	out="$(obs_cmd recording status 2>/dev/null || true)"

	tc=""
	dur_ms=""
	if [ -n "$out" ] && printf "%s" "$out" | jq -e . >/dev/null 2>&1; then
		# obs-websocket GetRecordStatus has outputDuration (ms) and outputTimecode.
		dur_ms="$(printf "%s" "$out" | jq -r '.outputDuration // .outputDurationMs // empty' | head -n 1)"
		tc="$(printf "%s" "$out" | jq -r '.outputTimecode // .recordTimecode // empty' | head -n 1)"
	else
		# Best-effort: extract timecode from common text formats.
		# Examples we try to handle:
		#   outputTimecode: 00:01:23.456
		#   Timecode: 00:01:23.456
		dur_ms="$(
			printf "%s\n" "$out" |
				sed -n -E 's/.*(outputDuration|OutputDuration|duration|Duration)[^0-9]*([0-9]{1,}).*/\2/p' |
				head -n 1
		)"
		tc="$(
			printf "%s\n" "$out" |
				sed -n -E 's/.*(outputTimecode|OutputTimecode|recordTimecode|RecordTimecode|timecode|Timecode)[^0-9]*([0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)?).*/\2/p' |
				head -n 1
		)"
		if [ -z "$tc" ]; then
			# Fallback: first thing that looks like HH:MM:SS(.mmm)
			tc="$(printf "%s\n" "$out" | rg -o '[0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?' -m 1 2>/dev/null || true)"
		fi
	fi

	# Primary: local elapsed timer derived from a persisted start epoch.
	start="$(state_get_start || true)"
	if [ -z "$start" ]; then
		now="$(date +%s)"
		# If obs-cmd gave us a duration, back-compute a start epoch once.
		if printf "%s" "$dur_ms" | rg -q '^[0-9]+$'; then
			sec=$((dur_ms / 1000))
			start=$((now - sec))
			((start < 0)) && start=0
			state_set_start "$start" || true
		else
			state_set_start_now
			start="$(state_get_start || true)"
		fi
	fi

	if [ -n "$start" ]; then
		pretty="$(format_elapsed "$start")"
	else
		# Last-resort fallback if we couldn't read/write the timer state.
		if printf "%s" "$dur_ms" | rg -q '^[0-9]+$'; then
			sec=$((dur_ms / 1000))
			h=$((sec / 3600))
			m=$(((sec % 3600) / 60))
			s=$((sec % 60))
			if [ "$h" -gt 0 ]; then
				pretty="$(printf "%d:%02d:%02d" "$h" "$m" "$s")"
			else
				pretty="$(printf "%02d:%02d" "$m" "$s")"
			fi
		else
			tc="${tc%%.*}"
			pretty="${tc:-00:00}"
			case "$pretty" in
				00:??:??) pretty="${pretty#00:}" ;;
			esac
		fi
	fi

	printf " %s\n" "$pretty"
}

hypr_clients_json() {
	hyprctl -j clients 2>/dev/null || true
}

hypr_has_client_matching() {
	# $1: jq boolean expression operating on the array of clients
	local expr="${1:?}"
	local clients
	clients="$(hypr_clients_json)"
	[[ -n "$clients" ]] || return 1
	command -v jq >/dev/null 2>&1 || return 1
	jq -e "$expr" >/dev/null 2>&1 <<EOF
$clients
EOF
}

portal_window_present() {
	# Best-effort: portal picker window (xdg-desktop-portal-gtk / xdg-desktop-portal-hyprland etc.)
	hypr_has_client_matching 'any(.[]; ((.class // "") | test("xdg-desktop-portal|org\\\\.freedesktop\\\\.portal|portal"; "i")) or ((.initialClass // "") | test("xdg-desktop-portal|org\\\\.freedesktop\\\\.portal|portal"; "i")) or ((.title // "") | test("screen|share|capture|portal|choose|select|экран|окно|область|выбор|поделиться|разреш"; "i")) or ((.initialTitle // "") | test("screen|share|capture|portal|choose|select|экран|окно|область|выбор|поделиться|разреш"; "i")) )'
}

start_monitor() {
	source_obs_cmd_env
	if [ -z "$OBS_WEBSOCKET_URL" ]; then
		notify "Missing OBS websocket config. Create ~/.config/hypr/scripts/obs_cmd.env (see obs_cmd.env.example)"
		return 1
	fi

	# Start OBS without recording. The portal picker will appear; only after it closes
	# we start recording via obs-websocket to avoid black frames.
	if ! obs_is_running; then
		set -- --scene "$scene_monitor" --minimize-to-tray --multi
		[[ -n "$collection" ]] && set -- "$@" --collection "$collection"
		[[ -n "$profile" ]] && set -- "$@" --profile "$profile"

		setsid -f obs "$@" >/dev/null 2>&1 || true
	fi

	# Wait until obs-cmd can connect (v5 websocket).
	local connected=0
	local last_err=""
	for _ in $(seq 1 80); do
		if obs_cmd_ready; then
			connected=1
			break
		fi
		last_err="$(obs_cmd info 2>&1 | tail -n 1 || true)"
		sleep 0.2
	done
	if [ "$connected" -ne 1 ]; then
		notify "obs-cmd can't connect (check port/password). ${last_err}"
		return 1
	fi

	# If the portal appears, wait until it closes (user granted permission / selected source).
	wait_until portal_window_present 5 || true
	wait_while portal_window_present 180 || true

	# Start recording via obs-cmd.
	if ! obs_cmd recording start >/dev/null 2>&1; then
		notify "Recording start failed via obs-cmd."
		return 1
	fi

	for _ in $(seq 1 50); do
		is_recording && break
		sleep 0.1
	done

	# Initialize local timer once recording is active.
	if is_recording; then
		state_set_start_now
	fi

	pkill -SIGRTMIN+9 waybar >/dev/null 2>&1 || true
}

stop() {
	local out rc
	out="$(obs_cmd recording stop 2>&1)" || {
		rc=$?
		out="${out//$'\n'/ }"
		notify "Recording stop failed via obs-cmd. ${out}"
		pkill -SIGRTMIN+9 waybar >/dev/null 2>&1 || true
		return 1
	}
	# Wait for inactive
	for _ in $(seq 1 80); do
		is_recording || break
		sleep 0.1
	done
	if is_recording; then
		notify "Recording stop timed out."
		pkill -SIGRTMIN+9 waybar >/dev/null 2>&1 || true
		return 1
	fi
	state_clear
	pkill -SIGRTMIN+9 waybar >/dev/null 2>&1 || true
}

open_dir() {
	xdg-open "$recordings_dir" >/dev/null 2>&1 || true
}

case "${1:-}" in
	--is-recording) is_recording ;;
	--status) status ;;
	--start-monitor) start_monitor ;;
	--stop) stop ;;
	--open-dir) open_dir ;;
	*)
		echo "Usage: $0 [--is-recording|--status|--start-monitor|--stop|--open-dir]" >&2
		exit 2
		;;
esac
