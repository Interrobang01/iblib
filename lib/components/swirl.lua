--[[
Makes it so that when the object rotates, it rotates things around it with it.
--]]

local pi = math.pi
local last_angle = self:get_angle()
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
local rotate_vector = iblib("rotate_vector")
local dynamic = BodyType.Dynamic

function on_step()
    local angle = self:get_angle()
    if angle ~= last_angle then
        local angle_diff = angle - last_angle

        -- get rid of the gap between 2pi and 0 because otherwise falloff doesn't work
        if angle_diff < pi then
            angle_diff = angle_diff + 2*pi
        end
        if angle_diff > pi then
            angle_diff = angle_diff - 2*pi
        end

        local position = self:get_position()
        local surroundings = Scene:get_objects_in_circle{
            position = position,
            radius = 200,
        }
        for i,v in pairs(surroundings) do
            if v ~= self and v:get_body_type() == dynamic then
                local obj_pos = v:get_position()
                local obj_angle = v:get_angle()
                local obj_vel = v:get_linear_velocity()

                local obj_distance = (obj_pos - position):magnitude()
                local falloff = 0.95^obj_distance

                local obj_old_relative_pos = obj_pos-position
                local obj_new_relative_pos = rotate_vector(obj_old_relative_pos, angle_diff*falloff)
                local direction = obj_new_relative_pos - obj_old_relative_pos
                local hits = Scene:raycast{
                    origin = obj_pos,
                    direction = direction,
                    distance = direction:magnitude(),
                    closest_only = false,
                }
                local no_obstructions = true
                local obstruction_point = nil
                for _,hit in pairs(hits) do
                    if hit.object:get_body_type() ~= dynamic then
                        no_obstructions = false
                        obstruction_point = hit.point
                    end
                end
                if no_obstructions == true then
                    v:set_position(obj_new_relative_pos+position)
                else
                    v:set_position(obstruction_point)
                end
                v:set_angle(obj_angle + angle_diff*falloff)
                v:set_linear_velocity(rotate_vector(obj_vel, angle_diff*falloff))
            end
        end
        last_angle = angle
    end
end