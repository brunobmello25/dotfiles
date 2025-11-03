local wibox = require("wibox")
local beautiful = require("beautiful")
local battery_widget = require("widgets.battery")
local capslock_widget = require("widgets.capslock")
local volume_widget = require("widgets.volume")
local media_widget = require("widgets.media")

local widgets = {}

function widgets.setup()
  local user = os.getenv("USER")
  
  -- Initialize all widgets
  local battery = battery_widget.new()
  local capslock = capslock_widget.new()
  local caffeine = require("widgets.caffeine")()
  local vpn_widget = require("widgets.vpn").new()
  local volume = volume_widget.new()
  local media = media_widget.new()
  
  -- Mic widget setup
  local widget_mic = wibox.widget({ 
    beautiful.mic.widget, 
    layout = wibox.layout.align.horizontal 
  })
  
  return {
    caffeine = caffeine,
    capslock = capslock,
    battery = battery,
    mic = widget_mic,
    vpn = vpn_widget,
    volume = volume,
    media = media
  }
end

return widgets