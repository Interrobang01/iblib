--[[
Makes the object take a curved path when moving.
--]]

local rotate_vector = require("./packages/@interrobang/iblib/lib/rotate_vector.lua")

function on_step()
    local vel = self:get_linear_velocity()
    self:set_linear_velocity(rotate_vector(vel,0.02))
end