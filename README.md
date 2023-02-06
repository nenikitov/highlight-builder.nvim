# highlight-builder.nvim

Create neovim colorschemes that work both in truecolor and 256 color terminals

## Quickstart

### Requirements

- Terminal that supports 256 mode. This plugin was tested with these terminals.
    - Alacritty
    - Kitty
    - XTerm
    - Wezterm
    - Gnome terminal
    - Konsole
- Python interpreter.
    - Check by running `python --version`
    - Link `python` to `python3` if needed

### Installation

- Install it like any other Neovim plugin.
    - [packer.nvim](https://github.com/wbthomason/packer.nvim)
        ```lua
        use 'nenikitov/highlight-builder.nvim'
        ```

### Usage

- To import.
    ```lua
    local highlight_builder = require('highlight_builder')
    ```
- This plugin exports utilities functions.
    ```lua
    -- Generate and append CTerm highlight properties close to GUI ones.
    -- gui: table - With these keys
    --     - fg: string - Hex color of text
    --     - bg: string - Hex color of background
    --     - sg: string - Hex color of special (underline)
    --     - underline: boolean
    --     - undercurl: boolean
    --     - underdouble: boolean
    --     - underdotted: boolean
    --     - underdashed: boolean
    --     - strikethrough: boolean
    --     - reverse: boolean
    --     - italic: boolean
    -- Returns a table that can be sent to `vim.api.nvim_set_hl()`
    highlight_builder.gui_to_cterm(gui)

    -- Get all the colors that the terminal supports.
    -- regenerate: boolean - Whether to get all the colors from scratch instead of using the cache (slow).
    -- Returns a table containing all the colors in HEX format grouped in:
    --     - primary: table
    --         - foreground: string
    --         - background: string
    --     - normal: table
    --         - black: string
    --         - red: string
    --         - green: string
    --         - yellow: string
    --         - blue: string
    --         - magenta: string
    --         - cyan: string
    --         - white: string
    --     - bright: table
    --         - black: string
    --         - red: string
    --         - green: string
    --         - yellow: string
    --         - blue: string
    --         - magenta: string
    --         - cyan: string
    --         - white: string
    --     - indexed: string[]
    highlight_builder.get_colors(regenerate)

    -- Get the closest color from 256 color palette of the terminal.
    -- color: string - HEX value of the color ("#RGB" or "#RRGGBB")
    -- Returns an integer index of the closest color from the palette.
    -- Returns also a string HEX value of the closest color.
    highlight-builder.find_closest_color(color)
    ```

