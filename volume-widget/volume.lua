-----------------------------------------------------
-- Volume widget for Awesome WM
-- based on volume widget from:
-- https://github.com/streetturtle/awesome-wm-widgets
-----------------------------------------------------

local wibox = require("wibox")
local spawn = require("awful.spawn")
local button = require("awful.button")
local util = require("awful.util")
local get_volume_cmd = "/usr/bin/echo $(pamixer --get-volume) $(pamixer --get-mute)"

local volume_text = wibox.widget.textbox()
volume_text:set_font("Iosevka 12")

local volume_image = wibox.widget {
    image  = image_path,
    resize = true,
    widget = wibox.widget.imagebox
}

local image_path_make = function(level, muted)
    local status = 'low'
    if muted == "true" then
        status = 'muted'
    else
        if level > 66 then
            status = 'high'
        elseif level > 33 then
            status = 'medium'
        end
    end
    local path = os.getenv("HOME") .. '/.config/awesome/icons/audio-volume-' .. status .. '.png'
    return path
end

local volume_widget = wibox.widget {
    volume_image,
    volume_text,
    layout = wibox.layout.fixed.horizontal
}

local update_widget = function(stdout, _, _, _)
    local space = string.find(stdout, ' ')
    local muted = string.sub(stdout, space + 1, -2)
    local volume = tonumber(string.sub(stdout, 1, space - 1))
    volume_text:set_text(" " .. volume .. "%  ")
    volume_image.image = image_path_make(volume, muted)
end

volume_widget:buttons(util.table.join(
    button({ }, 1, function ()
        spawn.with_shell("pactl set-sink-volume $(pacmd stat | grep sink | cut -d: -f 2) -2%")
        spawn.easy_async_with_shell(get_volume_cmd, update_widget)
    end),
    button({ }, 3, function ()
        spawn.with_shell("pactl set-sink-volume $(pacmd stat | grep sink | cut -d: -f 2) +2%")
        spawn.easy_async_with_shell(get_volume_cmd, update_widget)
    end),
    button({ }, 4, function ()
        spawn.with_shell("pactl set-sink-volume $(pacmd stat | grep sink | cut -d: -f 2) +2%")
        spawn.easy_async_with_shell(get_volume_cmd, update_widget)
    end),
    button({ }, 5, function ()
        spawn.with_shell("pactl set-sink-volume $(pacmd stat | grep sink | cut -d: -f 2) -2%")
        spawn.easy_async_with_shell(get_volume_cmd, update_widget)
    end)
))

volume_widget:connect_signal("volume_refresh", function()
    spawn.easy_async_with_shell(get_volume_cmd, update_widget)
end)

spawn.easy_async_with_shell(get_volume_cmd, update_widget)

return volume_widget
