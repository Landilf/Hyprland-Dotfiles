#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			"Gentle Round" \
			"Round" \
			"Square" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Rounding/R.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/Launcher/Launcher.sh
	exit 0
fi

case "$chosen" in
   "Gentle Round") ~/.config/RofiScripts/Rounding/RoundingThemes/10px/softround.sh ;;
   "Round") ~/.config/RofiScripts/Rounding/RoundingThemes/20px/round.sh ;;
   "Square") ~/.config/RofiScripts/Rounding/RoundingThemes/0px/pointy.sh ;;
   *) exit 1 ;;
esac
