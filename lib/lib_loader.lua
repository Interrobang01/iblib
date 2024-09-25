--[[
example usage:
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
--]]

local function iblib(name)
    local is_component = false
    if type(name) ~= "string" then
        name = tostring(name)
    end
    if name:sub(-4) == ".lua" then
        name = name:sub(1, -4)
    end
    Console:log("Loading iblib function '"..name.."'")
    
    local lib = require("./packages/@interrobang/iblib/lib/"..name..".lua")
    if lib == nil then
        lib = require("./packages/@interrobang/iblib/lib/components/"..name..".lua", "string")
    end
    return lib
end

return iblib
