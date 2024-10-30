--[[
Defines a material. Doesn't do anything on its own.
--]]

local MATERIAL = {
    Resistance = 1,
    BatteryID = nil,
    IsPositiveBattery = nil, -- false for negative
}
local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua")
local voltage = 0
local touching = {}

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_ping" then
        voltage = voltage + data.voltage
        local self_body_type = self:get_body_type()
        local hits = ""
        if self_body_type == BodyType.Dynamic then
            for i, v in pairs(touching) do
                if v == true and i ~= nil then
                    -- if it's static then someone might have moved it,
                    -- making the fact that it's in the touching table inaccurate,
                    -- so it's best to ban all statics
                    if Scene:get_object_by_guid(i):get_body_type() == BodyType.Dynamic then
                        hits = hits .. tostring(i) .. ","
                    end
                end
            end
        else
            touching = {}
            local check_hits = table.sort(check_around_object(self,0.01))
            for i = 1, #check_hits do
                hits = hits .. tostring(check_hits[i].guid) .. ","
            end
        end
        Scene:get_object_by_guid(data.sender):send_event("@interrobang/iblib/electricity_return_ping", {
            hits = hits,
            resistance = MATERIAL.Resistance,
            battery_id = MATERIAL.BatteryID,
            is_positive_battery = MATERIAL.IsPositiveBattery,
        })
    end
end

function on_step()
    self:set_color(Color:rgb(math.min(voltage,255),math.min(voltage,255),128))
    if self:get_name() == "resistor" then
        MATERIAL.Resistance = 64
        self:set_color(Color:rgb(math.min(voltage,255),math.min(voltage,255),64))
    end
    if self:get_name() == "positive_battery" then
        MATERIAL.BatteryID = 1
        MATERIAL.IsPositiveBattery = true
        self:set_color(Color:rgb(math.min(voltage,255),math.min(voltage,255),255))
    end

    if self:get_name() == "negative_battery" then
        MATERIAL.BatteryID = 1
        MATERIAL.IsPositiveBattery = false
        self:set_color(Color:rgb(math.min(voltage,255),math.min(voltage,255),128))
    end
    voltage = 0
end

function on_collision_start(data)
    touching[data.other.guid] = true
end


function on_collision_end(data)
    touching[data.other.guid] = false
end
