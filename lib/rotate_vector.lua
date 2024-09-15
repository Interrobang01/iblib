local function iblib_rotate_vector(vector,angle)
    local magnitude = vector:magnitude()
    local current_angle = math.atan2(vector.y,vector.x)
    local new_angle = current_angle + angle
    local new_vector = vec2(math.cos(new_angle),math.sin(new_angle)) * magnitude
    return new_vector
end

return iblib_rotate_vector
