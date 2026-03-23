#! /bin/sh

chosen=$(printf "Beam\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/Waybars/WB.rasi')

case "$chosen" in
   "Beam") ~/.config/RofiScripts/Waybars/WaybarThemes/bar/bar.sh & ~/.config/RofiScripts/Waybars/WaybarThemes/bar/launch.sh ;;
   *) exit 1 ;;
esac
