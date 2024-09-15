local self_mass = nil

function on_step()
    if self_mass == nil then self_mass = self:get_mass() end
    local angle = self:get_angle()
    self:apply_force_to_center(vec2(math.cos(angle),math.sin(angle)) * self_mass * -10)
end