# iblib

Go to the Simulo upload here: https://simulo.org/uploads/@interrobang/iblib
Go to the GitHub repo here: https://github.com/Interrobang01/iblib


Iblib (short for Interrobang's Library) is a library of Simulo Luau functions that you can use in whatever you want.
To get started, do

```
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
```

then, when you want to load a function, do

```
local function_name = iblib("function_name")
```

If that function is a component, it will return a string containing that component's code instead of a function. Use initialize_component to return a component hash instead.


### split_string
Python string split but in lua. Code courtesy of stackoverflow.

INPUTS:
- string, the string to test
- string, the separator; if it's longer than one character it'll treat them all as different separators and add them up, sort of like using an OR instead of an AND

OUTPUTS:
- table of strings, all the split substrings

### dump_table
Returns the input table in a form easily printable to console. Function courtesy of stackoverflow.

INPUTS:
- table, the table you want to dump

OUTPUTS:
- string, the table you want to dump but now easily printable

### is_point_in_polygon
Given a point and a table of points representing a polygon, returns whether the point is inside that polygon.

INPUTS:
- vec2, the point you want to test
- table of vec2 values, the polygon you want to test. Adjacent values are assumed to be connected.

OUTPUTS:
- boolean, true if inside

### middleclass
A third-party library for OOP in Lua, go to https://github.com/kikito/middleclass/wiki for documentation

### linear_algebra
A very tiny linear algebra library. Used with nodal_analysis.lua.

Included functions:

    ["create_matrix"]: Creates an empty n x n matrix

    ["create_vector"]: Creates an empty vector of size n

    ["solve_system"]: Solves the system A * x = B. Inputs are A and B, where A is a matrix and B is a vector.

### test_component
Given the name of an iblib component, creates a box with that component at (0,0) for testing purposes.

INPUTS:
- string/table, the name of the iblib component to test or a table of names to test
- vec2, optional, the size of the box

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

### initialize_component
Takes in a component code string, initializes the component with a filler name, id, and version, and returns the hash.

INPUTS:
- string, the component code or the name of the component

OUTPUTS:
- string, the component hash (for :add_component())

### check_around_object
Returns a table of all the objects within a set distance of another object, sort of like a forcefield. Used for checking contact.

INPUTS:
- object, the object you want to test
- number, how far away the rays should be (0.05 by default)

OUTPUTS:
- table of guids, all the hits

### draw_iblib_font
Make capsules draw text using the iblib font

INPUTS:
- string: the string to draw
- vec2: the location to draw the text at
- number: the point size to draw the text at (default 1)
OUTPUTS:
- table: a table of capsules that were created to draw the text

### three_point_box
Given three points, returns a table with the table.position, table.size, and table.rotation values needed to make a box with two corners at the first two points and extending to the third.

INPUTS:
- vec2, one corner of the box
- vec2, an adjacent corners of the box
- vec2, the point the box should extend to, from the first 2 points

OUTPUTS:
- a table containing the following indexes: position, size, rotation

### line
Given a line start, a line end, and an optional thickness, returns a table containing the table.position, table.size, and table.rotation values needed to make a line going between the line start and line end.

INPUTS:
- vec2, the start of the line
- vec2, the end of the line
- number, the thickness of the line (optional, default 0.1)

OUTPUTS:
- a table containing the following indexes: position, size, rotation

### rotate_vector
Rotates a vector by an angle in radians.

INPUTS:
- vec2, the vector to rotate
- number, the radians to rotate by

OUTPUTS:
- vec2, the rotated vector

### polygon
Functions for a variety of polygon and shape operations and conversions, the main one being boolean operations.

Terminology:
- shape: The thing used with get_shape() or set_shape()
- points: A table of *relative* vec2 points
- polygon: A table of *absolute* coordinates representing a polygon, e.g. {x1,y1,x2,y2,...}
- Polygon (object): An instance of the Polygon class. Built with a polygon.

Included functions:

    ["polygon_boolean"]: Performs boolean operations on two polygons.
		Go to https://github.com/Bigfoot71/2d-polygon-boolean-lua for better documentation
		INPUTS:
		- polygon, the subject polygon
		- polygon, the operating polygon
		- string, the operation to perform: "and", "or", "not"
		- boolean, if true, return only the most relevant polygon from the operation (default: false)
		OUTPUTS:
		- polygon, the polygon resulting from the operation,
		OR table, a tables of multiple polygons, if multiple polygons were returned


	["Point"]: vec2 but better, used by Polygon class
		Undocumented; check code

	["Polygon"]: Polygon class for representing 2D polygons
		Undocumented; check code

	["split_concave_polygon"]: Splits a concave polygon into convex polygons
		INPUTS:
		- polygon, the concave polygon to split
		OUTPUTS:
		- table, a table of convex polygons

	["shape_to_points"]: Converts a shape to relative points
		INPUTS:
		- shape, the shape to convert (can be a polygon, circle, or box)
		- circle_points (optional), the number of points to approximate a circle (default: 32)
		OUTPUTS:
		- points

	["points_to_shape"]: Converts relative points to a shape
		INPUTS:
		- points
		OUTPUTS:
		- shape, shape type of polygon (meaning shape to points to shape might be lossy)

	["points_to_polygon"]: Converts relative points to an absolute polygon
		INPUTS:
		- points
		- position (optional), the position to translate the polygon to (default: vec2(0, 0))
		- rotation (optional), the rotation to apply to the polygon (default: 0)
		OUTPUTS:
		- polygon

	["polygon_to_points"]: Converts an absolute polygon to relative points
		INPUTS:
		- polygon
		- position (optional), the position to subtract from the polygon (default: average position of points)
		- rotation (optional), the rotation to reverse on the polygon (default: 0)
		OUTPUTS:
		- points

	["shape_to_polygon"]: Converts a shape to an absolute polygon
		INPUTS:
		- shape
		- position (optional), the position to translate the polygon to (default: vec2(0, 0))
		- rotation (optional), the rotation to apply to the polygon (default: 0)
		OUTPUTS:
		- polygon

	["polygon_to_shape"]: Converts an absolute polygon to a shape
		INPUTS:
		- polygon
		- position (optional), the position to subtract from the polygon (default: average position of points)
		- rotation (optional), the rotation to reverse on the polygon (default: 0)
		OUTPUTS:
		- shape

	["shape_boolean"]: Performs boolean operations on two shapes
		INPUTS:
		- args, a table containing the following fields:
			- shape_a, the first shape
			- position_a (optional), the position of the first shape (default: vec2(0, 0))
			- rotation_a (optional), the rotation of the first shape (default: 0)
			- shape_b, the second shape
			- position_b (optional), the position of the second shape (default: vec2(0, 0))
			- rotation_b (optional), the rotation of the second shape (default: 0)
			- operation (optional), the boolean operation to perform: "and", "or", "not" (default: "not")
			- make_convex (optional), whether to split the result into convex polygons (default: false)
			- get_most_relevant (optional), whether to return only the most relevant polygon (default: false)
		OUTPUTS:
		- table of shapes, the shapes resulting from the operation, or nil if no result

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

### lib_loader
example usage:

local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")

INPUTS:
- string, the name of the iblib lib you want to load

OUTPUTS:
- string or function, the function or component you wanted

### collision_particles (component)
Makes the object release small particles on collision.

### gravity (component)
Makes the object attract other objects.
If you send the "@interrobang/iblib/send_to_orbit" event to an object with this component, it will be sent to orbit except that's actually broken right now so nevermind

### hose (component)
Makes the object accelerate based on its angle. The idea is to make it fly around like a hose but it doesn't do that right now

### maintain_x (component)
Makes the object maintain its horizontal position by setting its velocity to the difference between the desired x value and the current x value.

### curved (component)
Makes the object take a curved path when moving.

### delete_next_step (component)
Deletes object next step.

### swirl (component)
Makes it so that when the object rotates, it rotates things around it with it.

### maintain_y (component)
Makes the object maintain its vertical position by setting its velocity to the difference between the desired y value and the current y value.

### weird_world_origin (component)
Makes the world revolve around this object.
