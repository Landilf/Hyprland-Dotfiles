#! /bin/sh

chosen=$(printf " Apps Launcher\n System\n󰅌 Clipboard\n󰃬 Calculator\n Waybar\n Color Scheme\n󰘇 Decorations\n󰥛 Animations\n Wallpapers\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/Launcher/L.rasi')

case "$chosen" in
   " Apps Launcher") rofi -show drun -m DP-3 ;;
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
