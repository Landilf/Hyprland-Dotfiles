#! /bin/sh

chosen=$(printf "Square\nGentle Round\nRound\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/Rounding/R.rasi')

case "$chosen" in
   "Square") ~/.config/RofiScripts/Rounding/RoundingThemes/0px/pointy.sh ;;
   "Gentle Round") ~/.config/RofiScripts/Rounding/RoundingThemes/10px/softround.sh ;;
   "Round") ~/.config/RofiScripts/Rounding/RoundingThemes/20px/round.sh ;;
   *) exit 1 ;;
esac
