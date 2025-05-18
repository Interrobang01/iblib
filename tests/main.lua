-- -- File to test whatever is currently being worked on
-- -- Once the feature is done it will be moved into its own file.

-- -- create 100 polygons in a line, each with points closer together
-- -- point length ranges from 0.03 to 0.02
-- -- for i = 1, 100 do
-- --     local point_length = 0.03 - (i * 0.0001)
-- --     local object = Scene:add_polygon{
-- --         position = vec2(i, 0),
-- --         points = {
-- --             vec2(0, 0),
-- --             vec2(1, 0),
-- --             vec2(1, 1),
-- --             vec2(1 - point_length, 1),
-- --         },
-- --         color = Color:rgb(0, 1, 0),
-- --         body_type = BodyType.Dynamic,
-- --     }
-- --     object:set_name("polygon_" .. point_length)
-- -- end


local shatter = require("@interrobang/iblib/lib/shatter_object.lua")
 
local object = Scene:add_box{
    position = vec2(0, 0),
    size = vec2(1, 1),
    color = Color:rgb(1, 0, 0),
    body_type = BodyType.Dynamic,
}
local new_objects = shatter(object, 6, vec2(1, 0.5), 0)
-- -- if #new_objects ~= 2 then
-- --     print("Shatter failed, expected 2 objects, got " .. #new_objects)
-- -- else
-- --     print("Shatter succeeded, created " .. #new_objects .. " objects")
-- -- end
-- -- for i = 1, #new_objects do
-- --     local this_object = new_objects[i]
-- --     next_index = (i + 1) and (i < #new_objects) or 1
-- --     local next_object = new_objects[next_index]
-- --     if new_object:get_position() == next_object:get_position() then
-- --         print("Shatter failed, objects are at the same position")
-- --     end
-- -- end


-- -- local object2 = Scene:add_box{
-- --     position = vec2(10, 0),
-- --     size = vec2(1, 1),
-- --     color = Color:rgb(0, 1, 0),
-- --     body_type = BodyType.Dynamic,
-- -- }
-- -- local new_objects2 = shatter(object2, 4)
-- -- if #new_objects2 ~= 16 then
-- --     print("Shatter failed, expected 16 objects, got " .. #new_objects2)
-- -- else
-- --     print("Shatter succeeded, created " .. #new_objects2 .. " objects")
-- -- end


local polygon = require("@interrobang/iblib/lib/polygon.lua")
local dump = require("@interrobang/iblib/lib/dump_table.lua")

-- local points = {
--     vec2(0, 0),
--     vec2(1, 0),
--     vec2(0, 1),
--     vec2(1, 1),
-- }

-- local points = {
--     vec2(-1,0),
--     vec2(0,1),
--     vec2(1,0),
--     vec2(0,0),
--     vec2(1,-1),
--     vec2(0,-1),
--     vec2(1,-0.5),
-- }

-- print(dump(polygon.find_intersections_of_points(points)))

-- local shape = {
--     shape_type = "polygon",
--     points = points,
-- }

-- local object = Scene:add_polygon{
--     position = vec2(0, 0),
--     points = points,
--     color = Color:rgb(1, 0, 0),
--     body_type = BodyType.Dynamic,
-- }
