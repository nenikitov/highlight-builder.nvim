local Color = {}

--#region Term

---@alias Term8
---| 'NONE' Default foreground / background color
---| 0 Black
---| 1 Red
---| 2 Green
---| 3 Yellow
---| 4 Blue
---| 5 Magenta
---| 6 Cyan
---| 7 White

---@alias Term16
---| 'NONE' Default foreground / background color
---| 0 Dark black
---| 1 Dark red
---| 2 Dark green
---| 3 Dark yellow
---| 4 Dark blue
---| 5 Dark magenta
---| 6 Dark cyan
---| 7 Dark white
---| 8 Light black
---| 9 Red
---| 10 Green
---| 11 Yellow
---| 12 Blue
---| 13 Magenta
---| 14 Cyan
---| 15 White

---@alias Term256
---| Term16
---| (16  | 17  | 18  | 19  | 20  | 21  | 22  | 23  | 24  | 25  | 26  | 27  | 28  | 29  | 30  | 31  )
---| (32  | 33  | 34  | 35  | 36  | 37  | 38  | 39  | 40  | 41  | 42  | 43  | 44  | 45  | 46  | 47  )
---| (48  | 49  | 50  | 51  | 52  | 53  | 54  | 55  | 56  | 57  | 58  | 59  | 60  | 61  | 62  | 63  )
---| (64  | 65  | 66  | 67  | 68  | 69  | 70  | 71  | 72  | 73  | 74  | 75  | 76  | 77  | 78  | 79  )
---| (80  | 81  | 82  | 83  | 84  | 85  | 86  | 87  | 88  | 89  | 90  | 91  | 92  | 93  | 94  | 95  )
---| (96  | 97  | 98  | 99  | 100 | 101 | 102 | 103 | 104 | 105 | 106 | 107 | 108 | 109 | 110 | 111 )
---| (112 | 113 | 114 | 115 | 116 | 117 | 118 | 119 | 120 | 121 | 122 | 123 | 124 | 125 | 126 | 127 )
---| (128 | 129 | 130 | 131 | 132 | 133 | 134 | 135 | 136 | 137 | 138 | 139 | 140 | 141 | 142 | 143 )
---| (144 | 145 | 146 | 147 | 148 | 149 | 150 | 151 | 152 | 153 | 154 | 155 | 156 | 157 | 158 | 159 )
---| (160 | 161 | 162 | 163 | 164 | 165 | 166 | 167 | 168 | 169 | 170 | 171 | 172 | 173 | 174 | 175 )
---| (176 | 177 | 178 | 179 | 180 | 181 | 182 | 183 | 184 | 185 | 186 | 187 | 188 | 189 | 190 | 191 )
---| (192 | 193 | 194 | 195 | 196 | 197 | 198 | 199 | 200 | 201 | 202 | 203 | 204 | 205 | 206 | 207 )
---| (208 | 209 | 210 | 211 | 212 | 213 | 214 | 215 | 216 | 217 | 218 | 219 | 220 | 221 | 222 | 223 )
---| (224 | 225 | 226 | 227 | 228 | 229 | 230 | 231 | 232 | 233 | 234 | 235 | 236 | 237 | 238 | 239 )
---| (240 | 241 | 242 | 243 | 244 | 245 | 246 | 247 | 248 | 249 | 250 | 251 | 252 | 253 | 254 | 255 )

Color.Term = {}

Color.Term.indexes = {
    primary = {
        fg = 'NONE',
        bg = 'NONE',
    },
    normal = {
        black = 0,
        red = 1,
        green = 2,
        yellow = 3,
        blue = 4,
        magenta = 5,
        cyan = 6,
        white = 7,
    },
    bright = {
        black = 8,
        red = 9,
        green = 10,
        yellow = 11,
        blue = 12,
        magenta = 13,
        cyan = 14,
        white = 15,
    },
}

--- Get a brighter version of the terminal color.
---@param color Term16
---@return Term16 brightened
function Color.Term.brighten(color)
    if color == 'NONE' or (color + 8) > 16 then
        return color
    end

    return color + 8
end

--- Get a darker version of the terminal color.
---@param color Term16
---@return Term16 darkened
function Color.Term.darken(color)
    if color == 'NONE' or (color - 8) < 0 then
        return color
    end

    return color - 8
end

--- Get an index from looking up an indexed color.
---@param color Term256
---@return integer lookup
function Color.Term.lookup(color)
    return color + 1
end

--#endregion

--#region Gui

---@param number number
---@return number number
local function round(number)
    return math.floor(number + 0.5)
end

---@class Color.Gui with RGB components which can be manipulated.
---@field private r integer Red component of the color (capped between `0` - `255`).
---@field private g integer Green component of the color (capped between `0` - `255`).
---@field private b integer Blue component of the color (capped between `0` - `255`).
Color.Gui = {}
Color.Gui.__index = Color.Gui

--- Create a new color with specified RGB values.
---@param r integer Red component (`0` - `255`).
---@param g integer Green component (`0` - `255`).
---@param b integer Blue component (`0` - `255`).
---@return Color.Gui color Constructed color.
function Color.Gui.from_rgb(r, g, b)
    local self = setmetatable({}, Color.Gui)
    self.r = math.max(0, math.min(255, math.floor(r)))
    self.g = math.max(0, math.min(255, math.floor(g)))
    self.b = math.max(0, math.min(255, math.floor(b)))
    return self
