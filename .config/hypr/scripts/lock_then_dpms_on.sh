#!/usr/bin/env bash
set -euo pipefail

# Start the lock screen (if not already running), then turn DPMS back on.
if ! pgrep -x hyprlock >/dev/null 2>&1; then
  hyprlock >/dev/null 2>&1 &
  disown || true
fi

hyprctl dispatch dpms on >/dev/null 2>&1 || true
