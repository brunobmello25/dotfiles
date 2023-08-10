local beautiful = require("beautiful")
local awful = require("awful")

local M = {}

M.launcher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = awful.menu({
    items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
      { "open terminal", terminal }
    }
  })
})

return M
