local utils_color = require('highlight_builder.utils.utils_color')
local utils_env = require('highlight_builder.utils.utils_env')

--- Container for functions
local H = {}


--#region Types

---@class HighlightCTerm Font modifiers avaiable for non-truecolor mode.
---@field bold boolean Bold.
---@field underline boolean Underline.
---@field undercurl boolean Curly underline.
---@field underdouble boolean Double underline.
---@field underdotted boolean Dotted underline.
---@field underdashed boolean Dashed underline.
---@field strikethrough boolean Strike through.
---@field reverse boolean Reverse background and foreground colors.
---@field italic boolean Italicize.

---@alias CTermColor number | nil | 'NONE' | 'Black' | 'DarkRed' | 'DarkGreen' | 'DarkYellow' | 'DarkBlue' | 'DarkMagenta' | 'DarkCyan' | 'Gray' | 'DarkGray' | 'Red' | 'Green' | 'Yellow' | 'Blue' | 'Magenta' | 'Cyan' | 'White'

---@class HighlightGUI Highlight properties available to terminals in truecolor mode.
---@field fg string GUI text color ('#RRGGBB' or color name).
---@field bg string GUI background color ('#RRGGBB' or color name).
---@field sp string GUI special color ('#RRGGBB' or color name).
---@field bold boolean Bold.
---@field underline boolean Underline.
---@field undercurl boolean Curly underline.
---@field underdouble boolean Double underline.
---@field underdotted boolean Dotted underline.
---@field underdashed boolean Dashed underline.
---@field strikethrough boolean Strike through.
---@field reverse boolean Reverse background and foreground colors.
---@field italic boolean Italicize.

---@class HighlightFull All highlight properties available.
---@field ctermfg CTermColor Terminal text color.
---@field ctermbg CTermColor Terminal background color.
---@field cterm HighlightCTerm Terminal font modifiers.
---@field fg string GUI text color ('#RRGGBB' or color name).
---@field bg string GUI background color ('#RRGGBB' or color name).
---@field sp string GUI special color ('#RRGGBB' or color name).
---@field bold boolean Bold.
---@field underline boolean Underline.
---@field undercurl boolean Curly underline.
---@field underdouble boolean Double underline.
---@field underdotted boolean Dotted underline.
---@field underdashed boolean Dashed underline.
---@field strikethrough boolean Strike through.
---@field reverse boolean Reverse background and foreground colors.
---@field italic boolean Italicize.


---@class ColorTablePrimary Most basic colors from the color scheme.
---@field background string Background.
---@field foreground string Text color.

---@class ColorTableColors A colored block of colors.
---@field black string Black.
---@field red string Red.
---@field green string Green.
---@field yellow string Yellow.
---@field blue string Blue.
---@field magenta string Magenta.
---@field cyan string Cyan.
---@field White string White.

---@class ColorTable Colors that the terminal suppors.
---@field primary ColorTablePrimary Most basic colors from the colorscheme.
---@field normal ColorTableColors 8 dim colors.
---@field bright ColorTableColors 8 bright colors.
---@field indexed string[] 256 other colors.

--#endregion


--- Generate and append CTerm highlight properties to GUI only highlight.
---@param gui HighlightGUI Only GUI highlights.
---@return HighlightFull highlight Both GUI and CTerm highlight.
function H.gui_to_cterm(gui)
    return {}
end

--- Get all the colors that the terminal supports.
---@param regenerate boolean Whether to regenerate the color cache.
---@return ColorTable colors Colors that the terminal supports.
function H.get_colors(regenerate)
    -- TODO I can't run my color script inside of neovim because it doesn't support
    -- ANSI escape sequence I'm using.
    -- So for now it is hardcoded to open a new terminal
    -- Potentially I want to get the terminal name and open a new instance of the
    -- current terminal, or try to work around this ANSI limitation.

    local colors_status, _ = require('highlight_builder.colors')
    if not colors_status or regenerate then
        local path_root = utils_env.path_join(utils_env.script_path(), '..', '..')
        local path_script = utils_env.path_join(path_root, 'py', 'get_colors.py')
        local path_colors = utils_env.path_join(path_root, 'lua', 'highlight_builder', 'colors.lua')
        vim.cmd('!alacritty -e ' .. path_script .. ' ' .. path_colors)
    end

    local colors = require('highlight_builder.colors')
    return colors
end


H.mix_colors = utils_color.mix_colors

function H.find_closest_color(color)
    return utils_color.find_closest_color(color, H.get_colors(false).indexed)
end


return H

