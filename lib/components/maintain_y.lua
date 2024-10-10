--[[
Makes the object maintain its vertical position by setting its velocity to the difference between the desired y value and the current y value.
--]]

local desired_y = 0

function on_start()
    desired_y = self:get_position().y
end

function on_step()
    local vel = self:get_linear_velocity()
    local pos = self:get_position()
    self:set_linear_velocity(vec2(vel.x,desired_y-pos.y))
end