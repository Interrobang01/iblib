--[[
Makes the object release small particles on collision.
--]]

local particle_component = Scene:add_component_def{
    name = "Particle",
    id = "@interrobang/iblib/particle",
    version = "0.1.0",
    code = [[
local base_alpha = 255
function on_step()
    local color = self:get_color()
    local alpha = color.a
    alpha = alpha - 10
    if alpha < 0 then
        self:destroy()
        return
    end
    self:set_color(Color:rgba(color.r,color.g,color.b,alpha))
end
]]}

local function make_particle(pos)
    local particle = Scene:add_circle{
        position = pos,
        radius = math.random()*0.05,
        color = 0xffffff,
        is_static = false,
    }
    particle:set_body_type(BodyType.Kinematic)
    particle:temp_set_collides(false)
    particle:set_linear_velocity(vec2(math.random()-0.5,math.random()-0.5))
    particle:add_component({hash=particle_component})
end

function on_collision_start(data)
    for i = 1, #data.points do
        -- sometimes the second point isn't actually colliding so we have to check for that
        local circle = Scene:get_objects_in_circle{
            radius = 0.05,
            position = data.points[i],
        }
        if #circle > 1 then
            make_particle(data.points[i])
        end
    end
end

function on_event(id, data)
    if id == "@interrobang/iblib/release_particle" then
        make_particle(data.point)
    end
end
