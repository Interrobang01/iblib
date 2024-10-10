--[[
A bunch of random graph theory functions that ChatGPT 4o gave me. Untested, use with caution. Returns a table filled with functions, the indexes are listed below.

Included functions:

    create_graph: Create a new empty graph

    add_node: Add a node to the graph

    add_edge: Add an edge between two nodes (undirected by default)

    bfs: Breadth first search

    dfs: Depth first search

    dijkstra: Dijkstra's algorithm finds the shortest path between nodes in a weighted graph.

    has_cycle: Detecting cycles in an undirected graph is useful for ensuring graph structures like trees.

    is_connected: This function checks if the graph is fully connected (i.e., there is a path between any two nodes).
    
    topological_sort: Useful for scheduling tasks or resolving dependencies.

    find: Helper function to find a node's set in union-find structure
    
    union: Helper function to union two sets
    
    kruskal: Kruskal’s algorithm is used to find a minimum spanning tree for a graph.
    
--]]



-- Create a new empty graph
local function createGraph()
    return { adj = {} }
end

-- Add a node to the graph
local function addNode(graph, node)
    if not graph.adj[node] then
        graph.adj[node] = {}
    end
end

-- Add an edge between two nodes (undirected by default)
local function addEdge(graph, u, v, weight)
    weight = weight or 1
    if not graph.adj[u] then addNode(graph, u) end
    if not graph.adj[v] then addNode(graph, v) end
    table.insert(graph.adj[u], {node = v, weight = weight})
    table.insert(graph.adj[v], {node = u, weight = weight})  -- Remove for directed graph
end

local function bfs(graph, start)
    local queue = {start}
    local visited = {[start] = true}
    
    while #queue > 0 do
        local node = table.remove(queue, 1)
        
        for _, neighbor in ipairs(graph.adj[node]) do
            if not visited[neighbor.node] then
                visited[neighbor.node] = true
                table.insert(queue, neighbor.node)
            end
        end
    end
end

local function dfs(graph, start, visited)
    visited = visited or {}
    visited[start] = true
    
    for _, neighbor in ipairs(graph.adj[start]) do
        if not visited[neighbor.node] then
            dfs(graph, neighbor.node, visited)
        end
    end
end

local function dijkstra(graph, source)
    local dist = {}
    local visited = {}
    local pq = {}

    for node, _ in pairs(graph.adj) do
        dist[node] = math.huge
        visited[node] = false
    end
    dist[source] = 0
    
    table.insert(pq, {node = source, dist = 0})

    while #pq > 0 do
        -- Sort pq to get the node with the smallest distance
        table.sort(pq, function(a, b) return a.dist < b.dist end)
        local current = table.remove(pq, 1)
        
        if visited[current.node] then
            goto continue
        end
        visited[current.node] = true
        
        for _, neighbor in ipairs(graph.adj[current.node]) do
            local alt = dist[current.node] + neighbor.weight
            if alt < dist[neighbor.node] then
                dist[neighbor.node] = alt
                table.insert(pq, {node = neighbor.node, dist = alt})
            end
        end
        
        ::continue::
    end
    
    return dist
end

local function hasCycle(graph)
    local visited = {}
    
    local function dfs(node, parent)
        visited[node] = true
        
        for _, neighbor in ipairs(graph.adj[node]) do
            if not visited[neighbor.node] then
                if dfs(neighbor.node, node) then
                    return true
                end
            elseif neighbor.node ~= parent then
                return true
            end
        end
        
        return false
    end
    
    for node, _ in pairs(graph.adj) do
        if not visited[node] then
            if dfs(node, nil) then
                return true
            end
        end
    end
    
    return false
end

local function isConnected(graph)
    local visited = {}
    local startNode = next(graph.adj)
    
    if not startNode then return true end  -- Empty graph
    
    dfs(graph, startNode, visited)
    
    for node, _ in pairs(graph.adj) do
        if not visited[node] then
            return false
        end
    end
    
    return true
end

local function topologicalSort(graph)
    local visited = {}
    local stack = {}
    
    local function dfs(node)
        visited[node] = true
        
        for _, neighbor in ipairs(graph.adj[node]) do
            if not visited[neighbor.node] then
                dfs(neighbor.node)
            end
        end
        
        table.insert(stack, 1, node)
    end
    
    for node, _ in pairs(graph.adj) do
        if not visited[node] then
            dfs(node)
        end
    end
    
    return stack
end

-- Helper function to find a node's set in union-find structure
local function find(parent, node)
    if parent[node] == node then
        return node
    else
        parent[node] = find(parent, parent[node])
        return parent[node]
    end
end

-- Helper function to union two sets
local function union(parent, rank, u, v)
    local rootU = find(parent, u)
    local rootV = find(parent, v)

    if rootU ~= rootV then
        if rank[rootU] > rank[rootV] then
            parent[rootV] = rootU
        elseif rank[rootU] < rank[rootV] then
            parent[rootU] = rootV
        else
            parent[rootV] = rootU
            rank[rootU] = rank[rootU] + 1
        end
    end
end

-- Kruskal's algorithm
local function kruskal(graph)
    local edges = {}
    local parent = {}
    local rank = {}
    
    -- Collect all edges
    for u, neighbors in pairs(graph.adj) do
        for _, neighbor in ipairs(neighbors) do
            table.insert(edges, {u = u, v = neighbor.node, weight = neighbor.weight})
        end
    end
    
    -- Sort edges by weight
    table.sort(edges, function(a, b) return a.weight < b.weight end)
    
    -- Initialize union-find structure
    for node, _ in pairs(graph.adj) do
        parent[node] = node
        rank[node] = 0
    end
    
    local mst = {}
    
    -- Process edges
    for _, edge in ipairs(edges) do
        if find(parent, edge.u) ~= find(parent, edge.v) then
            table.insert(mst, edge)
            union(parent, rank, edge.u, edge.v)
        end
    end
    
    return mst
end

local iblib_graphs = {
    create_graph = createGraph,
    add_node = addNode,
    add_edge = addEdge,
    bfs = bfs,
    dfs = dfs,
    dijkstra = dijkstra,
    has_cycle = hasCycle,
    is_connected = isConnected,
    topological_sort = topologicalSort,
    find = find,
    union = union,
    kruskal = kruskal,
}

return iblib_graphs
