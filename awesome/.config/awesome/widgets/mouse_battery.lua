local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local mouse_battery = {}

function mouse_battery.new()
	local text = wibox.widget({
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Include the separator inside the widget so it disappears together
	local container = wibox.widget({
		wibox.container.margin(text, 4, 4, 2, 2),
		wibox.widget.textbox(" │ "),
		layout = wibox.layout.fixed.horizontal,
		visible = false,
	})

	local script = os.getenv("HOME") .. "/dev/personal/fantech-driver/fantech_aria.py"

	local function update()
		awful.spawn.easy_async_with_shell(
			"python " .. script .. " battery 2>/dev/null",
			function(stdout, _, _, exit_code)
				local level = stdout:match("(%d+)")
				if exit_code == 0 and level then
					text:set_text("🖱️ " .. level .. "%")
					container.visible = true
				else
					container.visible = false
				end
			end
		)
	end

	gears.timer({
		timeout = 60,
		autostart = true,
		callback = update,
	})

	update()

	return container
end

return mouse_battery
