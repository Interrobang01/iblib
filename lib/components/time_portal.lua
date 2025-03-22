--[[
It's about time
--]]

local timeline = {}
local time_events = {} -- points to time events in timeline
local time_travel_distance = 50
local delay = 10
local margin = 7 -- how big a difference the difference_sum can be before it registers as a paradox


local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
local dump = iblib("dump_table")
local draw = iblib("draw_iblib_font")
local tripoint_box = iblib("tripoint_box")

local function copy_table(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copy_table(k, s)] = copy_table(v, s) end
    return res
end


-- list of lists of object guids belonging to the same object in different points in its timeline
local objects = {}


local function find_object_guid_in_objects(obj_guid)
    for i = 1, #objects do
        for n = 1, #objects[i] do
            if objects[i][n] == obj_guid then
                return i, n -- n probably not needed
            end
        end
    end
    return nil
end


-- add a guid to the objects list next to another guid
local function add_object_guid_to_existing_object(starting_guid, new_guid)
    -- check to see if new_guid is already in objects list
    if find_object_guid_in_objects(new_guid) ~= nil then
        Console:log("object with guid "..tostring(new_guid).." already in objects list (add_object_guid_to_existing_object)")
        return
    end
    local object_index = find_object_guid_in_objects(starting_guid)
    if object_index ~= nil then
        objects[object_index][#objects[object_index] + 1] = new_guid
    end
end

-- add a new object to the objects list
local function add_object_to_objects(obj_guid)
    -- check to see if it's not already in
    local object_index = find_object_guid_in_objects(obj_guid)
    if object_index ~= nil then
        Console:log("object with guid "..tostring(obj_guid).." already in objects list (add_object_to_objects)")
        return
    end
    objects[#objects + 1] = {obj_guid}
end


-- remove a guid to the objects list (because of object deletion)
local function remove_object_guid_from_objects(obj_guid)
    local object_index, guid_index = find_object_guid_in_objects(obj_guid)
    if object_index ~= nil and guid_index ~= nil then
        table.remove(objects[object_index], guid_index)
        if #objects[object_index] == 0 then
            table.remove(objects, object_index)
        end
    end
end


local function update_time_events_to_new_object_guid(obj_guid, old_obj_guid) -- new guid and guid which doesn't exist any more
    -- update time events to point to new object
    for _,time_event_time_and_index in pairs(time_events) do
        Console:log("checking time event at "..tostring(time_event_time_and_index[1]).." with index "..tostring(time_event_time_and_index[2]))
        if timeline[time_event_time_and_index[1]][time_event_time_and_index[2]].obj[7] == old_obj_guid then
            if Scene:get_object_by_guid(timeline[time_event_time_and_index[1]][time_event_time_and_index[2]].obj[7]) == nil then
                
                timeline[time_event_time_and_index[1]][time_event_time_and_index[2]].obj[7] = obj_guid
                Console:log("updated guid from "..tostring(old_obj_guid).." to "..tostring(obj_guid))
            end
        end
    end
end

local function save_object(obj)
    local obj_pos = obj:get_position()
    local obj_vel = obj:get_linear_velocity()
    local obj_angle = obj:get_angle()
    local obj_rot_vel = obj:get_angular_velocity()
    local obj_color = obj:get_color()
    local obj_shape = obj:get_shape()


    if obj_vel.x == 1/0 then
        Console:log("oopsie")
    end

    add_object_to_objects(obj.guid)

    local saved_object = {obj_pos, obj_vel, obj_angle, obj_rot_vel, obj_color, obj_shape, obj.guid}
    return saved_object
end

local function load_object(saved_object, dont_update_time_events)
    local obj = Scene:add_box{
        position = vec2(100, 100),
        size = vec2(1, 1),
        color = 0xe5d3b9,
        is_static = false,
    }

    obj:set_position(saved_object[1])
    obj:set_linear_velocity(saved_object[2])
    obj:set_angle(saved_object[3])
    obj:set_angular_velocity(saved_object[4])
    --obj:set_color(Color:rgba(saved_object[5].r-100, saved_object[5].g, saved_object[5].b, saved_object[5].a))
    obj:set_color(saved_object[5])
    obj:set_shape(saved_object[6])

    if saved_object[2].x == 1/0 then
        Console:log("oopsie")
    end

    add_object_guid_to_existing_object(saved_object[7], obj.guid)

    Console:log("loaded object:")
    Console:log(dump(saved_object))

    return obj
end

local function save_scene()
    local scene = Scene:get_all_objects()
    local saved_scene = {}
    for i = 1, #scene do
        if scene[i]:get_body_type() ~= BodyType.Static and scene[i]:get_name() ~= "Particle" then
            local obj = scene[i]
            local obj_guid = obj.guid
            local obj_pos = obj:get_position()
            local obj_vel = obj:get_linear_velocity()
            local obj_angle = obj:get_angle()
            local obj_rot_vel = obj:get_angular_velocity()
            local obj_color = obj:get_color()
            local obj_shape = obj:get_shape()
            saved_scene[obj_guid] = {obj_pos, obj_vel, obj_angle, obj_rot_vel, obj_color, obj_shape, obj.guid}
        end
    end
    return saved_scene
end

local function load_scene(saved_scene, current_scene)
    for i,v in pairs(saved_scene) do
        local obj = Scene:get_object_by_guid(i)
        if obj == nil then
            obj = load_object(v)
        else
            obj:set_position(v[1])
            obj:set_linear_velocity(v[2])
            obj:set_angle(v[3])
            obj:set_angular_velocity(v[4])
        end
    end
    
    -- delete all objects in current_scene that aren't in saved_scene
    if current_scene ~= nil then
        for i, _ in pairs(current_scene) do
            if saved_scene[i] == nil then
                Console:log("destroying object with guid "..tostring(i))
                local obj = Scene:get_object_by_guid(i)
                if obj ~= nil then
                    obj:destroy()
                end
            end
        end
    else
        Console:log("current_scene is nil")
    end
end


local function get_object_difference(saved_object_1, saved_object_2)
    Console:log("comparing objects")
    Console:log(dump(saved_object_1))
    Console:log(dump(saved_object_2))
    local difference_sum = 0
    difference_sum = difference_sum + (saved_object_1[1] - saved_object_2[1]):magnitude()
    difference_sum = difference_sum + (saved_object_1[2] - saved_object_2[2]):magnitude()
    difference_sum = difference_sum + math.abs(saved_object_1[3] - saved_object_2[3])
    difference_sum = difference_sum + math.abs(saved_object_1[4] - saved_object_2[4])

    return difference_sum
end

local function make_particle(pos)
    local particle = Scene:add_circle{
        position = pos,
        radius = math.random()*0.5,
        color = 0xffffff,
        is_static = false,
    }
    particle:set_body_type(BodyType.Kinematic)
    particle:temp_set_collides(false)
    particle:set_linear_velocity(vec2(math.random()-0.5,math.random()-0.5) * 20)
    particle:set_name("Particle")
    return particle
end

local selves = {self}
function on_start()

    -- initialize selves table by getting all objects named "Time Portal"
    local all_objects = Scene:get_all_objects()
    for i = 1, #all_objects do
        if all_objects[i]:get_name() == "Time Portal" then
            selves[#selves + 1] = all_objects[i]
        end
    end

    for i = 1, #selves do
    
        selves[i]:set_body_type(BodyType.Static)
        selves[i]:temp_set_collides(false)
    end

    -- add open_portal event to time_travel_distance to prevent things from bouncing off the beginning of time
    timeline[time_travel_distance] = {portal_open = true}
end

local time = 0

local function add_timeline_event(event_time, event)
    if type(timeline[event_time]) ~= "table" then
        timeline[event_time] = {}
    end
    timeline[event_time][#timeline[event_time] + 1] = event
end

local function handle_contact(obj)
    local time_event = {type = "time_event"}
    local time_event_time = time
    local saved_obj = save_object(obj)
    time_event.obj = saved_obj
    
    -- close time portal around time event
    for i = time-delay, time+delay do
        if type(timeline[i]) ~= "table" then
            timeline[i] = {}
        end
        timeline[i].portal_open = false
    end
    if type(timeline[time+delay+1]) ~= "table" then
        timeline[time+delay+1] = {}
    end
    timeline[time+delay+1].portal_open = true
    
    local pre_event_timeline = {}
    for i = time - time_travel_distance, time - 1 do
        pre_event_timeline[i] = copy_table(timeline[i])
    end

    time_event.pre_event_timeline = pre_event_timeline
    time_event.original_scene = save_scene()
    time = time - time_travel_distance

    -- close time portal around object creation event to prevent recursion
    for i = time-delay, time+delay do
        if type(timeline[i]) ~= "table" then
            timeline[i] = {}
        end
        timeline[i].portal_open = false
    end

    
    local could_find_scene = false
    for i = 0, time_travel_distance do
        if timeline[time] ~= nil then
            if timeline[time].scene ~= nil then
                could_find_scene = true
                Console:log("found scene at "..tostring(time))
                load_scene(timeline[time].scene, timeline[time_event_time].scene)
                break
            end
        end
        time = time + 1
    end
    if could_find_scene then
        add_timeline_event(time_event_time, time_event)
        table.insert(time_events, 1, {time_event_time, #timeline[time_event_time]})
        Console:log("time event at "..tostring(time_event_time).." with index "..tostring(#timeline[time_event_time]))
        add_timeline_event(time, {
            type = "spawn_event",
            saved_obj = saved_obj,
            time_event_time = time_event_time,
            time_event_index = #timeline[time_event_time]
        })
        print("moved from "..tostring(time_event_time).." to "..tostring(time))
    end
end

local clock_strokes = {}
local timeline_strokes = {}
local timeline_horizontal_compression = 100
local function visualize_timeline(timeline)

    -- clean up last frame
    for i,v in pairs(clock_strokes) do
        v:destroy()
    end
    for i,v in pairs(timeline_strokes) do
        v:destroy()
    end

    clock_strokes = draw(tostring(time), vec2(-20,20), 1)

    timeline_strokes = {}
    local previous_moment_portal_open = false
    local last_timeline_line = 0
    for i,v in ipairs(timeline) do
        if type(v) == "table" then
            for n,event in ipairs(v) do
                local x = i/timeline_horizontal_compression
                local y = n+30
                local args = tripoint_box(vec2(x, y), vec2(x+0.25, y), vec2(x, y+0.9))
                args.is_static = true
                if event.type == "time_event" then
                    args.color = 0x00FF00 -- green
                elseif event.type == "spawn_event" then
                    args.color = 0xFF00FF -- purple
                end
                timeline_strokes[# timeline_strokes+1] = Scene:add_box(args)
            end
        end
        if v.portal_open ~= nil then
            if v.portal_open ~= previous_moment_portal_open or i == time then
                local x1 = i/timeline_horizontal_compression
                local x2 = last_timeline_line/timeline_horizontal_compression
                local y = 30
                local args = tripoint_box(vec2(x1, y), vec2(x2+(1/timeline_horizontal_compression), y), vec2(x1, y+0.1))
                args.is_static = true
                if previous_moment_portal_open then
                    args.color = 0x00FF00 -- green
                else
                    args.color = 0xFF0000 -- red
                end
                timeline_strokes[# timeline_strokes+1] = Scene:add_box(args)
                last_timeline_line = i
            end
            previous_moment_portal_open = v.portal_open
        end
    end

    local current_time_ticker_args = tripoint_box(vec2(time/timeline_horizontal_compression, 30-2), vec2(time/timeline_horizontal_compression+0.1, 30-2), vec2(time/timeline_horizontal_compression, 30))
    current_time_ticker_args.is_static = true
    current_time_ticker_args.color = 0x000000
    timeline_strokes[# timeline_strokes+1] = Scene:add_box(current_time_ticker_args)

    local time_travel_distance_indicator_args = tripoint_box(vec2((time-time_travel_distance)/timeline_horizontal_compression, 30-2), vec2((time-time_travel_distance)/timeline_horizontal_compression+0.05, 30-2), vec2((time-time_travel_distance)/timeline_horizontal_compression, 30-1.5))
    time_travel_distance_indicator_args.is_static = true
    time_travel_distance_indicator_args.color = 0x00FF00
    timeline_strokes[# timeline_strokes+1] = Scene:add_box(time_travel_distance_indicator_args)
end


local function search_for_contact()
    for i = 1, #selves do
        selves[i]:set_angle(selves[i]:get_angle() + 0.01)
        
        local surroundings = Scene:get_objects_in_circle{
            position = selves[i]:get_position(),
            radius = 3,
        }
        for _, v in pairs(surroundings) do
            if v:get_body_type() ~= BodyType.Static then
                handle_contact(v)
                return
            end
        end
    end
end


function on_step()
    time = time + 1
    if type(timeline[time]) ~= "table" then
        timeline[time] = {}
    end
    timeline[time].scene = save_scene()

    if timeline[time].portal_open == nil then
        -- open portal if previous moment had it open
        if timeline[time - 1] ~= nil and timeline[time - 1].portal_open then
            timeline[time].portal_open = true
        else
            timeline[time].portal_open = false
        end
    end

    if timeline[time].portal_open then
        search_for_contact()
    end

    if #timeline[time] ~= 0 then
        for i,v in ipairs(timeline[time]) do
            if v.type == "spawn_event" then
                print("spawn event spotted")
                local obj = load_object(v.saved_obj)
                --timeline[v.time_event_time][v.time_event_index].post_event_obj_guid = obj.guid
                --Console:log("time is "..tostring(time)..", post event obj guid "..tostring(v.post_event_obj_guid))
            elseif v.type == "time_event" then
                print("time event spotted")
                Console:log(dump(objects))
                local smallest_difference_sum = 1000
                local smallest_difference_sum_object = nil
                local objects_index = find_object_guid_in_objects(v.obj[7])
                if objects_index ~= nil then
                    for guid_index = 1, #objects[objects_index] do
                        local object = Scene:get_object_by_guid(objects[objects_index][guid_index])
                        if object ~= nil then
                            
                            local difference_sum = get_object_difference(v.obj, save_object(object))
                            if difference_sum < smallest_difference_sum then
                                smallest_difference_sum = difference_sum
                                smallest_difference_sum_object = object
                            end
                        end
                    end
                end
                Console:log("entering object guid should be "..tostring(v.obj[7]))
                print("difference_sum is "..tostring(smallest_difference_sum))
                if smallest_difference_sum < margin and smallest_difference_sum_object ~= nil then
                    print("similar, destroying entering object")
                    smallest_difference_sum_object:destroy()
                else
                    print("dissimilar")
                    Console:log("ddkjhd " ..tostring(v.post_event_obj_guid))
                    Console:log(dump(time_events))
                    local last_time_event_time_and_index = table.remove(time_events, 1)
                    Console:log("last time event time "..tostring(last_time_event_time_and_index[1]).." with index "..tostring(last_time_event_time_and_index[2]))
                    local time_event = table.remove(timeline[last_time_event_time_and_index[1]], last_time_event_time_and_index[2])

                    load_scene(time_event.original_scene, timeline[time].scene)
                    for i,v in pairs(time_event.pre_event_timeline) do
                        timeline[i] = copy_table(v)
                    end
                    time = last_time_event_time_and_index[1]

                    break
                end
            end
        end
    end

    if Input:key_just_pressed("Q") then
        Console:log("dumping timeline")
        Console:log(dump(timeline))
    end

    visualize_timeline(timeline)
end

--[==[
        if v:get_body_type() ~= BodyType.Static and not portal_blacklist[v.guid] then
            saved_obj = save_object(v)
            original_timeline = {scene = save_scene(), time = time}
            testing_timeline = true
            testing_timeline_time = 0
            effective_buffer_size = math.min(#buffer, time_travel_distance)
            load_scene(buffer[effective_buffer_size].scene)
            time = buffer[effective_buffer_size].time
            for i = 1, effective_buffer_size do
                table.remove(buffer, 1)
            end
            testing_timeline_object_guid = load_object(saved_obj).guid
            portal_blacklist[v.guid] = time + delay
            portal_blacklist[testing_timeline_object_guid] = time + delay
            --[[
            for i = 1, 10 do
                particle_list[#particle_list+1] = make_particle(saved_obj[1])
            end
            particles_inverted = false]]
        end
    if testing_timeline then
        testing_timeline_time = testing_timeline_time + 1
        if testing_timeline_time >= effective_buffer_size then
            --[[
            for i = 1, #particle_list do
                particle_list[i]:destroy()
            end
            particle_list = {}]]
            testing_timeline = false
            local tested_object = Scene:get_object_by_guid(saved_obj[7])
            local rounded_tested_object = round_saved_object(save_object(tested_object))
            local rounded_saved_object = round_saved_object(saved_obj)
            if dump(rounded_tested_object) == dump(rounded_saved_object) then
                testing_timeline = false
                tested_object:destroy()
            else
                Scene:get_object_by_guid(testing_timeline_object_guid):destroy()
                load_scene(original_timeline.scene)
                time = original_timeline.time
            end
        end
        --[[
        if testing_timeline_time > effective_buffer_size/2 and particles_inverted == false then
            print("inverting...")
            for i = 1, #particle_list do
                particle_list[i]:set_linear_velocity(particle_list[i]:get_linear_velocity() * -1)
                particles_inverted = true
            end
        end]]
        Scene.background_color = 0x382d3d
    else
        Scene.background_color = 0x34213d
    end

    for i,v in pairs(portal_blacklist) do
        if time > v then
            portal_blacklist[i] = nil
        end
    end
--]==]

