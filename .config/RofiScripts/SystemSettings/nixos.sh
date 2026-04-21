#! /bin/sh

: "${LC_ALL:=C.UTF-8}"
: "${LANG:=C.UTF-8}"
export LC_ALL LANG

back_label="← Back"

	chosen=$(
		printf "%s\n" \
			"$back_label" \
			" Configuration" \
			" Flake" \
			"󰋜 Home Manager" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/SystemSettings/system.sh
	exit 0
fi

case "$chosen" in
   " Configuration") codium ~/Hyprland-Dotfiles/NixOS/configuration.nix ;;
   " Flake") codium ~/Hyprland-Dotfiles/NixOS/flake.nix ;;
   "󰋜 Home Manager") codium ~/Hyprland-Dotfiles/NixOS/home.nix ;;
   *) exit 1 ;;
esac
