local programs = require("lua.programs")
local workspaces = require("lua.workspaces")
local main_mod = "SUPER"
local function exec(keys, command, options) hl.bind(keys, hl.dsp.exec_cmd(command), options) end

exec(main_mod .. " + Q", programs.terminal)
hl.bind(main_mod .. " + C", hl.dsp.window.close())
exec(main_mod .. " + SHIFT + C", "~/.config/hypr/scripts/active_window_signal.sh TERM")
exec(main_mod .. " + CTRL + C", "~/.config/hypr/scripts/active_window_signal.sh KILL")
exec(main_mod .. " + E", programs.file_manager)
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + V", hl.dsp.window.pin())
hl.bind(main_mod .. " + CTRL + V", hl.dsp.window.alter_zorder({ mode = "top" }))
exec(main_mod .. " + R", programs.menu); exec(main_mod .. " + Y", programs.sysmonitor)
exec(main_mod .. " + space", "pkill -x rofi || pkill -x .rofi-wrapped || ~/.config/RofiScripts/Launcher/Launcher.sh")
exec(main_mod .. " + F", programs.browser); exec(main_mod .. " + X", "~/.config/RofiScripts/Emojis/Emojis.sh")
exec(main_mod .. " + comma", "playerctl previous"); exec(main_mod .. " + period", "playerctl next"); exec(main_mod .. " + slash", "playerctl play-pause")
exec(main_mod .. " + SHIFT + G", "flameshot gui"); exec(main_mod .. " + SHIFT + T", "~/.config/hypr/scripts/ocr.sh")
exec(main_mod .. " + B", "pkill hyprsunset || hyprsunset -t 5300")
exec(main_mod .. " + TAB", "qs ipc -p ~/.config/quickshell/overview call overview toggle")
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen())
exec(main_mod .. " + T", "hyprlock"); exec("ALT + F4", "~/.config/RofiScripts/powermenu/powermenu.sh")
exec(main_mod .. " + SHIFT + X", "~/.config/RofiScripts/Clipboard/Clipboard.sh")
exec("CTRL + SUPER + space", "~/.config/RofiScripts/WallpaperChanger/wall.sh")
exec("CTRL + SUPER + Y", "~/.config/RofiScripts/WallpaperChanger/wallrandom.sh")
exec(main_mod .. " + SHIFT + Y", "~/.config/RofiScripts/Themes/Randomtheme.sh")

for key, direction in pairs({ up = "u", down = "d", left = "l", right = "r" }) do
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
end

-- Window-management mode keeps directional movement and resizing together.
local window_manage_state_file = "$XDG_RUNTIME_DIR/hypr-window-manage-mode"
local function update_window_manage_indicator(active)
  local command
  if active then
    command = "printf 'MOVE / RESIZE' > " .. window_manage_state_file
  else
    command = "rm -f " .. window_manage_state_file
  end
  hl.dispatch(hl.dsp.exec_cmd(command .. "; pkill -SIGRTMIN+11 waybar"))
end

local function set_window_manage_mode(enabled)
  if enabled then
    hl.dispatch(hl.dsp.submap("window-manage"))
    update_window_manage_indicator(true)
  else
    hl.dispatch(hl.dsp.submap("reset"))
    update_window_manage_indicator(false)
  end
end

hl.bind(main_mod .. " + Z", function() set_window_manage_mode(true) end)
hl.define_submap("window-manage", function()
  local repeating = { repeating = true }
  hl.bind(main_mod .. " + Z", function() set_window_manage_mode(false) end)
  for key, direction in pairs({ up = "u", down = "d", left = "l", right = "r" }) do
    hl.bind(key, hl.dsp.window.move({ direction = direction }), repeating)
  end
  for _, resize in ipairs({ { "up", 0, -100 }, { "down", 0, 100 }, { "left", -100, 0 }, { "right", 100, 0 } }) do
    hl.bind("SHIFT + " .. resize[1], hl.dsp.window.resize({ x = resize[2], y = resize[3], relative = true }), repeating)
  end
end)
for workspace = 1, 10 do
  local key = workspace % 10
  hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
  hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end
for _, navigation in ipairs({ { "A", -1 }, { "D", 1 } }) do
  local key, delta = navigation[1], navigation[2]
  hl.bind(main_mod .. " + " .. key, workspaces.focus_grid_relative(delta))
  hl.bind(main_mod .. " + CTRL + " .. key, workspaces.focus_open_relative(delta))
  hl.bind(main_mod .. " + SHIFT + " .. key, workspaces.move_active_window_grid_relative(delta))
  hl.bind(main_mod .. " + CTRL + SHIFT + " .. key, workspaces.move_active_window_open_relative(delta))
end
hl.bind(main_mod .. " + S", workspaces.focus_grid_relative(5))
hl.bind(main_mod .. " + SHIFT + S", workspaces.move_active_window_grid_relative(5))
hl.bind(main_mod .. " + O", workspaces.focus("steam"))
hl.bind(main_mod .. " + SHIFT + O", workspaces.move_active_window("steam"))
hl.bind(main_mod .. " + W", hl.dsp.workspace.toggle_special(workspaces.special.magic)); hl.bind(main_mod .. " + SHIFT + W", hl.dsp.window.move({ workspace = workspaces.special_selector("magic") }))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true }); hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local locked_repeating = { locked = true, repeating = true }
exec("XF86AudioRaiseVolume", "~/.config/hypr/scripts/volume_control.sh up", locked_repeating)
exec("XF86AudioLowerVolume", "~/.config/hypr/scripts/volume_control.sh down", locked_repeating)
exec("XF86AudioMute", "~/.config/hypr/scripts/volume_control.sh mute", locked_repeating)
exec("XF86AudioMicMute", "~/.config/hypr/scripts/volume_control.sh mic-mute", locked_repeating)
exec("XF86MonBrightnessUp", "~/.config/hypr/scripts/brightness_control.sh up", locked_repeating)
exec("XF86MonBrightnessDown", "~/.config/hypr/scripts/brightness_control.sh down", locked_repeating)
exec("XF86AudioNext", "playerctl next", { locked = true }); exec("XF86AudioPause", "playerctl play-pause", { locked = true })
exec("XF86AudioPlay", "playerctl play-pause", { locked = true }); exec("XF86AudioPrev", "playerctl previous", { locked = true })
