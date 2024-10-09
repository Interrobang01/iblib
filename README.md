# iblib

Iblib (short for Interrobang's Library) is a library of mostly-side-effect-less Simulo functions that you can use in whatever you want.

To download this package run
```
@interrobang/iblib;https://github.com/Interrobang01/iblib.git
```

To get started, do
```
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
```
then, when you want to load a function, do
```
local function_name = iblib("function_name")
```
If that function is a component, it will return a string containing that component's code instead of a function.

### lib_loader
example usage:

local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")

INPUTS:
- string, the name of the iblib lib you want to load

OUTPUTS:
- string or function, the function or component you wanted

### test_component
Given the name of an iblib component, creates a box with that component at (0,0) for testing purposes.

INPUTS:
- string, the name of the iblib component to test

### rotate_vector
Rotates a vector by an angle in radians.

INPUTS:
- vec2, the vector to rotate
- number, the radians to rotate by

OUTPUTS:
- vec2, the rotated vector

### tripoint_box
Given three points, returns a table with the table.position, table.size, and table.rotation values needed to make a box with two corners at the first two points and extending to the third.

INPUTS:
- vec2, one corner of the box
- vec2, an adjacent corners of the box
- vec2, the point the box should extend to, from the first 2 points

OUTPUTS:
- a table containing the following indexes: position, size, rotation

### initialize_component
Takes in a component code string, initializes the component with a filler name, id, and version, and returns the hash.

INPUTS:
- string, the component code

OUTPUTS:
- string, the component hash (for :add_component())

### graphs
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

### iblib_font
Letters go in, table of tables (characters) of tables (letters) of points goes out.

EXAMPLE USAGE:

```
local alphabet = "!\"#$%&'()*+,-./0123456789:'<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"
local text = "The, quick. Brown fox? Jumped! Over: the (lazy) dog :>"

local strokes_table = font(text)

for i = 1,#strokes_table do
    draw_letter(strokes_table[i],vec2(i*1.5,0)) 
end
```

INPUTS:
- string, the string you want to render

OUTPUTS:
- table of letters, containing:
-- table of strokes, containing:
-- table of vec2s

### line
Given a line start, a line end, and an optional thickness, returns a table containing the table.position, table.size, and table.rotation values needed to make a line going between the line start and line end.

INPUTS:
- vec2, the start of the line
- vec2, the end of the line
- number, the thickness of the line (optional, default 0.1)

OUTPUTS:
- a table containing the following indexes: position, size, rotation

### is_point_in_polygon
Given a point and a table of points representing a polygon, returns whether the point is inside that polygon.

INPUTS:
- vec2, the point you want to test
- table of vec2 values, the polygon you want to test. Adjacent values are assumed to be connected.

### antigravity (component)
Makes the object maintain its vertical position by setting its velocity to the difference between the desired y value and the current y value.

### collision_particles (component)
Makes the object release small particles on collision.

### gravity (component)
Makes the object attract other objects.
If you send the "@interrobang/iblib/send_to_orbit" event to an object with this component, it will be sent to orbit except that's actually broken right now so nevermind

### curved (component)
Makes the object take a curved path when moving.

### hose (component)
Makes the object accelerate based on its angle. The idea is to make it fly around like a hose but it doesn't do that right now

### weird_world_origin (component)
Makes the world revolve around this object.

### swirl (component)
Makes it so that when the object rotates, it rotates things around it with it.
