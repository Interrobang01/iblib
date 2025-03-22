--[[
Functions for converting to and from polygons, for use with polygon_boolean

Included functions:

    ["foo"]: Does foo

    ["bar"]: Does bar
]]--

local function iblib_points_to_polygon(shape)
    -- Converts a shape to a polygon
    local polygon = {}
    for _, point in ipairs(shape.points) do
        table.insert(polygon, {x = point.x, y = point.y})
    end
    return polygon
end

local function iblib_polygon_to_points(polygon)
    -- Converts a polygon to a shape
    local shape = {points = {}}
    for _, point in ipairs(polygon) do
        table.insert(shape.points, {x = point.x, y = point.y})
    end
    return shape
end

return {
    points_to_polygon = iblib_points_to_polygon,
    polygon_to_points = iblib_polygon_to_points
}
