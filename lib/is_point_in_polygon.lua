local function iblib_is_point_in_polygon(point,polygon)
    local numVertices = #polygon
    local inside = false

    -- Iterate over each edge of the polygon
    for i = 1, numVertices do
        local v1 = polygon[i]
        local v2 = polygon[(i % numVertices) + 1]

        -- Check if the point is on the line segment v1-v2
        local v1_x, v1_y = v1.x, v1.y
        local v2_x, v2_y = v2.x, v2.y
        local p_x, p_y = point.x, point.y

        if ((v1_y > p_y) ~= (v2_y > p_y)) and
           (p_x < (v2_x - v1_x) * (p_y - v1_y) / (v2_y - v1_y) + v1_x) then
            inside = not inside
        end
    end

    return inside
end

return iblib_is_point_in_polygon
