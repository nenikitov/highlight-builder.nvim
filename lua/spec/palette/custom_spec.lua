---@diagnostic disable: undefined-field -- For `assert` module

local custom = require('highlight_builder.palette.custom')
local Color = require('highlight_builder.color')

describe('custom', function()
    it(
        'Should copy indexed colors and transform them if necessary, and not complete them to 256',
        function()
            local p = custom({
                primary = {
                    fg = Color.Gui.from_hex('#B4BFC5'),
                    bg = '#14161E',
                },
                dark = {
                    black = Color.Gui.from_hex('#20232B'),
                    red = '#ED3A66',
                    green = Color.Gui.from_hex('#70B74B'),
                    yellow = '#F89861',
                    blue = Color.Gui.from_hex('#26B1E4'),
                    magenta = '#B570EB',
                    cyan = Color.Gui.from_hex('#3CAEB2'),
                    white = '#A6ACB0',
                },
                bright = {
                    black = Color.Gui.from_hex('#5F656F'),
                    red = '#F3848A',
                    green = Color.Gui.from_hex('#B9D583'),
                    yellow = '#F2CBA5',
                    blue = Color.Gui.from_hex('#AED1FC'),
                    magenta = '#D39FED',
                    cyan = Color.Gui.from_hex('#89DACC'),
                    white = '#DDEBF2',
                },
            }, false)

            assert.are.same({
                primary = {
                    fg = Color.Gui.from_hex('#B4BFC5'),
                    bg = Color.Gui.from_hex('#14161E'),
                },
                indexed = {
                    Color.Gui.from_hex('#20232B'),
                    Color.Gui.from_hex('#ED3A66'),
                    Color.Gui.from_hex('#70B74B'),
                    Color.Gui.from_hex('#F89861'),
                    Color.Gui.from_hex('#26B1E4'),
                    Color.Gui.from_hex('#B570EB'),
                    Color.Gui.from_hex('#3CAEB2'),
                    Color.Gui.from_hex('#A6ACB0'),
                    Color.Gui.from_hex('#5F656F'),
                    Color.Gui.from_hex('#F3848A'),
                    Color.Gui.from_hex('#B9D583'),
                    Color.Gui.from_hex('#F2CBA5'),
                    Color.Gui.from_hex('#AED1FC'),
                    Color.Gui.from_hex('#D39FED'),
                    Color.Gui.from_hex('#89DACC'),
                    Color.Gui.from_hex('#DDEBF2'),
                },
            }, p)
        end
    )

    it(
        'Should copy indexed colors and transform them if necessary, and complete them to 256',
        function()
            local p = custom({
                primary = {
                    fg = Color.Gui.from_hex('#B4BFC5'),
                    bg = '#14161E',
                },
                dark = {
                    black = Color.Gui.from_hex('#20232B'),
                    red = '#ED3A66',
                    green = Color.Gui.from_hex('#70B74B'),
                    yellow = '#F89861',
                    blue = Color.Gui.from_hex('#26B1E4'),
                    magenta = '#B570EB',
                    cyan = Color.Gui.from_hex('#3CAEB2'),
                    white = '#A6ACB0',
                },
                bright = {
                    black = Color.Gui.from_hex('#5F656F'),
                    red = '#F3848A',
                    green = Color.Gui.from_hex('#B9D583'),
                    yellow = '#F2CBA5',
                    blue = Color.Gui.from_hex('#AED1FC'),
                    magenta = '#D39FED',
                    cyan = Color.Gui.from_hex('#89DACC'),
                    white = '#DDEBF2',
                },
            }, true)

            assert.are.same(Color.Gui.from_hex('#B4BFC5'), p.primary.fg)
            assert.are.same(Color.Gui.from_hex('#14161E'), p.primary.bg)

            assert.are.same(Color.Gui.from_hex('#20232B'), p.indexed[1])
            assert.are.same(Color.Gui.from_hex('#ED3A66'), p.indexed[2])
            assert.are.same(Color.Gui.from_hex('#70B74B'), p.indexed[3])
            assert.are.same(Color.Gui.from_hex('#F89861'), p.indexed[4])
            assert.are.same(Color.Gui.from_hex('#26B1E4'), p.indexed[5])
            assert.are.same(Color.Gui.from_hex('#B570EB'), p.indexed[6])
            assert.are.same(Color.Gui.from_hex('#3CAEB2'), p.indexed[7])
            assert.are.same(Color.Gui.from_hex('#A6ACB0'), p.indexed[8])
            assert.are.same(Color.Gui.from_hex('#5F656F'), p.indexed[9])
            assert.are.same(Color.Gui.from_hex('#F3848A'), p.indexed[10])
            assert.are.same(Color.Gui.from_hex('#B9D583'), p.indexed[11])
            assert.are.same(Color.Gui.from_hex('#F2CBA5'), p.indexed[12])
            assert.are.same(Color.Gui.from_hex('#AED1FC'), p.indexed[13])
            assert.are.same(Color.Gui.from_hex('#D39FED'), p.indexed[14])
            assert.are.same(Color.Gui.from_hex('#89DACC'), p.indexed[15])
            assert.are.same(Color.Gui.from_hex('#DDEBF2'), p.indexed[16])

            assert.are.same(256, #p.indexed)
        end
    )
end)
