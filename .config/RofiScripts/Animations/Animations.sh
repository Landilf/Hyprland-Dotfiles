#! /bin/sh

chosen=$(printf "Vertical Animations\nHorizontal Animations\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/Animations/A.rasi')

case "$chosen" in
   "Horizontal Animations") ~/.config/RofiScripts/Animations/Horizontal/horizontal.sh ;;
   "Vertical Animations") ~/.config/RofiScripts/Animations/Vertical/vertical.sh ;;
   *) exit 1 ;;
esac
