---@diagnostic disable: undefined-field -- For `assert` module

local HighlightSetting = require('highlight_builder.highlight')
local Color = require('highlight_builder.color')

---@type Palette
local palette = {
    primary = {
        fg = Color.Gui.from_hex('#FFF'),
        bg = Color.Gui.from_hex('#000'),
    },
    indexed = {
        Color.Gui.from_hex('#111'),
        Color.Gui.from_hex('#A00'),
        Color.Gui.from_hex('#0A0'),
        Color.Gui.from_hex('#AA0'),
        Color.Gui.from_hex('#00A'),
        Color.Gui.from_hex('#A0A'),
        Color.Gui.from_hex('#0AA'),
        Color.Gui.from_hex('#AAA'),
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

        describe('Gui, term, and tty', function()
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
                    tty = {
                        fg = 1,
                        style = {
                            bold = true,
                        },
                    },
                }):complete(palette)
                assert.are.same({
                    gui = {
                        fg = Color.Gui.from_hex('#123456'),
                    },
                    term = {
                        fg = 3,
                        style = {
                            undercurl = true,
                            strikethrough = true,
                        },
                    },
                    tty = {
                        fg = 1,
                        style = {
                            bold = true,
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
                    tty = {
                        fg = 1,
                        style = {
                            bold = true,
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
                    tty = {
                        fg = 1,
                        style = {
                            bold = true,
                        },
                    },
                }, highlight)
            end)
        end)

        describe('Complete Gui', function()
            describe('With Term (priority) and Tty', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        tty = {
                            style = {
                                inverse = true,
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
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        term = {
                            bg = 'NONE',
                        },
                        tty = {
                            bg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            bg = 'NONE',
                        },
                        gui = {
                            bg = palette.primary.bg,
                        },
                        tty = {
                            bg = 1,
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        term = {
                            fg = 'NONE',
                        },
                        tty = {
                            fg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            fg = 'NONE',
                        },
                        gui = {
                            fg = palette.primary.fg,
                        },
                        tty = {
                            fg = 1,
                        },
                    }, highlight)
                end)

                it('Should look up background color in the palette', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            bg = 3,
                        },
                        tty = {
                            bg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            bg = 3,
                        },
                        gui = {
                            bg = palette.indexed[4],
                        },
                        tty = {
                            bg = 1,
                        },
                    }, highlight)
                end)

                it('Should look up foreground color in the palette', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            fg = 4,
                        },
                        tty = {
                            fg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            fg = 4,
                        },
                        gui = {
                            fg = palette.indexed[5],
                        },
                        tty = {
                            fg = 1,
                        },
                    }, highlight)
                end)
            end)

            describe('With Tty', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                        term = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            bg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 1,
                        },
                        gui = {
                            bg = palette.indexed[2],
                        },
                        term = {
                            bg = 1,
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            fg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 1,
                        },
                        gui = {
                            fg = palette.indexed[2],
                        },
                        term = {
                            fg = 1,
                        },
                    }, highlight)
                end)

                it('Should look up background color in the palette', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            bg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 1,
                        },
                        gui = {
                            bg = palette.indexed[2],
                        },
                        term = {
                            bg = 1,
                        },
                    }, highlight)
                end)

                it('Should look up foreground color in the palette', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            fg = 1,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 1,
                        },
                        gui = {
                            fg = palette.indexed[2],
                        },
                        term = {
                            fg = 1,
                        },
                    }, highlight)
                end)
            end)
        end)

        describe('Complete Term', function()
            describe('With Gui (priority) and Tty', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                    }):complete(palette)
                    assert.are.same({
                        gui = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        term = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should not resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            bg = palette.primary.bg,
                        },
                        tty = {
                            bg = 2,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            bg = Color.Term.indexes.normal.black,
                        },
                        gui = {
                            bg = palette.primary.bg,
                        },
                        tty = {
                            bg = 2,
                        },
                    }, highlight)
                end)

                it("Should not resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            fg = palette.primary.fg,
                        },
                        tty = {
                            fg = 2,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            fg = Color.Term.indexes.normal.white,
                        },
                        gui = {
                            fg = palette.primary.fg,
                        },
                        tty = {
                            fg = 2,
                        },
                    }, highlight)
                end)

                it('Should look up background color in the palette', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            bg = '#B00',
                        },
                        tty = {
                            bg = 6,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            bg = Color.Term.indexes.normal.red,
                        },
                        gui = {
                            bg = Color.Gui.from_hex('#B00'),
                        },
                        tty = {
                            bg = 6,
                        },
                    }, highlight)
                end)

                it('Should look up foreground color in the palette', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            fg = '#B00',
                        },
                        tty = {
                            fg = 6,
                        },
                    }):complete(palette)
                    assert.are.same({
                        term = {
                            fg = Color.Term.indexes.normal.red,
                        },
                        gui = {
                            fg = Color.Gui.from_hex('#B00'),
                        },
                        tty = {
                            fg = 6,
                        },
                    }, highlight)
                end)
            end)

            describe('With Tty', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                        term = {
                            style = {
                                inverse = true,
                            },
                        },
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            bg = 'NONE',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 'NONE',
                        },
                        term = {
                            bg = 'NONE',
                        },
                        gui = {
                            bg = palette.primary.bg,
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            fg = 'NONE',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 'NONE',
                        },
                        term = {
                            fg = 'NONE',
                        },
                        gui = {
                            fg = palette.primary.fg,
                        },
                    }, highlight)
                end)

                it('Should copy background color', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            bg = 6,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 6,
                        },
                        term = {
                            bg = 6,
                        },
                        gui = {
                            bg = palette.indexed[7],
                        },
                    }, highlight)
                end)

                it('Should copy foreground color', function()
                    local highlight = HighlightSetting.new({
                        tty = {
                            fg = 6,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 6,
                        },
                        term = {
                            fg = 6,
                        },
                        gui = {
                            fg = palette.indexed[7],
                        },
                    }, highlight)
                end)
            end)
        end)

        describe('Complete Tty', function()
            describe('With Term (priority) and Gui', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        term = {
                            style = {
                                bold = true,
                                underline = true,
                            },
                        },
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        term = {
                            bg = 'NONE',
                        },
                        gui = {
                            bg = '#FFF',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 'NONE',
                        },
                        term = {
                            bg = 'NONE',
                        },
                        gui = {
                            bg = Color.Gui.from_hex('#FFF'),
                        },
                    }, highlight)
                end)

                it("Should resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        term = {
                            fg = 'NONE',
                        },
                        gui = {
                            fg = '#FFF',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 'NONE',
                        },
                        term = {
                            fg = 'NONE',
                        },
                        gui = {
                            fg = Color.Gui.from_hex('#FFF'),
                        },
                    }, highlight)
                end)

                it('Should copy background color', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            bg = 6,
                        },
                        gui = {
                            bg = '#B00',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = 6,
                        },
                        term = {
                            bg = 6,
                        },
                        gui = {
                            bg = Color.Gui.from_hex('#B00'),
                        },
                    }, highlight)
                end)

                it('Should copy foreground color', function()
                    local highlight = HighlightSetting.new({
                        term = {
                            fg = 6,
                        },
                        gui = {
                            fg = '#B00',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = 6,
                        },
                        term = {
                            fg = 6,
                        },
                        gui = {
                            fg = Color.Gui.from_hex('#B00'),
                        },
                    }, highlight)
                end)
            end)

            describe('With Gui', function()
                it('Should copy style', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            style = {
                                inverse = true,
                            },
                        },
                        term = {
                            style = {
                                inverse = true,
                            },
                        },
                        gui = {
                            style = {
                                inverse = true,
                            },
                        },
                    }, highlight)
                end)

                it("Should not resolve 'NONE' background color", function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            bg = palette.primary.bg,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = Color.Term.indexes.normal.black,
                        },
                        term = {
                            bg = Color.Term.indexes.normal.black,
                        },
                        gui = {
                            bg = palette.primary.bg,
                        },
                    }, highlight)
                end)

                it("Should not resolve 'NONE' foreground color", function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            fg = palette.primary.fg,
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = Color.Term.indexes.normal.white,
                        },
                        term = {
                            fg = Color.Term.indexes.normal.white,
                        },
                        gui = {
                            fg = palette.primary.fg,
                        },
                    }, highlight)
                end)

                it('Should look up background color in the palette', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            bg = '#0B0',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            bg = Color.Term.indexes.normal.green,
                        },
                        gui = {
                            bg = Color.Gui.from_hex('#0B0'),
                        },
                        term = {
                            bg = Color.Term.indexes.normal.green,
                        },
                    }, highlight)
                end)

                it('Should look up foreground color in the palette', function()
                    local highlight = HighlightSetting.new({
                        gui = {
                            fg = '#0B0',
                        },
                    }):complete(palette)
                    assert.are.same({
                        tty = {
                            fg = Color.Term.indexes.normal.green,
                        },
                        gui = {
                            fg = Color.Gui.from_hex('#0B0'),
                        },
                        term = {
                            fg = Color.Term.indexes.normal.green,
                        },
                    }, highlight)
                end)
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

        describe('Should translate all properties', function()
            it('Force 256 colors', function()
                local highlight = HighlightSetting.new({
                    term = {
                        fg = 2,
                        bg = nil,
                        style = {
                            bold = true,
                        },
                    },
                    tty = {
                        fg = 4,
                        bg = 7,
                    },
                    gui = {
                        fg = '#123',
                        bg = '#FAB',
                        sp = '#789',
                        style = {
                            inverse = true,
                        },
                    },
                }):compile(palette, false)
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

            it('Force 16 colors', function()
                local highlight = HighlightSetting.new({
                    term = {
                        fg = 2,
                        bg = nil,
                        style = {
                            bold = true,
                        },
                    },
                    tty = {
                        fg = 4,
                        bg = 7,
                    },
                    gui = {
                        fg = '#123',
                        bg = '#FAB',
                        sp = '#789',
                        style = {
                            inverse = true,
                        },
                    },
                }):compile(palette, true)
                assert.are.same({
                    ctermfg = 4,
                    ctermbg = 7,
                    fg = '#112233',
                    bg = '#FFAABB',
                    sp = '#778899',
                    inverse = true,
                }, highlight)
            end)
        end)
    end)
end)
