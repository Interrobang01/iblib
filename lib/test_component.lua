local function iblib_test_component(name)
    local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
    local initialize_component = iblib("initialize_component")
    local component = initialize_component(iblib(name))

    local box = Scene:add_box{
        position = vec2(0,0),
        size = vec2(1,1),
        color = 0xe5d3b9,
        is_static = false,
    }
    box:add_component(component)
end

return iblib_test_component
