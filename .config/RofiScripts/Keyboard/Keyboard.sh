#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
back_cmd="${ROFI_BACK_CMD:-$HOME/.config/RofiScripts/Settings/Settings.sh}"

state_dir="$HOME/.config/hypr/state"
state_file="$state_dir/kbd_mode"

hyprcolors_file="${HYPRCOLORS_FILE:-$HOME/.config/colors/hyprcolors.conf}"

led_device="${KBD_BACKLIGHT_DEVICE:-asus::kbd_backlight}"
brightness_path="/sys/class/leds/${led_device}/brightness"

get_kbd_brightness() {
	if [ -r "$brightness_path" ]; then
		cat "$brightness_path" 2>/dev/null || true
	fi
}

set_kbd_brightness() {
	value="$1"
	[ -n "$value" ] || return 0
	if [ -w "$brightness_path" ]; then
		echo "$value" >"$brightness_path" 2>/dev/null || true
		return 0
	fi
	if command -v brightnessctl >/dev/null 2>&1; then
		brightnessctl -d "$led_device" set "$value" >/dev/null 2>&1 || true
	fi
}

get_rgba_hex() {
	var="$1"
	awk -v var="$var" '
		$0 ~ "^\\$"var"[[:space:]]*=" {
			if (match($0, /rgba\(([0-9a-fA-F]{6,8})\)/, m)) {
				print m[1]
				exit
			}
		}
	' "$hyprcolors_file" 2>/dev/null
}

primary_hex="$(get_rgba_hex primary | cut -c1-6)"
secondary_hex="$(get_rgba_hex secondary | cut -c1-6)"
[ -n "$primary_hex" ] || primary_hex="ffffff"
[ -n "$secondary_hex" ] || secondary_hex="$primary_hex"

set_state() {
	mode="$1"
	mkdir -p "$state_dir" 2>/dev/null || true
	printf "%s\n" "$mode" >"$state_file" 2>/dev/null || true
}

asusctl_try() {
	asusctl "$@" >/dev/null 2>&1 && return 0
	sudo -n asusctl "$@" >/dev/null 2>&1 && return 0
	return 1
}

apply_mode() {
	mode="$1"
	pre_brightness="$(get_kbd_brightness)"
	case "$mode" in
		Static)
			# Adaptive static: re-apply colour from wallpaper palette on wallpaper changes.
			set_state adaptive:static
			"$HOME/.config/hypr/scripts/sync-kbd-rgb.sh" >/dev/null 2>&1 || true
			;;
		Breathe)
			# Adaptive breathe: re-apply colours from wallpaper palette on wallpaper changes.
			set_state adaptive:breathe
			asusctl_try aura effect breathe --colour "$primary_hex" --colour2 "$secondary_hex" --speed med || true
			;;
		Pulse)
			# Adaptive pulse: re-apply colour from wallpaper palette on wallpaper changes.
			set_state adaptive:pulse
			asusctl_try aura effect pulse -c "$primary_hex" || true
			;;
		RainbowCycle)
			set_state manual
			asusctl_try aura effect rainbow-cycle --speed med || true
			;;
		RainbowWave)
			set_state manual
			asusctl_try aura effect rainbow-wave --direction right --speed med || true
			;;
	esac

	# Some Aura mode changes reset keyboard brightness; restore the previous level.
	set_kbd_brightness "$pre_brightness"
}

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"Breathe" \
		"Pulse" \
		"RainbowCycle" \
		"RainbowWave" \
		"Static" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	"$back_cmd"
	exit 0
fi

if [ "$rc" -ne 0 ] || [ -z "$chosen" ]; then
	exit 0
fi

if [ "$chosen" = "$back_label" ]; then
	"$back_cmd"
	exit 0
fi

apply_mode "$chosen"
exec "$0"
