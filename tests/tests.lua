---- Run everything to make sure it works


local function run_tests()
    local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
    
    local function test_tripoint_box()
        local tripoint_box = iblib("tripoint_box")
        local result = tripoint_box(vec2(30,30), vec2(33,30), vec2(0,35))
        print("tripoint_box test complete")
    end
    
    local function test_iblib_font()
        local font = iblib("iblib_font")
        local test_text = "ABC"
        local strokes_table = font(test_text)
        print("iblib_font test complete, returned " .. #strokes_table .. " characters")
    end
    
    local function test_split_string()
        local split_string = iblib("split_string")
        local result = split_string("hello,world,test", ",")
        print("split_string test complete, split into " .. #result .. " parts")
    end
    
    local function test_is_point_in_polygon()
        local is_point_in_polygon = iblib("is_point_in_polygon")
        local polygon = {vec2(0,0), vec2(10,0), vec2(10,10), vec2(0,10)}
        local inside = is_point_in_polygon(vec2(5,5), polygon)
        local outside = is_point_in_polygon(vec2(15,15), polygon)
        print("is_point_in_polygon test complete, inside=" .. tostring(inside) .. ", outside=" .. tostring(outside))
    end
    
    local function test_test_component()
        local test_component = iblib("test_component")
        -- Testing with multiple components
        test_component({"maintain_x", "maintain_y"}, vec2(2,2))
        print("test_component test complete")
    end
    
    local function test_check_around_object()
        local check_around_object = iblib("check_around_object")
        -- This requires an actual object in the game
        print("check_around_object test skipped, requires game object")
    end
    
    local function test_rotate_vector()
        local rotate_vector = iblib("rotate_vector")
        local result = rotate_vector(vec2(1,0), math.pi/2)
        print("rotate_vector test complete")
    end
    
    local function test_linear_algebra()
        local linear_algebra = iblib("linear_algebra")
        local matrix = linear_algebra.create_matrix(3)
        local vector = linear_algebra.create_vector(3)
        
        -- Fill with test values
        for i=1,3 do
            vector[i] = i
            for j=1,3 do
                if i == j then
                    matrix[i][j] = 1
                else
                    matrix[i][j] = 0
                end
            end
        end
        
        local result = linear_algebra.solve_system(matrix, vector)
        print("linear_algebra test complete")
    end
    
    local function test_line()
        local line = iblib("line")
        local result = line(vec2(0,0), vec2(10,10), 0.5)
        print("line test complete")
    end
    
    local function test_initialize_component()
        local initialize_component = iblib("initialize_component")
        local component_code = "function step()\n  print('test')\nend"
        local hash = initialize_component(component_code)
        print("initialize_component test complete, hash=" .. hash)
    end
    
    local function test_graphs()
        local graphs = iblib("graphs")
        local g = graphs.create_graph()
        graphs.add_node(g, "A")
        graphs.add_node(g, "B")
        graphs.add_edge(g, "A", "B", 1)
        local path = graphs.bfs(g, "A", "B")
        local has_cycle = graphs.has_cycle(g)
        local is_connected = graphs.is_connected(g)
        print("graphs test complete")
    end
    
    local function test_dump_table()
        local dump_table = iblib("dump_table")
        local test_table = {a = 1, b = 2, c = {d = 3}}
        local dumped = dump_table(test_table)
        print("dump_table test complete")
    end
    
    local function test_components()
        local test_component = iblib("test_component")
        -- Test various components by loading them
        local components = {
            "curved",
            "maintain_x",
            "delete_next_step",
            "collision_particles",
            "maintain_y",
            "swirl",
            "hose",
            "gravity",
            "weird_world_origin"
        }
        
        local x_pos = 50
        for _, component_name in ipairs(components) do
            local component = iblib(component_name)
            print("Loaded component: " .. component_name)
            test_component(component_name, vec2(x_pos, 50))  -- Position them at x_pos, 50
            x_pos = x_pos + 5  -- Space them out if they get created in the world
        end
        print("Components test complete")
    end

    -- Run all tests
    print("Starting iblib tests...")
    test_tripoint_box()
    test_iblib_font()
    test_split_string()
    test_is_point_in_polygon()
    test_test_component()
    test_check_around_object()
    test_rotate_vector()
    test_linear_algebra()
    test_line()
    test_initialize_component()
    test_graphs()
    test_dump_table()
    test_components()
    print("All iblib tests completed!")
end

return run_tests
