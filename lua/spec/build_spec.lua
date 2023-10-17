---@diagnostic disable: undefined-field -- For `assert` module

local build = require('highlight_builder.build')
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

describe('build', function()
    describe('set', function()
        it('Should generate completed highlights', function()
            local scheme = build(palette, function(_, set)
                set('OnlyTerm', {
                    term = {
                        fg = 3,
                    },
                })
                set('OnlyGui', {
                    gui = {
                        fg = '#00AB00',
                        style = {
                            bold = true,
                        },
                    },
                })
                set('Nothing', {})
                set('Both', {
                    term = {
                        fg = 1,
                        style = {
                            bold = true,
                        },
                    },
                    gui = {
                        bg = '#ffffff',
                        style = {
                            underline = true,
                        },
                    },
                })
                set('Link', {
                    link = 'Both',
                })
            end)
            assert.are.same({
                OnlyTerm = {
                    ctermfg = 3,
                    fg = '#AAAA00',
                },
                OnlyGui = {
                    ctermfg = 2,
                    cterm = {
                        bold = true,
                    },
                    fg = '#00AB00',
                    bold = true,
                },
                Nothing = {},
                Both = {
                    ctermfg = 1,
                    cterm = {
                        bold = true,
                    },
                    bg = '#FFFFFF',
                    underline = true,
                },
                Link = {
                    link = 'Both',
                },
            }, scheme)
        end)
    end)
    describe('get', function()
        it('Should get from highlight', function()
            build(palette, function(get, set)
                ---@type HighlightInput
                local highlight = {
                    gui = {
                        bg = nil,
                        fg = Color.Gui.from_hex('#456'),
                        style = {
                            undercurl = true,
                            reverse = true,
                        },
                    },
                    term = {
                        fg = nil,
                        bg = 4,
                        style = {
                            strikethrough = true,
                            underdashed = true,
                            bold = false,
                        },
                    },
                    tty = {
                        bg = 3,
                        fg = 1,
                        style = {
                            bold = true,
                        },
                    },
                }
                set('Get', highlight)
                assert.are.same(highlight, get('Get'))
            end)
        end)

        it('Should complete the highlight', function()
            build(palette, function(get, set)
                ---@type HighlightInput
                local highlight = {
                    gui = {
                        bg = nil,
                        fg = Color.Gui.from_hex('#009'),
                        style = {
                            undercurl = true,
                            reverse = true,
                        },
                    },
                }
                set('Get', highlight)
                assert.are.same(
                    vim.tbl_deep_extend('force', highlight, {
                        term = {
                            bg = nil,
                            fg = 4,
                            style = {
                                undercurl = true,
                                reverse = true,
                            },
                        },
                        tty = {
                            bg = nil,
                            fg = 4,
                            style = {
                                undercurl = true,
                                reverse = true,
                            },
                        },
                    }),
                    get('Get')
                )
            end)
        end)
    end)
end)
