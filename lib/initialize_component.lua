--[[
Takes in a component code string, initializes the component with a filler name, id, and version, and returns the hash.

INPUTS:
- string, the component code

OUTPUTS:
- string, the component hash (for :add_component())
--]]

local function iblib_initialize_component(code)
    if type(code) ~= "string" then
        return nil
    end

    local component = Scene:add_component{
        name = "iblib_temp_name",
        id = "iblib_temp_id",
        version = "0.1.0",
        code = code,
    }
    return component
end

return iblib_initialize_component
