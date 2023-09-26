---@diagnostic disable: undefined-field -- For `assert` module

local build = require('highlight_builder.build')
local ColorGui = require('highlight_builder.color')

-- TODO(Use ColorGui class instead of string colors)
local palette = {
    '#000000',
    '#FF0000',
    '#00FF00',
    '#0000FF',
    '#FFFFFF',
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
                    fg = '#0000FF',
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
                        fg = ColorGui.from_hex('#456'),
                        style = {
                            undercurl = true,
                            inverse = true,
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
                        fg = ColorGui.from_hex('#009'),
                        style = {
                            undercurl = true,
                            inverse = true,
                        },
                    },
                }
                set('Get', highlight)
                assert.are.same(
                    vim.tbl_deep_extend('force', highlight, {
                        term = {
                            bg = nil,
                            fg = 3,
                            style = {
                                undercurl = true,
                                inverse = true,
                            },
                        },
                    }),
                    get('Get')
                )
            end)
        end)
    end)
end)
