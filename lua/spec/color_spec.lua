---@diagnostic disable: undefined-field -- For `assert` module

local say = require('say')
local ColorGui = require('highlight_builder.color')

---@param _ unknown
---@param arguments {[1 | 2]: ColorGui}
---@return boolean
local function color_equals(_, arguments)
    local color_1 = arguments[1]
    local color_2 = arguments[2]

    local max_distance = ColorGui.from_rgb(0, 0, 0):distance_squared(ColorGui.from_rgb(2, 2, 2))
    local distance = ColorGui.distance_squared(color_1, color_2)

    return distance < max_distance
end

say:set('assertion.color_equals.positive', 'Expected color rgb(%s)\nto be close enough to rgb(%s)')
say:set('assertion.color_equals.negative', 'Expected color rgb(%s)\nnot to be close to rgb(%s)')
assert:register(
    'assertion',
    'color_equals',
    color_equals,
    'assertion.color_equals.positive',
    'assertion.color_equals.negative'
)

describe('ColorGui', function()
    describe('from_rgb', function()
        for _, v in ipairs({
            { 179, 243, 247 },
            { 221, 127, 215 },
            { 4, 4, 6 },
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
                    local color = ColorGui.from_rgb(v[1], v[2], v[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(v, { r, g, b })
                end
            )
        end

        for _, v in ipairs({
            { { 274, 134, 95 }, { 255, 134, 95 } },
            { { 214, 300, 252 }, { 214, 255, 252 } },
            { { 215, 182, 1000 }, { 215, 182, 255 } },
            { { 800, 900, 500 }, { 255, 255, 255 } },

            { { -274, 134, 95 }, { 0, 134, 95 } },
            { { 214, -300, 252 }, { 214, 0, 252 } },
            { { 215, 182, -1000 }, { 215, 182, 0 } },
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
                    local color = ColorGui.from_rgb(initial[1], initial[2], initial[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(capped, { r, g, b })
                end
            )
        end
    end)

    describe('from_hsv', function()
        for _, v in ipairs({
            { { 2, 92, 53 }, { 135, 14, 10 } },
            { { 29, 21, 49 }, { 124, 111, 98 } },
            { { 52, 71, 46 }, { 117, 106, 34 } },
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
                    local color = ColorGui.from_hsv(hsv[1], hsv[2], hsv[3])
                    local r, g, b = color:to_rgb()
                    assert.are.same(rgb, { r, g, b })
                end
            )
        end

        for _, v in ipairs({
            { { 400, 92, 53 }, { 360, 92, 53 } },
            { { 29, 120, 49 }, { 29, 100, 49 } },
            { { 52, 71, 221 }, { 52, 71, 100 } },
            { { 362, 500, 221 }, { 360, 100, 100 } },
            { { -400, 92, 53 }, { 0, 92, 53 } },
            { { 29, -120, 49 }, { 29, 0, 49 } },
            { { 52, 71, -221 }, { 52, 71, 0 } },
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
                    local color_initial = ColorGui.from_hsv(initial[1], initial[2], initial[3])
                    local color_capped = ColorGui.from_hsv(capped[1], capped[2], capped[3])
                    assert.are.same(color_capped, color_initial)
                end
            )
        end
    end)

    describe('from_hex', function()
        for _, v in ipairs({
            { '15c', { 17, 85, 204 } },
            { '#15c', { 17, 85, 204 } },
            { '15C', { 17, 85, 204 } },
            { '#15C', { 17, 85, 204 } },
            { 'e7ce36', { 231, 206, 54 } },
            { '#e7ce36', { 231, 206, 54 } },
            { 'E7CE36', { 231, 206, 54 } },
            { '#E7CE36', { 231, 206, 54 } },
        }) do
            it('Should initialize R G B values correctly for color hex(' .. v[1] .. ')', function()
                local hex = v[1]
                local rgb = v[2]
                local color = ColorGui.from_hex(hex)
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
                    ColorGui.from_hex(v)
                end)
            end)
        end
    end)

    describe('distance_squared', function()
        for _, v in ipairs({
            { { 104, 189, 135 }, { 104, 189, 135 }, 0 },
            { { 0, 0, 0 }, { 255, 255, 255 }, 195075 },
            { { 194, 63, 133 }, { 132, 41, 131 }, 4332 },
            { { 185, 54, 247 }, { 245, 223, 188 }, 35642 },
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
                    local color_1 = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local color_2 = ColorGui.from_rgb(v[2][1], v[2][2], v[2][3])
                    local distance = color_1:distance_squared(color_2)
                    assert.are.equal(v[3], distance)
                end
            )
        end

        it('Should be commutative', function()
            local color_1 = ColorGui.from_rgb(104, 213, 69)
            local color_2 = ColorGui.from_rgb(211, 204, 197)
            local distance_1 = color_1:distance_squared(color_2)
            local distance_2 = color_2:distance_squared(color_1)
            assert.are.equal(distance_1, distance_2)
        end)
    end)

    describe('blend', function()
        for _, v in ipairs({
            { { 221, 117, 51 }, { 11, 14, 71 }, 0.0, { 221, 117, 51 } },
            { { 221, 117, 51 }, { 11, 14, 71 }, 1.0, { 11, 14, 71 } },
            { { 50, 38, 66 }, { 228, 139, 174 }, 0.3, { 103, 68, 98 } },
            { { 194, 188, 161 }, { 12, 85, 120 }, 0.9, { 30, 95, 124 } },
            { { 39, 164, 240 }, { 28, 55, 3 }, -0.5, { 44, 218, 255 } },
            { { 130, 147, 11 }, { 12, 58, 82 }, 2.0, { 0, 0, 153 } },
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
                    local color_1 = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local color_2 = ColorGui.from_rgb(v[2][1], v[2][2], v[2][3])
                    local factor = v[3]
                    local blended = color_1:blend(color_2, factor)
                    assert.are.same(ColorGui.from_rgb(v[4][1], v[4][2], v[4][3]), blended)
                end
            )
        end
    end)

    describe('darken', function()
        for _, v in ipairs({
            { { 241, 227, 24 }, 0.0, { 241, 227, 24 } },
            { { 160, 149, 34 }, 0.2, { 128, 119, 27 } },
            { { 237, 250, 245 }, 1.0, { 0, 0, 0 } },
        }) do
            it(
                'Should correctly darken color rgb('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') with factor '
                    .. v[2],
                function()
                    local color = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local factor = v[2]
                    local lightened = color:darken(factor)
                    assert.are.same(ColorGui.from_rgb(v[3][1], v[3][2], v[3][3]), lightened)
                end
            )
        end
    end)

    describe('lighen', function()
        for _, v in ipairs({
            { { 241, 227, 24 }, 0.0, { 241, 227, 24 } },
            { { 160, 149, 34 }, 0.2, { 179, 170, 78 } },
            { { 237, 250, 245 }, 1.0, { 255, 255, 255 } },
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
                    local color = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local factor = v[2]
                    local lightened = color:lighten(factor)
                    assert.are.same(ColorGui.from_rgb(v[3][1], v[3][2], v[3][3]), lightened)
                end
            )
        end
    end)

    describe('hue_rotate', function()
        for _, v in ipairs({
            { { 73, 40, 48 }, 0, { 73, 40, 48 } },
            { { 55, 65, 38 }, 20, { 75, 65, 38 } },
            { { 131, 2, 45 }, -20, { 110, 2, 45 } },
            { { 320, 17, 8 }, 80, { 40, 17, 8 } },
            { { 320, 17, 8 }, 440, { 40, 17, 8 } },
            { { 2, 74, 89 }, -80, { 282, 74, 89 } },
            { { 2, 74, 89 }, -440, { 282, 74, 89 } },
        }) do
            it(
                'Should correctly hue rotate color hsv('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') by a amount '
                    .. v[2],
                function()
                    local color = ColorGui.from_hsv(v[1][1], v[1][2], v[1][3])
                    local amount = v[2]
                    local hue_rotated = color:hue_rotate(amount)
                    assert.color_equals(ColorGui.from_hsv(v[3][1], v[3][2], v[3][3]), hue_rotated)
                end
            )
        end
    end)

    describe('saturate', function()
        for _, v in ipairs({
            { { 73, 40, 48 }, 0, { 73, 40, 48 } },
            { { 55, 65, 38 }, 20, { 55, 85, 38 } },
            { { 131, 76, 45 }, -20, { 131, 56, 45 } },
            { { 320, 17, 8 }, 100, { 320, 100, 8 } },
            { { 2, 74, 89 }, -100, { 2, 0, 89 } },
        }) do
            it(
                'Should correctly saturate color hsv('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') by a amount '
                    .. v[2],
                function()
                    local color = ColorGui.from_hsv(v[1][1], v[1][2], v[1][3])
                    local amount = v[2]
                    local saturated = color:saturate(amount)
                    assert.color_equals(ColorGui.from_hsv(v[3][1], v[3][2], v[3][3]), saturated)
                end
            )
        end
    end)

    describe('brighten', function()
        for _, v in ipairs({
            { { 73, 40, 48 }, 0, { 73, 40, 48 } },
            { { 55, 65, 38 }, 20, { 55, 65, 58 } },
            { { 131, 76, 45 }, -20, { 131, 76, 25 } },
            -- TODO(Fix this test)
            -- { { 320, 17, 8 }, 100, { 320, 17, 100 } },
            { { 2, 74, 89 }, -100, { 2, 74, 0 } },
        }) do
            it(
                'Should correctly brighten color hsv('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') by a amount '
                    .. v[2],
                function()
                    local color = ColorGui.from_hsv(v[1][1], v[1][2], v[1][3])
                    local amount = v[2]
                    local saturated = color:brighten(amount)
                    assert.color_equals(ColorGui.from_hsv(v[3][1], v[3][2], v[3][3]), saturated)
                end
            )
        end
    end)

    describe('to_hex', function()
        for _, v in ipairs({
            { { 30, 215, 28 }, '#1ED71C' },
            { { 8, 2, 84 }, '#080254' },
            { { 92, 35, 101 }, '#5C2365' },
            { { 244, 238, 251 }, '#F4EEFB' },
            { { 83, 43, 56 }, '#532B38' },
        }) do
            it(
                'Should correctly convert color rgb('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') to hex',
                function()
                    local color = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local hex = color:to_hex()
                    assert.are.same(v[2], hex)
                end
            )
        end

        for _, v in ipairs({
            { 65, 26, 20 },
            { 182, 74, 45 },
            { 244, 222, 144 },
            { 85, 239, 87 },
            { 54, 66, 123 },
            { 188, 153, 215 },
            { 224, 174, 228 },
        }) do
            it(
                'Should be the reverse of new_from_hex for color rgb('
                    .. v[1]
                    .. ', '
                    .. v[2]
                    .. ', '
                    .. v[3]
                    .. ')',
                function()
                    local original = ColorGui.from_rgb(v[1], v[2], v[3])
                    local transformed = ColorGui.from_hex(original:to_hex())
                    assert.are.same(original, transformed)
                end
            )
        end
    end)

    describe('to_hsv', function()
        for _, v in ipairs({
            { { 30, 215, 28 }, { 119, 87, 84 } },
            { { 8, 2, 84 }, { 244, 98, 33 } },
            { { 92, 35, 101 }, { 292, 65, 40 } },
            { { 244, 238, 251 }, { 268, 5, 98 } },
            { { 83, 43, 56 }, { 341, 48, 33 } },
        }) do
            it(
                'Should correctly convert color rgb('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') to hsv',
                function()
                    local color = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local color_h, color_s, color_v = color:to_hsv()
                    assert.are.same(
                        { h = v[2][1], s = v[2][2], v = v[2][3] },
                        { h = color_h, s = color_s, v = color_v }
                    )
                end
            )
        end

        for _, v in ipairs({
            { 65, 26, 20 },
            { 182, 74, 45 },
            { 244, 222, 144 },
            { 85, 239, 87 },
            { 54, 66, 123 },
            { 188, 153, 215 },
            { 224, 174, 228 },
        }) do
            it(
                'Should be the reverse of new_from_hsv for color rgb('
                    .. v[1]
                    .. ', '
                    .. v[2]
                    .. ', '
                    .. v[3]
                    .. ')',
                function()
                    local original = ColorGui.from_rgb(v[1], v[2], v[3])
                    local transformed = ColorGui.from_hsv(original:to_hsv())
                    assert.color_equals(original, transformed)
                end
            )
        end
    end)

    describe('to_rgb', function()
        for _, v in ipairs({
            { { 30, 215, 28 } },
            { { 8, 2, 84 } },
            { { 92, 35, 101 } },
            { { 244, 238, 251 } },
            { { 83, 43, 56 } },
        }) do
            it(
                'Should correctly convert color rgb('
                    .. v[1][1]
                    .. ', '
                    .. v[1][2]
                    .. ', '
                    .. v[1][3]
                    .. ') to rgb',
                function()
                    local color = ColorGui.from_rgb(v[1][1], v[1][2], v[1][3])
                    local r, g, b = color:to_rgb()
                    assert.are.same({ v[1][1], v[1][2], v[1][3] }, { r, g, b })
                end
            )
        end

        for _, v in ipairs({
            { 65, 26, 20 },
            { 182, 74, 45 },
            { 244, 222, 144 },
            { 85, 239, 87 },
            { 54, 66, 123 },
            { 188, 153, 215 },
            { 224, 174, 228 },
        }) do
            it(
                'Should be the reverse of new_from_rgb for color rgb('
                    .. v[1]
                    .. ', '
                    .. v[2]
                    .. ', '
                    .. v[3]
                    .. ')',
                function()
                    local original = ColorGui.from_rgb(v[1], v[2], v[3])
                    local transformed = ColorGui.from_rgb(original:to_rgb())
                    assert.color_equals(original, transformed)
                end
            )
        end
    end)
end)
