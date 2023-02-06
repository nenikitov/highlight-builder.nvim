--- Container for functions.
local U = {}


--- Clamp value to be in inclusive range.
---@param value number A number.
---@param min number Minimum value.
---@param max number Maximum value.
---@return number Clamped value.
local function clamp(value, min, max)
    return math.max(
        math.min(
            value,
            max
        ),
        min
    )
end


--- Convert a HEX color to RGB triplet.
---@param hex string HEX value of the color ("#RGB" or "#RRGGBB" format).
---@return number R component (0-255).
---@return number G component (0-255).
---@return number B component (0-255).
function U.hex_to_rgb(hex)
    local length = string.len(hex)
    assert(length == 4 or length == 7, 'Value "' .. hex .. '" is not a valid HEX color')

    if length == 4 then
        local r = hex:sub(2, 2)
        local g = hex:sub(3, 3)
        local b = hex:sub(4, 4)
        return U.hex_to_rgb('#' .. r .. r .. g .. g .. b .. b)
    else
        return
            ---@diagnostic disable-next-line: return-type-mismatch
            tonumber('0x' .. hex:sub(2, 3)),
            ---@diagnostic disable-next-line: return-type-mismatch
            tonumber('0x' .. hex:sub(4, 5)),
            ---@diagnostic disable-next-line: return-type-mismatch
            tonumber('0x' .. hex:sub(6, 7))
    end
end


--- Convert RGB triplet to HEX.
---@param r number R component (0-255).
---@param g number G component (0-255).
---@param b number B component (0-255).
---@return string HEX value of the color ("#RRGGBB" format).
function U.rgb_to_hex(r, g, b)
    r = clamp(r, 0, 255)
    g = clamp(g, 0, 255)
    b = clamp(b, 0, 255)
    local r_hex = string.format('%02x', math.floor(r))
    local g_hex = string.format('%02x', math.floor(g))
    local b_hex = string.format('%02x', math.floor(b))
    return '#' .. r_hex .. g_hex .. b_hex
end


--- Convert RGB int to HEX.
---@param int number RGB int (0 -  16777216).
---@return string HEX value of the color ("#RRGGBB" format).
function U.int_to_hex(int)
    int = clamp(int, 0, 256 * 256 * 256)
    return '#' .. string.format('%06x', math.floor(int))
end


--- Get a color in between colors.
---@param color_1 string HEX value of color 1.
---@param color_2 string HEX value of color 2.
---@param factor number Mix factor.
---    - 0 - full color 1
---    - 1 - full color 2
---    - 0-1 - in between
---@return string HEX value of the color ("#RRGGBB" format).
function U.mix_colors(color_1, color_2, factor)
    local color_1_r, color_1_g, color_1_b = U.hex_to_rgb(color_1)
    local color_2_r, color_2_g, color_2_b = U.hex_to_rgb(color_2)
    return U.rgb_to_hex(
        color_1_r + (color_2_r - color_1_r) * factor,
        color_1_g + (color_2_g - color_1_g) * factor,
        color_1_b + (color_2_b - color_1_b) * factor
    )
end


return U

