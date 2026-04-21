#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"󰥛 Animations (Variables!)" \
		"󱓞 Autostart" \
		"󰘇 Decoration (Variables!)" \
		"󰪫 Environment" \
		"󰍽 Input" \
		"󰌌 Keybindings" \
		" Look and Feel" \
		"󰍹 Monitors" \
		" Permissions" \
		" Plugins" \
		" Programs" \
		"󰆍 Scripts" \
		" Windows and Workspaces" |
		rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S_hyprland.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
)
rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/SystemSettings/system.sh
	exit 0
fi

case "$chosen" in
   "󰥛 Animations (Variables!)") codium ~/.config/hypr/hyprconfigs/hypranimations.conf ;;
   "󱓞 Autostart") codium ~/.config/hypr/hyprconfigs/hyprautostart.conf ;;
   "󰘇 Decoration (Variables!)") codium ~/.config/hypr/hyprconfigs/hyprdecoration.conf ;;
   "󰪫 Environment") codium ~/.config/hypr/hyprconfigs/hyprenvironment.conf ;;
   "󰍽 Input") codium ~/.config/hypr/hyprconfigs/hyprinput.conf ;;
   "󰌌 Keybindings") codium ~/.config/hypr/hyprconfigs/hyprkeybinds.conf ;;
   " Look and Feel") codium ~/.config/hypr/hyprconfigs/hyprlookandfeel.conf ;;
   "󰍹 Monitors") codium ~/.config/hypr/hyprconfigs/hyprmonitors.conf ;;
   " Permissions") codium ~/.config/hypr/hyprconfigs/hyprpermissions.conf ;;
   " Plugins") codium ~/.config/hypr/hyprconfigs/hyprplugins.conf ;;
   " Programs") codium ~/.config/hypr/hyprconfigs/hyprprograms.conf ;;
   "󰆍 Scripts") ~/.config/RofiScripts/SystemSettings/scripts.sh ;;
   " Windows and Workspaces") codium ~/.config/hypr/hyprconfigs/hyprwindowsandworkspaces.conf ;;
   *) exit 1 ;;
esac
