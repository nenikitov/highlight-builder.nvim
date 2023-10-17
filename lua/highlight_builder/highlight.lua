local Color = require('highlight_builder.color')
local Tty = require('highlight_builder.tty')

--#region Types

---@class TextStyleTty
---@field bold boolean? Bolden.
---@field reverse boolean? Inverse background and foreground colors.
---@field nocombine boolean? Whether to fully overwrite `TextStyle` properties or to add them.

---@class TextStyle: TextStyleTty Text style modifications.
---@field underline boolean? Underline.
---@field undercurl boolean? Curly underline.
---@field underdouble boolean? Double underline.
---@field underdotted boolean? Dotted underline.
---@field underdashed boolean? Dashed underline.
---@field strikethrough boolean? Strikethrough.
---@field italic boolean? Italicize.

---@class HighlightDefinitionCompiled: TextStyle Highlight properties necessary to create a new highlight group.
---@field fg string? Foreground color for GUI interfaces.
---@field bg string? Background color for GUI interfaces.
---@field sp string? Special color (used for underline) for GUI interfaces.
---@field ctermfg Term256? Foreground color for terminal interfaces.
---@field ctermbg Term256? Background color for terminal interfaces.
---@field cterm TextStyle? Text style for terminal interfaces.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@class HighlightLinkCompiled Highlight properties necessary to create a link highlight.
---@field link string? Name of the highlight group to link this one to.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@alias HighlightCompiled HighlightDefinitionCompiled | HighlightLinkCompiled

---@class HighlightSettingGui
---@field fg Color.Gui?
---@field bg Color.Gui?
---@field sp Color.Gui?
---@field style TextStyle?

---@class HighlightSettingTerm Highlight properties for 256-color terminal interfaces.
---@field fg Term256? Foreground color.
---@field bg Term256? Background color.
---@field style TextStyle? Text style.

---@class HighlightSettingTty Highlight properties for tty.
---@field fg Term16? Foreground color.
---@field bg TermLow8? Background color.
---@field style TextStyleTty? Text style.

---@class HighlightSettingGuiInput Style Highlight properties for GUI interfaces.
---@field fg (Color.Gui | string)? Foreground color.
---@field bg (Color.Gui | string)? Background color.
---@field sp (Color.Gui | string)? Special color (used for underline).
---@field style TextStyle? Text style.

---@class HighlightSettingDefinitionInput
---@field gui HighlightSettingGuiInput? GUI properties.
---@field term HighlightSettingTerm? 256-color terminal properties.
---@field tty HighlightSettingTty? 8 or 16-color terminal properties.

---@alias HighlightInput HighlightSettingDefinitionInput | HighlightLinkCompiled | HighlightSetting | nil

--#endregion

--#region Settings

---@class HighlightSetting Highlight properties for both GUI and terminal interfaces.
---@field gui HighlightSettingGui? GUI properties.
---@field term HighlightSettingTerm? 256-color terminal properties.
---@field tty HighlightSettingTty? 8 or 16-color terminal properties.
---@field link string? Name of the highlight group to link this one to.
local HighlightSetting = {}
HighlightSetting.__index = HighlightSetting

---@param color Color.Gui
---@param palette Palette
---@return integer | 'NONE' closest_index
local function find_in_palette(color, palette)
    local closest_index = nil
    local closest_distance = math.huge

    for i, v in ipairs(palette.indexed) do
        local distance = color:distance_squared(v)
        if distance < closest_distance then
            closest_index = i
            closest_distance = distance
        end
    end

    return closest_index - 1
end

---@param color Color.Gui
---@param palette Palette
---@param is_foreground boolean
---@return integer | 'NONE' closest_index
local function find_in_tty_palette(color, palette, is_foreground)
    ---@type Palette
    local palette_reduced = {
        primary = palette.primary,
        indexed = {},
    }

    for i = 1, is_foreground and 16 or 8 do
        palette_reduced.indexed[i] = palette.indexed[i]
    end

    return find_in_palette(color, palette_reduced)
end

