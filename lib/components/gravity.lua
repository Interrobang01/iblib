local self_mass = self:get_mass()
local self_guid = self.guid
local should_apply_reaction = true

function on_event(id, data)
    if id == "@interrobang/iblib/gravity_ping" then
        Scene:get_object_by_guid(data.guid):send_event("@interrobang/iblib/gravity_return_ping",{})
    end
    if id == "@interrobang/iblib/gravity_return_ping" then
        should_apply_reaction = false
    end
end

function on_step()
    if self_guid == nil then self_guid = self.guid end
    local self_position = self:get_position()
    local surroundings = Scene:get_objects_in_circle{
        position = self_position,
        radius = 250,
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

            should_apply_reaction = true
        end
    end
end


