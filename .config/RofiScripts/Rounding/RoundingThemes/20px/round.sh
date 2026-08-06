#! /bin/sh

"$HOME/.config/hypr/scripts/set_lua_preset.sh" rounding round
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/20px/rofiradius.rasi ~/.config/colors/rofiradius.rasi
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/20px/swayncradius.css ~/.config/colors/swayncradius.css
swaync-client -R
swaync-client -rs
