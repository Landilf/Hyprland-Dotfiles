#!/usr/bin/env bash

set -euo pipefail

# Resolutions to cycle through (in order).
# 1440x900 removed because it causes side bars on a 16:9 1920x1080 panel.
RESOLUTIONS=(
	"1920x1080"
	"1280x720"
	"640x480"
)

get_monitor() {
	hyprctl monitors | grep "Monitor " | awk '{print $2}' | head -n 1
}

get_monitor_state() {
	local monitor="$1"
	hyprctl monitors | awk -v mon="$monitor" '
		$1=="Monitor" {
			if (in_mon && $2!=mon) { exit }
			in_mon=($2==mon)
			next
		}
		in_mon && $1 ~ /@/ {
			split($1, a, "@")
			res=a[1]
			rate=a[2]
			pos=$3
			next
		}
		in_mon && $1=="scale:" { scale=$2 }
		END { print res, rate, pos, scale }
	'
}

set_resolution() {
	local new_res="$1"
	local monitor _res rate pos scale

	monitor="$(get_monitor)"
	monitor="${monitor:-eDP-1}"

	read -r _res rate pos scale < <(get_monitor_state "$monitor")

	rate="${rate:-60}"
	pos="${pos:-0x0}"
	scale="${scale:-1}"

	hyprctl keyword monitor "$monitor,${new_res}@${rate},${pos},${scale}" >/dev/null
}

get_current_res() {
	local monitor="$1"
	local res _rate _pos _scale
	read -r res _rate _pos _scale < <(get_monitor_state "$monitor")
	printf "%s\n" "${res:-}"
}

print_status() {
	local monitor res
	monitor="$(get_monitor)"
	monitor="${monitor:-eDP-1}"
	res="$(get_current_res "$monitor")"
	printf "%s\n" "${res:-?}"
}

toggle_resolution() {
	local monitor cur next i
	monitor="$(get_monitor)"
	monitor="${monitor:-eDP-1}"
	cur="$(get_current_res "$monitor")"

	next="${RESOLUTIONS[0]}"
	for i in "${!RESOLUTIONS[@]}"; do
		if [ "${RESOLUTIONS[$i]}" = "$cur" ]; then
			next="${RESOLUTIONS[$(( (i + 1) % ${#RESOLUTIONS[@]} ))]}"
			break
		fi
	done

	set_resolution "$next"
}

case "${1:-}" in
	--status|"")
		print_status
		;;
	--toggle)
		toggle_resolution
		;;
	--set)
		shift
		[ -n "${1:-}" ] || exit 2
		set_resolution "$1"
		;;
	*)
		echo "Usage: $0 [--status|--toggle|--set <WxH>]" >&2
		exit 2
		;;
esac
