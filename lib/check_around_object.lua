--[[
Returns a table of all the objects within a set distance of another object, sort of like a forcefield. Used for checking contact. Doesn't work with circles, use get_objects_in_circle() instead.

INPUTS:
- object, the object you want to test
- table of objects, all the hits
--]]

function dump(o)
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
 

local function iblib_check_around_object(object,distance)
    distance = distance or 0.05

    local shape = object:get_shape()
    local extended_points = {}

    print(dump(shape.points))

    for i = 1, #shape.points do
        local point = shape.points[i]
        local extended_point = point:normalize() * (point:magnitude() + distance)
        extended_points[#extended_points+1] = object:get_world_point(extended_point)
    end
    print(dump(extended_points))

    local all_hits_keys = {} -- hits will be keys because otherwise you get duplicates
    for i = 1, #extended_points do
        local second_point = extended_points[i+1]
        if i == #extended_points then
            second_point = extended_points[1]
        end
        local direction = second_point - extended_points[i]
        local hits = Scene:raycast{
            origin = extended_points[i],
            direction = direction,
            distance = direction:magnitude(),
            closest_only = false,
        }
        print(extended_points[i],second_point)
        print(dump(hits))
        if #hits ~= 0 then
            for n = 1, #hits do
                all_hits_keys[hits[n].object] = true
            end
        end
    end

    local all_hits = {}
    local n = 0
    for i,v in pairs(all_hits_keys) do
        n = n + 1
        all_hits[n] = i
    end

    return all_hits
end

return iblib_check_around_object
