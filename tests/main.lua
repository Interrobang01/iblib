-- File to test whatever is currently being worked on
-- Once the feature is done it will be moved into its own file.

local shatter = require("@interrobang/iblib/lib/shatter_object.lua")

local object = Scene:add_box{
    position = vec2(0, 0),
    size = vec2(1, 1),
    color = Color:rgb(1, 0, 0),
    body_type = BodyType.Dynamic,
}

local new_objects = shatter(object)



