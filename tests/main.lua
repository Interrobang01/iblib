-- File to test whatever is currently being worked on
-- Once the feature is done it will be moved into its own file.

local shatter = require("@interrobang/iblib/lib/shatter_object.lua")

local object = Scene:add_box{
    position = vec2(0, 0),
    size = vec2(1, 1),
    color = Color:rgb(1, 0, 0),
    body_type = BodyType.Dynamic,
}
local new_objects = shatter(object, 4, vec2(1, 0.5), 1)
-- if #new_objects ~= 2 then
--     print("Shatter failed, expected 2 objects, got " .. #new_objects)
-- else
--     print("Shatter succeeded, created " .. #new_objects .. " objects")
-- end
-- for i = 1, #new_objects do
--     local this_object = new_objects[i]
--     next_index = (i + 1) and (i < #new_objects) or 1
--     local next_object = new_objects[next_index]
--     if new_object:get_position() == next_object:get_position() then
--         print("Shatter failed, objects are at the same position")
--     end
-- end


-- local object2 = Scene:add_box{
--     position = vec2(10, 0),
--     size = vec2(1, 1),
--     color = Color:rgb(0, 1, 0),
--     body_type = BodyType.Dynamic,
-- }
-- local new_objects2 = shatter(object2, 4)
-- if #new_objects2 ~= 16 then
--     print("Shatter failed, expected 16 objects, got " .. #new_objects2)
-- else
--     print("Shatter succeeded, created " .. #new_objects2 .. " objects")
-- end





