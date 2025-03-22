--[[
example usage:

local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")

INPUTS:
- string, the name of the iblib lib you want to load

OUTPUTS:
- string or function, the function or component you wanted
--]]

local function iblib(name)
    if type(name) ~= "string" then
        name = tostring(name)
    end
    if name:sub(-4) == ".lua" then
        name = name:sub(1, -4)
    end
    print("Loading iblib function '"..name.."'")
    
    local lib = nil
    
    if pcall(function()
---@diagnostic disable-next-line: redundant-parameter
        lib = require("./packages/@interrobang/iblib/lib/components/"..name..".lua", "string")
    end) then
        return lib
    elseif pcall(function()
        lib = require("./packages/@interrobang/iblib/lib/"..name..".lua")
    end) then
        return lib
    else
        print("Error: Could not load iblib function '"..name.."'")
        return nil
    end
end

return iblib
