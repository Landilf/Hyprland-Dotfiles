local colors = { primary = 0xffaac9f2, background = 0xff121316 }
local generated_colors = loadfile(os.getenv("HOME") .. "/.config/colors/hyprcolors.lua")
if generated_colors then colors = generated_colors() end

local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local preset_file = state_home .. "/hyprland/rounding_preset"
local rounding_presets = { square = 0, gentle = 10, round = 20 }
local rounding = rounding_presets.round
local file = io.open(preset_file, "r")

if file then
  rounding = rounding_presets[file:read("*l")] or rounding
  file:close()
end

hl.config({
  general = {
    gaps_in = 10, gaps_out = 15, border_size = 2,
    col = { active_border = colors.primary, inactive_border = colors.background },
    resize_on_border = false, allow_tearing = true, layout = "dwindle",
  },
  decoration = {
    rounding = rounding, rounding_power = 2, active_opacity = 1, inactive_opacity = 1,
    shadow = { enabled = true, range = 10, render_power = 2, color = 0x00000099, color_inactive = 0x00000077, offset = { 0, 0 } },
    blur = { enabled = true, size = 5, passes = 4, noise = 0.1, popups = true, popups_ignorealpha = 0.45, contrast = 1.5, xray = false, new_optimizations = true, vibrancy = 1 },
  },
  dwindle = { preserve_split = true }, master = { new_status = "master", mfact = 0.55 },
  misc = { force_default_wallpaper = -1, disable_hyprland_logo = true },
})
