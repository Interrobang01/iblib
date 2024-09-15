local function iblib_line(line_start,line_end,thickness)
    local pos = (line_start+line_end)/2
    local sx = (line_start-line_end):magnitude()
    local relative_line_end = line_end-pos
    local rotation = math.atan(relative_line_end.y/relative_line_end.x)
    
    if thickness == nil then
        thickness = 0.1
    end
    return {
        position = pos,
        size = vec2(sx,thickness),
        rotation = rotation,
    }
end

return iblib_line
