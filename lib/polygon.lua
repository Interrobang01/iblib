--[[
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
	
	["is_polygon_in_polygon"]: Checks if one polygon is entirely contained inside another
		INPUTS:
		- polygon, the polygon that might be inside the other
		- polygon, the polygon that might contain the other
		OUTPUTS:
		- boolean, true if the first polygon is inside the second polygon, else false

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
	
	["get_shape_size"]: Approximates the 'radius' of the shape
		INPUTS:
		- shape, the shape to get the size of
		OUTPUTS:
		- number, the size of the shape
	
	
--]]

local rotate = require("@interrobang/iblib/lib/rotate_vector.lua")
local middleclass = require("@interrobang/iblib/lib/middleclass.lua")



--[[
Original repo:
https://github.com/Bigfoot71/2d-polygon-boolean-lua
]]--

-- <license> (everything until the end tag is included in the license)
--[[
MIT License

Copyright (c) 2022 Le Juez Victor

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

local function sign(x)
    if x>0 then return 1
    elseif x<0 then return -1
    else return 0 end
end

local function push(tab,tab2)
    for i = 1, #tab2 do
        tab[#tab+1] = tab2[i]
    end
end

local function unshift(tab,tab2)
    for i,v in ipairs(tab2) do
        table.insert(tab,i,v)
    end
end

local function reverse(tab)
    local len = #tab
    local rt = {}
    for i,v in ipairs(tab) do
        rt[len-i+1] = v
    end
    tab = rt
end

local function copy(tab)
    return {table.unpack(tab)}
end


local Node = {}
Node.__index = Node
function Node:new(x,y,alpha,intersection)
    return setmetatable({
        x = x, y = y,
        alpha = alpha or 0,
        intersect = intersection,
        next = nil,
        prev = nil,
        nextPoly = nil,
        neighbor = nil,
        entry = nil,
        visited = false,
    }, Node)
end

function Node:nextNonIntersection()
    local a = self
    while a and a.intersect and a.next do
        a = a.next
    end
    return a
end

function Node:last()
    local a = self
    while a.next and a.next ~= self do
        a = a.next
    end
    return a
end

function Node:createLoop()
    local last = self:last()
    last.prev.next = self
    self.prev = last.prev
end

function Node:firstNodeOfInterest()
    local a = self
    if a then
        a = a.next
        while a ~= self and (not a.intersect or (a.intersect and a.visited)) do
            a = a.next
        end
    end
    return a
end

function Node:insertBetween(first, last)
    local a = first
    while a ~= last and a.alpha < self.alpha do
        a = a.next
    end

    self.next = a
    self.prev = a.prev
    if self.prev then
        self.prev.next = self
    end
    self.next.prev = self
end

local function createList(p)

    local len = #p
    local ret, where

    for i = 1, len-1, 2 do

        if not ret then
            where = Node:new(p[i],p[i+1])
            ret = where
        else
            where.next = Node:new(p[i],p[i+1])
            where.next.prev = where
            where = where.next
        end

    end

    return ret

end

local function clean(verts)
    for i = #verts-2, 1, -2 do
        if verts[i-1] == verts[i+1]
        and verts[i] == verts[i+2]
        then
            table.remove(verts, i+1)
            table.remove(verts, i)
        end
    end
    return verts
end


local function lineCross(x1,y1,x2,y2,x3,y3,x4,y4)

    local a1 = y2 - y1
    local b1 = x1 - x2
    local c1 = x2 * y1 - x1 * y2

    local r3 = a1 * x3 + b1 * y3 + c1
    local r4 = a1 * x4 + b1 * y4 + c1

    if r3 ~= 0 and r4 ~= 0 and ((r3 >= 0 and r4 >= 0) or (r3 < 0 and r4 < 0)) then
        return
    end

    local a2 = y4 - y3
    local b2 = x3 - x4
    local c2 = x4 * y3 - x3 * y4

    local r1 = a2 * x1 + b2 * y1 + c2
    local r2 = a2 * x2 + b2 * y2 + c2

    if r1 ~= 0 and r2 ~= 0 and ((r1 >= 0 and r2 >= 0) or (r1 < 0 and r2 < 0)) then
        return
    end

    local denom = a1 * b2 - a2 * b1

    if denom == 0 then
        return true
    end

    --offset = denom < 0 and - denom / 2 or denom / 2

    local x = b1 * c2 - b2 * c1
    local y = a2 * c1 - a1 * c2

    return x~=0 and x/denom or x,
           y~=0 and y/denom or y

end

local function pointContain(x,y,p)

    local oddNodes = false

    local j = #p-1
    for i = 1, #p-1, 2 do

        local px1,py1 = p[i], p[i+1]
        local px2,py2 = p[j], p[j+1]

        if (py1 < y and py2 >= y or py2 < y and py1 >= y) then
            if (px1 + ( y - py1 ) / (py2 - py1) * (px2 - px1) < x) then
                oddNodes = not oddNodes
            end
        end

        j = i

    end

    return oddNodes

end

local function area(p)

    local ax,ay = 0,0
    local bx,by = 0,0

    local area = 0
    local fx,fy = p[1],p[2]

    for i = 3, #p-1, 2 do
        local px,py = p[i-2],p[i-1]
        local cx,cy = p[i],p[i+1]
        ax = fx - cx
        ay = fy - cy
        bx = fx - px
        by = fy - py
        area = area + (ax*by) - (ay*bx)
    end

    return area/2

end

local function distance(x1,y1,x2,y2)
    return math.sqrt((x1-x2)^2+(y1-y2)^2)
end


local function identifyIntersections(subjectList, clipList)

    local auxs = subjectList:last()
    auxs.next = Node:new(subjectList.x, subjectList.y, auxs)
    auxs.next.prev = auxs

    local auxc = clipList:last()
    auxc.next = Node:new(clipList.x, clipList.y, auxc)
    auxc.next.prev = auxc

    local found = false
    local subject = subjectList

    while subject.next do

        local clip = clipList
        if(not subject.intersect) then

            while clip.next do
                if(not clip.intersect) then

                    local subjectNext = subject.next:nextNonIntersection()
                    local clipNext = clip.next:nextNonIntersection()

                    local x1,y1 = subject.x, subject.y
                    local x2,y2 = subjectNext.x, subjectNext.y
                    local x3,y3 = clip.x, clip.y
                    local x4,y4 = clipNext.x, clipNext.y

                    local x, y = lineCross(x1,y1,x2,y2,x3,y3,x4,y4)

                    if x and x ~= true then
                        found = true
                        local intersectionSubject = Node:new(x,y, distance(x1,y1,x,y)/distance(x1,y1,x2,y2), true)
                        local intersectionClip = Node:new(x,y, distance(x3,y3,x,y) / distance(x3,y3,x4,y4), true)
                        intersectionSubject.neighbor = intersectionClip
                        intersectionClip.neighbor = intersectionSubject
                        intersectionSubject:insertBetween(subject, subjectNext)
                        intersectionClip:insertBetween(clip, clipNext)
                    end
                end

                clip = clip.next

            end
        end

        subject = subject.next

    end

    return found

end

local function identifyIntersectionType(subjectList, clipList, clipPoly, subjectPoly, type)

    local se = pointContain(subjectList.x, subjectList.y, clipPoly)
    if (type == 'and') then se = not se end

    local subject = subjectList
    while subject.next do
        if(subject.intersect) then
            subject.entry = se
            se = not se
        end
        subject = subject.next
    end

    local ce = not pointContain(clipList.x, clipList.y, subjectPoly)
    if (type == 'or') then ce = not ce end

    local clip = clipList
    while clip.next do
        if(clip.intersect) then
            clip.entry = ce
            ce = not ce
        end
        clip = clip.next
    end

end


local function collectClipResults(subjectList, clipList, getMostRevelant)

    subjectList:createLoop()
    clipList:createLoop()

    local results = {}
	local walker = nil

    while true do

        walker = subjectList:firstNodeOfInterest()
        if walker == subjectList then break end

        local result = {}

        while true do

            if walker.visited  then break end

            walker.visited = true
            walker = walker.neighbor

            result[#result+1] = walker.x
            result[#result+1] = walker.y

            local forward = walker.entry

            while true do

                walker.visited = true
                walker = forward and walker.next or walker.prev

                if walker.intersect then
                    --walker.visited = true
                    break
                else
                    result[#result+1] = walker.x
                    result[#result+1] = walker.y
                end

            end

        end

        results[#results+1] = clean(result)

    end

    local res
    if getMostRevelant then

        res = {}

        local index, length = 1, -math.huge

        for i = 1, #results do
            if #results[i] > length then
                index, length = i, #results[i]
            end
        end

        res = results[index]

    end

    return res or results

end


local function polygon_boolean(subjectPoly, clipPoly, operation, getMostRevelant)

    local subjectList = createList(subjectPoly)
    local clipList = createList(clipPoly)

    -- Phase 1: Identify and store intersections between the subject
    --					and clip polygons
    local isects = identifyIntersections(subjectList, clipList)

    if isects then
        -- Phase 2: walk the resulting linked list and mark each intersection
        --					as entering or exiting
        identifyIntersectionType(
            subjectList,
            clipList,
            clipPoly,
            subjectPoly,
            operation
        )

        -- Phase 3: collect resulting polygons
        return collectClipResults(subjectList, clipList, getMostRevelant)

    else
        -- No intersections

        local inner = pointContain(subjectPoly[1], subjectPoly[2], clipPoly)
        local outer = pointContain(clipPoly[1], clipPoly[2], subjectPoly)

        local res = {}

        if operation == "or" then

            if (not inner and not outer) then
                push(res, copy(subjectPoly))
                push(res, copy(clipPoly))
            elseif (inner) then
                push(res, copy(clipPoly))
            elseif (outer) then
                push(res, copy(subjectPoly))
            end

        elseif operation == "and" then

            if (inner) then
                push(res, copy(subjectPoly))
            elseif (outer) then
                push(res, copy(clipPoly))
            end

        elseif operation == "not" then

            local sclone = copy(subjectPoly)
            local cclone = copy(clipPoly)

            local sarea = area(sclone)
            local carea = area(cclone)
            if (sign(sarea) == sign(carea)) then
                if (outer) then
                    cclone = reverse(cclone)
                elseif (inner) then
                    sclone = reverse(sclone)
                end
            end

            push(res, sclone)

            if (math.abs(sarea) > math.abs(carea)) then
                push(res, cclone)
            else
                unshift(res, cclone)
            end

        end

        if getMostRevelant then
            return false, res
        end

        return res

    end

end
-- </license>


-- <license> (everything until the end tag is included in the license)
--[[
Copyright (c) 2010-2011 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

local sqrt, cos, sin = math.sqrt, math.cos, math.sin

--------------------------------------------------------------
-- Point class
--------------------------------------------------------------

Point = middleclass.class("Point")

function Point:initialize(x,y)
	self.x = x
	self.y = y
end

local function is_point(v)
	return getmetatable(v) == Point
end

function Point:clone()
	return Point(self.x, self.y)
end

function Point:unpack()
	return self.x, self.y
end

function Point:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..")"
end

function Point.__unm(a)
	return Point(-a.x, -a.y)
end

function Point.__add(a,b)
	return Point(a.x+b.x, a.y+b.y)
end

function Point.__sub(a,b)
	return Point(a.x-b.x, a.y-b.y)
end

function Point.__mul(a,b)
	if type(a) == "number" then
		return Point(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return Point(b*a.x, b*a.y)
	else
		return a.x*b.x + a.y*b.y
	end
end

function Point.__div(a,b)
	return Point(a.x / b, a.y / b)
end

function Point.__eq(a,b)
	return a.x == b.x and a.y == b.y
end

function Point.__lt(a,b)
	return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Point.__le(a,b)
	return a.x <= b.x and a.y <= b.y
end

function Point.permul(a,b)
	return Point(a.x*b.x, a.y*b.y)
end

function Point:len2()
	return self * self
end

function Point:len()
	return sqrt(self*self)
end

function Point.dist(a, b)
	return (b-a):len()
end

function Point:normalize_inplace()
	local l = self:len()
	self.x, self.y = self.x / l, self.y / l
	return self
end

function Point:normalized()
	return self / self:len()
end

function Point:rotate_inplace(phi)
	local c, s = cos(phi), sin(phi)
	self.x, self.y = c * self.x - s * self.y, s * self.x + c * self.y
	return self
end

function Point:rotated(phi)
	return self:clone():rotate_inplace(phi)
end

function Point:perpendicular()
	return Point(-self.y, self.x)
end

function Point:projectOn(v)
	return (self * v) * v / v:len2()
end

function Point:cross(other)
	return self.x * other.y - self.y * other.x
end

--------------------------------------------------------------
-- Helpers for Polygon class
--------------------------------------------------------------

-- create vertex list of coordinate pairs
local function to_vertex_list(vertices, x,y, ...)
	if not x or not y then return vertices end -- no more arguments

	vertices[#vertices + 1] = Point(x, y)     -- set vertex
	return to_vertex_list(vertices, ...)         -- recurse
end

-- returns true if three points lie on a line
local function are_collinear(p,q,r)
	return (q - p):cross(r - p) == 0
end
-- remove vertices that lie on a line
local function remove_collinear(vertices)
	local ret = {}
	for k=1,#vertices do
		local i = k > 1 and k - 1 or #vertices
		local l = k < #vertices and k + 1 or 1
		if not are_collinear(vertices[i], vertices[k], vertices[l]) then
			ret[#ret+1] = vertices[k]
		end
	end
	return ret
end

-- get index of rightmost vertex (for testing orientation)
local function get_index_of_leftmost(vertices)
	local idx = 1
	for i = 2,#vertices do
		if vertices[i].x < vertices[idx].x then
			idx = i
		end
	end
	return idx
end

-- returns true if three points make a counter clockwise turn
local function ccw(p, q, r)
	return (q - p):cross(r - p) >= 0
end

-- unpack vertex coordinates, i.e. {x=p, y=q}, ... -> p,q, ...
local function unpack_helper(v, ...)
	if not v then return end
	return v.x, v.y, unpack_helper(...)
end

-- test if a point lies inside of a triangle using cramers rule
local function point_in_triangle(q, p1,p2,p3)
	local v1,v2 = p2 - p1, p3 - p1
	local qp = q - p1
	local dv = v1:cross(v2)
	local l = qp:cross(v2) / dv
	if l <= 0 then return false end
	local m = v1:cross(qp) / dv
	if m <= 0 then return false end
	return l+m < 1
end

-- returns starting indices of shared edge, i.e. if p and q share the
-- edge with indices p1,p2 of p and q1,q2 of q, the return value is p1,q1
local function get_shared_edge(p,q)
	local vertices = {}
	for i,v in ipairs(q) do vertices[ tostring(v) ] = i end
	for i,v in ipairs(p) do
		local w = (i == #p) and p[1] or p[i+1]
		if vertices[ tostring(v) ] and vertices[ tostring(w) ] then
			return i, vertices[ tostring(v) ]
		end
	end
end

--------------------------------------------------------------
-- Polygon class
--------------------------------------------------------------
Polygon = middleclass.class("Polygon")

function Polygon:initialize(...)
	local vertices = remove_collinear( to_vertex_list({}, ...) )
	assert(#vertices >= 3, "Need at least 3 non collinear points to build polygon (got "..#vertices..")")

	-- assert polygon is oriented counter clockwise
	local r = get_index_of_leftmost(vertices)
	local q = r > 1 and r - 1 or #vertices
	local s = r < #vertices and r + 1 or 1
	if not ccw(vertices[q], vertices[r], vertices[s]) then -- reverse order if polygon is not ccw
		local tmp = {}
		for i=#vertices,1,-1 do
			tmp[#tmp + 1] = vertices[i]
		end
		vertices = tmp
	end
	self.vertices = vertices

	-- compute polygon area and centroid
	self.area = vertices[#vertices]:cross(vertices[1])
	for i = 1,#vertices-1 do
		self.area = self.area + vertices[i]:cross(vertices[i+1])
	end
	self.area = self.area / 2

	local p,q = vertices[#vertices], vertices[1]
	local det = p:cross(q)
	self.centroid = Point((p.x+q.x) * det, (p.y+q.y) * det)
	for i = 1,#vertices-1 do
		p,q = vertices[i], vertices[i+1]
		det = p:cross(q)
		self.centroid.x = self.centroid.x + (p.x+q.x) * det
		self.centroid.y = self.centroid.y + (p.y+q.y) * det
	end
	self.centroid = self.centroid / (6 * self.area)

	-- get outcircle
	self._radius = 0
	for i = 1,#vertices do
		self._radius = math.max(vertices[i]:dist(self.centroid), self._radius)
	end
end

-- return vertices as x1,y1,x2,y2, ..., xn,yn
function Polygon:unpack()
	return unpack_helper( table.unpack(self.vertices) )
end

-- deep copy of the polygon
function Polygon:clone()
	return Polygon( self:unpack() )
end

-- get bounding box
function Polygon:get_b_box()
	local ul = self.vertices[1]:clone()
	local lr = ul:clone()
	for i=2,#self.vertices do
		local p = self.vertices[i]
		if ul.x > p.x then ul.x = p.x end
		if ul.y > p.y then ul.y = p.y end

		if lr.x < p.x then lr.x = p.x end
		if lr.y < p.y then lr.y = p.y end
	end

	return ul.x,ul.y, lr.x,lr.y
end

-- a polygon is convex if all edges are oriented ccw
function Polygon:is_convex()
	local v = self.vertices
	if #v == 3 then 
		return true 
	end

	if not ccw(v[#v], v[1], v[2]) then
		return false
	end
	for i = 2, #v - 1 do
		if not ccw(v[i-1], v[i], v[i+1]) then
			return false
		end
	end
	if not ccw(v[#v-1], v[#v], v[1]) then
		return false
	end
	return true
end

function Polygon:move(dx, dy)
	if not dy then
		dx, dy = dx:unpack()
	end
	for i,v in ipairs(self.vertices) do
		v.x = v.x + dx
		v.y = v.y + dy
	end
	self.centroid.x = self.centroid.x + dx
	self.centroid.y = self.centroid.y + dy
end

function Polygon:rotate(angle, center, cy)
	local center = center or self.centroid
	if cy then center = Point(center, cy) end
	for i,v in ipairs(self.vertices) do
		self.vertices[i] = (self.vertices[i] - center):rotate_inplace(angle) + center
	end
end

-- triangulation by the method of kong
function Polygon:triangulate()
	if #self.vertices == 3 then return {self:clone()} end
	local triangles = {} -- list of triangles to be returned
	local concave = {}   -- list of concave edges
	local adj = {}       -- vertex adjacencies
	local vertices = self.vertices

	-- retrieve adjacencies as the rest will be easier to implement
	for i,p in ipairs(vertices) do
		local l = (i == 1) and vertices[#vertices] or vertices[i-1]
		local r = (i == #vertices) and vertices[1] or vertices[i+1]
		adj[p] = {p = p, l = l, r = r} -- point, left and right neighbor
		-- test if vertex is a concave edge
		if not ccw(l,p,r) then concave[p] = p end
	end

	-- and ear is an edge of the polygon that contains no other
	-- vertex of the polygon
	local function isEar(p1,p2,p3)
		if not ccw(p1,p2,p3) then return false end
		for q,_ in pairs(concave) do
			if point_in_triangle(q, p1,p2,p3) then return false end
		end
		return true
	end

	-- main loop
	local nPoints, skipped = #vertices, 0
	local p = adj[ vertices[2] ]
	while nPoints > 3 do
		if not concave[p.p] and isEar(p.l, p.p, p.r) then
			triangles[#triangles+1] = Polygon( unpack_helper(p.l, p.p, p.r) )
			if concave[p.l] and ccw(adj[p.l].l, p.l, p.r) then
				concave[p.l] = nil
			end
			if concave[p.r] and ccw(p.l, p.r, adj[p.r].r) then
				concave[p.r] = nil
			end
			-- remove point from list
			adj[p.p] = nil
			adj[p.l].r = p.r
			adj[p.r].l = p.l
			nPoints = nPoints - 1
			skipped = 0
			p = adj[p.l]
		else
			p = adj[p.r]
			skipped = skipped + 1
			assert(skipped <= nPoints, "Cannot triangulate polygon (is the polygon intersecting itself?)")
		end
	end
	triangles[#triangles+1] = Polygon( unpack_helper(p.l, p.p, p.r) )
	return triangles
end

-- return merged polygon if possible or nil otherwise
function Polygon:merged_with(other)
	local p,q = get_shared_edge(self.vertices, other.vertices)
	if not (p and q) then 
		return nil 
	end

	local ret = {}
	for i = 1, p do 
		ret[#ret+1] = self.vertices[i] 
	end
	for i = 2, #other.vertices-1 do
		local k = i + q - 1
		if k > #other.vertices then k = k - #other.vertices end
		ret[#ret+1] = other.vertices[k]
	end
	for i = p+1,#self.vertices do 
		ret[#ret+1] = self.vertices[i] 
	end

	return Polygon( unpack_helper( table.unpack(ret) ) )
end

-- split polygon into convex polygons.
-- note that this won't be the optimal split in most cases, as
-- finding the optimal split is a really hard problem.
-- the method is to first triangulate and then greedily merge
-- the triangles.
function Polygon:split_convex()
	-- edge case: polygon is a triangle or already convex
	if #self.vertices <= 3 or self:is_convex() then 
		return {self:clone()}
	end

	local convex = self:triangulate()

	local i = 1
	repeat
		local p = convex[i]
		local k = i + 1
		while k <= #convex do
			local success, merged = pcall(function() return p:mergedWith(convex[k]) end)
			if success and merged and merged:isConvex() then
				convex[i] = merged
				p = convex[i]
				table.remove(convex, k)
			else
				k = k + 1
			end
		end
		i = i + 1
	until i >= #convex

	return convex
end

function Polygon:contains(x,y)
	-- test if an edge cuts the ray
	local function cut_ray(p,q)
		return ((p.y > y and q.y < y) or (p.y < y and q.y > y)) -- possible cut
			and (x - p.x < (y - p.y) * (q.x - p.x) / (q.y - p.y)) -- x < cut.x
	end

	-- test if the ray crosses boundary from interior to exterior.
	-- this is needed due to edge cases, when the ray passes through
	-- polygon corners
	local function cross_boundary(p,q)
		return (p.y == y and p.x > x and q.y < y)
			or (q.y == y and q.x > x and p.y < y)
	end

	local v = self.vertices
	local in_polygon = false
	for i = 1, #v do
		local p, q = v[i], v[(i % #v) + 1]
		if cut_ray(p,q) or cross_boundary(p,q) then
			in_polygon = not in_polygon
		end
	end
	return in_polygon
end

function Polygon:intersects_ray(x,y, dx,dy)
	local p = Point(x,y)
	local v = Point(dx,dy)
	local n = v:perpendicular()

	local vertices = self.vertices
	for i = 1, #vertices do
		local q1, q2 = vertices[i], vertices[ (i % #vertices) + 1 ]
		local w = q2 - q1
		local det = v:cross(w)

		if det ~= 0 then
			-- there is an intersection point. check if it lies on both
			-- the ray and the segment.
			local r = q2 - p
			local l = r:cross(w)
			local m = v:cross(r)
			if l >= 0 and m >= 0 and m <= det then return true, l end
		else
			-- lines parralel or incident. get distance of line to
			-- anchor point. if they are incident, check if an endpoint
			-- lies on the ray
			local dist = (q1 - p) * n
			if dist == 0 then
				local l,m = v * (q1 - p), v * (q2 - p)
				if l >= 0 and l >= m then return true, l end
				if m >= 0 then return true, m end
			end
		end
	end
	return false
end



-- </license>

local function split_concave_polygon(polygon)
    local polygon_object = Polygon(table.unpack(polygon))

    -- split polygon into convex polygons
    local convex_polygon_objects = polygon_object:split_convex()
    local convex_polygons = {}
    for i = 1, #convex_polygon_objects do
        table.insert(convex_polygons, {convex_polygon_objects[i]:unpack()})
    end
    return convex_polygons
end


local function iblib_shape_to_points(shape, circle_points)
    if not circle_points then
        circle_points = 32 -- Default number of points for circle approximation
    end
    -- Converts a shape to a list of points
    local points = {}
    if shape.shape_type == "polygon" then
        points = shape.points
    elseif shape.shape_type == "circle" then
        -- Lossy conversion for circles to points
        for i = 0, circle_points - 1 do
            local angle = (i / circle_points) * (2 * math.pi)
            local x = shape.radius * math.cos(angle)
            local y = shape.radius * math.sin(angle)
            table.insert(points, vec2(x,y))
        end
    elseif shape.shape_type == "box" then
        -- Points are based on the size of the box
        local half_width = shape.size.x / 2
        local half_height = shape.size.y / 2
        points = {
            vec2(half_width, half_height),
            vec2(half_width, -half_height),
            vec2(-half_width, -half_height),
            vec2(-half_width, half_height)
        }
    else
        error("Unsupported shape type: " .. tostring(shape.shape_type))
    end
    return points
end

local function iblib_points_to_shape(points)
    -- Converts a list of points to a shape
    return {radius = 0, points = points, shape_type = "polygon"}
end

local function iblib_points_to_polygon(points, position, rotation)
    -- Converts vec2 points to a polygon
    local polygon = {}
    for _, point in ipairs(points) do
        local rotated_point = rotate(point, rotation or 0)
        local translated_point = rotated_point + (position or vec2(0, 0))
        table.insert(polygon, translated_point.x)
        table.insert(polygon, translated_point.y)
    end
    return polygon
end

local function iblib_polygon_to_points(polygon, position, rotation)
    -- Converts a polygon to a shape
    local points = {}
    for index, coordinate in ipairs(polygon) do
        if index % 2 == 1 then
            -- x coordinate
            table.insert(points, vec2(coordinate, 0))
        else
            -- y coordinate
            points[#points].y = coordinate
        end
    end
    if position == nil then
        -- Get average position if no position is provided
        local avg_x, avg_y = 0, 0
        for _, point in ipairs(points) do
            avg_x = avg_x + point.x
            avg_y = avg_y + point.y
        end
        local num_points = #points
        if num_points > 0 then
            avg_x = avg_x / num_points
            avg_y = avg_y / num_points
        end
        position = vec2(avg_x, avg_y)
    end
    -- Adjust points based on the provided position
    for i = 1, #points do
        points[i] = points[i] - position
        points[i] = rotate(points[i], -(rotation or 0))
    end
    return points
end

local function shape_to_polygon(shape, position, rotation)
    -- Converts a shape to a polygon
    return iblib_points_to_polygon(iblib_shape_to_points(shape), position, rotation)
end

local function polygon_to_shape(polygon, position, rotation)
    -- Converts a polygon to a shape
    return iblib_points_to_shape(iblib_polygon_to_points(polygon, position, rotation))
end



local function is_polygon_in_polygon(polygon_a, polygon_b)
	local Polygon_a = Polygon(table.unpack(polygon_a))
	local Polygon_b = Polygon(table.unpack(polygon_b))

	-- Check if any vertex of polygon_a is inside polygon_b
	for i = 1, #Polygon_a.vertices do
		local vertex = Polygon_a.vertices[i]
		if not Polygon_b:contains(vertex.x, vertex.y) then
			return false
		end
	end

	return true
end



local function shape_boolean(args)
	local shape_a = args.shape_a
	local position_a = args.position_a
	local rotation_a = args.rotation_a
	local shape_b = args.shape_b
	local position_b = args.position_b
	local rotation_b = args.rotation_b
	local operation = args.operation or "not"
	local make_convex = args.make_convex or false
	local get_most_relevant = args.get_most_relevant or false

	if not shape_a or not shape_b then
		return nil
	end

	-- Convert shapes to polygons
	local polygon_a = shape_to_polygon(shape_a, position_a, rotation_a)
	local polygon_b = shape_to_polygon(shape_b, position_b, rotation_b)

	-- Ensure polygons do not contain each other
	if is_polygon_in_polygon(polygon_a, polygon_b) or is_polygon_in_polygon(polygon_b, polygon_a) then
		print("Warning: One polygon is contained within the other. This may lead to unexpected results.")
	end

	-- Perform boolean operation
	local result = polygon_boolean(polygon_a, polygon_b, operation, get_most_relevant)
	if result == nil then
		return nil
	end
	if result[1] == nil then
		-- No intersection found
		return nil
	end

	-- Check if it's a table of numbers or a table of tables
	if type(result) == "table" and type(result[1]) == "number" then
		-- Convert single polygon result to a table of tables
		result = {result}
	end

	-- If make_convex is true, make a new table of convex polygons
	if make_convex then
		local all_convex_shapes = {}
		for i = 1, #result do
			local convex_polygons = split_concave_polygon(result[i])
			for _, convex_polygon in ipairs(convex_polygons) do
				local convex_shape = polygon_to_shape(convex_polygon, position_a, rotation_a)
				table.insert(all_convex_shapes, convex_shape)
			end
		end
		return all_convex_shapes
	else
		-- Convert the result back to shapes
		for i = 1, #result do
			result[i] = polygon_to_shape(result[i], position_a, rotation_a)
		end
		-- Return the result as a table of shapes
		return result
	end

end

local function get_shape_size(shape)
    local obj_size = 1
    if shape.shape_type == "circle" then
        obj_size = shape.radius
    elseif shape.shape_type == "box" then
        obj_size = math.min(shape.size.x, shape.size.y) / 2
    elseif shape.shape_type == "polygon" then
        -- For polygons, estimate the size from the points
        local max_dist = 0
        for _, point in ipairs(shape.points) do
            local dist = point:magnitude()
            if dist > max_dist then
                max_dist = dist
            end
        end
        obj_size = max_dist
    else
		error("Unsupported shape type: " .. tostring(shape.shape_type))
	end
	return obj_size
end

return {
	polygon_boolean = polygon_boolean,

	Point = Point,
	Polygon = Polygon,

    split_concave_polygon = split_concave_polygon,
    shape_to_points = iblib_shape_to_points,
    points_to_shape = iblib_points_to_shape,
    points_to_polygon = iblib_points_to_polygon,
    polygon_to_points = iblib_polygon_to_points,
    shape_to_polygon = shape_to_polygon,
    polygon_to_shape = polygon_to_shape,

	is_polygon_in_polygon = is_polygon_in_polygon,

	shape_boolean = shape_boolean,
	
	get_shape_size = get_shape_size,
}
