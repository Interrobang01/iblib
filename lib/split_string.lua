--[[
Python string split but in lua. Code courtesy of stackoverflow.

INPUTS:
- string, the string to test
- string, the separator; if it's longer than one character it'll treat them all as different separators and add them up, sort of like using an OR instead of an AND

OUTPUTS:
- table of strings, all the split substrings
--]]

local function iblib_split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

return iblib_split
