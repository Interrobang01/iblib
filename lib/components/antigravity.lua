--[[
Makes the object unaffected by gravity.
--]]

function on_step()
    self:apply_force_to_center(-Scene:get_gravity()*self:get_mass())
end