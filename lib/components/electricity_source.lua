--[[
Use with electicity_carrier
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua")
local received_type = nil
local self_guid = self.guid

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
                received_type = "Carrier"
                --hits[i]:send_event("@interrobang/iblib/electricity_get_hits", {sender=self})
                if received_type == "Carrier" then
                    visited[hit_guid] = true
                    visited = recursive_get_touching(check_around_object(hits[i]), visited)
                end
            end
        end
    end
    return visited
end

function on_step()
    local hits = check_around_object(self)

    local visited = {} -- handled objects are keys set to true
    visited[self_guid] = true
    visited = recursive_get_touching(hits, visited)

    for i,v in pairs(Scene:get_all_objects()) do
        v:set_color(0)
        if visited[v.guid] == true then
            v:set_color(0xffffff)
        end
    end
end
