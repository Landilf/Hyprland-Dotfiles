local M = {
  monitor = "eDP-1",
  named = { overlay = "", steam = "Steam", windows = "Windows" },
  special = { magic = "magic" },
}

function M.selector(name)
  return "name:" .. M.named[name]
end

function M.focus(name)
  return hl.dsp.focus({ workspace = M.selector(name) })
end

function M.move_active_window(name)
  return hl.dsp.window.move({ workspace = M.selector(name) })
end

function M.special_selector(name)
  return "special:" .. M.special[name]
end

function M.relative_selector(delta)
  return "r" .. (delta > 0 and "+" or "") .. tostring(delta)
end

function M.open_relative_selector(delta)
  return "e" .. (delta > 0 and "+" or "") .. tostring(delta)
end

function M.focus_relative_on_active_monitor(delta)
  return hl.dsp.focus({ workspace = M.relative_selector(delta) })
end

function M.focus_open_relative(delta)
  return hl.dsp.focus({ workspace = M.open_relative_selector(delta) })
end

function M.move_active_window_open_relative(delta)
  return hl.dsp.window.move({ workspace = M.open_relative_selector(delta) })
end

function M.move_active_window_relative_on_active_monitor(delta)
  return hl.dsp.window.move({ workspace = M.relative_selector(delta) })
end

function M.configure()
  -- Keep only the initial workspace on the laptop panel. Other numeric
  -- workspaces are created on whichever monitor is active.
  hl.workspace_rule({ workspace = "1", monitor = M.monitor, persistent = true, default = true })
  hl.workspace_rule({ workspace = "11", persistent = true })

  hl.workspace_rule({ workspace = M.selector("overlay"), monitor = M.monitor, no_rounding = true, decorate = false, no_shadow = true })
  hl.workspace_rule({ workspace = M.selector("steam"), monitor = M.monitor })
  hl.workspace_rule({ workspace = M.selector("windows"), monitor = M.monitor })
end

return M
