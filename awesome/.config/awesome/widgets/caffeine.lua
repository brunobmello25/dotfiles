-- ~/.config/awesome/widgets/caffeine.lua

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local M = {}

-- constructor
function M.new()
	-- state
	local dpms_enabled = true

	-- the little icon widget
	local icon = wibox.widget({
		widget = wibox.widget.textbox,
		-- initial placeholder, we'll sync below
		text = "…",
		font = "Monospace 16",
	})

	-- wrap it in a margin/bg so it isn’t too cramped or jumps around
	local container = wibox.widget({
		{
			icon,
			margins = 4,
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
	})

	-- helper to update the icon and send a notification
	local function update_ui()
		if dpms_enabled then
			icon:set_text("🌙")
			awful.spawn.with_shell('notify-send -t 1000 "DPMS/Screensaver enabled"')
		else
			icon:set_text("☕")
			awful.spawn.with_shell('notify-send -t 1000 "DPMS/Screensaver disabled"')
		end
	end

	-- toggle DPMS on/off
	function container:toggle()
		if dpms_enabled then
			awful.spawn.with_shell("xset s off -dpms")
		else
			awful.spawn.with_shell("xset s on +dpms")
		end
		dpms_enabled = not dpms_enabled
		update_ui()
	end

	-- click handler
	container:buttons(gears.table.join(awful.button({}, 1, function()
		container:toggle()
	end)))

	-- at startup, sync our dpms_enabled state with the real xset state
	awful.spawn.easy_async_with_shell("xset q | grep 'DPMS is'", function(stdout)
		dpms_enabled = (stdout:match("Enabled") ~= nil)
		update_ui()
	end)

	return container
end

return setmetatable({}, {
	__call = function(_, ...)
		return M.new(...)
	end,
})
