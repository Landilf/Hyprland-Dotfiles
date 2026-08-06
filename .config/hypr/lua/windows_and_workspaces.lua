local workspaces = require("lua.workspaces")

workspaces.configure()
hl.window_rule({ name = "maximize-and-idle", match = { class = ".*" }, suppress_event = "maximize", idle_inhibit = "fullscreen" })
hl.window_rule({ name = "jetbrains-xwayland-popups", match = { class = "^(jetbrains-(studio|idea|pycharm))$", xwayland = true, title = "^(win[a-z]*[0-9]+)$" }, no_focus = true })
hl.window_rule({ name = "generic-empty-xwayland-popups", match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false }, no_focus = true })
for _, rule in ipairs({ { "kdeconnect-app", "org.kde.kdeconnect.app" }, { "kdeconnect-sms", "org.kde.kdeconnect.sms" }, { "kdeconnect-indicator", "org.kde.kdeconnect-indicator" } }) do
  hl.window_rule({ name = rule[1], match = { class = rule[2] }, float = true, center = true, size = { 1000, 700 } })
end
hl.window_rule({ name = "pavucontrol", match = { class = "org.pulseaudio.pavucontrol" }, float = true, center = true, size = { 879, 879 }, opacity = "0.80 0.75" })
hl.window_rule({ name = "blueman", match = { class = "blueman-manager" }, float = true, center = true, size = { 879, 879 } })
for _, class in ipairs({ "thunar", "Thunar", "org.gnome.Nautilus" }) do hl.window_rule({ name = "file-manager-opacity-" .. class, match = { class = class }, opacity = "0.80 0.75" }) end
hl.window_rule({ name = "text-editor-opacity", match = { class = "org.gnome.TextEditor" }, opacity = "0.90 0.85" })
hl.window_rule({ name = "vscodium-opacity", match = { class = "VSCodium" }, opacity = "0.90 0.85" })
hl.window_rule({ name = "steam-workspace", match = { class = "steam" }, workspace = workspaces.selector("steam") })
for _, class in ipairs({ "^(Microsoft Windows)$", "^(xfreerdp)$", "^(msword-rdp)$", "^(msexcel-rdp)$", "^(mspowerpoint-rdp)$" }) do
  hl.window_rule({ name = "windows-workspace-" .. class, match = { class = class }, workspace = workspaces.selector("windows") })
end
