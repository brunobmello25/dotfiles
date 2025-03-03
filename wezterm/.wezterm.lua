local wezterm = require("wezterm")

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

config.enable_tab_bar = false

config.font_size = 12.0

config.keys = {
	{
		key = "LeftArrow",
		mods = "SHIFT|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "RightArrow",
		mods = "SHIFT|CTRL",
		action = wezterm.action.DisableDefaultAssignment,
	},

	{
		key = "LeftArrow",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "RightArrow",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

return config
