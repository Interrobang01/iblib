--[[
Solves for the voltages of an electrical circuit.

INPUTS:
- table, a table of the circuit with a very specific format and structure that I won't get into here
- table, the linear_algebra.lua library

OUTPUTS:
- table of numbers, the resulting voltages
--]]

-- Uses algorithm detailed here http://lpsa.swarthmore.edu/Systems/Electrical/mna/MNA3.html 
local function iblib_nodal_analysis(circuit, iblib_linear_algebra)
    iblib_linear_algebra = iblib_linear_algebra or require("./packages/@interrobang/iblib/lib/linear_algebra.lua") -- requires it if user forgets. laggier, probably.
    local dump = require("./packages/@interrobang/iblib/lib/dump_table.lua") -- only temporary

    -- Step 1: Create a node list and map node names to indices.
    Console:log("Step 1: Create a node list and map node names to indices.")
    local voltage_sources = {} -- [1] is positive side, [2] is negative side
    local ground = nil

    local indexed_circuit = {} -- needed for matricies to make sense.
    -- length will be number of nodes minus one because of zero-indexing
    -- index 0 is ground

    local index_to_guid_map = {} -- to go from indexed_circuit indexes to guids
    local guid_to_index_map = {}

    for node, data in pairs(circuit) do
        local circuit_index = #indexed_circuit + 1
        if indexed_circuit[0] == nil and data.is_positive_battery == false then
            circuit_index = 0
        end
        Console:log(node, dump(data), circuit_index)
        indexed_circuit[circuit_index] = data
        index_to_guid_map[circuit_index] = node
        guid_to_index_map[node] = circuit_index

        -- get voltage sources
        if data.battery_id ~= nil then
            local voltage_source_index = nil
            if data.is_positive_battery then
                voltage_source_index = 1
            else
                voltage_source_index = 2
            end
            voltage_sources.battery_id = voltage_sources.battery_id or {}
            voltage_sources.battery_id[voltage_source_index] = circuit_index
        end
    end

    -- index voltage sources properly
    local new_voltage_sources = {}
    for _, v in pairs(voltage_sources) do -- unlike nodes, indexes aren't meaningful here
        new_voltage_sources[#new_voltage_sources + 1] = v
    end
    voltage_sources = new_voltage_sources
    new_voltage_sources = nil -- clean up

    -- transparency
    Console:log("Logging indexed circuit:")
    Console:log("Indexed circuit:")
    Console:log(dump(indexed_circuit))
    Console:log("Indexed circuit length:")
    Console:log(#indexed_circuit)
    Console:log("index-to-guid:")
    Console:log(dump(index_to_guid_map))
    Console:log("guid-to-index:")
    Console:log(dump(guid_to_index_map))
    Console:log("voltage sources:")
    Console:log(dump(voltage_sources))

    if indexed_circuit[0] == nil then
        Console:log("ground not found!")
        return nil
    end

    -- change neighbors in data to new indexes
    for i = 0, #indexed_circuit do -- #indexed_circuit is one less than the number of nodes because it is zero-indexed
        local new_neighbor_table = {} -- will be indexed correctly
        for node_guid, resistance in pairs(indexed_circuit[i].neighbors) do
            if resistance == 0 then
                resistance = 1 -- otherwise results in dividing by zero and I don't want to implement node merging right now
            end
            new_neighbor_table[guid_to_index_map[node_guid]] = resistance
        end
        indexed_circuit[i].neighbors = new_neighbor_table
    end


    -- Step 2: Set up the conductance matrix (A) and the current and voltage vector (z)
    Console:log("Step 2: Set up the conductance matrix (A) and the current and voltage vector (z)")
    local A = iblib_linear_algebra.create_matrix(#indexed_circuit + #voltage_sources)
    local z = iblib_linear_algebra.create_vector(#indexed_circuit + #voltage_sources) -- known quantities
    -- Ax = z, where x is the unknown quantities

    -- Step 3: Make G matrix
    Console:log("Step 3: Make G matrix")
    for x = 1, #indexed_circuit do
        for y = 1, #indexed_circuit do
            if x == y then -- diagonal
                local conductance_sum = 0
                local node = indexed_circuit[x]
                for neighbor, resistance in pairs(node.neighbors) do
                    conductance_sum = conductance_sum + (1/resistance)
                end
                A[x][y] = conductance_sum
            else
                local resistance = indexed_circuit[x].neighbors[y] -- won't be 0 (ground) because indexing starts at 1
                if resistance ~= nil then -- iff this is an actual connection it won't be nil
                    local conductance = 1/resistance
                    A[x][y] = -conductance
                else
                    A[x][y] = 0
                end
            end
        end
    end

    Console:log(dump(A))

    -- Step 4: Make B and C matricies
    Console:log("Step 4: Make B and C matricies")
    for m = 1, #voltage_sources do
        for i = 1,2 do
            local node = voltage_sources[m][i]
            if node ~= 0 then
                local value = 0
                if i == 1 then
                    value = 1
                elseif i == 2 then
                    value = -1
                end
                A[m + #indexed_circuit][node] = value -- B matrix
                A[node][m + #indexed_circuit] = value -- C matrix
            end
        end
    end

    Console:log(dump(A))

    -- Step 5: Make D matrix
    Console:log("Step 5: Make D matrix")
    
    -- unneeded since all voltage sources are independent

    -- Step 6: Make x matrix
    Console:log("Step 6: Make x matrix")
    -- everything is unknown so we can't actually do anything; that's the matrix solver's job

    -- Step 7: Make i matrix (part of z matrix)
    Console:log("Step 7: Make i matrix (part of z matrix)")
    -- Current sources aren't planned so this is unneeded

    -- Step 8: Make e matirx (part of z matrix)
    Console:log("Step 8: Make e matirx (part of z matrix)")
    for i = #indexed_circuit+1, #indexed_circuit + #voltage_sources do
        z[i] = 8
    end

    -- Step 9: Solve the linear system A * x = z to get node voltages
    Console:log("Step 9: Solve the linear system A * x = z to get node voltages")

    local x = iblib_linear_algebra.solve_system(A, z)

    -- Step 10: Return the node voltages in a readable format
    Console:log("Step 10: Return the node voltages in a readable format")
    local voltages = {}
    for i = 0, #indexed_circuit do
        voltages[index_to_guid_map[i]] = x[i] or 0
    end

    return voltages
end


-- Example circuit graphs
-- local circuit_1 = 
-- { ["13"] = { ["neighbors"] = { ["16"] = 65,["17"] = 65,} ,} ,["16"] = { ["neighbors"] = { ["13"] = 65,} ,["battery_id"] = 1,["is_positive_battery"] = false,} ,["17"] = { ["neighbors"] = { ["13"] = 65,} ,["battery_id"] = 1,["is_positive_battery"] = true,} ,} 
-- local circuit_2 = 
-- { ["14"] = { ["neighbors"] = { ["15"] = 128,["17"] = 65,} ,} ,["15"] = { ["neighbors"] = { ["14"] = 128,["16"] = 65,} ,} ,["16"] = { ["neighbors"] = { ["11"] = 65,["15"] = 65,} ,["battery_id"] = 1,["is_positive_battery"] = false,} ,["17"] = { ["neighbors"] = { ["14"] = 65,["11"] = 65,} ,["battery_id"] = 1,["is_positive_battery"] = true,} ,["11"] = { ["neighbors"] = { ["16"] = 65,["17"] = 65,} ,} ,} 

return iblib_nodal_analysis
