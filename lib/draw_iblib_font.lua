local function iblib_draw_iblib_font(text, location, pt)
    pt = pt or 1

    local font = require("./packages/@interrobang/iblib/lib/iblib_font.lua")
    local line = require("./packages/@interrobang/iblib/lib/line.lua")
    local text_vectors = font(text)

    local capsules = {}
    for i = 1, #text_vectors do
        local character = text_vectors[i]
        local character_location = location + vec2(1.5 * pt * i, 0)
        for n = 1, #character do
            local stroke = character[n]
            for k = 1, #stroke - 1 do
                local point_a = stroke[k] * pt
                local point_b = stroke[k+1] * pt
                local stroke_capsule = Scene:add_capsule{
                    position = character_location,
                    local_point_a = point_a,
                    local_point_b = point_b,
                    radius = pt/10,
                    is_static = true,
                    color = 0xffffff,
                }
                capsules[#capsules+1] = stroke_capsule
            end
        end
    end
    return capsules
end

return iblib_draw_iblib_font
