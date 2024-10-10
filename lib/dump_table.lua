--[[
Returns the input table in a form easily printable to console. Function courtesy of stackoverflow.

INPUTS:
- table, the table you want to dump

OUTPUTS:
- string, the table you want to dump but now easily printable
--]]

local function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return dump
