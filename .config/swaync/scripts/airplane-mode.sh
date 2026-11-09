#!/usr/bin/env bash
set -euo pipefail

export LC_ALL=C

has_bluetooth() {
  bluetoothctl list | grep -q '^Controller '
}

is_active() {
  [[ $(nmcli -t -f WIFI radio) == disabled ]] || return 1
  ! has_bluetooth || [[ $(bluetoothctl show | sed -n 's/^[[:space:]]*Powered: //p' | head -n 1) == no ]]
}

case "${1:-}" in
  state)
    if is_active; then echo true; else echo false; fi
    ;;
  toggle)
    if [[ ${SWAYNC_TOGGLE_STATE:-} == true ]]; then
      nmcli radio all off
      if has_bluetooth; then bluetoothctl power off; fi
    else
      nmcli radio all on
      if has_bluetooth; then bluetoothctl power on; fi
    fi
    ;;
  *)
    echo "Usage: $0 {state|toggle}" >&2
    exit 2
    ;;
esac
