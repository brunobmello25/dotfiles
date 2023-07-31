local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.colors = {
  cursor_bg = '#ccc',
}

return config
