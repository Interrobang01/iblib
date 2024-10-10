--[[
Use with electicity_source
--]]

local check_around_object = require("./packages/@interrobang/iblib/lib/check_around_object.lua")

function on_event(id, data)
    if id == "@interrobang/iblib/electricity_get_type" then
        data.sender:send_event("@interrobang/iblib/electricity_send_type", {type = "Carrier"})
    end
end

function on_step()
    
end
