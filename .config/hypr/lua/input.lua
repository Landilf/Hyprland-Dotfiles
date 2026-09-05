hl.config({
  input = {
    kb_layout = "us,ru", kb_options = "grp:alt_shift_toggle", follow_mouse = 1,
    force_no_accel = true, sensitivity = 0,
    touchpad = { natural_scroll = true, disable_while_typing = true },
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.device({ name = "dualsense-wireless-controller-touchpad", enabled = false })
hl.device({ name = "sony-interactive-entertainment-dualsense-wireless-controller-touchpad", enabled = false })
hl.device({ name = "opentabletdriver-virtual-artist-tablet", output = "eDP-1" })
hl.device({ name = "wacom-one-by-wacom-s-pen", output = "eDP-1" })
