---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Grab environment
local tonumber = tonumber
local setmetatable = setmetatable
local string = { format = string.format, gsub = string.gsub }
local helpers = require("vicious.helpers")
local math = {
    min = math.min,
    floor = math.floor
}
-- }}}


-- Bat: provides state, charge, and remaining time for a requested battery
-- vicious.widgets.bat
local bat = {}


-- {{{ Battery widget type
local function worker(format, warg)
    if not warg then return end

    local battery = helpers.pathtotable("/sys/devices/platform/smapi/"..warg)

    -- Check if the battery is present
    if battery.installed ~= "1\n" then
        return {"unknown", 0, "N/A"}
    end

    local battery_var = {
        ["idle\n"] = battery.remaining_charging_time,
        ["charging\n"] = battery.remaining_charging_time,
        ["discharging\n"] = battery.remaining_running_time_now,
    }
    local timeleft = tonumber(battery_var[ battery.state ]) or 0
    local hoursleft   = math.floor(timeleft / 60)
    local minutesleft = math.floor(timeleft - (hoursleft * 60))

    local time = string.format("%02d:%02d", hoursleft, minutesleft)
    
    return{string.gsub(battery.state, "(%w+)\n","%1"), tonumber(battery.remaining_percent) or 0, time}
end
-- }}}

return setmetatable(bat, { __call = function(_, ...) return worker(...) end })
