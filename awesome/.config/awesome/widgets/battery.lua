local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local utils = require("utils")

local battery = {}

function battery.new()
	local battery_text = wibox.widget({
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	local battery_widget = wibox.container.margin(battery_text, 4, 4, 2, 2)

	local low_battery_notified = false

	local function update_battery()
		local bat = "/sys/class/power_supply/BAT0"
		local cap = utils.read_file(bat .. "/capacity") or "N/A"
		local status = utils.read_file(bat .. "/status") or "Unknown"

		local ico
		if status == "Charging" then
			ico = "🔌"
			low_battery_notified = false
		elseif tonumber(cap) and tonumber(cap) < 10 then
			ico = ""
		elseif tonumber(cap) and tonumber(cap) < 40 then
			ico = ""
		elseif tonumber(cap) and tonumber(cap) < 70 then
			ico = ""
		else
			ico = ""
		end

		local resulting_text = string.format("%s   %s%%", ico, cap)
		battery_text:set_text(resulting_text)
		local battery_threshold = 20

		if
			tonumber(cap)
			and tonumber(cap) <= battery_threshold
			and status ~= "Charging"
			and not low_battery_notified
		then
			naughty.notify({
				preset = naughty.config.presets.critical,
				title = "Low Battery",
				text = string.format("Battery is at %s%%!", cap),
			})
			low_battery_notified = true
		elseif tonumber(cap) and tonumber(cap) > battery_threshold then
			low_battery_notified = false
		end
	end

	gears.timer({
		timeout = 30,
		autostart = true,
		callback = update_battery,
	})

	update_battery()

	-- Only show battery widget for specific users
	local user = os.getenv("USER")
	if user == "bruno.mello" then
		return battery_widget
	else
		return nil
	end
end

return battery

