--[[
Given the name of an iblib component, creates a box with that component at (0,0) for testing purposes.

INPUTS:
- string/table, the name of the iblib component to test or a table of names to test
- vec2, optional, the size of the box
--]]

local function iblib_test_component(name,size)
    local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
    local initialize_component = iblib("initialize_component")
    local components = {}
    if type(name) == "string" then
        components[1] = initialize_component(iblib(name))
    end
    if type(name) == "table" then
        for i,v in pairs(name) do
            components[i] = initialize_component(iblib(v))
        end
    end

    local box = Scene:add_box{
        position = vec2(0,0),
        size = size or vec2(1,1),
        color = 0xe5d3b9,
        is_static = false,
    }
    for i,v in pairs(components) do
        box:add_component(v)
    end
    return box
end

return iblib_test_component
