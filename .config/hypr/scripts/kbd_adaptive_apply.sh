#!/usr/bin/env bash
set -euo pipefail

state_file="$HOME/.config/hypr/state/kbd_mode"
state="adaptive:static"
if [[ -f "$state_file" ]]; then
  state="$(cat "$state_file" 2>/dev/null || echo adaptive:static)"
fi

led_device="${KBD_BACKLIGHT_DEVICE:-asus::kbd_backlight}"
brightness_path="/sys/class/leds/${led_device}/brightness"

get_kbd_brightness() {
  if [[ -r "$brightness_path" ]]; then
    cat "$brightness_path" 2>/dev/null || true
  fi
}

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

asusctl_try() {
  asusctl "$@" >/dev/null 2>&1 && return 0
  sudo -n asusctl "$@" >/dev/null 2>&1 && return 0
  return 1
}

get_rgba_hex() {
  local var="$1"
  local hyprcolors_file="${HYPRCOLORS_FILE:-$HOME/.config/colors/hyprcolors.conf}"
  awk -v var="$var" '
    $0 ~ "^\\$"var"[[:space:]]*=" {
      if (match($0, /rgba\(([0-9a-fA-F]{6,8})\)/, m)) {
        print m[1]
        exit
      }
    }
  ' "$hyprcolors_file" 2>/dev/null || true
}

primary_hex="$(get_rgba_hex primary | cut -c1-6)"
secondary_hex="$(get_rgba_hex secondary | cut -c1-6)"
[[ -n "$primary_hex" ]] || primary_hex="ffffff"
[[ -n "$secondary_hex" ]] || secondary_hex="$primary_hex"

pre_brightness="$(get_kbd_brightness)"

case "$state" in
  adaptive|adaptive:static|"")
    "$HOME/.config/hypr/scripts/sync-kbd-rgb.sh" >/dev/null 2>&1 || true
    ;;
  adaptive:pulse)
    asusctl_try aura pulse -c "$primary_hex" || \
    asusctl_try aura pulse --colours "$primary_hex" || \
    asusctl_try aura pulse || true
    ;;
  adaptive:breathe)
    asusctl_try aura breathe -c "$primary_hex" -c "$secondary_hex" || \
    asusctl_try aura breathe --colours "$primary_hex" --colours "$secondary_hex" || true
    ;;
esac

# Some Aura mode changes reset keyboard brightness; restore the previous level.
set_kbd_brightness "$pre_brightness"
