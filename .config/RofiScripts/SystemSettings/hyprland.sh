#! /bin/sh

chosen=$(printf "󱓞 Autostart\n󰪫 Environment\n󰍽 Input\n󰌌 Keybindings\n Look and Feel\n󰍹 Monitors\n Permissions\n Programs\n Plugins\n Windows and Workspaces\n󰥛 Animations (Variables!)\n󰘇 Decoration (Variables!)\n" | rofi -dmenu -i -m DP-3 -config '~/.config/RofiScripts/SystemSettings/S.rasi')

case "$chosen" in
   "󱓞 Autostart") codium ~/.config/hypr/hyprconfigs/hyprautostart.conf ;;
   "󰪫 Environment") codium ~/.config/hypr/hyprconfigs/hyprenvironment.conf ;;
   "󰍽 Input") codium ~/.config/hypr/hyprconfigs/hyprinput.conf ;;
   "󰌌 Keybindings") codium ~/.config/hypr/hyprconfigs/hyprkeybinds.conf ;;
   " Look and Feel") codium ~/.config/hypr/hyprconfigs/hyprlookandfeel.conf ;;
   "󰍹 Monitors") codium ~/.config/hypr/hyprconfigs/hyprmonitors.conf ;;
   " Permissions") codium ~/.config/hypr/hyprconfigs/hyprpermissions.conf ;;
   " Programs") codium ~/.config/hypr/hyprconfigs/hyprprograms.conf ;;
   " Plugins") codium ~/.config/hypr/hyprconfigs/hyprplugins.conf ;;
   " Windows and Workspaces") codium ~/.config/hypr/hyprconfigs/hyprwindowsandworkspaces.conf ;;
   "󰥛 Animations (Variables!)") codium ~/.config/hypr/hyprconfigs/hypranimations.conf ;;
   "󰘇 Decoration (Variables!)") codium ~/.config/hypr/hyprconfigs/hyprdecoration.conf ;;
   *) exit 1 ;;
esac
