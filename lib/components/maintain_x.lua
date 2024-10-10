--[[
Makes the object maintain its horizontal position by setting its velocity to the difference between the desired x value and the current x value.
--]]

local desired_x = 0

function on_start()
    desired_x = self:get_position().x
end

function on_step()
    local vel = self:get_linear_velocity()
    local pos = self:get_position()
    self:set_linear_velocity(vec2(desired_x-pos.x,vel.y))
end