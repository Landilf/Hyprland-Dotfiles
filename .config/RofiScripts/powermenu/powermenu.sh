#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

	chosen=$(
		printf "%s\n" \
		"󰐥" \
		"󰜉" \
		"󰒲" \
		"󰌾" \
		"󰀄" |
		rofi -dmenu -i -selected-row 0 -config "$HOME/.config/RofiScripts/powermenu/P.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-row-left "Left" -kb-row-right "Right" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter"
	)
	rc=$?

if [ "$rc" -ne 0 ] || [ -z "$chosen" ]; then
	exit 0
fi

case "$chosen" in
   "󰐥") poweroff ;;
   "󰜉") reboot ;;
   "󰒲") systemctl hibernate ;;
   "󰌾") hyprlock ;;
   "󰀄") hyprctl dispatch exit ;;
   *) exit 1 ;;
esac
