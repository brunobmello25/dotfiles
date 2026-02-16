-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library (disabled - using dunst instead)
-- local naughty = require("naughty")
local menubar = require("menubar")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Custom modules
local autostart = require("autostart")
local keybindings = require("keybindings")
local widgets = require("widgets")
local threecolumn = require("layouts.threecolumn")

-- Setup autostart applications
autostart.setup()

context_menu_max_length = 180

-- naughty.config.defaults.screen = screen.primary

-- {{{ Error handling
-- Note: Error notifications are now handled by dunst
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	awful.spawn.with_shell(
		string.format('notify-send -u critical "AwesomeWM Startup Error" "%s"', awesome.startup_errors:gsub('"', '\\"'))
	)
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		awful.spawn.with_shell(
			string.format('notify-send -u critical "AwesomeWM Error" "%s"', tostring(err):gsub('"', '\\"'))
		)
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "x-terminal-emulator"
local terminal = "kitty"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	threecolumn,
	awful.layout.suit.max,
	awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- Initialize all widgets
local my_widgets = widgets.setup()

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_context_menu = nil

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function(c)
		-- If menu is currently visible, just hide and return
		if tasklist_context_menu and tasklist_context_menu.wibox and tasklist_context_menu.wibox.visible then
			tasklist_context_menu:hide()
			return
		end

		local menu_items = {
			{
				"Toggle Floating",
				function()
					c.floating = not c.floating
				end,
			},
			{
				"Always on Top",
				function()
					c.ontop = not c.ontop
				end,
			},
			{
				"Show on All Workspaces",
				function()
					c.sticky = not c.sticky
				end,
			},
			{
				"Close",
				function()
					c:kill()
				end,
			},
		}
		tasklist_context_menu = awful.menu({ items = menu_items, theme = { width = context_menu_max_length } })
		tasklist_context_menu:show()
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Select wallpaper based on screen resolution
	local wallpaper
	local geo = s.geometry

	-- QHD ultrawide: 3440x1440
	if geo.width == 3440 and geo.height == 1440 then
		wallpaper = beautiful.wallpaper_qhd
	else
		wallpaper = beautiful.wallpaper_default
	end

	if wallpaper then
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, false)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = {
			shape = gears.shape.rounded_rect,
			font = beautiful.taglist_font,
			squares_sel = nil,
			squares_unsel = nil,
		},
		layout = {
			spacing = beautiful.taglist_spacing,
			layout = wibox.layout.fixed.horizontal,
		},
		widget_template = {
			{
				{
					id = "text_role",
					widget = wibox.widget.textbox,
				},
				left = 8,
				right = 8,
				top = 4,
				bottom = 4,
				widget = wibox.container.margin,
			},
			id = "background_role",
			widget = wibox.container.background,
			create_callback = function(self, tag, index, objects)
				self:connect_signal("mouse::enter", function()
					if tag.selected then
						self.bg = beautiful.taglist_bg_focus
					elseif #tag:clients() > 0 then
						self.bg = "#555555"
					else
						self.bg = "#3a3a3a"
					end
				end)
				self:connect_signal("mouse::leave", function()
					if tag.selected then
						self.bg = beautiful.taglist_bg_focus
					elseif #tag:clients() > 0 then
						self.bg = beautiful.taglist_bg_occupied
					else
						self.bg = beautiful.taglist_bg_empty
					end
				end)
			end,
		},
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			my_widgets.caffeine,
			wibox.widget.textbox(" │ "),
			my_widgets.dunst,
			wibox.widget.textbox(" │ "),
			my_widgets.capslock,
			wibox.widget.textbox(" │ "),
			(my_widgets.battery or wibox.widget.textbox("")),
			(my_widgets.battery and wibox.widget.textbox(" │ ") or wibox.widget.textbox("")),
			my_widgets.volume,
			wibox.widget.textbox(" │ "),
			my_widgets.mic,
			wibox.widget.textbox(" │ "),
			my_widgets.vpn,
			wibox.widget.textbox(" │ "),
			my_widgets.media,
			wibox.widget.textbox(" │ "),
			awful.widget.keyboardlayout(),
			wibox.widget.textbox(" │ "),
			wibox.widget.systray(),
			wibox.widget.textbox(" │ "),
			wibox.widget.textclock(),
			wibox.widget.textbox(" │ "),
			s.mylayoutbox,
		},
	})
end)
-- }}}

-- {{{ Key bindings
local keys = keybindings.setup(terminal, modkey)
local globalkeys = keys.globalkeys
local clientkeys = keys.clientkeys
local clientbuttons = keys.clientbuttons

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"gnome-calculator",
				"pavucontrol",
				"Pavucontrol",
				"xtightvncviewer",
				"Vial",
				"vial",
				"Sokoban",
				"Project Seed",
				"org.gnome.FileRoller",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
				"Handmade Hero",
				"Voxel Engine",
				"Evermore",
				"Friends List", -- Steam Friends List
			},
		},
		properties = { floating = true, placement = awful.placement.centered },
	},
	{
		rule_any = {
			name = {
				".*[Gg]ame.*", -- Any window with "game" or "Game" in the name
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true, placement = awful.placement.centered },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	{ rule = { class = "Firefox" }, properties = { screen = 1, tag = "2" } },

	-- Set Vesktop to always map on tag 3
	{ rule = { class = "vesktop" }, properties = { tag = "3" } },
}
-- }}}

-- {{{ Signals
-- Helper function to size and center floating windows
local function resize_floating_client(c)
	if c.floating and not c.fullscreen and not c.maximized then
		local screen_geo = c.screen.geometry
		local height = math.floor(screen_geo.height * 0.7)
		local width = height -- Make it square
		local x = screen_geo.x + math.floor((screen_geo.width - width) / 2)
		local y = screen_geo.y + math.floor((screen_geo.height - height) / 2)

		c:geometry({
			x = x,
			y = y,
			width = width,
			height = height,
		})
	end
end

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- Size and center floating windows
	resize_floating_client(c)
end)

-- Handle when a window is toggled to/from floating
client.connect_signal("property::floating", function(c)
	resize_floating_client(c)
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	-- Helper function to add hover effect to buttons
	local function add_hover_effect(widget)
		local container = wibox.widget({
			widget,
			shape = gears.shape.rounded_rect,
			widget = wibox.container.background,
		})

		container:connect_signal("mouse::enter", function()
			container.bg = "#333333"
			container.shape_border_width = 1
			container.shape_border_color = "#555555"
		end)

		container:connect_signal("mouse::leave", function()
			container.bg = nil
			container.shape_border_width = 0
		end)

		return wibox.widget({
			container,
			margins = 2,
			widget = wibox.container.margin,
		})
	end

	awful.titlebar(c, { size = 28 }):setup({
		{ -- Left
			{
				awful.titlebar.widget.iconwidget(c),
				margins = 4,
				widget = wibox.container.margin,
			},
			{
				{
					align = "left",
					font = "sans bold 10",
					widget = awful.titlebar.widget.titlewidget(c),
				},
				left = 8,
				right = 8,
				widget = wibox.container.margin,
			},
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			{
				add_hover_effect(awful.titlebar.widget.minimizebutton(c)),
				add_hover_effect(awful.titlebar.widget.maximizedbutton(c)),
				add_hover_effect(awful.titlebar.widget.closebutton(c)),
				spacing = 4,
				layout = wibox.layout.fixed.horizontal(),
			},
			margins = 4,
			widget = wibox.container.margin,
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}
