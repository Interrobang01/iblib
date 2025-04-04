--[[
Turns an object into a bunch of small shards by repeatedly cutting it in half

INPUTS:
- object, the object you want to shatter

OUTPUTS:
- table of objects, the resulting shards
--]]

local polygon = require("@interrobang/iblib/lib/polygon.lua")

local function shatter_object(obj)
    -- Get object properties
    local obj_position = obj:get_position()
    local obj_angle = obj:get_angle()
    local obj_shape = obj:get_shape()
    local obj_color = obj:get_color()
    local obj_body_type = obj:get_body_type()
    
    local obj_size = polygon.get_shape_size(obj_shape) * 5

    print("Object size: " .. obj_size)
    
    local cutout_shape = {
        shape_type = "polygon",
        points = {
            vec2(-obj_size, 0),
            vec2(obj_size, 0),
            vec2(-obj_size, obj_size),
            vec2(obj_size, obj_size),
        }
    }
    
    -- Create objects for all shapes
    local created_objects = {}
    
    -- Perform boolean operation to cut out the box (NOT operation)
    local shards = polygon.shape_boolean{
        shape_a = obj_shape,
        position_a = vec2(0, 0),  -- relative to the object
        rotation_a = 0,
        shape_b = cutout_shape,
        position_b = vec2(0, 0),  -- center of the object
        rotation_b = 0,
        operation = "split",
        make_convex = true,
        get_most_relevant = false,
    }
    
    -- Only proceed if shards were created
    if shards and #shards > 0 then
        -- Create the shards
        for _, shard_shape in ipairs(shards) do
            local shard = Scene:add_circle{
                position = obj_position,
                radius = 1, -- Will be overridden by set_shape
                color = obj_color,
                body_type = obj_body_type,
            }
            shard:set_angle(obj_angle)
            shard:set_shape(shard_shape)
            table.insert(created_objects, shard)
        end
        
        -- Delete the original object only if we succeeded in creating shards
        obj:destroy()
    else
        -- If sharding failed, just return the original object
        table.insert(created_objects, obj)
    end
    
    return created_objects
end

return shatter_object
