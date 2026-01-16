local awful = require("awful")
local utils = require("utils")

local autostart = {}

local function run_once(name, cmd)
	local user = os.getenv("USER")
	local flagfile = string.format("/tmp/awesome-%s-%s", name, user)

	awful.spawn.with_shell(string.format(
		[[
		if [ ! -f "%s" ]; then
			touch "%s"
			%s
		fi
	]],
		flagfile,
		flagfile,
		cmd
	))
end

function autostart.setup()
	local user = os.getenv("USER")
	local home = os.getenv("HOME")

	run_once("xdg-autostart", "dex-autostart --autostart --environment Awesome")

	awful.spawn.with_shell("pgrep -u $USER -x lxpolkit >/dev/null || lxpolkit &")

	awful.spawn.with_shell([[
    # Find the internal KB device-id
    DEV=$(xinput list --id-only "AT Translated Set 2 keyboard")
    if [ -n "$DEV" ]; then
      # apply caps<->esc swap only to that device
      setxkbmap -device $DEV -option "caps:swapescape"
    fi
  ]])

	awful.spawn.with_shell("nm-applet --indicator &")

	if user == "brubs" then
		awful.spawn.once(home .. "/.screenlayout/desktop.sh")
	elseif user == "bruno.mello" then
		if utils.external_connected() then
			awful.spawn.once(home .. "/.screenlayout/plugged.sh")
		else
			awful.spawn.once(home .. "/.screenlayout/unplugged.sh")
		end
	end

	-- Start clipboard manager
	awful.spawn.with_shell("copyq &")

	-- Start dunst notification daemon
	awful.spawn.with_shell("pgrep -u $USER -x dunst >/dev/null || dunst &")

	-- Set keyboard layout and bind to a key for quick reset
	awful.spawn.with_shell("setxkbmap -layout us -variant intl -option ''")

	-- Also set it with a slight delay to override any conflicting startup processes
	awful.spawn.with_shell("sleep 2 && setxkbmap -layout us -variant intl -option ''")

	-- awful.spawn.with_shell("pgrep -u $USER -x picom >/dev/null || picom -b --config " .. home .. "/.dotfiles/picom/picom.conf")
end

return autostart