end

--- Create a new color with specified HSV values.
---@param h integer Hue component (`0` - `360`).
---@param s integer Saturation component (`0` - `100`).
---@param v integer Value component (`0` - `100`).
---@return Color.Gui color Constructed color.
function Color.Gui.from_hsv(h, s, v)
    h = math.max(0, math.min(1, h / 360))
    s = math.max(0, math.min(1, s / 100))
    v = math.max(0, math.min(1, v / 100))
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

    return Color.Gui.from_rgb(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

--- Create a new color with specified HSV values.
---@param hex string HEX representation of the color (`#000` or `#000000`).
---@return Color.Gui color Constructed color.
function Color.Gui.from_hex(hex)
    hex = hex:gsub('#', '')
    if #hex == 3 then
        hex = hex:gsub('(%x)(%x)(%x)', '%1%1%2%2%3%3')
    end

    assert(#hex == 6, 'Invalid hex color passed (' .. hex .. ')')

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    return Color.Gui.from_rgb(r, g, b)
end

--- Compute the distance between the colors.
---@param other Color.Gui Other color to compute the distance between.
---@return number distance Computed distance.
function Color.Gui:distance_squared(other)
    local delta_r = (self.r - other.r)
    local delta_g = (self.g - other.g)
    local delta_b = (self.b - other.b)
    return delta_r * delta_r + delta_g * delta_g + delta_b * delta_b
end

--- Create a color that is in between 2 colors.
---@param other Color.Gui Other color to blend with.
---@param factor number Blending factor, how close the color should be to the `other` color (`0` - `1`).
---@return Color.Gui blended Blended color.
function Color.Gui:blend(other, factor)
    local r = self.r + (other.r - self.r) * factor
    local g = self.g + (other.g - self.g) * factor
    local b = self.b + (other.b - self.b) * factor
    return Color.Gui.from_rgb(r, g, b)
end

--- Darken the color, bringing it closer to black.
---@param factor number Factor to darken by, how close the color should be to black (`0` - `1`).
---@return Color.Gui darkened Darkened color.
function Color.Gui:darken(factor)
    return self:blend(Color.Gui.from_rgb(0, 0, 0), factor)
end

--- Lighten the color, bringing it closer to white.
---@param factor number Factor to lighten by, how close the color should be to white (`0` - `1`).
---@return Color.Gui lightened Lightened color.
function Color.Gui:lighten(factor)
    return self:blend(Color.Gui.from_rgb(255, 255, 255), factor)
end

--- Shift the hue of the color.
---@param amount number Amount to shift the hue by in degrees (`-360` - `360`).
---@return Color.Gui hue_rotated Hue rotated color.
function Color.Gui:hue_rotate(amount)
    local h, s, v = self:to_hsv()
    h = (h + amount) % 360
    if h < 0 then
        h = h + 360
    end
    return Color.Gui.from_hsv(h, s, v)
end

--- Saturate the color.
---@param amount number Amount to saturate by in percent (`-100` - `100`).
---@return Color.Gui saturated Saturated color.
function Color.Gui:saturate(amount)
    local h, s, v = self:to_hsv()
    return Color.Gui.from_hsv(h, s + amount, v)
end

--- Brighten (modify the value) the color.
---@param amount number Amount to brighten by in percent (`-100` - `100`).
---@return Color.Gui brightened Brightened color.
function Color.Gui:brighten(amount)
    local h, s, v = self:to_hsv()
    return Color.Gui.from_hsv(h, s, v + amount)
end

--- Convert the color to HEX.
---@return string hex HEX representation (`#000000`).
function Color.Gui:to_hex()
    return string.format('#%02X%02X%02X', self.r, self.g, self.b)
end

--- Convert the color to HSV components.
---@return number hue Hue component (`0` - `360`).
---@return number saturation Saturation component (`0` - `100`).
---@return number value Value component (`0` - `100`).
function Color.Gui:to_hsv()
    local r = self.r / 255
    local g = self.g / 255
    local b = self.b / 255
    local h
    local s

    local c_max = math.max(r, g, b)
    local c_min = math.min(r, g, b)
    local c_diff = c_max - c_min

    if c_max == c_min then
        h = 0
    elseif c_max == r then
        h = (60 * ((g - b) / c_diff) + 360) % 360
    elseif c_max == g then
        h = (60 * ((b - r) / c_diff) + 120) % 360
    else
        h = (60 * ((r - g) / c_diff) + 240) % 360
    end

    if c_max == 0 then
        s = 0
    else
        s = (c_diff / c_max) * 100
    end

    local v = c_max * 100

    return round(h), round(s), round(v)
end

--- Convert the color to RGB components.
---@return number red Red component (`0` - `255`).
---@return number green Green component (`0` - `255`).
---@return number blue Blue component (`0` - `255`).
function Color.Gui:to_rgb()
    return self.r, self.g, self.b
end

--#endregion

return Color
