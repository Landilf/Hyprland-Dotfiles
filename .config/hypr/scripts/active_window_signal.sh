#!/usr/bin/env bash

set -euo pipefail

signal="${1:-TERM}"

case "$signal" in
  TERM|KILL) ;;
  *)
    notify-send "Window control" "Unsupported signal: $signal" -u critical >/dev/null 2>&1 || true
    exit 1
    ;;
esac

window_info="$(hyprctl -j activewindow 2>/dev/null || true)"

if [[ -z "$window_info" ]]; then
  notify-send "Window control" "No active window found" >/dev/null 2>&1 || true
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  pid="$(printf '%s\n' "$window_info" | jq -r '.pid // empty')"
  class="$(printf '%s\n' "$window_info" | jq -r '.class // empty')"
  title="$(printf '%s\n' "$window_info" | jq -r '.title // empty')"
else
  pid="$(printf '%s\n' "$window_info" | sed -n 's/.*"pid":[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -n1)"
  class="$(printf '%s\n' "$window_info" | sed -n 's/.*"class":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
  title="$(printf '%s\n' "$window_info" | sed -n 's/.*"title":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"
fi

if [[ -z "$pid" ]]; then
  notify-send "Window control" "Could not determine PID of active window" -u critical >/dev/null 2>&1 || true
  exit 1
fi

kill "-$signal" "$pid"

case "$signal" in
  TERM)
    notify-send "Window control" "Sent soft close to ${class:-window}: ${title:-untitled}" >/dev/null 2>&1 || true
    ;;
  KILL)
    notify-send "Window control" "Force-killed ${class:-window}: ${title:-untitled}" >/dev/null 2>&1 || true
    ;;
esac
