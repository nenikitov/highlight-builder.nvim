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
local function hex_to_rgb(hex)
    local length = string.len(hex)
    assert(length == 4 or length == 7, 'Value "' .. hex .. '" is not a valid HEX color')

    if length == 4 then
        local r = hex:sub(2, 2)
        local g = hex:sub(3, 3)
        local b = hex:sub(4, 4)
        return hex_to_rgb('#' .. r .. r .. g .. g .. b .. b)
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
local function rgb_to_hex(r, g, b)
    r = clamp(r, 0, 255)
    g = clamp(g, 0, 255)
    b = clamp(b, 0, 255)
    local r_hex = string.format('%02x', math.floor(r))
    local g_hex = string.format('%02x', math.floor(g))
    local b_hex = string.format('%02x', math.floor(b))
    return '#' .. r_hex .. g_hex .. b_hex
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
    local color_1_r, color_1_g, color_1_b = hex_to_rgb(color_1)
    local color_2_r, color_2_g, color_2_b = hex_to_rgb(color_2)
    return rgb_to_hex(
        color_1_r + (color_2_r - color_1_r) * factor,
        color_1_g + (color_2_g - color_1_g) * factor,
        color_1_b + (color_2_b - color_1_b) * factor
    )
end


--- Get a difference between 2 colors.
--- Uses a formula from [here](https://en.wikipedia.org/wiki/Color_difference#sRGB).
---@param color_1 string HEX value of color 1.
---@param color_2 string HEX value of color 2.
---@return number difference Difference.
local function color_difference(color_1, color_2)
    local color_1_r, color_1_g, color_1_b = hex_to_rgb(color_1)
    local color_2_r, color_2_g, color_2_b = hex_to_rgb(color_2)

    local delta_r = color_2_r - color_1_r
    local delta_g = color_2_g - color_1_g
    local delta_b = color_2_b - color_1_b

    local r = 0.5 * (color_1_r + color_2_r)
    return (
        (2 + r / 256) * delta_r * delta_r
        + 4 * delta_g * delta_g
        + (2 + (255 - r) / 256) * delta_b * delta_b
    )
end


--- Approximate a color using a color from a palette.
---@param color string HEX value of color to approximate.
---@param palette string[] HEX values of available colors.
---@return integer index Index of the closest color from the palette.
---@return string closest HEX value of the closest color from the palettte.
function U.find_closest_color(color, palette)
    local closest
    local difference
    local index

    for i, c in ipairs(palette) do
        local d = color_difference(color, c)
        if difference == nil or d < difference then
            closest = c
            difference = d
            index = i
        end
    end

    return index - 1, closest
end


return U

