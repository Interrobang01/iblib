--[[
Functions for converting to and from polygons, for use with polygon_boolean

Included functions:

    ["foo"]: Does foo

    ["bar"]: Does bar
]]--

local function iblib_shape_to_points(shape)
    -- Converts a shape to a list of points
    local points = {}
    if shape.shape_type == "polygon" then
        points = shape.points
    elseif shape.shape_type == "circle" then
        -- Lossy conversion for circles to points
        local num_points = 16 -- Number of points to approximate the circle
        for i = 0, num_points - 1 do
            local angle = (i / num_points) * (2 * math.pi)
            local x = shape.radius * math.cos(angle)
            local y = shape.radius * math.sin(angle)
            table.insert(points, vec2(x,y))
        end
    elseif shape.shape_type == "box" then
        -- Points are based on the size of the box
        local half_width = shape.size.x / 2
        local half_height = shape.size.y / 2
        points = {
            vec2(half_width, half_height),
            vec2(half_width, half_height),
            vec2(half_width, half_height),
            vec2(half_width, half_height)
        }
    else
        error("Unsupported shape type: " .. tostring(shape.shape_type))
    end
    return points
end

local function iblib_points_to_shape(points)
    -- Converts a list of points to a shape
    return {points = points, shape_type = "polygon"}
end

local function iblib_points_to_polygon(points, position)
    -- Converts vec2 points to a polygon
    local polygon = {}
    for _, point in ipairs(points) do
        table.insert(polygon, point.x + position.x)
        table.insert(polygon, point.y + position.y)
    end
    return polygon
end

local function iblib_polygon_to_points(polygon, position)
    -- Converts a polygon to a shape
    local points = {}
    for index, coordinate in ipairs(polygon) do
        if index % 2 == 1 then
            -- x coordinate
            table.insert(points, vec2(coordinate, 0))
        else
            -- y coordinate
            points[#points].y = coordinate
        end
    end
    if position == nil then
        -- Get average position if no position is provided
        local avg_x, avg_y = 0, 0
        for _, point in ipairs(points) do
            avg_x = avg_x + point.x
            avg_y = avg_y + point.y
        end
        local num_points = #points
        if num_points > 0 then
            avg_x = avg_x / num_points
            avg_y = avg_y / num_points
        end
        position = vec2(avg_x, avg_y)
    end
    -- Adjust points based on the provided position
    for _, point in ipairs(points) do
        point = point - position
    end
    return points
end

local function shape_to_polygon(shape, position)
    -- Converts a shape to a polygon
    return iblib_points_to_polygon(iblib_shape_to_points(shape), position)
end

local function polygon_to_shape(polygon, position)
    -- Converts a polygon to a shape
    return iblib_points_to_shape(iblib_polygon_to_points(polygon, position))
end

return {
    shape_to_points = iblib_shape_to_points,
    points_to_shape = iblib_points_to_shape,
    points_to_polygon = iblib_points_to_polygon,
    polygon_to_points = iblib_polygon_to_points,
    shape_to_polygon = shape_to_polygon,
    polygon_to_shape = polygon_to_shape
}
