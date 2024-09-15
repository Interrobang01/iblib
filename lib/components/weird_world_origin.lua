function on_step()
    local pos = self:get_position()

    local everything = Scene:get_all_objects()
    for i = 1,#everything do
        local obj = everything[i]
        local obj_pos = obj:get_position()
        obj_pos = obj_pos - pos
        obj:set_position(obj_pos)
    end
end