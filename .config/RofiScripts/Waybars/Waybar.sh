#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
back_cmd="${ROFI_BACK_CMD:-$HOME/.config/RofiScripts/Launcher/Launcher.sh}"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			"Beam" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Waybars/WB.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
	)
	rc=$?

	if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
		"$back_cmd"
		exit 0
	fi

case "$chosen" in
   "Beam") ~/.config/RofiScripts/Waybars/WaybarThemes/bar/bar.sh & ~/.config/RofiScripts/Waybars/WaybarThemes/bar/launch.sh ;;
   *) exit 1 ;;
esac
