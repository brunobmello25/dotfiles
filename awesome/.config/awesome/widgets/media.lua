local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")

local media = {}

function media.new()
	-- Create icon widget
	local media_icon = wibox.widget({
		font = "sans bold 11",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Create text widget
	local media_text = wibox.widget({
		font = "sans 9",
		align = "center",
		valign = "center",
		widget = wibox.widget.textbox,
	})

	-- Create container with icon and text
	local media_layout = wibox.widget({
		media_icon,
		{
			media_text,
			left = 6,
			right = 6,
			widget = wibox.container.margin,
		},
		spacing = 0,
		layout = wibox.layout.fixed.horizontal,
	})

	-- Create background container with rounded corners
	local media_bg = wibox.widget({
		media_layout,
		bg = beautiful.bg_normal,
		shape = function(cr, width, height)
			gears.shape.rounded_rect(cr, width, height, 4)
		end,
		widget = wibox.container.background,
	})

	-- Outer margin container
	local media_widget = wibox.container.margin(media_bg, 6, 6, 4, 4)

	-- Tooltip for full track information
	local media_tooltip = awful.tooltip({
		objects = { media_widget },
		timer_function = function()
			return "Click to play/pause\nScroll to change tracks\nRight-click to stop"
		end,
		delay_show = 0.5,
	})

	-- Store current track info for tooltip
	local current_info = {
		title = "",
		artist = "",
		album = "",
		player = "",
		status = "",
	}

	local function update_media()
		-- Check if any player is running
		awful.spawn.easy_async("playerctl status 2>&1", function(status_stdout)
			local status = status_stdout:match("^%s*(.-)%s*$") -- trim whitespace

			if status == "No players found" or status == "" then
				media_icon:set_markup('<span foreground="#666666">♫</span>')
				media_text:set_markup('<span foreground="#666666">No media</span>')
				media_bg.bg = beautiful.bg_normal
				media_tooltip:set_text("No media playing")
				return
			end

			-- Get detailed metadata
			awful.spawn.easy_async(
				"playerctl metadata --format '{{playerName}}|{{status}}|{{title}}|{{artist}}|{{album}}' 2>&1",
				function(metadata_stdout)
					if metadata_stdout:match("No player") then
						media_icon:set_markup('<span foreground="#666666">♫</span>')
						media_text:set_markup('<span foreground="#666666">No media</span>')
						media_bg.bg = beautiful.bg_normal
						media_tooltip:set_text("No media playing")
						return
					end

					local player, status, title, artist, album =
						metadata_stdout:match("([^|]*)|([^|]*)|([^|]*)|([^|]*)|([^|]*)")

					if not player or not status then
						media_icon:set_markup('<span foreground="#666666">♫</span>')
						media_text:set_markup('<span foreground="#666666">No media</span>')
						media_bg.bg = beautiful.bg_normal
						return
					end

					-- Store for tooltip
					current_info.player = player
					current_info.status = status
					current_info.title = title or "Unknown"
					current_info.artist = artist or "Unknown Artist"
					current_info.album = album or ""

					-- Determine icon and color based on status
					local icon, icon_color, bg_color
					if status == "Playing" then
						icon = "▶"
						icon_color = "#81c784" -- Green
						bg_color = "#2d3a2d"
					elseif status == "Paused" then
						icon = "⏸"
						icon_color = "#ffd54f" -- Yellow
						bg_color = "#3a372d"
					else
						icon = "⏹"
						icon_color = "#e57373" -- Red
						bg_color = "#3a2d2d"
					end

					-- Format icon with color
					media_icon:set_markup(string.format('<span foreground="%s" font="sans bold 12">%s</span>', icon_color, icon))

					-- Create display text with artist if available
					local display_text = current_info.title
					if current_info.artist and current_info.artist ~= "" and current_info.artist ~= "Unknown Artist" then
						display_text = string.format("%s - %s", current_info.artist, current_info.title)
					end

					-- Truncate if too long
					if #display_text > 35 then
						display_text = display_text:sub(1, 32) .. "..."
					end

					-- Set text with appropriate color
					local text_color = beautiful.fg_normal or "#aaaaaa"
					media_text:set_markup(string.format('<span foreground="%s">%s</span>', text_color, display_text))

					-- Update background color
					media_bg.bg = bg_color

					-- Update tooltip
					local tooltip_text = string.format(
						"%s: %s\n\n🎵 %s\n🎤 %s%s\n\n%s",
						player,
						status,
						current_info.title,
						current_info.artist,
						(current_info.album ~= "" and "\n💿 " .. current_info.album or ""),
						"Click: Play/Pause | Scroll: Change Track | Right-click: Stop"
					)
					media_tooltip:set_text(tooltip_text)
				end
			)
		end)
	end

	-- Add hover effect
	media_bg:connect_signal("mouse::enter", function()
		local current_bg = media_bg.bg
		-- Lighten the background slightly on hover
		if current_bg == beautiful.bg_normal then
			media_bg.bg = "#2a2a2a"
		elseif current_bg == "#2d3a2d" then
			media_bg.bg = "#3a4a3a"
		elseif current_bg == "#3a372d" then
			media_bg.bg = "#4a473d"
		elseif current_bg == "#3a2d2d" then
			media_bg.bg = "#4a3d3d"
		end
	end)

	media_bg:connect_signal("mouse::leave", function()
		-- Restore based on current status
		if current_info.status == "Playing" then
			media_bg.bg = "#2d3a2d"
		elseif current_info.status == "Paused" then
			media_bg.bg = "#3a372d"
		elseif current_info.status == "Stopped" then
			media_bg.bg = "#3a2d2d"
		else
			media_bg.bg = beautiful.bg_normal
		end
	end)

	-- Listen for media change signals
	awesome.connect_signal("media::update", update_media)

	-- Add click handlers for media control
	media_widget:buttons(gears.table.join(
		awful.button({}, 1, function() -- Left click: play/pause
			awful.spawn("playerctl play-pause")
			gears.timer.start_new(0.3, function()
				awesome.emit_signal("media::update")
				return false
			end)
		end),
		awful.button({}, 3, function() -- Right click: stop
			awful.spawn("playerctl stop")
			gears.timer.start_new(0.3, function()
				awesome.emit_signal("media::update")
				return false
			end)
		end),
		awful.button({}, 4, function() -- Scroll up: previous track
			awful.spawn("playerctl previous")
			gears.timer.start_new(0.5, function()
				awesome.emit_signal("media::update")
				return false
			end)
		end),
		awful.button({}, 5, function() -- Scroll down: next track
			awful.spawn("playerctl next")
			gears.timer.start_new(0.5, function()
				awesome.emit_signal("media::update")
				return false
			end)
		end)
	))

	-- Update media info every 3 seconds
	gears.timer({
		timeout = 3,
		autostart = true,
		callback = update_media,
	})

	-- Initial update
	update_media()

	return media_widget
end

return media
