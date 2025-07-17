local wibox = require("wibox")
local gears = require("gears")

local capslock = {}

function capslock.new()
  local capslock_widget = wibox.widget({
    text = "a",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  capslock_widget = wibox.container.margin(capslock_widget, 4, 4, 2, 2)

  local function update_caps()
    local fh = io.popen("xset q | grep 'Caps Lock:'")
    if not fh then
      return
    end
    local s = fh:read("*a")
    fh:close()

    local on = s:match("Caps Lock:%s+on")
    if on then
      capslock_widget.widget:set_text("A")
    else
      capslock_widget.widget:set_text("a")
    end
  end

  gears.timer({
    timeout = 1,
    autostart = true,
    callback = update_caps,
  })

  update_caps()

  return capslock_widget
end

return capslock