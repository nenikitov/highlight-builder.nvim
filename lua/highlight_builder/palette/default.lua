local custom = require('highlight_builder.palette.custom')

---@param colors 8 | 16 | 256
---@return Palette
return function(colors)
    local p = custom({
        primary = {
            fg = '#FFFFFF',
            bg = '#000000',
        },
        dark = {
            black = '#000000',
            red = '#AA0000',
            green = '#00AA00',
            yellow = '#AA5500',
            blue = '#0000AA',
            magenta = '#AA00AA',
            cyan = '#00AAAA',
            white = '#AAAAAA',
        },
        bright = {
            black = '#555555',
            red = '#FF5555',
            green = '#55FF55',
            yellow = '#FFFF55',
            blue = '#5555FF',
            magenta = '#FF55FF',
            cyan = '#55FFFF',
            white = '#FFFFFF',
        },
    }, true)

    ---@type Palette
    local reduced = {
        primary = p.primary,
        indexed = {},
    }

    for i = 1, colors do
        reduced.indexed[i] = p.indexed[i]
    end

    return reduced
end
