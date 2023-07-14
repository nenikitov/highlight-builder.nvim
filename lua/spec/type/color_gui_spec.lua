local ColorGui = require('highlight_builder.type.color_gui')

describe('ColorGui', function()
    describe('new_wtih_rgb', function()
        for _, v in ipairs({
            { 179, 243, 247 },
            { 221, 127, 215 },
            { 4,   4,   6 },
            { 247, 241, 232 },
        }) do
            it(
                'Should initialize R G B values correctly for color rgb('
                .. v[1]
                .. ', '
                .. v[2]
                .. ', '
                .. v[3]
                .. ')',
                function()
                    local color = ColorGui.new_with_rgb(v[1], v[2], v[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(v, { r, g, b })
                end
            )
        end

        for _, v in ipairs({
            { { 274, 134, 95 },     { 255, 134, 95 } },
            { { 214, 300, 252 },    { 214, 255, 252 } },
            { { 215, 182, 1000 },   { 215, 182, 255 } },
            { { 800, 900, 500 },    { 255, 255, 255 } },

            { { -274, 134, 95 },    { 0, 134, 95 } },
            { { 214, -300, 252 },   { 214, 0, 252 } },
            { { 215, 182, -1000 },  { 215, 182, 0 } },
            { { -800, -900, -500 }, { 0, 0, 0 } },
        }) do
            it(
                'Should cap R G B values to 0-255 for color rgb('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ')',
                function()
                    local initial = v[1]
                    local capped = v[2]
                    local color = ColorGui.new_with_rgb(initial[1], initial[2], initial[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(capped, { r, g, b })
                end
            )
        end
    end)

    describe('new_with_hsv', function()
        for _, v in ipairs({
            { { 2, 92, 53 },   { 135, 14, 10 } },
            { { 29, 21, 49 },  { 124, 111, 98 } },
            { { 52, 71, 46 },  { 117, 106, 34 } },
            { { 143, 92, 57 }, { 11, 145, 62 } },
            { { 207, 67, 56 }, { 47, 99, 142 } },
            { { 267, 56, 93 }, { 164, 104, 237 } },
            { { 302, 69, 35 }, { 89, 27, 87 } },
        }) do
            it(
                'Should initialize R G B values correctly for color hsv('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ')',
                function()
                    local hsv = v[1]
                    local rgb = v[2]
                    local color = ColorGui.new_with_hsv(hsv[1], hsv[2], hsv[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(rgb, { r, g, b })
                end
            )
        end

        for _, v in ipairs({
            { { 400, 92, 53 },      { 360, 92, 53 } },
            { { 29, 120, 49 },      { 29, 100, 49 } },
            { { 52, 71, 221 },      { 52, 71, 100 } },
            { { 362, 500, 221 },    { 360, 100, 100 } },
            { { -400, 92, 53 },     { 0, 92, 53 } },
            { { 29, -120, 49 },     { 29, 0, 49 } },
            { { 52, 71, -221 },     { 52, 71, 0 } },
            { { -362, -500, -221 }, { 0, 0, 0 } },
        }) do
            it(
                'Should cap H S V values for color hsv('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ')',
                function()
                    local initial = v[1]
                    local capped = v[2]
                    local color_initial = ColorGui.new_with_hsv(initial[1], initial[2], initial[3])
                    local color_capped = ColorGui.new_with_hsv(capped[1], capped[2], capped[3])
                    local initial_r, initial_g, initial_b = color_initial:to_rgb()
                    local capped_r, capped_g, capped_b = color_capped:to_rgb()
                    assert.are.same(
                        { capped_r, capped_g, capped_b },
                        { initial_r, initial_g, initial_b }
                    )
                end
            )
        end
    end)

    describe('new_with_hex', function()
        for _, v in ipairs({
            { '15c',     { 17, 85, 204 } },
            { '#15c',    { 17, 85, 204 } },
            { '15C',     { 17, 85, 204 } },
            { '#15C',    { 17, 85, 204 } },
            { 'e7ce36',  { 231, 206, 54 } },
            { '#e7ce36', { 231, 206, 54 } },
            { 'E7CE36',  { 231, 206, 54 } },
            { '#E7CE36', { 231, 206, 54 } },
        }) do
            it('Should initialize R G B values correctly for color hex(' .. v[1] .. ')', function()
                local hex = v[1]
                local rgb = v[2]
                local color = ColorGui.new_with_hex(hex)
                local r, g, b = color:to_rgb()
                assert.are.same(rgb, { r, g, b })
            end)
        end

        for _, v in ipairs({
            '1',
            '#1',
            '12',
            '#12',
            '1234',
            '#1234',
            '12334567890',
            '#12334567890',
            '#abu',
            '#12345x',
        }) do
            it('Should fail for invalid color hex(' .. v .. ')', function()
                assert.has.errors(function()
                    ColorGui.new_with_hex(v)
                end)
            end)
        end
    end)

    describe('distance_squared', function()
        for _, v in ipairs({
            { { 104, 189, 135 }, { 104, 189, 135 }, 0 },
            { { 0, 0, 0 },       { 255, 255, 255 }, 195075 },
            { { 194, 63, 133 },  { 132, 41, 131 },  4332 },
            { { 185, 54, 247 },  { 245, 223, 188 }, 35642 },
        }) do
            it(
                'Should compute correct distance for colors rgb('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ')'
                .. ' and rgb('
                .. v[2][1]
                .. ', '
                .. v[2][2]
                .. ', '
                .. v[2][3]
                .. ')',
                function()
                    local color_1 = ColorGui.new_with_rgb(v[1][1], v[1][2], v[1][3])
                    local color_2 = ColorGui.new_with_rgb(v[2][1], v[2][2], v[2][3])
                    local distance = color_1:distance_squared(color_2)
                    assert.are.equal(v[3], distance)
                end
            )
        end

        it('Should be commutative', function()
            local color_1 = ColorGui.new_with_rgb(104, 213, 69)
            local color_2 = ColorGui.new_with_rgb(211, 204, 197)
            local distance_1 = color_1:distance_squared(color_2)
            local distance_2 = color_2:distance_squared(color_1)
            assert.are.equal(distance_1, distance_2)
        end)
    end)

    describe('blend', function()
        for _, v in ipairs({
            { { 221, 117, 51 },  { 11, 14, 71 },    0.0,  { 221, 117, 51 } },
            { { 221, 117, 51 },  { 11, 14, 71 },    1.0,  { 11, 14, 71 } },
            { { 50, 38, 66 },    { 228, 139, 174 }, 0.3,  { 103, 68, 98 } },
            { { 194, 188, 161 }, { 12, 85, 120 },   0.9,  { 30, 95, 124 } },
            { { 39, 164, 240 },  { 28, 55, 3 },     -0.5, { 44, 218, 255 } },
            { { 130, 147, 11 },  { 12, 58, 82 },    2.0,  { 0, 0, 153 } },
        }) do
            it(
                'Should correctly blend colors rgb('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ')'
                .. ' and rgb('
                .. v[2][1]
                .. ', '
                .. v[2][2]
                .. ', '
                .. v[2][3]
                .. ') with factor '
                .. v[3],
                function()
                    local color_1 = ColorGui.new_with_rgb(v[1][1], v[1][2], v[1][3])
                    local color_2 = ColorGui.new_with_rgb(v[2][1], v[2][2], v[2][3])
                    local factor = v[3]
                    local blended = color_1:blend(color_2, factor)
                    assert.are.same(ColorGui.new_with_rgb(v[4][1], v[4][2], v[4][3]), blended)
                end
            )
        end
    end)

    describe('lighen', function()
        for _, v in ipairs({
            { {10, 10, 10}, 0.2, {59, 59, 59} },
            { {0, 0, 0}, 0.2, {51, 51, 51} },
        }) do
            it(
                'Should correctly lighten color rgb('
                .. v[1][1]
                .. ', '
                .. v[1][2]
                .. ', '
                .. v[1][3]
                .. ') with factor '
                .. v[2],
                function()
                    local color = ColorGui.new_with_rgb(v[1][1], v[1][2], v[1][3])
                    local factor = v[2]
                    local lightened = color:lighten(factor)
                    assert.are.same(ColorGui.new_with_rgb(v[3][1], v[3][2], v[3][3]), lightened)
                end
            )
        end
    end)
end)
