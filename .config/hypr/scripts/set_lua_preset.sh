#!/bin/sh

set -eu

kind="${1:-}"
preset="${2:-}"

case "$kind:$preset" in
	animation:horizontal|animation:vertical|rounding:square|rounding:gentle|rounding:round) ;;
	*) exit 2 ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland"
mkdir -p "$state_dir"
printf '%s\n' "$preset" > "$state_dir/${kind}_preset"
hyprctl reload
