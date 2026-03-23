#! /bin/sh

chosen=$(printf "Dark Mode\nLight Mode\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/Animations/A.rasi')

case "$chosen" in
   "Dark Mode") ~/.config/RofiScripts/Dark-Light-Mode/Dunkel/dunkel.sh && ~/.config/nwg-dock-hyprland/launch.sh ;;
   "Light Mode") ~/.config/RofiScripts/Dark-Light-Mode/Hell/hell.sh && ~/.config/nwg-dock-hyprland/launch.sh ;;
   *) exit 1 ;;
esac