---@param highlight HighlightInput
---@return HighlightSetting
function HighlightSetting.new(highlight)
    if not highlight then
        highlight = {}
    end

    local self = setmetatable(highlight, HighlightSetting)

    if self.gui and self.gui.fg and type(self.gui.fg) == 'string' then
        local color = self.gui.fg
        ---@cast color -Color.Gui,-?
        self.gui.fg = Color.Gui.from_hex(color)
    end
    if self.gui and self.gui.bg and type(self.gui.bg) == 'string' then
        local color = self.gui.bg
        ---@cast color -Color.Gui,-?
        self.gui.bg = Color.Gui.from_hex(color)
    end
    if self.gui and self.gui.sp and type(self.gui.sp) == 'string' then
        local color = self.gui.sp
        ---@cast color -Color.Gui,-?
        self.gui.sp = Color.Gui.from_hex(color)
    end

    ---@cast self HighlightSetting
    return self
end

---@param palette Palette
---@return HighlightSetting
function HighlightSetting:complete(palette)
    if self.link then
        return HighlightSetting.new({ link = self.link })
    end

    local r = vim.tbl_deep_extend('force', self, {})

    if not r.tty then
        if r.term then
            --- Types are compatible because neovim will just ignore all incompatibilities from TERM to TTY style
            ---@diagnostic disable-next-line: assign-type-mismatch
            r.tty = r.term
        elseif r.gui then
            r.tty = {
                fg = r.gui.fg and (find_in_tty_palette(r.gui.fg, palette, true)) or nil,
                bg = r.gui.bg and (find_in_tty_palette(r.gui.bg, palette, false)) or nil,
                style = r.gui.style,
            }
        end
    end
    if not r.term then
        if r.gui then
            r.term = {
                fg = r.gui.fg and (find_in_palette(r.gui.fg, palette)) or nil,
                bg = r.gui.bg and (find_in_palette(r.gui.bg, palette)) or nil,
                style = r.gui.style,
            }
        elseif r.tty then
            --- Types are compatible because TERM is a superset of TTY
            ---@diagnostic disable-next-line: assign-type-mismatch
            r.term = r.tty
        end
    end
    if not r.gui and (r.term or r.tty) then
        local term = r.term or r.tty
        ---@cast term -?
        term = term

        r.gui = {
            --- Types are compatible because GUI style is the same as TERM style and is a superset of TTY style
            ---@diagnostic disable-next-line: assign-type-mismatch
            style = term.style,
        }
        if term.fg then
            r.gui.fg = type(term.fg) == 'number' and palette.indexed[term.fg + 1]
                or palette.primary.fg
        end
        if term.bg then
            r.gui.bg = type(term.bg) == 'number' and palette.indexed[term.bg + 1]
                or palette.primary.bg
        end
    end

    ---@cast r HighlightSettingDefinitionInput
    return HighlightSetting.new(r)
end

--- Compile highlight settings transforming it into a table that NeoVim can understand.
---@param palette Color.Gui[] Palette of the terminal.
---@param force_tty boolean | nil Whether to force 16 color tty mode.
---@return HighlightCompiled compiled Compiled highlight.
function HighlightSetting:compile(palette, force_tty)
    local completed = self:complete(palette)
    if completed.link then
        return {
            link = self.link,
        }
    end

    if force_tty == nil then
        force_tty = Tty.is_gui()
    end

    local term = force_tty and completed.tty or completed.term

    ---@type HighlightCompiled
    local result = {
        fg = completed.gui and completed.gui.fg and completed.gui.fg:to_hex() or nil,
        bg = completed.gui and completed.gui.bg and completed.gui.bg:to_hex() or nil,
        sp = completed.gui and completed.gui.sp and completed.gui.sp:to_hex() or nil,
        ctermfg = term and term.fg or nil,
        ctermbg = term and term.bg or nil,
        --- Types are compatible because TERM is a superset of TTY
        ---@diagnostic disable-next-line: assign-type-mismatch
        cterm = term and term.style or nil,
    }
    for k, v in pairs(completed.gui and completed.gui.style or {}) do
        result[k] = v
    end

    return result
end

--#endregion

return HighlightSetting
