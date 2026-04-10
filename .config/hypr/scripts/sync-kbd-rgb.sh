#!/usr/bin/env bash
set -euo pipefail

# Sync keyboard backlight to the current Matugen palette.
#
# Usage:
#   sync-kbd-rgb.sh [--color-var primary|secondary|tertiary] [--brightness 0-100]
#
# Environment:
#   HYPRCOLORS_FILE  Path to hyprcolors.conf (default: ~/.config/colors/hyprcolors.conf)
#   OPENRGB_DEVICE       OpenRGB device selector (number or name). If unset, applies to all devices.
#   SYNC_OPENRGB         Set to 0 to disable OpenRGB entirely (default: 1).
#   OPENRGB_BIN          Override OpenRGB binary path (default: openrgb).
#   OPENRGB_EXTRA_ARGS   Extra args passed to OpenRGB (space-delimited).
#   OPENRGB_SERVER_ADDR  If set (or default), uses SDK client when server is up (default: 127.0.0.1:6742).
#
#   KBD_BACKLIGHT_DEVICE LED class device for laptop keyboard backlight (default: asus::kbd_backlight).
#   SYNC_KBD_BACKLIGHT   Set to 0 to disable LED-class brightness preserving (default: 1).
#   KBD_BACKLIGHT_DEFAULT If current brightness can't be read, use this level (default: 1).
#   KBD_BACKLIGHT_TARGET  If set, always force this brightness level (0..max).
#   KBD_BACKLIGHT_FORCE_DEFAULT If set to 1, always force KBD_BACKLIGHT_DEFAULT (even if current level is readable).
#   KBD_BRIGHTNESS_GUARD_ITERS  How many times to enforce brightness (default: 200).
#   KBD_BRIGHTNESS_GUARD_SLEEP  Sleep between guard iterations in seconds (default: 0.02).

color_var="primary"
brightness=""
debug="${DEBUG:-0}"
log_file="${LOG_FILE:-}"

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

log() {
  local msg="$1"
  if [[ -n "$log_file" ]]; then
    printf '%s %s\n' "$(date -Is)" "$msg" >>"$log_file" 2>/dev/null || true
  fi
  if [[ "$debug" != "0" ]]; then
    echo "$msg" >&2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --color-var)
      color_var="${2:-}"
      shift 2
      ;;
    --brightness)
      brightness="${2:-}"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--color-var primary|secondary|tertiary] [--brightness 0-100]" >&2
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
log "hyprcolors_file=$hyprcolors_file color_var=$color_var rgba_hex=${rgba_hex:-} rgb_hex=${rgb_hex:-}"

# 1) Optional: OpenRGB (for external RGB keyboards / devices)
openrgb_bin="${OPENRGB_BIN:-openrgb}"
if ! command -v "$openrgb_bin" >/dev/null 2>&1; then
  if [[ -x /run/current-system/sw/bin/openrgb ]]; then
    openrgb_bin="/run/current-system/sw/bin/openrgb"
  fi
fi

led_device="${KBD_BACKLIGHT_DEVICE:-asus::kbd_backlight}"
brightness_path="/sys/class/leds/${led_device}/brightness"
max_brightness_path="/sys/class/leds/${led_device}/max_brightness"
pre_led_brightness=""
if [[ -e "$brightness_path" ]]; then
  pre_led_brightness="$(cat "$brightness_path" 2>/dev/null || true)"
fi
log "led_device=$led_device pre_led_brightness=${pre_led_brightness:-unset}"

default_led_brightness="${KBD_BACKLIGHT_DEFAULT:-1}"
if [[ -n "${KBD_BACKLIGHT_TARGET:-}" ]]; then
  target_led_brightness="${KBD_BACKLIGHT_TARGET}"
elif [[ "${KBD_BACKLIGHT_FORCE_DEFAULT:-0}" == "1" ]]; then
  target_led_brightness="${default_led_brightness}"
else
  target_led_brightness="${pre_led_brightness:-${default_led_brightness}}"
fi
log "target_led_brightness=$target_led_brightness"

set_led_brightness() {
  local value="$1"
  if [[ -z "${value:-}" ]]; then
    return 0
  fi
  if [[ -e "$brightness_path" ]] && [[ -w "$brightness_path" ]]; then
    echo "$value" >"$brightness_path" 2>/dev/null || true
  elif command -v brightnessctl >/dev/null 2>&1; then
    brightnessctl -d "$led_device" set "$value" >/dev/null 2>&1 || true
  fi
}

