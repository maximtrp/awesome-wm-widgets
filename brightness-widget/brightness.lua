-----------------------------------------------------
-- Brightness widget for Awesome WM
-- based on brightness widget from:
-- https://github.com/streetturtle/awesome-wm-widgets
-----------------------------------------------------

local wibox = require("wibox")
local spawn = require("awful.spawn")
local button = require("awful.button")
local util = require("awful.util")

local GET_BRIGHTNESS_CMD = "xbacklight -get"
local INC_BRIGHTNESS_CMD = "xbacklight -inc "
local DEC_BRIGHTNESS_CMD = "xbacklight -dec "

local get_brightness_cmd = GET_BRIGHTNESS_CMD
local inc_brightness_cmd = INC_BRIGHTNESS_CMD
local dec_brightness_cmd = DEC_BRIGHTNESS_CMD

local brightness_text = wibox.widget.textbox()
brightness_text:set_font("Iosevka 12")

local brightness_image = wibox.widget {
    image = os.getenv("HOME") .. '/.config/awesome/icons/brightness.png',
    resize = true,
    widget = wibox.widget.imagebox
}

local brightness_image_margin = wibox.widget {
    brightness_image,
    margins = 4,
    widget = wibox.container.margin
}

local widget = wibox.widget {
    brightness_image_margin,
    brightness_text,
    layout = wibox.layout.fixed.horizontal,
}

local update_widget = function(stdout, _, _, _)
    local brightness_level = tonumber(string.format("%.0f", stdout))
    brightness_text:set_text(" " .. brightness_level .. "%  ")
end

widget:buttons(util.table.join(
    button({ }, 1, function()
        spawn.with_shell(dec_brightness_cmd .. "5")
        spawn.easy_async_with_shell(get_brightness_cmd, update_widget)
    end),
    button({ }, 3, function()
        spawn.with_shell(inc_brightness_cmd .. "5")
        spawn.easy_async_with_shell(get_brightness_cmd, update_widget)
    end),
    button({ }, 4, function()
        spawn.with_shell(inc_brightness_cmd .. "2")
        spawn.easy_async_with_shell(get_brightness_cmd, update_widget)
    end),
    button({ }, 5, function()
        spawn.with_shell(dec_brightness_cmd .. "2")
        spawn.easy_async_with_shell(get_brightness_cmd, update_widget)
    end)
))

widget:connect_signal("brightness_refresh", function() 
    spawn.easy_async_with_shell(get_brightness_cmd, update_widget)
end)

spawn.easy_async_with_shell(get_brightness_cmd, update_widget)

return widget
