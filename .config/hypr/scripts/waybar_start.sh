#!/usr/bin/env bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Ensure we don't keep a stale Waybar from a previous session.
pkill -x waybar 2>/dev/null || true
pkill -x .waybar-wrapped 2>/dev/null || true

for _ in $(seq 1 10); do
  pgrep -x waybar >/dev/null 2>&1 || pgrep -x .waybar-wrapped >/dev/null 2>&1 || break
  sleep 0.1
done

# Best-effort: wait until Hyprland's IPC socket exists (helps Hyprland modules/scripts start instantly).
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  socket="$runtime_dir/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
  for _ in $(seq 1 10); do
    [[ -S "$socket" ]] && break
    sleep 0.1
  done
fi

# Avoid Waybar blocking ~25s waiting for the desktop appearance portal.
systemctl --user start xdg-desktop-portal.service xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service 2>/dev/null || true
for _ in $(seq 1 20); do
systemctl --user is-active --quiet xdg-desktop-portal.service && break
  sleep 0.1
done

waybar -l off >/dev/null 2>&1 &
disown || true
