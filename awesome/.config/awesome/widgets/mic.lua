local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local function factory(args)
	args = args or {}

	-- user‐overrideable parameters
	local widget = args.widget or wibox.widget.imagebox()
	local timeout = args.timeout or 10
	local icon_unmute = args.icon_unmute or "/usr/share/icons/Adwaita/32x32/status/audio-input-microphone.png"
	local icon_mute = args.icon_mute or "/usr/share/icons/Adwaita/32x32/status/audio-input-microphone-muted.png"
	local on_state_cb = args.settings -- optional callback(state, mic) after every update

	-- internal state
	local mic = {
		widget = widget,
		timeout = timeout,
		state = nil, -- "muted" or "unmuted"
		timer = gears.timer, -- placeholder, will be set below
	}

	----------------------------------------------------------------
	-- control methods
	----------------------------------------------------------------
	function mic:mute()
		awful.spawn.easy_async("pactl set-source-mute @DEFAULT_SOURCE@ 1", function()
			self:update()
		end)
	end

	function mic:unmute()
		awful.spawn.easy_async("pactl set-source-mute @DEFAULT_SOURCE@ 0", function()
			self:update()
		end)
	end

	function mic:toggle()
		awful.spawn.easy_async("pactl set-source-mute @DEFAULT_SOURCE@ toggle", function()
			self:update()
		end)
	end

	function mic:update()
		-- force an immediate re‐read of the status
		if self.timer and self.timer.started then
			self.timer:emit_signal("timeout")
		end
	end

	----------------------------------------------------------------
	-- watch the actual mute‐state
	----------------------------------------------------------------
	local watch_cmd = { "bash", "-c", "pactl get-source-mute @DEFAULT_SOURCE@" }

	-- awful.widget.watch returns: (base_widget, timer)
	mic, mic.timer = awful.widget.watch(
		watch_cmd,
		mic.timeout,
		function(self, stdout)
			-- stdout = "Mute: yes\n" or "Mute: no\n"
			local muted = stdout:match("yes")
			local new_state = muted and "muted" or "unmuted"

			if new_state ~= self.state then
				self.state = new_state

				-- update icon
				self.widget:set_image(muted and icon_mute or icon_unmute)

				-- optional notification on change
			end

			-- user‐supplied hook
			if on_state_cb then
				on_state_cb(self.state, self)
			end
		end,
		mic -- pass our mic table as the base_widget
	)

	----------------------------------------------------------------
	-- click handling
	----------------------------------------------------------------
	mic.widget:connect_signal("button::press", function(_, _, _, button)
		if button == 1 then
			mic:toggle()
		elseif button == 3 then
			-- right‐click: force on/off
			if mic.state == "muted" then
				mic:unmute()
			else
				mic:mute()
			end
		end
	end)

	return mic
end

return factory
