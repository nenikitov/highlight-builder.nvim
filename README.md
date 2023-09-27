# highlight-builder.nvim

Utility plugin to create Neovim colorschemes that work both in truecolor, 256, and 16 color terminals.

## Installation

- Install it like any other Neovim plugin.
    - [packer.nvim](https://github.com/wbthomason/packer.nvim)
        ```lua
        use 'nenikitov/highlight-builder.nvim'
        ```
    - [lazy.nvim](https://github.com/folke/lazy.nvim)
        ```lua
        return {
            'nenikitov/highlight-builder.nvim'
        }
        ```

## Builder

### High level example

```lua
-- Import
local build = require('highlight_builder').build
local Color = require('highlight_builder').Color
local palette = require('highlight_builder').palette

-- Construct color scheme
local scheme = bulid(
    palette.default(256),
    function(get, set)
        set('HighlightGroup', {
            -- Highlight structure goes here
            -- ...
        })
        -- ...
    end
)

-- Apply
for k, v in pairs(scheme) do
    vim.nvim_set_hl(0, k, v)
end
```

### Highlight structure

```lua
--- All properties are optional
local highlight = {
    --- Style used for truecolor terminals and GUI clients
    gui = {
        --- Foreground color - HEX of format `#000` or `#000000`, or an instance of `Color`
        fg = '#000',
        --- Background color - Same type as `gui.fg`
        bg = Color.from_rgb(0, 0, 0),
        --- Underline color - Same type as `gui.fg`
        sp = '#000',
        --- Various font options
        style = {
            --- Bolden - boolean
            bold = false,
            --- Underline - boolean
            underline = false,
            --- Underline with curly line - boolean
            undercurl = false,
            --- Underline with double line - boolean
            underdouble = false,
            --- Underline with dots - boolean
            underdotted = false,
            --- Underline with dashed line - boolean
            underdashed = false,
            --- Strikethrough  - boolean
            strikethrough = false,
            --- Inverse foreground and background colors  - boolean
            inverse = false,
            --- Italicize - boolean
            italic = false,
            --- Fully overwrite the style instead of appending to it - boolean
            nocombine = false,
        }
    },
    --- Style used for basic terminals
    term = {
        --- Foreground color - 'NONE' for default foreground color, integer 0 -> 15 for named colors, 0 -> 255 for indexed colors
        fg = 'NONE',
        --- Background color - Same type as `term.fg`
        bg = 0,
        --- Various font options - Same type as `gui.style`
        style = { ... }
    }
}
```

### `set` function

- Automatically completes `term` style from `gui`
    ```lua
    set('MissingTerm', {
        gui = {
            fg = '#F00',
            style = {
                bold = true,
            },
        },
    })
    -- Is equivalent to
    set('MissingTerm', {
        gui = {
            fg = '#F00',
            style = {
                bold = true,
            },
        },
        term = {
            fg = 12, -- Example closest red color from the palette
            style = {
                bold = true,
            },
        },
    })
    ```
- Same applies to `gui` from `term`
    ```lua
    set('MissingGui', {
        term = {
            fg = 'NONE',
            style = {
                undercurl = true,
            },
        },
    })
    -- Is equivalent to
    set('MissingGui', {
        term = {
            fg = 'NONE',
            style = {
                undercurl = true,
            },
        },
        gui = {
            fg = '#FFF', -- Example default foreground color from the palette
            style = {
                undercurl = true,
            },
        },
    })
    ```

### `get` function

- Lets you query existing highlight groups retrieving highlight structure
    ```lua
    set('DiagnosticError', {
        gui = {
            fg = '#F00',
        },
    })
    set('DiagnosticUnderlineError', {
        gui = {
            sp = get('DiagnosticError').gui.fg
        }
    })
    ```
- Gui colors will be automatically transformed to color class (you can use color functions after)
    ```lua
    get('DiagnosticError').gui.fg:darken(0.2)
    ```

## Color

### Constructors

```lua
local Color = require('highlight_builder').Color

local red = Color.from_rgb(255, 0, 0)
local green = Color.from_hsl(120, 100, 100)
local blue = Color.from_rgb('#00F')
```

### Operations

```lua
local cyan = green:blend(blue, 0.5)
local dark_red = red:darken(0.2)
local pink = red:lighten(0.2)
local magenta = blue:hue_rotate(60)
local gray = green:saturate(-100)
local medium_red = dark_red:brighten(20)
```

### Converters

```lua
local hex_string = magenta:to_hex()
local h, s, v = dark_red:to_hsv()
local r, g, b = pink:to_rgb()
```

## Palette

### Palette structure

```lua
--- All properties are required, and all colors are instances of `Color`
local palette = {
    --- Default colors (when cterm color is `'NONE'`)
    primary = {
        fg = Color.from_hex("#FFF"),
        bg = Color.from_hex("#000"),
    },
    --- Colors indexable with an integer
    indexed = {
        Color.from_hex('#000'),
        Color.from_hex('#A00'),
        Color.from_hex('#0A0'),
        Color.from_hex('#A50'),
        Color.from_hex('#00A'),
        Color.from_hex('#A0A'),
        Color.from_hex('#0AA'),
        Color.from_hex('#AAA'),
        -- ...
    }
}
```

### Built-in palettes

#### Default

- Follows default 16 colors of Linux TTY color palette with 240 additional indexed colors
- Can be generated with either `8`, `16`, or `256` colors
- Usage
    ```lua
    local default = require('highlight_builder').palette.default

    local palette = default(
        --- 8 | 16 | 256 - Number of colors to generate
        256
    )
    ```

#### Custom

- Requests primary, dark, and bright versions of terminal color scheme and optionally adds 240 indexed colors
- Can be generated with either `16` or `256` colors
- Usage
    ```lua
    local custom = require('highlight_builder').palette.custom

    local palette = custom(
        --- Color scheme
        {
            --- Primary colors
            primary = {
                --- Foreground color - HEX of format `#000` or `#000000`, or an instance of `Color` 
                fg = '#14161E',
                --- Background color - Same type as `primary.fg`
                bg = Color.from_hex('#B4BFC5')
            },
            --- Dark colors
            dark = {
                --- Dark gray - Same type as `primary.fg`
                black = '#20232B'
                --- Dark red - ...
                red = '#ED3A66'
                green = '#70B74B'
                yellow = '#F89861'
                blue = '#26B1E4'
                magenta = '#B570EB'
                cyan = '#3CAEB2'
                white = '#A6ACB0'
            },
            --- Bright colors - Same type as `dark`
            bright = {
                -- ...
            }
        },
        --- Whether to complete to 256 colors - boolean
        true
    )
    ```

#### Fully custom

- You can always define a fully custom palette by following the [palette structure](#palette-structure)
