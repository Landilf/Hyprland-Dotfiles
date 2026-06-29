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
			"󰃠 Brightness" \
			"󰥔 Idle Timers" \
			"󰕾 Sound" |
			rofi -dmenu -i -selected-row 1 -config "$HOME/.config/RofiScripts/SystemSettings/S.rasi" -kb-move-char-back "" -kb-move-char-forward "" -kb-custom-1 "Left" -kb-accept-entry "Return,KP_Enter,Right"
	)
	rc=$?

if [ "$rc" -eq 10 ] || [ "$chosen" = "$back_label" ]; then
	~/.config/RofiScripts/SystemSettings/hyprland.sh
	exit 0
fi

case "$chosen" in
	"󰃠 Brightness") open_codium ~/.config/hypr/scripts/brightness_control.sh ;;
	"󰥔 Idle Timers") open_codium ~/.config/hypr/hypridle.conf ;;
	"󰕾 Sound") open_codium ~/.config/hypr/scripts/volume_control.sh ;;
	*) exit 1 ;;
esac
