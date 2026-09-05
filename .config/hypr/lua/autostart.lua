local commands = {
  "blueman-applet", "systemctl --user start hyprpolkitagent", "hypridle", "kdeconnectd", "kdeconnect-indicator",
  "/run/current-system/sw/bin/bash -lc '/etc/profiles/per-user/landilf/bin/awww-daemon & sleep 0.5; /etc/profiles/per-user/landilf/bin/awww restore'",
  "swaync", "/run/current-system/sw/bin/bash -lc '~/.config/hypr/scripts/waybar_start.sh'",
  "wl-paste --type text --watch cliphist store", "wl-paste --type image --watch cliphist store",
  "~/.config/nwg-dock-hyprland/launch.sh", "/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1",
  "~/.config/hypr/scripts/kbd_adaptive_apply.sh", "[workspace special:magic silent] Throne",
  "qs -p ~/.config/quickshell/overview -n",
}
hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.focus({ workspace = 1 }))
  for _, command in ipairs(commands) do hl.exec_cmd(command) end
end)
