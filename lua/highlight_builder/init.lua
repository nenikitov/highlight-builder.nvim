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

---@class HighlightTerm Highlight properties available to terminals in truecolor mode.
---@field ctermfg CTermColor Term text color.
---@field ctermbg CTermColor Term background color.
---@field cterm HighlightCTerm Font modifiers.

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


--- Generate CTerm highlight properties close to GUI ones.
---@param gui HighlightGUI Only GUI highlights.
---@return HighlightTerm highlight Approximated CTerm highlight.
function H.gui_to_cterm(gui)
    ---@type HighlightTerm
    local result = {}
    if gui.fg ~= nil then
        result.ctermfg, _ = H.find_closest_color(gui.fg)
    end
    if gui.bg ~= nil then
        result.ctermbg, _ = H.find_closest_color(gui.bg)
    end
    result.cterm = {
        bold = gui.bold,
        italic = gui.italic,
        reverse = gui.reverse,
        undercurl = gui.undercurl,
        underline = gui.underline,
        underdashed = gui.underdashed,
        underdotted = gui.underdotted,
        underdouble = gui.underdouble,
        strikethrough = gui.strikethrough
    }
    return result
end


--- Generate GUI highlight properties close to CTerm ones.
---@param cterm HighlightTerm Only CTerm highlights.
---@return HighlightGUI highlight Approximated GUI highlight.
function H.cterm_to_gui(cterm)
    local colors = H.get_colors()
    ---@type HighlightGUI
    local result = {}
    if cterm.ctermfg ~= nil and type(cterm.ctermfg) == 'number' then
        result.fg = colors.indexed[cterm.ctermfg + 1]
    end
    if cterm.ctermbg ~= nil and type(cterm.ctermbg) == 'number' then
        result.bg, _ = colors.indexed[cterm.ctermbg + 1]
    end
    if cterm.cterm ~= nil then
        result.bold = cterm.cterm.bold
        result.italic = cterm.cterm.italic
        result.reverse = cterm.cterm.reverse
        result.undercurl = cterm.cterm.undercurl
        result.underline = cterm.cterm.underline
        result.underdashed = cterm.cterm.underdashed
        result.underdotted = cterm.cterm.underdotted
        result.underdouble = cterm.cterm.underdouble
        result.strikethrough = cterm.cterm.strikethrough
    end
    return result
end

--- Get all the colors that the terminal supports.
---@param regenerate boolean | nil Whether to get all the colors from scratch instead of using the cache (slow).
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

--- Get the closest color from the 256 color palette the terminal supports.
---@param color string HEX value of the color ("#RGB" or "#RRGGBB" format).
---@return integer index Index of the closest color from the palette.
---@return string closest HEX value of the closest color from the palettte.
function H.find_closest_color(color)
    return utils_color.find_closest_color(color, H.get_colors(false).indexed)
end


return H

