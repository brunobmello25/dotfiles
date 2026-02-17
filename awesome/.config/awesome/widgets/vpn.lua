local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local vpn_widget = {}

function vpn_widget.new()
    local widget = wibox.widget({
        text = "🔒",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    })

    local function update_vpn_status()
        local handle = io.popen("warp-cli status")
        local result = handle:read("*a")
        handle:close()

        if result:match("Connected") then
            widget:set_text("🌐")
        else
            widget:set_text("🔒")
        end
    end

    -- Create a timer to update VPN status every 10 seconds
    local vpn_timer = gears.timer({
        timeout = 10,
        autostart = true,
        callback = update_vpn_status
    })

    -- Initial update
    update_vpn_status()

    local user = os.getenv("USER")
    if user == "bruno.mello" then
        return wibox.container.margin(widget, 4, 4, 2, 2)
    else
        return nil
    end
end

return vpn_widget