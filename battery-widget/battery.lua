-----------------------------------------------------
-- Battery widget for Awesome WM
-- based on battery widget from:
-- https://github.com/streetturtle/awesome-wm-widgets
-----------------------------------------------------

local wibox = require("wibox")
local spawn = require("awful.spawn")
local timer = require("gears.timer")
local widget = {}

local function worker(user_args)

    local args = user_args or {}
    local battery_name = args.battery or "BAT0"
    local battery_path = "/sys/class/power_supply/" .. battery_name
    local get_battery_cmd = ''

    local image_path_make = function(val, charging)
        local charge_status = ""
        if charging == 'Charging' then
            charge_status = "-charging"
        end
        local battery_level = string.format("%03d", val)
        local path = os.getenv("HOME") .. '/.config/awesome/icons/battery-' .. battery_level .. charge_status .. '.png'
        return path
    end

    local image_path = image_path_make(100)

    local battery_image = wibox.widget {
        image  = image_path,
        resize = true,
        widget = wibox.widget.imagebox
    }

    local battery_text = wibox.widget.textbox()

    local widget = wibox.widget {
        battery_image,
        battery_text,
        layout = wibox.layout.fixed.horizontal,
    }

    local update_widget = function(stdout, _, _, _)
        local space = string.find(stdout, " ")
        local status = string.sub(stdout, 1, space - 1)
        local battery_level = tonumber(string.sub(stdout, space + 1, -1))
        local battery_level_10 = math.floor(battery_level / 10 + 0.5) * 10

        battery_text:set_text(" " .. battery_level .. "%  ")
        battery_image.image = image_path_make(battery_level_10, status)
    end

    timer {
        timeout = 60,
        call_now = true,
        autostart = true,
        callback = function()
            spawn.easy_async_with_shell("echo $(cat " .. battery_path .. "/status) $(cat " .. battery_path .. "/capacity)", update_widget)
        end
    }

    return widget
end

return setmetatable(widget, {
    __call = worker
})
