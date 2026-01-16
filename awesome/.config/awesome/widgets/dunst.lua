-- ~/.config/awesome/widgets/dunst.lua

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local M = {}

-- constructor
function M.new()
	-- state
	local notifications_enabled = true

	-- the little icon widget
	local icon = wibox.widget({
		widget = wibox.widget.textbox,
		-- initial placeholder, we'll sync below
		text = "…",
		font = "Monospace 16",
	})

	-- wrap it in a margin/bg so it isn't too cramped or jumps around
	local container = wibox.widget({
		{
			icon,
			margins = 4,
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
	})

	-- helper to update the icon (without sending notification to avoid recursion)
	local function update_ui(silent)
		if notifications_enabled then
			icon:set_text("🔔")
			if not silent then
				awful.spawn.with_shell('notify-send -t 1000 "Notifications enabled"')
			end
		else
			icon:set_text("🔕")
			-- Don't notify when disabling notifications (would be weird)
		end
	end

	-- toggle notifications on/off
	function container:toggle()
		if notifications_enabled then
			awful.spawn.with_shell("dunstctl set-paused true")
		else
			awful.spawn.with_shell("dunstctl set-paused false")
		end
		notifications_enabled = not notifications_enabled
		update_ui()
	end

	-- click handler
	container:buttons(gears.table.join(awful.button({}, 1, function()
		container:toggle()
	end)))

	-- at startup, sync our state with dunst's actual state
	awful.spawn.easy_async_with_shell("dunstctl is-paused", function(stdout)
		-- stdout will be "true" or "false"
		notifications_enabled = (stdout:match("false") ~= nil)
		update_ui(true) -- silent on startup
	end)

	return container
end

return setmetatable({}, {
	__call = function(_, ...)
		return M.new(...)
	end,
})
