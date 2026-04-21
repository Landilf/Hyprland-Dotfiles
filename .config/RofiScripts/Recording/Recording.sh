#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

# You can override these in the environment if your scene names differ.
obsctl="$HOME/.config/hypr/scripts/obs_recording.sh"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"Open Recordings Folder" \
		"Record Monitor" \
		"Stop Recording" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/Launcher/L.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	"$HOME/.config/RofiScripts/Launcher/Launcher.sh"
	exit 0
fi

case "$chosen" in
	"Open Recordings Folder") bash "$obsctl" --open-dir ;;
	"Record Monitor") bash "$obsctl" --start-monitor ;;
	"Stop Recording") bash "$obsctl" --stop ;;
	*) exit 1 ;;
esac
