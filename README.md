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








# gravity component

hi all. just wanted to put some code for using the gravity component here, at least before i get around to actually documenting some of this stuff.
just run this
```
Scene:reset()
Scene:set_gravity(vec2(0,0))
local iblib = require("./packages/@interrobang/iblib/lib/lib_loader.lua")
local test_component = iblib("test_component")
local initialize_component = iblib("initialize_component")
local gravity = initialize_component(iblib("gravity"))

local planet = Scene:add_circle{
radius = 50,
position = vec2(0,0),
color = 0,
is_static = false,
}
planet:add_component(gravity)

local satellite = Scene:add_circle{
radius = 5,
position = vec2(0,100),
color = 0,
is_static = false,
}
satellite:add_component(gravity)
print(satellite.guid)
```
then run this
```
Scene:get_object_by_guid(put_satellite_guid_here):send_event("@interrobang/iblib/send_to_orbit",{})
```
