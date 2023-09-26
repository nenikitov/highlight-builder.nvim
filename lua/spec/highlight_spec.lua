---@diagnostic disable: undefined-field -- For `assert` module

local HighlightSetting = require('highlight_builder.highlight')
local ColorGui = require('highlight_builder.color')

---@type Palette
local palette = {
    primary = {
        fg = ColorGui.from_hex('#FFF'),
        bg = ColorGui.from_hex('#000'),
    },
    indexed = {
        ColorGui.from_hex('#111'),
        ColorGui.from_hex('#A00'),
        ColorGui.from_hex('#0A0'),
        ColorGui.from_hex('#AA0'),
        ColorGui.from_hex('#00A'),
        ColorGui.from_hex('#A0A'),
        ColorGui.from_hex('#0AA'),
        ColorGui.from_hex('#AAA'),
    },
}

describe('HighlightSetting', function()
    describe('new', function()
        it('Should convert HEX colors to Color class', function()
            local highlight = HighlightSetting.new({
                gui = {
                    bg = '#123456',
                    fg = '#789',
                    sp = '#FFBCDE',
                },
            })
            local bg_r, bg_g, bg_b = highlight.gui.bg:to_rgb()
            assert.are.same({ bg_r, bg_g, bg_b }, { 0x12, 0x34, 0x56 })
            local fg_r, fg_g, fg_b = highlight.gui.fg:to_rgb()
            assert.are.same({ fg_r, fg_g, fg_b }, { 0x77, 0x88, 0x99 })
            local sp_r, sp_g, sp_b = highlight.gui.sp:to_rgb()
            assert.are.same({ sp_r, sp_g, sp_b }, { 0xFF, 0xBC, 0xDE })
        end)
    end)

    describe('complete', function()
        describe('link', function()
            it('Should prioritise link over all properties', function()
                local highlight = HighlightSetting.new({
                    link = 'MyLink',
                    gui = {
                        fg = '#123456',
                    },
                }):complete(palette)
                assert.are.same({ link = 'MyLink' }, highlight)
            end)
        end)

        describe('Term without gui', function()
            it('Should copy style', function()
                local highlight = HighlightSetting.new({
                    term = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                    gui = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                }, highlight)
            end)

            it('Should copy fg from palette', function()
                local highlight = HighlightSetting.new({
                    term = {
                        fg = 3,
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        fg = 3,
                    },
                    gui = {
                        fg = palette.indexed[4],
                    },
                }, highlight)
            end)

            it('Should copy bg from palette', function()
                local highlight = HighlightSetting.new({
                    term = {
                        bg = 1,
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        bg = 1,
                    },
                    gui = {
                        bg = palette.indexed[2],
                    },
                }, highlight)
            end)
        end)

        describe('Gui without term', function()
            it('Should copy style', function()
                local highlight = HighlightSetting.new({
                    gui = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                    gui = {
                        style = {
                            bold = true,
                            underline = true,
                        },
                    },
                }, highlight)
            end)

            it('Should copy fg from palette', function()
                local highlight = HighlightSetting.new({
                    gui = {
                        fg = ColorGui.from_hex('#AA0000'),
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        fg = 1,
                    },
                    gui = {
                        fg = ColorGui.from_hex('#AA0000'),
                    },
                }, highlight)
            end)

            it('Should copy bg from palette', function()
                local highlight = HighlightSetting.new({
                    gui = {
                        bg = ColorGui.from_hex('#000'),
                    },
                }):complete(palette)
                assert.are.same({
                    term = {
                        bg = 'NONE',
                    },
                    gui = {
                        bg = ColorGui.from_hex('#000'),
                    },
                }, highlight)
            end)
        end)

        describe('Gui and term', function()
            it('Should conserve all values', function()
                local highlight = HighlightSetting.new({
                    gui = {
                        fg = '#123456',
                    },
                    term = {
                        fg = 3,
                        style = {
                            undercurl = true,
                            strikethrough = true,
                        },
                    },
                }):complete(palette)
                assert.are.same({
                    gui = {
                        fg = ColorGui.from_hex('#123456'),
                    },
                    term = {
                        fg = 3,
                        style = {
                            undercurl = true,
                            strikethrough = true,
                        },
                    },
                }, highlight)
            end)

            it('Should conserve even with empty style', function()
                local highlight = HighlightSetting.new({
                    gui = {},
                    term = {
                        fg = 3,
                        style = {
                            undercurl = true,
                            strikethrough = true,
                        },
                    },
                }):complete(palette)
                assert.are.same({
                    gui = {},
                    term = {
                        fg = 3,
                        style = {
                            undercurl = true,
                            strikethrough = true,
                        },
                    },
                }, highlight)
            end)
        end)
    end)

    describe('compile', function()
        it('Should translate link', function()
            local highlight = HighlightSetting.new({
                link = 'Hello',
            }):compile(palette)
            assert.are.same({
                link = 'Hello',
            }, highlight)
        end)

        it('Should translate all properties', function()
            local highlight = HighlightSetting.new({
                term = {
                    fg = 2,
                    bg = nil,
                    style = {
                        bold = true,
                    },
                },
                gui = {
                    fg = '#123',
                    bg = '#FAB',
                    sp = '#789',
                    style = {
                        inverse = true,
                    },
                },
            }):compile(palette)
            assert.are.same({
                ctermfg = 2,
                cterm = {
                    bold = true,
                },
                fg = '#112233',
                bg = '#FFAABB',
                sp = '#778899',
                inverse = true,
            }, highlight)
        end)
    end)
end)
