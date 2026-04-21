#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"󰥛 Animations" \
		" Color Scheme" \
		"󰘇 Decorations" \
		"󰓅 Performance" \
		" Wallpapers" \
		" Waybar" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	"$HOME/.config/RofiScripts/Launcher/Launcher.sh"
	exit 0
fi

case "$chosen" in
	"󰥛 Animations") ~/.config/RofiScripts/Animations/Animations.sh ;;
	" Color Scheme") ~/.config/RofiScripts/Dark-Light-Mode/DLmode.sh ;;
	"󰘇 Decorations") ~/.config/RofiScripts/Rounding/Rounding.sh ;;
	"󰓅 Performance") ~/.config/RofiScripts/Performance/Performance.sh ;;
	" Wallpapers") ~/.config/RofiScripts/WallpaperChanger/WallMenu.sh ;;
	" Waybar") ~/.config/RofiScripts/Waybars/Waybar.sh ;;
	*) exit 1 ;;
esac