guard_led_brightness() {
  local target="$1"
  local iters="${KBD_BRIGHTNESS_GUARD_ITERS:-200}"
  local delay="${KBD_BRIGHTNESS_GUARD_SLEEP:-0.02}"

  [[ -e "$brightness_path" ]] || return 0

  for _ in $(seq 1 "$iters" 2>/dev/null); do
    cur="$(cat "$brightness_path" 2>/dev/null || true)"
    if [[ -n "${cur:-}" ]] && [[ "$cur" != "$target" ]]; then
      set_led_brightness "$target"
    fi
    sleep "$delay" 2>/dev/null || true
  done

  # Final forced restore (some devices switch brightness late).
  set_led_brightness "$target"
}

if [[ "${SYNC_OPENRGB:-1}" != "0" ]] && [[ -n "${rgb_hex:-}" ]] && command -v "$openrgb_bin" >/dev/null 2>&1; then
  # Keep arguments minimal to avoid device-side effect restarts/flicker.
  openrgb_base=(--mode static --color "$rgb_hex")
  if [[ -n "${brightness:-}" ]]; then
    openrgb_base+=(--brightness "$brightness")
  fi
  if [[ -n "${OPENRGB_DEVICE:-}" ]]; then
    openrgb_base=(--device "$OPENRGB_DEVICE" "${openrgb_base[@]}")
  fi
  if [[ -n "${OPENRGB_EXTRA_ARGS:-}" ]]; then
    # shellcheck disable=SC2206
    extra_args=(${OPENRGB_EXTRA_ARGS})
    openrgb_base+=("${extra_args[@]}")
  fi

  server_addr="${OPENRGB_SERVER_ADDR:-127.0.0.1:6742}"
  use_client="0"
  if [[ -n "${server_addr:-}" ]]; then
    if timeout 0.15 bash -c "</dev/tcp/${server_addr%:*}/${server_addr##*:}" >/dev/null 2>&1; then
      use_client="1"
    fi
  fi

  if [[ "$use_client" == "1" ]]; then
    openrgb_cmd=("$openrgb_bin" --client "$server_addr" "${openrgb_base[@]}")
  else
    openrgb_cmd=("$openrgb_bin" "${openrgb_base[@]}")
  fi

  guard_pid=""
  if [[ "${SYNC_KBD_BACKLIGHT:-1}" != "0" ]] && [[ -n "${target_led_brightness:-}" ]] && [[ -e "$brightness_path" ]]; then
    ( guard_led_brightness "$target_led_brightness" ) >/dev/null 2>&1 &
    guard_pid="$!"
  fi

  log "openrgb_cmd=${openrgb_cmd[*]}"
  if [[ "$debug" != "0" ]]; then
    "${openrgb_cmd[@]}" || true
  else
    # Match manual usage: run OpenRGB once and return.
    "${openrgb_cmd[@]}" >/dev/null 2>&1 || true
  fi

  # Stop brightness guard immediately after OpenRGB finishes so it doesn't fight with manual brightness keys.
  if [[ -n "${guard_pid:-}" ]]; then
    kill "$guard_pid" >/dev/null 2>&1 || true
    wait "$guard_pid" >/dev/null 2>&1 || true
  fi
else
  log "openrgb skipped (SYNC_OPENRGB=${SYNC_OPENRGB:-1}, rgb_hex=${rgb_hex:-}, openrgb_bin=$(command -v "$openrgb_bin" 2>/dev/null || echo missing))"
fi

# 2) Preserve current keyboard backlight brightness (some devices reset it on OpenRGB updates)
if [[ "${SYNC_KBD_BACKLIGHT:-1}" != "0" ]] && [[ -e "$brightness_path" ]]; then
  post_led_brightness="$(cat "$brightness_path" 2>/dev/null || true)"
  if [[ -n "${post_led_brightness:-}" ]] && [[ "$post_led_brightness" != "$target_led_brightness" ]]; then
    set_led_brightness "$target_led_brightness"
    log "restored led brightness $post_led_brightness -> $target_led_brightness"
  else
    log "led brightness unchanged (${target_led_brightness})"
  fi
fi
