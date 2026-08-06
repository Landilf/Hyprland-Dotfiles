#! /bin/sh

"$HOME/.config/hypr/scripts/set_lua_preset.sh" rounding gentle
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/10px/rofiradius.rasi ~/.config/colors/rofiradius.rasi
ln -sf ~/.config/RofiScripts/Rounding/RoundingThemes/10px/swayncradius.css ~/.config/colors/swayncradius.css
swaync-client -R
swaync-client -rs
