local self_mass = self:get_mass()
local self_guid = self.guid
local should_apply_reaction = true
local last_force = 0
local last_distance = 0

function on_event(id, data)
    if id == "@interrobang/iblib/gravity_ping" then
        Scene:get_object_by_guid(data.guid):send_event("@interrobang/iblib/gravity_return_ping",{})
    end
    if id == "@interrobang/iblib/gravity_return_ping" then
        should_apply_reaction = false
    end
    if id == "@interrobang/iblib/send_to_orbit" then
        local normalized_force = last_force:normalize()
        local rotated_normal = vec2(normalized_force.y,normalized_force.x * -1)
        local magnitude = math.sqrt(last_force:magnitude()*last_distance/self_mass)
        self:set_linear_velocity(rotated_normal * magnitude)
    end
end

function on_step()
    if self_guid == nil then self_guid = self.guid end
    local self_position = self:get_position()
    local surroundings = Scene:get_objects_in_circle{
        position = self_position,
        radius = 2500,
    }
    for i = 1, #surroundings do
        local obj = surroundings[i]
        if obj ~= self then
            obj:send_event("@interrobang/iblib/gravity_ping",{
                guid = self_guid,
            })
            local obj_pos = obj:get_position()
            local obj_mass = obj:get_mass()
            local dir = self_position-obj_pos
            local distance = dir:magnitude()
            local force = (dir/(distance^2))*10*self_mass*obj_mass -- change to distance^2 for more realism
            if should_apply_reaction then
                obj:apply_force_to_center(force)
            end
            self:apply_force_to_center(-force)

            last_force = force
            last_distance = distance

            should_apply_reaction = true
        end
    end
end


