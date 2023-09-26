local HighlightSetting = require('highlight_builder.type.highlight_setting')
local ColorGui = require('highlight_builder.type.color_gui')

local palette = {
    ColorGui.from_hex('#000000'),
    ColorGui.from_hex('#FF0000'),
    ColorGui.from_hex('#00FF00'),
    ColorGui.from_hex('#0000FF'),
    ColorGui.from_hex('#FFFFFF'),
}

describe('HighlightSetting', function()
    describe('new', function()
        it('Should convert HEX colors to Color class', function()
            local highlight = HighlightSetting.new {
                gui = {
                    bg = '#123456',
                    fg = '#789',
                    sp = '#FFBCDE'
                }
            }
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
                local highlight = HighlightSetting.new {
                    link = 'MyLink',
                    gui = {
                        fg = '#123456'
                    }
                }:complete(palette)
                assert.are.same({ link = 'MyLink' }, highlight)
            end)
        end)

        describe('Term without gui', function()
            it('Should copy term style', function()
                local highlight = HighlightSetting.new {
                    term = {
                        style = {
                            bold = true,
                            underline = true
                        }
                    }
                }:complete(palette)
                assert.are.same(
                    {
                        term = {
                            style = {
                                bold = true,
                                underline = true
                            }
                        },
                        gui = {
                            style = {
                                bold = true,
                                underline = true
                            }
                        },
                    },
                    highlight
                )
            end)

            it('Should copy term fg from palette', function()
                local highlight = HighlightSetting.new {
                    term = {
                        ctermfg = 3
                    }
                }:complete(palette)
                assert.are.same(
                    {
                        term = {
                            ctermfg = 3
                        },
                        gui = {
                            fg = palette[4]
                        },
                    },
                    highlight
                )
            end)

            it('Should copy term bg from palette', function()
                local highlight = HighlightSetting.new {
                    term = {
                        ctermbg = 1
                    }
                }:complete(palette)
                assert.are.same(
                    {
                        term = {
                            ctermbg = 1
                        },
                        gui = {
                            bg = palette[2]
                        },
                    },
                    highlight
                )
            end)
        end)
    end)
end)
