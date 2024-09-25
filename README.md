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

## lib_loader.luaexample usage:
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")

## test_component.lua
## rotate_vector.lua
## tripoint_box.lua
## initialize_component.luaTakes in a component code string, initializes the component with a filler name, id, and version, and returns the hash.

## line.lua
## is_point_in_polygon.lua
## antigravity.luaMakes the object maintain its vertical position by setting its velocity to the difference between the desired y value and the current y value.

## gravity.luaMakes the object attract other objects.
If you send the "@interrobang/iblib/send_to_orbit" event to an object with this component, it will be sent to orbit except that's actually broken right now so nevermind

## curved.luaMakes the object take a curved path when moving.

## hose.luaMakes the object accelerate based on its angle. The idea is to make it fly around like a hose but it doesn't do that right now

## weird_world_origin.luaMakes the world revolve around this object.
