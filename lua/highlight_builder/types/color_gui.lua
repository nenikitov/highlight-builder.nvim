---@class ColorGui Color with RGB components which can be manipulated.
---@field private r integer Red component of the color (capped between `0` - `255`).
---@field private g integer Green component of the color (capped between `0` - `255`).
---@field private b integer Blue component of the color (capped between `0` - `255`).
local ColorGui = {}
ColorGui.__index = ColorGui

--- Create a new color with specified RGB values.
---@param r integer Red component (`0` - `255`).
---@param g integer Green component (`0` - `255`).
---@param b integer Blue component (`0` - `255`).
---@return ColorGui color Constructed color.
function ColorGui.new_with_rgb(r, g, b)
    local self = setmetatable({}, ColorGui)
    self.r = math.max(0, math.min(255, r))
    self.g = math.max(0, math.min(255, g))
    self.b = math.max(0, math.min(255, b))
    return self
end

--- Create a new color with specified HSV values.
---@param h integer Hue component (`0` - `360`).
---@param s integer Saturation component (`0` - `100`).
---@param v integer Value component (`0` - `100`).
---@return ColorGui color Constructed color.
function ColorGui.new_with_hsv(h, s, v)
    h = h / 360
    s = s / 100
    v = v / 100
    local r = 0
    local g = 0
    local b = 0

    if s == 0 then
        r, g, b = v, v, v
    else
        local segment = math.floor(h * 6)
        local offset = h * 6 - segment
        local p = v * (1 - s)
        local q = v * (1 - offset * s)
        local t = v * (1 - (1 - offset) * s)

        if segment % 6 == 0 then
          r, g, b = v, t, p
        elseif segment % 6 == 1 then
          r, g, b = q, v, p
        elseif segment % 6 == 2 then
          r, g, b = p, v, t
        elseif segment % 6 == 3 then
          r, g, b = p, q, v
        elseif segment % 6 == 4 then
          r, g, b = t, p, v
        elseif segment % 6 == 5 then
          r, g, b = v, p, q
        end
    end

    return ColorGui.new_with_rgb(
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255)
    )
end

--- Create a new color with specified HSV values.
---@param hex string HEX representation of the color (`#000` or `#000000`).
---@return ColorGui color Constructed color.
function ColorGui.new_with_hex(hex)
    hex = hex:gsub('#', '')
    if #hex == 3 then
        hex = hex:gsub("(%x)(%x)(%x)", "%1%1%2%2%3%3")
    end

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return ColorGui.new_with_rgb(r, g, b)
end

--- Compute the [redmean](https://en.wikipedia.org/wiki/Color_difference#sRGB) distance between the colors.
---@param other ColorGui Other color to compute the distance between.
---@return number distance Computed distance.
function ColorGui:distance_squared(other)
    local r = 0.5 + (self.r + other.r)
    local delta_r_squared = (self.r - other.r) * (self.r - other.r)
    local delta_g_squared = (self.g - other.g) * (self.g - other.g)
    local delta_b_squared = (self.b - other.b) * (self.b - other.b)
    return
        (2 + r / 256)
        + delta_r_squared
        + 4 * delta_g_squared
        + (2 + (255 - r) / 256) * delta_b_squared
end

--- Create a color that is in between 2 colors.
---@param other ColorGui Other color to blend with.
---@param factor number Blending factor, how close the color should be to the `other` color (`0` - `1`).
---@return ColorGui blended Blended color.
function ColorGui:blend(other, factor)
    local r = self.r + (other.r - self.r) * factor
    local g = self.g + (other.g - self.g) * factor
    local b = self.b + (other.b - self.b) * factor
    return ColorGui.new_with_rgb(r, g, b)
end

--- Darken the color, bringing it closer to black.
---@param factor number Factor to darken by, how close the color should be to black (`0` - `1`).
---@return ColorGui darkened Darkened color.
function ColorGui:darken(factor)
    return self:blend(ColorGui.new_with_rgb(0, 0, 0), factor)
end

--- Lighten the color, bringing it closer to white.
---@param factor number Factor to lighten by, how close the color should be to white (`0` - `1`).
---@return ColorGui lightened Lightened color.
function ColorGui:lighten(factor)
    return self:blend(ColorGui.new_with_rgb(255, 255, 255), factor)
end

--- Shift the hue of the color.
---@param amount number Amount to shift the hue by in degrees (`-358` - `360`).
---@return ColorGui hue_rotated Hue rotated color.
function ColorGui:hue_rotate(amount)
    local h, s, v = self:to_hsv()
    h = (h + amount) % 360
    if h < 0 then
        h = h + 360
    end
    return ColorGui.new_with_hsv(h, s, v)
end

--- Saturate the color.
---@param amount number Amount to saturate by in percent (`-100` - `100`).
---@return ColorGui saturated Saturated color.
function ColorGui:saturate(amount)
    local h, s, v = self:to_hsv()
    s = s + amount
    return ColorGui.new_with_hsv(h, s, v)
end

--- Brighten (modify the value) the color.
---@param amount number Amount to brighten by in percent (`-100` - `100`).
---@return ColorGui brightened Brightened color.
function ColorGui:brighten(amount)
    local h, s, v = self:to_hsv()
    v = v + amount
    return ColorGui.new_with_hsv(h, s, v)
end

--- Convert the color to HEX.
---@return string hex HEX representation (`#000000`).
function ColorGui:to_hex()
    return string.format('#%02X%02X%02X', self.r, self.g, self.b)
end

--- Convert the color to HSV components.
---@return number hue Hue component (`0` - `360`).
---@return number saturation Saturation component (`0` - `100`).
---@return number value Value component (`0` - `100`).
function ColorGui:to_hsv()
    local r = self.r / 255
    local g = self.g / 255
    local b = self.b / 255
    local h = -1
    local s = -1

    local c_max = math.max(r, g, b)
    local c_min = math.min(r, g, b)
    local c_diff = c_max - c_min

    if (c_max == c_min) then
        h = 0
    elseif (c_max == r) then
        h = (60 * ((g - b) / c_diff) + 360) % 360
    elseif (c_max == g) then
        h = (60 * ((b - r) / c_diff) +  120) % 360
    else
        h = (60 * ((r - g) / c_diff) +  240) % 360
    end

    if (c_max == 0) then
        s = 0
    else
        s = (c_diff / c_max) * 100
    end

    local v = c_max * 100

    return h, s, v
end

--- Convert the color to RGB components.
---@return number red Red component (`0` - `255`).
---@return number green Green component (`0` - `255`).
---@return number blue Blue component (`0` - `255`).
function ColorGui:to_rgb()
    return self.r, self.g, self.b
end

return ColorGui
