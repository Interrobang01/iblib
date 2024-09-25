--[[
Given a line start, a line end, and an optional thickness, returns a table containing the table.position, table.size, and table.rotation values needed to make a line going between the line start and line end.
INPUTS:
- vec2, the start of the line
- vec2, the end of the line
- number, the thickness of the line (optional, default 0.1)
OUTPUTS:
- a table containing the following indexes: position, size, rotation
--]]

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
