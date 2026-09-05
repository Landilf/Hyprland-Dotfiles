#!/bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"
input_config="$HOME/.config/hypr/lua/input.lua"

if grep -q 'disable_while_typing = true' "$input_config"; then
  touchpad_typing_label="󰍽 Touchpad while typing: Off"
else
  touchpad_typing_label="󰍽 Touchpad while typing: On"
fi

chosen=$(printf "%s\n" "$back_label" "󰌌 Keyboard" "$touchpad_typing_label" |
  rofi -dmenu -i -selected-row 1 \
    -config "$HOME/.config/RofiScripts/Launcher/L.rasi" \
    -kb-move-char-back "" -kb-move-char-forward "" \
    -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right")
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
  ~/.config/RofiScripts/Settings/Settings.sh
  exit 0
fi

case "$chosen" in
  "󰌌 Keyboard")
    ROFI_BACK_CMD="$HOME/.config/RofiScripts/Settings/input.sh" \
      ~/.config/RofiScripts/Keyboard/Keyboard.sh
    ;;
  "$touchpad_typing_label")
    ~/.config/hypr/scripts/toggle_touchpad_typing.sh
    exec ~/.config/RofiScripts/Settings/input.sh
    ;;
  *) exit 1 ;;
esac
