--[[
Use with electicity_carrier. Object must have electricity_carrier.
--]]

local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
local dump = iblib("dump_table")
local split = iblib("split_string")
local line = iblib("line")
local initialize_component = iblib("initialize_component")
local delete_next_step = initialize_component(iblib("delete_next_step"))
local linear_algebra = iblib("linear_algebra")
local nodal_analysis = iblib("nodal_analysis")

local received_data = nil
local self_guid = self.guid

local voltage = 64

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_return_ping" then
        received_data  = data
    end
end



local function visualize_node(node, battery_negative_guid)
    local angle = 1.197*node
    local radius = 0.3
    if battery_negative_guid ~= nil then
        radius = 0.5
    end
    local node_obj = Scene:add_circle{
        position = (vec2(math.cos(angle), math.sin(angle)) * 10) + vec2(self_guid*25-450,20),
        radius = 0.3,
        color = 0xffffff,
        is_static = true,
    }
    node_obj:add_component(delete_next_step)
    return node_obj
end

local function visualize_graph(graph)
    local pi = math.pi
    local physical_node_graph = {}
    for i, v in pairs(graph) do
        physical_node_graph[i] = visualize_node(i, v.battery_negative_guid)
    end
    for i, v in pairs(graph) do
        --print("this is "..tonumber(i))
        --print(dump(v))
        for k, m in pairs(v.neighbors) do
            if physical_node_graph[k] == nil then
                physical_node_graph[k] = visualize_node(k, v.battery_negative_guid)
            end
            if v.battery_negative_guid ~= nil and physical_node_graph[v.battery_negative_guid] == nil then
                physical_node_graph[v.battery_negative_guid] = visualize_node(v.battery_negative_guid, v.battery_negative_guid)
            end
            local p1 = physical_node_graph[i]:get_position()
            local p2 = (physical_node_graph[k]:get_position() + p1)/2
            local args = line(p1, p2)
            args.color = Color:rgb(m, m, 128)
            args.is_static = true
            local box = Scene:add_box(args)
            box:set_angle(args.rotation)
            box:add_component(delete_next_step)
            if v.battery_negative_guid ~= nil and physical_node_graph[v.battery_negative_guid] ~= nil then
                local p1 = physical_node_graph[i]:get_position()
                local p2 = physical_node_graph[v.battery_negative_guid]:get_position()
                local args = line(p1, p2)
                args.color = Color:rgb(m, m, 255)
                args.is_static = true
                local box = Scene:add_box(args)
                box:set_angle(args.rotation)
                box:add_component(delete_next_step)
            end
        end
    end
end

local function get_object_data(object) -- gets object contacts and properties, also does deseralization
    received_data = {}
    object:send_event("@interrobang/iblib/electricity_ping", {
        voltage = voltage,
        sender = self_guid,
    })
    if received_data.hits ~= nil then
        received_data.hits = split(received_data.hits, ",")
    end

    return received_data
end

local function search(start)
    start = tostring(start)
    local queue = {start}
    local visited = {[start] = true}
    local graph = {}

    while #queue > 0 do
        local node = table.remove(queue, 1)
        visited[node] = true
        --print("yer node is "..tostring(node))
        graph[node] = {}
        graph[node].neighbors = {}
        local data = get_object_data(Scene:get_object_by_guid(node))
        graph[node].battery_id = data.battery_id
        graph[node].is_positive_battery = data.is_positive_battery
        if data.hits ~= nil then
            --print("wow you have "..tostring(#data.hits).." hits")
            for _, neighbor in ipairs(data.hits) do
                --print("we are on "..tostring(neighbor))
                local neighbor_data = get_object_data(Scene:get_object_by_guid(neighbor))
                if neighbor_data.resistance ~= nil then
                    graph[node].neighbors[neighbor] = neighbor_data.resistance + data.resistance
                    if neighbor_data.resistance ~= nil and not visited[neighbor] then
                        table.insert(queue, neighbor)
                    end
                end
            end
        end
    end

    return graph
end

local last_graph = nil
function on_step()
    local graph = {}
    --[[
    graph of the local circuit topology
    looks like this
{ -- graph
    { -- node
    [neighbors] = {
        1 = 5, -- connection
        2 = 5, -- connection
    }
    [voltage] = -5
    },
}
    --]]

    
    --print("im doing "..tostring(min_guid))
    graph = search(self_guid)
    if Input:key_just_pressed("A") then
        print(dump(graph))
    end
    --print"graph"
    --print(dump(graph))
    --print"visited"
    --print(dump(visited))
    visualize_graph(graph)

    local serialized_graph = dump(graph)

    if last_graph ~= serialized_graph then
        local voltages = nodal_analysis(graph, linear_algebra)
        for node, voltage in pairs(voltages or {}) do
            Console:log("Node " .. node .. ": Voltage = " .. voltage .. " V")
        end
    end
    last_graph = serialized_graph
    print("goob")
end
