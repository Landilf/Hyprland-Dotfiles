#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

chosen=$(
	printf "%s\n" \
		" Apps Launcher" \
		" System" \
		"󰅌 Clipboard" \
		"󰃬 Calculator" \
		" Waybar" \
			" Color Scheme" \
			"󰘇 Decorations" \
			"󰥛 Animations" \
			" Wallpapers" |
			rofi -dmenu -i -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Control+j,Control+m,Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	exit 0
fi

case "$chosen" in
   " Apps Launcher") rofi -show drun -ml-row-left ScrollUp -ml-row-right ScrollDown -ml-row-up ScrollLeft -ml-row-down ScrollRight ;;
   " System") ~/.config/RofiScripts/SystemSettings/system.sh ;;
   "󰅌 Clipboard") ~/.config/RofiScripts/Clipboard/Clipboard.sh ;;
   "󰃬 Calculator") ~/.config/RofiScripts/RofiCalc/Calc.sh ;;
   " Waybar") ~/.config/RofiScripts/Waybars/Waybar.sh ;;
   " Color Scheme") ~/.config/RofiScripts/Dark-Light-Mode/DLmode.sh ;;
   "󰘇 Decorations") ~/.config/RofiScripts/Rounding/Rounding.sh ;;
   "󰥛 Animations") ~/.config/RofiScripts/Animations/Animations.sh ;;
   " Wallpapers") ~/.config/RofiScripts/WallpaperChanger/WallMenu.sh ;;
   *) exit 1 ;;
esac
