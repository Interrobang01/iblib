--[[
Turns an object into a bunch of small shards by repeatedly cutting it in half

INPUTS:
- object, the object you want to shatter
- number, the number of iterations to perform, with the number of shards equalling 2^iterations
- vec2 (optional), the (global) position to shatter the object at, defaults to a random angle
- number (optional), how much the shards to them fly apart, defaults to 0

OUTPUTS:
- table of objects, the resulting shards
--]]

local polygon = require("@interrobang/iblib/lib/polygon.lua")
local rotate_vector = require("@interrobang/iblib/lib/rotate_vector.lua")

local EPSILON = vec2(0.029, 0.037) -- no shared edge is gonna have THAT slope, right?

local function shatter_object(obj, iterations, location, explosion_force)
    -- Get object properties
    local obj_position = obj:get_position()
    local obj_angle = obj:get_angle()
    local obj_shape = obj:get_shape()
    local obj_color = obj:get_color()
    local obj_body_type = obj:get_body_type()
    local obj_friction = obj:get_friction()
    local obj_restitution = obj:get_restitution()
    local obj_density = obj:get_density()
    local obj_velocity = obj:get_linear_velocity()
    local obj_angular_velocity = obj:get_angular_velocity()
    
    -- Base case: if iterations is 0 or less, just return the original object
    if iterations <= 0 then
        return {obj}
    end
    
    local actual_force = (explosion_force or 0) * obj:get_mass() * (0.5^iterations)
    
    local angle
    if location == nil then
        -- If no location is provided, use a random angle
        angle = math.random(0, math.pi * 2)
    else
        -- If a location is provided, use it as the angle
        angle = math.atan2(location.y - obj_position.y, location.x - obj_position.x)
    end 


    local box_center, box_size = polygon.get_bounding_box(obj_shape)

    print("Object size: ", box_size)
    
    local cutout_shape = {
        shape_type = "box",
        size = vec2(box_size.x * 2, box_size.y * 2),
    }

    
    local cutout_offset = vec2(0, box_size.y)
    cutout_offset = rotate_vector(cutout_offset, angle)
    print("Cutout offset: ", cutout_offset)

    local cutout_position = obj_position + cutout_offset + EPSILON

    print("Cutout position: ", cutout_position)
    print("Cutout angle: ", angle)


    -- make box for debug
    -- local cutout_object = Scene:add_box{
    --     position = cutout_position,
    --     size = vec2(box_size.x, box_size.y / 2),
    --     color = Color:rgb(0, 1, 0),
    --     body_type = BodyType.Dynamic,
    -- }
    -- cutout_object:set_angle(angle)
    -- cutout_object:set_shape(cutout_shape)


    -- Create objects for all shapes
    local created_objects = {}
    
    -- Perform boolean operation to cut out the box (NOT operation)
    local shards = polygon.shape_boolean{
        shape_a = obj_shape,
        position_a = obj_position,
        rotation_a = obj_angle,
        shape_b = cutout_shape,
        position_b = cutout_position,
        rotation_b = angle,
        operation = "split",
        make_convex = true,
        get_most_relevant = false,
    }
    
    -- Only proceed if shards were created
    if shards and #shards > 0 then
        -- Create the shards
        for _, shard_shape in ipairs(shards) do
            local centered_shape, offset = polygon.center_shape(shard_shape)
            offset = rotate_vector(offset, obj_angle)
            local shard = Scene:add_circle{
                position = obj_position + offset,
                radius = 1, -- Will be overridden by set_shape
                color = obj_color,
                body_type = obj_body_type,
            }
            shard:set_angle(obj_angle)
            shard:set_shape(centered_shape)
            shard:set_body_type(obj_body_type)
            shard:set_friction(obj_friction)
            shard:set_restitution(obj_restitution)
            shard:set_density(obj_density)
            shard:set_linear_velocity(obj_velocity)
            shard:set_angular_velocity(obj_angular_velocity)

            -- force
            shard:apply_linear_impulse_to_center((offset / offset:magnitude()) * actual_force)
            
            -- If we have more iterations to go, recursively shatter this shard
            if iterations > 1 then
                local sub_shards = shatter_object(shard, iterations - 1, nil, explosion_force)
                for _, sub_shard in ipairs(sub_shards) do
                    table.insert(created_objects, sub_shard)
                end
            else
                table.insert(created_objects, shard)
            end
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
