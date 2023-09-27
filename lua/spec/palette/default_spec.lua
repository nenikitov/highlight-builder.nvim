---@diagnostic disable: undefined-field -- For `assert` module

local default = require('highlight_builder.palette.default')
local ColorGui = require('highlight_builder.color')

describe('default', function()
    for _, colors in ipairs({ 8, 16, 256 }) do
        it(
            'Should generate a default palette with ' .. tostring(colors) .. ' number of colors',
            function()
                local p = default(colors)
                assert.are.same(ColorGui.from_hex('#FFF'), p.primary.fg)
                assert.are.same(ColorGui.from_hex('#000'), p.primary.bg)
                assert.are.same(colors, #p.indexed)
            end
        )
    end
end)
