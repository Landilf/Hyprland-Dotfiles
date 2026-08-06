local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
local preset_file = state_home .. "/hyprland/animation_preset"
local preset = "horizontal"
local file = io.open(preset_file, "r")

if file then
  preset = file:read("*l") or preset
  file:close()
end

local workspace_style = preset == "vertical" and "slidevert" or "slide"

hl.config({ animations = { enabled = true } })
hl.curve("smoothFast", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("smoothSlow", { type = "bezier", points = { { 0, 0 }, { 0.2, 1 } } })
hl.curve("easeInSleek", { type = "bezier", points = { { 0.55, 0 }, { 0.1, 1 } } })
hl.curve("easeOutSleek", { type = "bezier", points = { { 0.1, 0 }, { 0.45, 1 } } })
hl.curve("linearSlick", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("softGlide", { type = "bezier", points = { { 0.3, 0 }, { 0.3, 1 } } })
hl.curve("gentleCurve", { type = "bezier", points = { { 0.25, 0.1 }, { 0.35, 0.95 } } })
for _, animation in ipairs({
  { "global", 10, "smoothSlow" }, { "border", 5.39, "smoothFast" },
  { "windows", 2.2, "softGlide", "slide" }, { "windowsIn", 2.2, "softGlide", "popin" },
  { "windowsOut", 2.2, "easeOutSleek", "popin" }, { "fadeIn", 1.73, "easeInSleek" },
  { "fadeOut", 1.46, "easeOutSleek" }, { "fade", 3.03, "gentleCurve" },
  { "layers", 2.1, "softGlide", "slide" }, { "layersIn", 2.5, "softGlide", "popin" },
  { "layersOut", 2.5, "easeOutSleek", "popin" }, { "fadeLayersIn", 1.79, "easeInSleek" },
  { "fadeLayersOut", 1.39, "easeOutSleek" }, { "workspaces", 2, "softGlide", workspace_style },
  { "workspacesIn", 2, "softGlide", workspace_style }, { "workspacesOut", 2, "easeOutSleek", workspace_style },
  { "zoomFactor", 7, "gentleCurve" },
}) do
  hl.animation({ leaf = animation[1], enabled = true, speed = animation[2], bezier = animation[3], style = animation[4] })
end
