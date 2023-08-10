local awful = require("awful")
local wibox = require("wibox")

local vpn_status = {
}

vpn_status.activated = "<b>vpn: on</b>"
vpn_status.deactivated = "<b>vpn: off</b>"
vpn_status.loading = "<b>vpn: loading</b>"

local widget = awful.widget.watch("bash -c 'warp-cli status'", 3, function(widget, stdout)
  for line in stdout:gmatch("[^\r\n]+") do
    if line:match("Connected") then
      widget:set_markup_silently(vpn_status.activated)
      return
    elseif line:match("Disconnected") then
      widget:set_markup_silently(vpn_status.deactivated)
      return
    elseif line:match("Connecting") then
      widget:set_markup_silently(vpn_status.loading)
      return
    end
  end
end)

return widget
