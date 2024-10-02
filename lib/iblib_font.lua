--[[
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
--]]

local function iblib_font(str)
    local font_table = {
        A = {
            {vec2(0, 0), vec2(0.5, 2), vec2(1, 0)},  -- Left diagonal, right diagonal
            {vec2(0.25, 1), vec2(0.75, 1)},          -- Crossbar
        },
        
        B = {
            {vec2(0, 0), vec2(0, 2)},               -- Vertical line
            {vec2(0, 2), vec2(1, 1.75), vec2(1, 1.25), vec2(0, 1)},  -- First bump
            {vec2(0, 1), vec2(1, 0.75), vec2(1, 0.25), vec2(0, 0)},  -- Second bump
        },
        
        C = {
            {vec2(1, 2), vec2(0, 1.5), vec2(0, 0.5), vec2(1, 0)},  -- Open curve
        },
        
        D = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 2), vec2(1, 1), vec2(0, 0)},  -- Right curve
        },
        
        E = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 2), vec2(1, 2)},              -- Top horizontal line
            {vec2(0, 1), vec2(1, 1)},                -- Middle horizontal line
            {vec2(0, 0), vec2(1, 0)},              -- Bottom horizontal line
        },
        F = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 2), vec2(1, 2)},              -- Top horizontal line
            {vec2(0, 1), vec2(1, 1)},                -- Middle horizontal line
        },
        
        G = {
            {vec2(1, 2), vec2(0, 1.5), vec2(0, 0.5), vec2(1, 0), vec2(1, 1)},  -- Open curve
            {vec2(0.5, 1), vec2(1, 1)},                -- Middle horizontal line
        },
        
        H = {
            {vec2(0, 0), vec2(0, 2)},                -- Left vertical line
            {vec2(0, 1), vec2(1, 1)},              -- Middle horizontal line
            {vec2(1, 0), vec2(1, 2)},            -- Right vertical line
        },
        
        I = {
            {vec2(0.5, 0), vec2(0.5, 2)},            -- Vertical line
            {vec2(0, 2), vec2(1, 2)},                -- Top horizontal line
            {vec2(0, 0), vec2(1, 0)},                -- Bottom horizontal line
        },
        
        J = {
            {vec2(1, 2), vec2(1, 0.5), vec2(0.5, 0), vec2(0, 0.5)},  -- Entire curve
        },

        K = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 1), vec2(1, 2)},                -- Upper diagonal
            {vec2(0, 1), vec2(1, 0)},                -- Lower diagonal
        },
        
        L = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 0), vec2(1, 0)},              -- Bottom horizontal line
        },
        
        M = {
            {vec2(0, 0), vec2(0, 2)},                -- Left vertical line
            {vec2(0, 2), vec2(0.5, 1)},              -- Left diagonal
            {vec2(0.5, 1), vec2(1, 2)},              -- Right diagonal
            {vec2(1, 2), vec2(1, 0)},                -- Right vertical line
        },
        
        N = {
            {vec2(0, 0), vec2(0, 2)},                -- Left vertical line
            {vec2(0, 2), vec2(1, 0)},                -- Diagonal
            {vec2(1, 0), vec2(1, 2)},                -- Right vertical line
        },
        
        O = {
            {vec2(0.5, 2), vec2(1, 1), vec2(0.5, 0), vec2(0, 1), vec2(0.5, 2)},  -- Closed curve
        },
        
        P = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 2), vec2(1, 1.5), vec2(0, 1)},  -- Top curve
        },
        
        Q = {
            {vec2(0.5, 2), vec2(1, 1), vec2(0.5, 0), vec2(0, 1), vec2(0.5, 2)},  -- Closed curve
            {vec2(1, 0), vec2(0.75, 0.25)},            -- Diagonal tail
        },
        
        R = {
            {vec2(0, 0), vec2(0, 2)},                -- Vertical line
            {vec2(0, 2), vec2(1, 1.5), vec2(0, 1)},  -- Top curve
            {vec2(0, 1), vec2(1, 0)},                -- Diagonal leg
        },
        
        S = {
            {vec2(1, 1.5), vec2(0.5, 2), vec2(0, 1.5), vec2(1, 0.5), vec2(0.5, 0), vec2(0, 0.5)},  -- Open curve
        },
        
        T = {
            {vec2(0.5, 0), vec2(0.5, 2)},            -- Vertical line
            {vec2(0, 2), vec2(1, 2)},                -- Top horizontal line
        },
        
        U = {
            {vec2(0, 0), vec2(0, 2)},                -- Left vertical line
            {vec2(0, 0), vec2(1, 0)},              -- Bottom horizontal line
            {vec2(1, 0), vec2(1, 2)},            -- Right vertical line
        },
        
        V = {
            {vec2(0, 2), vec2(0.5, 0)},             -- Left diagonal
            {vec2(1, 2), vec2(0.5, 0)},           -- Right diagonal
        },
        
        W = {
            {vec2(0, 2), vec2(0, 0)},                -- Left vertical line
            {vec2(0, 0), vec2(0.5, 1)},              -- Left diagonal
            {vec2(0.5, 1), vec2(1, 0)},              -- Right diagonal
            {vec2(1, 0), vec2(1, 2)},                -- Right vertical line
        },
        
        X = {
            {vec2(0, 2), vec2(1, 0)},              -- Left diagonal
            {vec2(1, 2), vec2(0, 0)},              -- Right diagonal
        },
        
        Y = {
            {vec2(0.5, 0), vec2(0.5, 1)},          -- Upper vertical
            {vec2(0.5, 1), vec2(1, 2)},             -- Left diagonal
            {vec2(0.5, 1), vec2(0, 2)},           -- Right diagonal
        },
        
        Z = {
            {vec2(0, 2), vec2(1.5, 2)},              -- Top horizontal line
            {vec2(1.5, 2), vec2(0, 0)},              -- Diagonal
            {vec2(0, 0), vec2(1.5, 0)},              -- Bottom horizontal line
        },

        ascii_33 = { -- '!'
            {vec2(0, 1), vec2(0, 2)},
            {vec2(0, 0), vec2(0, 0)},
        },
        
        ascii_34 = { -- '"'
            {vec2(0, 1.5), vec2(0, 2)},
            {vec2(0.5, 1.5), vec2(0.5, 2)},
        },
        
        ascii_35 = { -- '#'
            {vec2(0.25, 0), vec2(0.25, 2)},
            {vec2(0.75, 0), vec2(0.75, 2)},
            {vec2(0, 0.5), vec2(1, 0.5)},
            {vec2(0, 1.5), vec2(1, 1.5)},
        },
        
        ascii_36 = { -- '$'
            {vec2(1, 1.5), vec2(0.5, 2), vec2(0, 1.5), vec2(1, 0.5), vec2(0.5, 0), vec2(0, 0.5)},
            {vec2(0.5, 0), vec2(0.5, 2)},
        },
            
        ascii_37 = { -- '%'
            {vec2(0, 0), vec2(0.5, 0.5)},
            {vec2(1, 0), vec2(0, 1)},
            {vec2(0.25, 0.75), vec2(0.25, 0.75)}, -- Dot for the '%' symbol
            {vec2(0.75, 0.25), vec2(0.75, 0.25)}, -- Dot for the '%' symbol
        },
        
        ascii_38 = { -- '&'
            {vec2(1, 0.5), vec2(0.5, 0), vec2(0, 0.5), vec2(0.5, 1)},
            {vec2(0.75, 1.25), vec2(1.5, 0.5)},
            {vec2(0.25, 1), vec2(0.5, 0.75)},
        },
        
        ascii_39 = { -- '''
            {vec2(0.5, 1.5), vec2(0.5, 2)},
        },
        
        ascii_40 = { -- '('
            {vec2(0.75, 0), vec2(0.5, 0.25), vec2(0.5, 1.75), vec2(0.75, 2)},
        },
        
        ascii_41 = { -- ')'
            {vec2(0.25, 0), vec2(0.5, 0.25), vec2(0.5, 1.75), vec2(0.25, 2)},
        },
        
        ascii_42 = { -- '*'
            {vec2(0, 1), vec2(1, 1)},
            {vec2(0.5, 0.5), vec2(0.5, 1.5)},
            {vec2(0.25, 0.75), vec2(0.75, 1.25)},
            {vec2(0.25, 1.25), vec2(0.75, 0.75)},
        },
        
        ascii_43 = { -- '+'
            {vec2(0.5, 0.5), vec2(0.5, 1.5)},
            {vec2(0, 1), vec2(1, 1)},
        },
        
        ascii_44 = { -- ','
            {vec2(0.5, 0), vec2(0.25, -0.25)},
        },
        
        ascii_45 = { -- '-'
            {vec2(0, 1), vec2(1, 1)},
        },
        
        ascii_46 = { -- '.'
            {vec2(0.5, 0), vec2(0.5, 0)},
        },
        
        ascii_47 = { -- '/'
            {vec2(0, 0), vec2(1, 2)},
        },
        
        ascii_48 = { -- '0'
            {vec2(0.5, 0), vec2(1, 0.5), vec2(1, 1.5), vec2(0.5, 2), vec2(0, 1.5), vec2(0, 0.5), vec2(0.5, 0)},
        },
        
        ascii_49 = { -- '1'
            {vec2(0.5, 0), vec2(0.5, 2)},
        },
        
        ascii_50 = { -- '2'
            {vec2(0, 1.5), vec2(0.5, 2), vec2(1, 1.5), vec2(0, 0), vec2(1, 0)},
        },
        
        ascii_51 = { -- '3'
            {vec2(0, 2), vec2(1, 1.5), vec2(0.5, 1), vec2(1, 0.5), vec2(0, 0)},
        },
        
        ascii_52 = { -- '4'
            {vec2(0.75, 0), vec2(0.75, 2)},
            {vec2(0.25, 2), vec2(0.25, 1), vec2(1, 1)},
        },
        
        ascii_53 = { -- '5'
            {vec2(1, 2), vec2(0, 2), vec2(0, 1), vec2(1, 1), vec2(1, 0), vec2(0, 0)},
        },
        
        ascii_54 = { -- '6'
            {vec2(1, 1.5), vec2(0.5, 2), vec2(0, 1.5), vec2(0, 0.5), vec2(0.5, 0), vec2(1, 0.5), vec2(0.5, 1), vec2(0, 0.5)},
        },
        
        ascii_55 = { -- '7'
            {vec2(0, 2), vec2(1, 2), vec2(0.5, 0)},
        },
        
        ascii_56 = { -- '8'
            {vec2(0.5, 1), vec2(0, 1.5), vec2(0.5, 2), vec2(1, 1.5), vec2(0.5, 1), vec2(0, 0.5), vec2(0.5, 0), vec2(1, 0.5), vec2(0.5, 1)},
        },
        
        ascii_57 = { -- '9'
            {vec2(0, 0.5), vec2(0.5, 0), vec2(1, 0.5), vec2(1, 1.5), vec2(0.5, 2), vec2(0, 1.5), vec2(0.5, 1), vec2(1, 1.5)},
        },
        
        ascii_58 = { -- ':'
            {vec2(0.5, 1), vec2(0.5, 1)},
            {vec2(0.5, 0), vec2(0.5, 0)},
        },
        
        ascii_59 = { -- ';'
            {vec2(0.5, 1), vec2(0.5, 1)},
            {vec2(0.5, 0), vec2(0.25, -0.25)},
        },
        
        ascii_60 = { -- '<'
            {vec2(1, 0), vec2(0, 1), vec2(1, 2)},
        },
        
        ascii_61 = { -- '='
            {vec2(0, 0.75), vec2(1, 0.75)},
            {vec2(0, 1.25), vec2(1, 1.25)},
        },
        
        ascii_62 = { -- '>'
            {vec2(0, 0), vec2(1, 1), vec2(0, 2)},
        },
        
        ascii_63 = { -- '?'
            {vec2(0, 1.5), vec2(0.5, 2), vec2(1, 1.5), vec2(0.5, 1), vec2(0.5, 0.5)},
            {vec2(0.5, 0), vec2(0.5, 0)},
        },
        
        ascii_64 = { -- '@'
            {vec2(1, 0.5), vec2(0.5, 0), vec2(0, 0.5), vec2(0, 1.5), vec2(0.5, 2), vec2(1, 1.5), vec2(1, 0.75), vec2(0.5, 0.75)},
            {vec2(0.5, 1), vec2(1, 1)},
        },
    
    }

    local output = {}

    str = str:upper()

    for i = 1, #str do
        local letter = str:sub(i,i)
        local ascii = string.byte(letter)

        local strokes = nil

        if (ascii >= 65 and ascii <= 90) then -- if it's a letter
            strokes = font_table[letter]
        else
            strokes = font_table["ascii_"..tostring(ascii)] -- you can't index things like . so we need to use ascii
        end

        if strokes == nil then strokes = {} end

        output[#output+1] = strokes
    end

    return output
end

return iblib_font
