---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}
local mic = require("widgets/mic")

theme.font = "sans 10"

theme.bg_normal = "#222222"
theme.bg_focus = "#535d6c"
theme.bg_urgent = "#ff0000"
theme.bg_minimize = "#444444"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#aaaaaa"
theme.fg_focus = "#ffffff"
theme.fg_urgent = "#ffffff"
theme.fg_minimize = "#ffffff"

theme.useless_gap = dpi(4)
theme.border_width = dpi(1)
theme.border_normal = "#000000"
theme.border_focus = "#dd7373"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Taglist styling
theme.taglist_font = "sans bold 11"
theme.taglist_bg_focus = "#dd7373"
theme.taglist_fg_focus = "#ffffff"
theme.taglist_bg_occupied = "#444444"
theme.taglist_fg_occupied = "#dddddd"
theme.taglist_bg_empty = "#2a2a2a"
theme.taglist_fg_empty = "#666666"
theme.taglist_bg_urgent = "#ff6b6b"
theme.taglist_fg_urgent = "#ffffff"
theme.taglist_spacing = dpi(4)

-- Disable taglist squares (we use background colors instead)
theme.taglist_squares_sel = nil
theme.taglist_squares_unsel = nil

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)

-- Titlebar styling
theme.titlebar_bg_normal = "#1a1a1a"
theme.titlebar_bg_focus = "#2a2a2a"
theme.titlebar_fg_normal = "#888888"
theme.titlebar_fg_focus = "#ffffff"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load (custom titlebar icons)
local titlebar_icon_path = gfs.get_configuration_dir() .. "icons/titlebar/"

theme.titlebar_close_button_normal = titlebar_icon_path .. "close_normal.png"
theme.titlebar_close_button_focus = titlebar_icon_path .. "close_focus.png"

theme.titlebar_minimize_button_normal = titlebar_icon_path .. "minimize_normal.png"
theme.titlebar_minimize_button_focus = titlebar_icon_path .. "minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path .. "default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themes_path .. "default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path .. "default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themes_path .. "default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themes_path .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themes_path .. "default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path .. "default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themes_path .. "default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path .. "default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themes_path .. "default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = titlebar_icon_path .. "maximize_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = titlebar_icon_path .. "maximize_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = titlebar_icon_path .. "maximize_normal_active.png"
theme.titlebar_maximized_button_focus_active = titlebar_icon_path .. "maximize_focus_active.png"

-- Per-screen wallpapers based on resolution
theme.wallpaper_qhd = "~/Pictures/wallpapers/WQHD/chameleon_wildlife_illustration-wallpaper-3440x1440.jpg"
theme.wallpaper_default = "~/Pictures/wallpapers/FHD/cats_fishing.png"

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"
theme.layout_threecolumn = gfs.get_configuration_dir() .. "icons/threecolumnw.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

theme.widget_micMuted = gfs.get_configuration_dir() .. "widgets/icons/micMuted.png"
theme.widget_micUnmuted = gfs.get_configuration_dir() .. "widgets/icons/micUnmuted.png"
theme.mic = mic({
	timeout = 10,
	icon_mute = gfs.get_configuration_dir() .. "widgets/icons/micMuted.png",
	icon_unmute = gfs.get_configuration_dir() .. "widgets/icons/micUnmuted.png",
})

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
