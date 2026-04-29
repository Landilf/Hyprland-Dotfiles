#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
back_cmd="${ROFI_BACK_CMD:-$HOME/.config/RofiScripts/Launcher/Launcher.sh}"

get_status() {
	# Keep it single-line for rofi rows.
	bash "$HOME/.config/hypr/scripts/power_refresh.sh" --status 2>/dev/null | tr -d '\n'
}

raw_status="$(get_status)"

# power_refresh.sh prints like: "󰄵 144Hz" or "󰄴 60Hz"
# We want the checkbox only once (on the menu item), not inside the value.
icon="$(printf "%s" "$raw_status" | awk '{print $1}')"
status="$(printf "%s" "$raw_status" | cut -d' ' -f2-)"

[ -n "$status" ] || status="?Hz"
case "$icon" in
	"󰄴"|"󰄵") : ;;
	*) icon="󰄴" ;;
esac

toggle_label="${icon} Refresh rate: ${status}"

get_res() {
	bash "$HOME/.config/hypr/scripts/screen_resolution.sh" --status 2>/dev/null | tr -d '\n'
}

res="$(get_res)"
[ -n "$res" ] || res="?"
res_label="󰍹 Resolution: ${res}"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"$toggle_label" \
		"$res_label" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	"$back_cmd"
	exit 0
fi

	case "$chosen" in
		"$toggle_label")
			bash "$HOME/.config/hypr/scripts/power_refresh.sh" --toggle
			exec "$0"
			;;
		"$res_label")
			bash "$HOME/.config/hypr/scripts/screen_resolution.sh" --toggle
			exec "$0"
			;;
		*)
			exit 1
			;;
	esac
