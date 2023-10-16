---@diagnostic disable: undefined-field -- For `assert` module

local default = require('highlight_builder.palette.default')
local Color = require('highlight_builder.color')

describe('default', function()
    for _, colors in ipairs({ 8, 16, 256 }) do
        it(
            'Should generate a default palette with ' .. tostring(colors) .. ' number of colors',
            function()
                local p = default(colors)
                assert.are.same(Color.Gui.from_hex('#FFF'), p.primary.fg)
                assert.are.same(Color.Gui.from_hex('#000'), p.primary.bg)
                assert.are.same(colors, #p.indexed)
            end
        )
    end
end)
