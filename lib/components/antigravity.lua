local elevation = 0

function on_start()
    elevation = self:get_position().y
end

function on_step()
    local vel = self:get_linear_velocity()
    local pos = self:get_position()
    self:set_linear_velocity(vec2(vel.x,elevation-pos.y))
end