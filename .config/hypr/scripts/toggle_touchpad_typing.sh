#!/bin/sh

config="$HOME/.config/hypr/lua/input.lua"

if grep -q 'disable_while_typing = true' "$config"; then
  sed -i 's/disable_while_typing = true/disable_while_typing = false/' "$config"
else
  sed -i 's/disable_while_typing = false/disable_while_typing = true/' "$config"
fi

hyprctl reload
