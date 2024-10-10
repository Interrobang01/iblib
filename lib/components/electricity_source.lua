--[[
Use with electicity_carrier. Object must have electricity_carrier.
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua")
local received_type = nil
local self_guid = self.guid

local voltage = 64

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_send_type" then
        received_type = data.type
    end
end

local function recursive_get_touching(hits, visited)
    if #hits ~= 0 then
        for i = 1, #hits do
            local hit_guid = hits[i].guid
            if visited[hit_guid] ~= true then
                received_type = nil
                hits[i]:send_event("@interrobang/iblib/electricity_voltage_send", {
                    voltage = voltage,
                    sender = self_guid,
                })
                if received_type == "Wire" or hits[i] == self then
                    visited[hit_guid] = true
                    visited = recursive_get_touching(check_around_object(hits[i]), visited)
                end
            end
        end
    end
    return visited
end

function on_step()

    local visited = {} -- handled objects are keys set to true
    visited = recursive_get_touching({self}, visited)
end
