#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

chosen=$(
	printf "%s\n" \
		" Apps Launcher" \
		"󰃬 Calculator" \
		"󰅌 Clipboard" \
		" Recording" \
		" Settings" \
		" System" \
			| rofi -dmenu -i -selected-row 5 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ]; then
	exit 0
fi

case "$chosen" in
   " Apps Launcher") rofi -show drun -ml-row-left ScrollUp -ml-row-right ScrollDown -ml-row-up ScrollLeft -ml-row-down ScrollRight ;;
   "󰃬 Calculator") ~/.config/RofiScripts/RofiCalc/Calc.sh ;;
   "󰅌 Clipboard") ~/.config/RofiScripts/Clipboard/Clipboard.sh ;;
   " Recording") ~/.config/RofiScripts/Recording/Recording.sh ;;
   " Settings") ~/.config/RofiScripts/Settings/Settings.sh ;;
   " System") ~/.config/RofiScripts/SystemSettings/system.sh ;;
   *) exit 1 ;;
esac
