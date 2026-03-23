#! /bin/sh

chosen=$(printf "󰌧 Select Wallpaper\n Random Wallpapers\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/WallpaperChanger/WM.rasi')

case "$chosen" in
   "󰌧 Select Wallpaper") ~/.config/RofiScripts/WallpaperChanger/wall.sh ;;
   " Random Wallpaper") ~/.config/RofiScripts/WallpaperChanger/wallrandom.sh ;;
   *) exit 1 ;;
esac
