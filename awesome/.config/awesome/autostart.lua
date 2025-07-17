local awful = require("awful")
local utils = require("utils")

local autostart = {}

function autostart.setup()
  local user = os.getenv("USER")
  local home = os.getenv("HOME")

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

  awful.spawn.with_shell("setxkbmap -layout us -variant intl -option ''")
end

return autostart