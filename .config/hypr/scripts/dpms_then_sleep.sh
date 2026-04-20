#!/usr/bin/env bash
set -uo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
pid_file="$runtime_dir/hypr-dpms-sleep.pid"

cancel_pending() {
  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(cat "$pid_file" 2>/dev/null || true)"
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
    fi
    rm -f "$pid_file"
  fi
}

start_pending() {
  local delay="${1:-${HYPR_AUTO_SLEEP_DELAY:-2700}}"

  cancel_pending

  (
    sleep "$delay"

    hyprctl dispatch dpms on >/dev/null 2>&1 || true

    if ! pgrep -x hyprlock >/dev/null 2>&1; then
      hyprlock >/dev/null 2>&1 &
      sleep 0.5
    fi

    systemctl suspend -i
  ) &

  printf '%s\n' "$!" > "$pid_file"
  hyprctl dispatch dpms off >/dev/null 2>&1 || true
}

case "${1:-}" in
  start)
    start_pending "${2:-}"
    ;;
  cancel-and-lock)
    cancel_pending
    ~/.config/hypr/scripts/lock_then_dpms_on.sh
    ;;
  cancel)
    cancel_pending
    ;;
  *)
    echo "Usage: $0 {start [delay_seconds]|cancel-and-lock|cancel}" >&2
    exit 2
    ;;
esac
