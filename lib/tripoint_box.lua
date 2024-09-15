local function tripoint_box(line_start,line_end,line_extension)

    -- declaring functions might be inefficient but uhhhh shut up it's a stylistic choice
    local function points_to_standard_form(p1,p2)
        local a = p2.y-p1.y
        local b = p1.x-p2.x
        local c = p1.y*(p2.x-p1.x)-(p2.y-p1.y)*p1.x
        return {a=a,b=b,c=c}
    end
    
    local function distance_from_line_to_point(a,b,c,p)
        return math.abs(a*p.x+b*p.y+c)/math.sqrt(a^2+b^2)
    end
    
    local function closest_point_on_line_to_point(a,b,c,point)
        local denominator = a^2+b^2
        local x = (b*(b*point.x-a*point.y)-a*c)/denominator
        local y = (a*(-b*point.x+a*point.y)-b*c)/denominator
        return vec2(x,y)
    end
    
    local function midpoint(p1,p2)
        return (p1+p2)/2
    end

    -- https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
    local line = points_to_standard_form(line_start,line_end)
    local sy = distance_from_line_to_point(line.a,line.b,line.c,line_extension)
    local altitude_intersection = closest_point_on_line_to_point(line.a,line.b,line.c,line_extension)
    local edge_midpoint = midpoint(line_start,line_end)
    local altitude_midpoint = midpoint(altitude_intersection,line_extension)
    local pos = altitude_midpoint + (edge_midpoint-altitude_intersection)
    local sx = (line_start-line_end):magnitude()
    local relative_line_end = line_end-line_start
    local rotation = math.atan(relative_line_end.y/relative_line_end.x)

    return {
        position = pos,
        size = vec2(sx,sy),
        rotation = rotation,
    }
end

return tripoint_box
