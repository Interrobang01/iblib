--[[
Use with electicity_source
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local voltage = 0

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_voltage_send" then
        voltage = voltage + data.voltage
        Scene:get_object_by_guid(data.sender):send_event("@interrobang/iblib/electricity_send_type", {
            type = "Wire"
        })
    end
end

function on_step()
    self:set_color(Color:rgb(math.min(voltage,255),math.min(voltage,255),128))
    voltage = 0
end
