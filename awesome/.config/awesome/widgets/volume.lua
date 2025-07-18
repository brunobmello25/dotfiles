local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

local volume = {}

function volume.new()
  local volume_text = wibox.widget({
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local volume_widget = wibox.container.margin(volume_text, 4, 4, 2, 2)

  local function update_volume()
    awful.spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(stdout)
      local vol = stdout:match("(%d+)%%")
      if not vol then
        volume_text:set_text("🔇 N/A")
        return
      end

      awful.spawn.easy_async("pactl get-sink-mute @DEFAULT_SINK@", function(mute_stdout)
        local is_muted = mute_stdout:match("yes")
        local volume_level = tonumber(vol)
        
        local ico
        if is_muted then
          ico = "🔇"
        elseif volume_level == 0 then
          ico = "🔇"
        elseif volume_level < 30 then
          ico = "🔈"
        elseif volume_level < 70 then
          ico = "🔉"
        else
          ico = "🔊"
        end

        local resulting_text = string.format("%s %s%%", ico, vol)
        volume_text:set_text(resulting_text)
      end)
    end)
  end

  -- Listen for volume change signals
  awesome.connect_signal("volume::update", update_volume)

  -- Add click handlers for volume control
  volume_widget:buttons(gears.table.join(
    awful.button({}, 1, function() -- Left click: toggle mute
      awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
      awesome.emit_signal("volume::update")
    end),
    awful.button({}, 3, function() -- Right click: open pavucontrol
      awful.spawn("pavucontrol")
    end),
    awful.button({}, 4, function() -- Scroll up: increase volume
      awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
      awesome.emit_signal("volume::update")
    end),
    awful.button({}, 5, function() -- Scroll down: decrease volume
      awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
      awesome.emit_signal("volume::update")
    end)
  ))

  -- Update volume every 30 seconds (fallback)
  gears.timer({
    timeout = 30,
    autostart = true,
    callback = update_volume,
  })

  -- Initial update
  update_volume()

  return volume_widget
end

return volume