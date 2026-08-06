#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

open_codium() {
	target="$1"
	repo_root="$(git -C "$(dirname "$target")" rev-parse --show-toplevel 2>/dev/null || true)"

	if [ -n "$repo_root" ]; then
		codium --reuse-window "$repo_root" "$target"
	else
		codium --reuse-window "$target"
	fi
}

back_label="← Back"

chosen=$(
	printf "%s\n" \
		"$back_label" \
		"󰥛 Animations" \
		"󱓞 Autostart" \
		"󰘇 Decoration" \
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
   "󰥛 Animations") open_codium ~/.config/hypr/lua/animations.lua ;;
   "󱓞 Autostart") open_codium ~/.config/hypr/lua/autostart.lua ;;
   "󰘇 Decoration") open_codium ~/.config/hypr/lua/look_and_feel.lua ;;
   "󰪫 Environment") open_codium ~/.config/uwsm/env-hyprland ;;
   "󰍽 Input") open_codium ~/.config/hypr/lua/input.lua ;;
   "󰌌 Keybindings") open_codium ~/.config/hypr/lua/keybinds.lua ;;
   " Look and Feel") open_codium ~/.config/hypr/lua/look_and_feel.lua ;;
   "󰍹 Monitors") open_codium ~/.config/hypr/lua/monitors.lua ;;
   " Permissions") open_codium ~/.config/hypr/lua/permissions.lua ;;
   " Plugins") open_codium ~/.config/hypr/lua/plugins.lua ;;
   " Programs") open_codium ~/.config/hypr/lua/programs.lua ;;
   "󰆍 Scripts") ~/.config/RofiScripts/SystemSettings/scripts.sh ;;
   " Windows and Workspaces") open_codium ~/.config/hypr/lua/windows_and_workspaces.lua ;;
   *) exit 1 ;;
esac
