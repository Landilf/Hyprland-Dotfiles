#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
back_cmd="${ROFI_BACK_CMD:-$HOME/.config/RofiScripts/Launcher/Launcher.sh}"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			" Random Wallpapers" \
			"󰌧 Select Wallpaper" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/WallpaperChanger/WM.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
	)
	rc=$?

	if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
		"$back_cmd"
		exit 0
	fi

case "$chosen" in
   " Random Wallpapers") ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh ;;
   "󰌧 Select Wallpaper") ~/.config/RofiScripts/WallpaperChanger/wall.sh ;;
   *) exit 1 ;;
esac
