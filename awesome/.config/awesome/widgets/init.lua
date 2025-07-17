local wibox = require("wibox")
local beautiful = require("beautiful")
local battery_widget = require("widgets.battery")
local capslock_widget = require("widgets.capslock")

local widgets = {}

function widgets.setup()
  local user = os.getenv("USER")
  
  -- Initialize all widgets
  local battery = battery_widget.new()
  local capslock = capslock_widget.new()
  local caffeine = require("widgets.caffeine")()
  local vpn_widget = require("widgets.vpn").new()
  
  -- Mic widget setup
  local widget_mic = wibox.widget({ 
    beautiful.mic.widget, 
    layout = wibox.layout.align.horizontal 
  })
  
  -- Battery widget logic - only show for work laptop
  local function get_battery_widget()
    if user == "brubs" then
      return nil
    end
    return battery
  end
  
  return {
    caffeine = caffeine,
    capslock = capslock,
    battery = get_battery_widget(),
    mic = widget_mic,
    vpn = vpn_widget
  }
end

return widgets