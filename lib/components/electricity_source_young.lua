--[[
Use with electicity_carrier. Object must have electricity_carrier.
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")
local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua")
local split = require("./packages/@interrobang/iblib/lib/split_string.lua")
local received_data = nil
local self_guid = self.guid

local voltage = 128

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_return_ping" then
        received_data  = data
    end
end

local function get_object_data(object) -- gets object contacts and properties
    received_data = {}
    object:send_event("@interrobang/iblib/electricity_ping", {
        voltage = voltage,
        sender = self_guid,
    })
    return received_data
end

local function search(visited, obj_guid, obj_data)

    local hits = obj_data.hits
    if type(hits) == "string" then
        hits = split(hits,",")
    end

    local todo_new = {}
    if #hits ~= 0 then
        for i = 1, #hits do
            local hit_guid = nil
            local obj = nil
            if type(hits[i]) == "string" or type(hits[i]) == "number" then
                hit_guid = tonumber(hits[i])
                obj = Scene:get_object_by_guid(hit_guid)
            else
                hit_guid = hits[i].guid
                obj = hits[i]
            end
            if visited[hit_guid] ~= true then
                local data = get_object_data(obj)
                if data.resistance ~= nil and obj ~= nil and hit_guid ~= nil then
                    visited[hit_guid] = true
                    todo_new[hit_guid] = data
                end
            end
        end
    end
    return visited, todo_new
end

function on_step()

    voltage = 128

    local visited = {} -- handled objects are keys set to true
    local todo = {}
    todo[self_guid] = get_object_data(self)
    print("im steppin")
    print(dump(todo))
    print(#todo)
    local is_todo_empty = false
    while not is_todo_empty and voltage > 0 do
        print(#todo)
        local min = math.huge
        local min_guid = nil
        local min_data = nil
        is_todo_empty = true
        for i, v in pairs(todo)  do
            is_todo_empty = false
            if v.resistance < min then
                min = v.resistance
                min_guid = i
                min_data = v
            end
        end
        if min_guid ~= nil then
            voltage = voltage - min
            if voltage < 0 then voltage = 0 end
            Scene:get_object_by_guid(min_guid):apply_force_to_center(vec2(0,min * (voltage/255)))
            todo[min_guid] = nil
            local todo_new = nil
            visited, todo_new = search(visited, min_guid, min_data)
            for i, v in pairs(todo_new) do
                todo[i] = v
            end
        end
    end
end
