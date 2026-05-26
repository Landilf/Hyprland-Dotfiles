#!/usr/bin/env bash
set -euo pipefail

# Sync keyboard backlight to the current Matugen palette.
#
# Usage:
#   sync-kbd-rgb.sh [--color-var primary|secondary|tertiary]
#
# Environment:
#   HYPRCOLORS_FILE     Path to hyprcolors.conf (default: ~/.config/colors/hyprcolors.conf)
#   SYNC_ASUSCTL        Set to 0 to disable ASUS Aura sync (default: 1).
#   ASUSCTL_BIN         Override asusctl binary path (default: asusctl).
#
#   KBD_BACKLIGHT_DEVICE        LED class device for laptop keyboard backlight (default: asus::kbd_backlight).
#   KBD_BRIGHTNESS_MODE         "preserve" (default) or "force".
#   KBD_BRIGHTNESS_TARGET       Brightness to force when mode is "force" (default: 1).

color_var="primary"

hyprcolors_file="${HYPRCOLORS_FILE:-$HOME/.config/colors/hyprcolors.conf}"

get_rgba_hex() {
  local var="$1"
  awk -v var="$var" '
    $0 ~ "^\\$"var"[[:space:]]*=" {
      if (match($0, /rgba\(([0-9a-fA-F]{6,8})\)/, m)) {
        print m[1]
        exit
      }
    }
  ' "$hyprcolors_file" 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --color-var)
      color_var="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--color-var primary|secondary|tertiary]" >&2
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

[[ -f "$hyprcolors_file" ]] || exit 0

rgba_hex="$(get_rgba_hex "$color_var")"
rgb_hex=""
if [[ -n "${rgba_hex:-}" ]]; then
  rgb_hex="${rgba_hex:0:6}"
fi

led_device="${KBD_BACKLIGHT_DEVICE:-asus::kbd_backlight}"
brightness_path="/sys/class/leds/${led_device}/brightness"
pre_brightness=""
if [[ -r "$brightness_path" ]]; then
  pre_brightness="$(cat "$brightness_path" 2>/dev/null || true)"
fi

set_kbd_brightness() {
  local value="$1"

  [[ -n "$value" ]] || return 0

  if [[ -w "$brightness_path" ]]; then
    echo "$value" >"$brightness_path" 2>/dev/null || true
    return 0
  fi

  if command -v brightnessctl >/dev/null 2>&1; then
    brightnessctl -d "$led_device" set "$value" >/dev/null 2>&1 || true
  fi
}

asusctl_bin="${ASUSCTL_BIN:-asusctl}"
if ! command -v "$asusctl_bin" >/dev/null 2>&1; then
  if [[ -x /run/current-system/sw/bin/asusctl ]]; then
    asusctl_bin="/run/current-system/sw/bin/asusctl"
  fi
fi

apply_asusctl_rgb() {
  local hex="$1"

  [[ -n "$hex" ]] || return 1
  [[ "${SYNC_ASUSCTL:-1}" != "0" ]] || return 1
  command -v "$asusctl_bin" >/dev/null 2>&1 || return 1

  # The current asusctl build exposes aura modes with a shared colour option.
  "$asusctl_bin" aura static -c "$hex" >/dev/null 2>&1 && return 0
  "$asusctl_bin" aura static --colours "$hex" >/dev/null 2>&1 && return 0
  "$asusctl_bin" aura static "$hex" >/dev/null 2>&1 && return 0

  return 1
}

apply_asusctl_rgb "$rgb_hex" >/dev/null 2>&1 || true

brightness_mode="${KBD_BRIGHTNESS_MODE:-preserve}"
case "$brightness_mode" in
  force)
    set_kbd_brightness "${KBD_BRIGHTNESS_TARGET:-1}"
    ;;
  preserve|*)
    set_kbd_brightness "$pre_brightness"
    ;;
esac
