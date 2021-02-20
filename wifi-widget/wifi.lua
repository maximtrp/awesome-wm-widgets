-----------------------------------------------------
-- Volume widget for Awesome WM
-- based on volume widget from:
-- https://github.com/streetturtle/awesome-wm-widgets
-----------------------------------------------------

local wibox = require("wibox")
local spawn = require("awful.spawn")
local timer = require("gears.timer")
local widget = {}

local function worker(user_args)

    local args = user_args or {}
    local interface = args.interface or 'wlp3s0'
    local get_wifi_cmd = 'iwconfig ' .. interface .. ' | grep Quality | grep -Eo "[0-9]+/[0-9]+"'

    local image_path_make = function(level)
        local path = os.getenv("HOME") .. "/.config/awesome/icons/network-wireless-disconnected.png"
        if level ~= nil then
            path = os.getenv("HOME") .. "/.config/awesome/icons/network-wireless-connected-" .. level .. ".png"
        end
        return path
    end

    local image_path = image_path_make(0)

    local wifi_image = wibox.widget {
        image  = image_path,
        resize = true,
        widget = wibox.widget.imagebox
    }

    local wifi_text = wibox.widget.textbox()

    local widget = wibox.widget {
        wifi_image,
        wifi_text,
        layout = wibox.layout.fixed.horizontal,
    }

    local update_widget = function(stdout, _, _, _)
        local wifi_level = nil
        local wifi_level_rounded = nil
        wifi_text:set_text("  ")
        local slash = string.find(stdout, '/')
        if slash ~= nil then
            local current = string.sub(stdout, 1, slash - 1)
            local total = string.sub(stdout, slash + 1, -1)
            wifi_level = current * 100 // total
            wifi_level_rounded = math.floor(wifi_level / 25 + 0.5) * 25
            wifi_text:set_text(string.format(" %.0f%%  ", wifi_level))
        end
        wifi_image.image = image_path_make(wifi_level_rounded)
    end

    timer {
        timeout = 60,
        call_now = true,
        autostart = true,
        callback = function()
            spawn.easy_async_with_shell(get_wifi_cmd, update_widget)
        end
    }
    return widget
end

return setmetatable(widget, {
    __call = worker
})

