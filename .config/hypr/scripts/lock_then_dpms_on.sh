#!/usr/bin/env bash
set -euo pipefail

# Start the lock screen (if not already running), then turn DPMS back on.
# Resume can be racy; retry a bit until Hyprland IPC is ready.
runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  socket="$runtime_dir/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  for _ in $(seq 1 30); do
    [[ -S "$socket" ]] && break
    sleep 0.1
  done
fi

sleep "${HYPR_RESUME_GRACE:-0.3}"

if ! pgrep -x hyprlock >/dev/null 2>&1; then
  hyprlock >/dev/null 2>&1 &
  disown || true
fi

dpms_on() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 1s hyprctl dispatch dpms on >/dev/null 2>&1
  else
    hyprctl dispatch dpms on >/dev/null 2>&1
  fi
}

dpms_ok=0
for _ in $(seq 1 30); do
  if dpms_on; then
    dpms_ok=1
    break
  fi
  sleep 0.1
done

if [[ "$dpms_ok" == "1" ]]; then
  exit 0
fi
exit 0
