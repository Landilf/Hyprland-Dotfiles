#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

get_status() {
	# Keep it single-line for rofi rows.
	bash "$HOME/.config/hypr/scripts/power_refresh.sh" --status 2>/dev/null | tr -d '\n'
}

status="$(get_status)"
[ -n "$status" ] || status="󰄴 ?Hz"

toggle_label="󰄵 Refresh rate: ${status}"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"$toggle_label" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	"$HOME/.config/RofiScripts/Launcher/Launcher.sh"
	exit 0
fi

case "$chosen" in
	"$toggle_label")
		bash "$HOME/.config/hypr/scripts/power_refresh.sh" --toggle
		exec "$0"
		;;
	*)
		exit 1
		;;
esac
