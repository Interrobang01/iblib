--[[
Use with electicity_carrier. Object must have electricity_carrier.
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua")
local split = require("./packages/@interrobang/iblib/lib/split_string.lua")
local received_data = nil
local self_guid = self.guid

local voltage = 50

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_return_ping" then
        received_data  = data
    end
end

local function recursive_get_touching(hits, visited)
    if type(hits) == "string" then
        hits = split(hits,",")
    end
    if #hits ~= 0 then
        for i = 1, #hits do
            local hit_guid = nil
            local obj = nil
            if type(hits[i]) == "string" then
                hit_guid = tonumber(hits[i])
                obj = Scene:get_object_by_guid(hit_guid)
            else
                hit_guid = hits[i].guid
                obj = hits[i]
            end
            if visited[hit_guid] ~= true and obj ~= nil then
                received_data = {}
                obj:send_event("@interrobang/iblib/electricity_ping", {
                    voltage = voltage,
                    sender = self_guid,
                })
                if received_data.resistance ~= nil or obj == self then
                    visited[hit_guid] = true
                    visited = recursive_get_touching(received_data.hits, visited)
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
