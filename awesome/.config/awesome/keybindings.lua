local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local utils = require("utils")

local keybindings = {}

local volume_step = "5%"

function keybindings.setup(terminal, modkey)
	local globalkeys = gears.table.join(
		awful.key({ modkey, "Shift" }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),

		awful.key({ modkey, "Control", "Shift" }, "o", function()
			local screen = awful.screen.focused()
			utils.debug_log("Focused screen: " .. screen.index)

			local screen_tags = screen.tags
			local screen_clients = {}
			for _, t in ipairs(screen_tags) do
				for _, c in ipairs(t:clients()) do
					table.insert(screen_clients, c)
				end
			end
			utils.debug_log(screen_clients)
		end, { description = "", group = "client" }),

		awful.key({ modkey }, "o", function()
			awful.screen.focus_relative(1)
		end, { description = "focus next non-empty screen with fallback", group = "screen" }),

		awful.key({ modkey }, "s", function()
			awful.spawn("flameshot gui")
		end, {}),

		awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
		awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
		awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

		awful.key({ modkey }, "j", function()
			awful.client.focus.byidx(1)
		end, { description = "focus next by index", group = "client" }),
		awful.key({ modkey }, "k", function()
			awful.client.focus.byidx(-1)
		end, { description = "focus previous by index", group = "client" }),

		awful.key({ modkey, "Shift" }, "j", function()
			awful.client.swap.byidx(1)
		end, { description = "swap with next client by index", group = "client" }),
		awful.key({ modkey, "Shift" }, "k", function()
			awful.client.swap.byidx(-1)
		end, { description = "swap with previous client by index", group = "client" }),
		awful.key({ modkey, "Control" }, "j", function()
			awful.screen.focus_relative(1)
		end, { description = "focus the next screen", group = "screen" }),
		awful.key({ modkey, "Control" }, "k", function()
			awful.screen.focus_relative(-1)
		end, { description = "focus the previous screen", group = "screen" }),
		awful.key(
			{ modkey },
			"u",
			awful.client.urgent.jumpto,
			{ description = "jump to urgent client", group = "client" }
		),

		awful.key({ modkey, "Shift" }, "Tab", function()
			local focused = awful.screen.focused()
			for _ = 1, #focused.tags do
				awful.tag.viewidx(-1, focused)
				if #focused.clients > 0 then
					return
				end
			end
		end, { description = "view previous tag", group = "tag" }),

		awful.key({ modkey }, "Tab", function()
			local focused = awful.screen.focused()
			for _ = 1, #focused.tags do
				awful.tag.viewidx(1, focused)
				if #focused.clients > 0 then
					return
				end
			end
		end, { description = "view next tag", group = "tag" }),

		awful.key({ modkey }, "Return", function()
			awful.spawn(terminal)
		end, { description = "open a terminal", group = "launcher" }),

		awful.key({ modkey }, "b", function()
			awful.spawn("google-chrome-stable")
		end, { description = "spawn browser", group = "launcher" }),

		awful.key({ modkey }, "space", function()
			awful.spawn("rofi -show drun")
		end, { description = "app launcher (rofi)", group = "launcher" }),

		awful.key({ modkey }, "v", function()
			awful.spawn("copyq show")
		end, { description = "clipboard history", group = "launcher" }),

		awful.key({ "Control", "Shift" }, "space", function()
			beautiful.mic:toggle()
		end, { description = "Toggle microphone (amixer)", group = "Audio" }),

		awful.key({}, "XF86AudioRaiseVolume", function()
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +" .. volume_step)
			awesome.emit_signal("volume::update")
			utils.debug_log("Volume raised by 5%")
		end, { description = "Raise volume", group = "Audio" }),

		awful.key({}, "XF86AudioLowerVolume", function()
			awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -" .. volume_step)
			awesome.emit_signal("volume::update")
			utils.debug_log("Volume lowered by 5%")
		end, { description = "Lower volume", group = "Audio" }),

		awful.key({}, "XF86AudioMute", function()
			awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
			awesome.emit_signal("volume::update")
		end, { description = "Mute/Unmute volume", group = "Audio" }),

		awful.key({}, "XF86AudioPlay", function()
			awful.spawn("playerctl play-pause")
			awesome.emit_signal("media::update")
		end, { description = "Play/Pause media", group = "Media" }),

		awful.key({}, "XF86AudioPause", function()
			awful.spawn("playerctl pause")
			awesome.emit_signal("media::update")
		end, { description = "Pause media", group = "Media" }),

		awful.key({}, "XF86AudioNext", function()
			awful.spawn("playerctl next")
			awesome.emit_signal("media::update")
		end, { description = "Next track", group = "Media" }),

		awful.key({}, "XF86AudioPrev", function()
			awful.spawn("playerctl previous")
			awesome.emit_signal("media::update")
		end, { description = "Previous track", group = "Media" }),

		awful.key({}, "XF86MonBrightnessUp", function()
			awful.spawn("brightnessctl set +10%")
		end, { description = "Increase brightness", group = "Screen" }),

		awful.key({}, "XF86MonBrightnessDown", function()
			awful.spawn("brightnessctl set 10%-")
		end, { description = "Decrease brightness", group = "Screen" }),

		awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
		awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

		awful.key({ modkey }, "l", function()
			awful.tag.incmwfact(0.05)
		end, { description = "increase master width factor", group = "layout" }),
		awful.key({ modkey }, "h", function()
			awful.tag.incmwfact(-0.05)
		end, { description = "decrease master width factor", group = "layout" }),
		awful.key({ modkey, "Shift" }, "h", function()
			awful.tag.incnmaster(1, nil, true)
		end, { description = "increase the number of master clients", group = "layout" }),
		awful.key({ modkey, "Shift" }, "l", function()
			awful.tag.incnmaster(-1, nil, true)
		end, { description = "decrease the number of master clients", group = "layout" }),
		awful.key({ modkey, "Control" }, "h", function()
			awful.tag.incncol(1, nil, true)
		end, { description = "increase the number of columns", group = "layout" }),
		awful.key({ modkey, "Control" }, "l", function()
			awful.tag.incncol(-1, nil, true)
		end, { description = "decrease the number of columns", group = "layout" }),

		awful.key({ modkey, "Shift" }, "space", function()
			awful.layout.inc(1)
		end, { description = "select next", group = "layout" }),

		awful.key({ modkey, "Control" }, "n", function()
			local c = awful.client.restore()
			if c then
				c:emit_signal("request::activate", "key.unminimize", { raise = true })
			end
		end, { description = "restore minimized", group = "client" }),

		awful.key({ modkey }, "r", function()
			awful.screen.focused().mypromptbox:run()
		end, { description = "run prompt", group = "launcher" }),

		awful.key({ modkey }, "x", function()
			awful.prompt.run({
				prompt = "Run Lua code: ",
				textbox = awful.screen.focused().mypromptbox.widget,
				exe_callback = awful.util.eval,
				history_path = awful.util.get_cache_dir() .. "/history_eval",
			})
		end, { description = "lua execute prompt", group = "awesome" }),

		awful.key({ modkey }, "p", function()
			local menubar = require("menubar")
			menubar.show()
		end, { description = "show the menubar", group = "launcher" }),

		awful.key({ modkey, "Shift" }, "d", function()
			awful.spawn(terminal .. " -e tail -f " .. utils.debug_log_path)
		end, { description = "open debug log", group = "awesome" }),

		awful.key({ "Mod1", "Shift" }, "l", function()
			local home = os.getenv("HOME")
			awful.spawn.with_shell(home .. "/.config/awesome/bin/lock.sh")
		end, { description = "lock screen", group = "awesome" }),

		awful.key({ modkey, "Shift" }, "i", function()
			awful.spawn.with_shell("setxkbmap -layout us -variant intl -option ''")
		end, { description = "reset keyboard to us(intl)", group = "awesome" })
	)

	local clientkeys = gears.table.join(
		awful.key({ modkey }, "w", function(c)
			c:kill()
		end, { description = "close", group = "client" }),

		awful.key({ modkey }, "f", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),

		awful.key({ modkey, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),

		awful.key({ modkey, "Shift" }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),

		awful.key({ modkey }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		awful.key({ modkey }, "n", function(c)
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ modkey }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ modkey, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ modkey, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" })
	)

	for i = 1, 9 do
		globalkeys = gears.table.join(
			globalkeys,
			awful.key({ modkey }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end, { description = "view tag #" .. i, group = "tag" }),
			awful.key({ modkey, "Control" }, "#" .. i + 9, function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end, { description = "toggle tag #" .. i, group = "tag" }),
			awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:move_to_tag(tag)
					end
				end
			end, { description = "move focused client to tag #" .. i, group = "tag" }),
			awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end, { description = "toggle focused client on tag #" .. i, group = "tag" })
		)
	end

	local clientbuttons = gears.table.join(
		awful.button({}, 1, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
		end),
		awful.button({ modkey }, 1, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({ modkey }, 3, function(c)
			c:emit_signal("request::activate", "mouse_click", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	return {
		globalkeys = globalkeys,
		clientkeys = clientkeys,
		clientbuttons = clientbuttons,
	}
end

return keybindings
