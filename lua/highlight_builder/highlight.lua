local ColorGui = require('highlight_builder.color')

--#region Types

---@class TextStyle Text style modifications.
---@field bold boolean? Bolden.
---@field underline boolean? Underline.
---@field undercurl boolean? Curly underline.
---@field underdouble boolean? Double underline.
---@field underdotted boolean? Dotted underline.
---@field underdashed boolean? Dashed underline.
---@field strikethrough boolean? Strikethrough.
---@field inverse boolean? Inverse background and foreground colors.
---@field italic boolean? Italicize.
---@field nocombine boolean? Whether to fully overwrite `TextStyle` properties or to add them.

---@class HighlightCompiledDefinition: TextStyle Highlight properties necessary to create a new highlight group.
---@field fg string? Foreground color for GUI interfaces.
---@field bg string? Background color for GUI interfaces.
---@field sp string? Special color (used for underline) for GUI interfaces.
---@field ctermfg ColorTerm? Foreground color for terminal interfaces.
---@field ctermbg ColorTerm? Background color for terminal interfaces.
---@field cterm TextStyle? Text style for terminal interfaces.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@class HighlightCompiledLink Highlight properties necessary to create a link highlight.
---@field link string? Name of the highlight group to link this one to.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@alias HighlightCompiled HighlightCompiledDefinition | HighlightCompiledLink

---@class HighlightSettingGui
---@field fg ColorGui?
---@field bg ColorGui?
---@field sp ColorGui?
---@field style TextStyle?

---@class HighlightSettingTerm Highlight properties for terminal interfaces.
---@field fg ColorTerm? Foreground color.
---@field bg ColorTerm? Background color.
---@field style TextStyle? Text style.

---@class HighlightInputGui Style Highlight properties for GUI interfaces.
---@field fg (ColorGui | string)? Foreground color.
---@field bg (ColorGui | string)? Background color.
---@field sp (ColorGui | string)? Special color (used for underline).
---@field style TextStyle? Text style.

---@class HighlightInput
---@field gui HighlightInputGui? GUI properties.
---@field term HighlightSettingTerm? Terminal properties.
---@field link string? Name of the highlight group to link this one to.

--#endregion

--#region Settings

---@class HighlightSetting Highlight properties for both GUI and terminal interfaces.
---@field gui HighlightSettingGui? GUI properties.
---@field term HighlightSettingTerm? Terminal properties.
---@field link string? Name of the highlight group to link this one to.
local HighlightSetting = {}
HighlightSetting.__index = HighlightSetting

---@param color ColorGui
---@param palette Palette
---@param is_foreground boolean
---@return integer | 'NONE' closest_index
local function find_closest_index_in_palette(color, palette, is_foreground)
    local closest_index = nil
    local closest_distance = math.huge

    ---@param color_new ColorGui
    ---@param index integer | 'NONE'
    local function assign_if_closer(color_new, index)
        local distance = color:distance_squared(color_new)
        if distance < closest_distance then
            closest_index = index
            closest_distance = distance
        end
    end

    for i, v in ipairs(palette.indexed) do
        assign_if_closer(v, i)
    end

    assign_if_closer(is_foreground and palette.primary.fg or palette.primary.bg, 'NONE')

    if type(closest_index) == 'number' then
        return closest_index - 1
    end

    ---@cast closest_index 'NONE'
    return closest_index
end

---@param highlight HighlightInput
---@return HighlightSetting
function HighlightSetting.new(highlight)
    local self = setmetatable(highlight, HighlightSetting)

    if self.gui and self.gui.fg and type(self.gui.fg) == 'string' then
        local color = self.gui.fg
        ---@cast color string
        self.gui.fg = ColorGui.from_hex(color)
    end
    if self.gui and self.gui.bg and type(self.gui.bg) == 'string' then
        local color = self.gui.bg
        ---@cast color string
        self.gui.bg = ColorGui.from_hex(color)
    end
    if self.gui and self.gui.sp and type(self.gui.sp) == 'string' then
        local color = self.gui.sp
        ---@cast color string
        self.gui.sp = ColorGui.from_hex(color)
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
    if r.term and not r.gui then
        r.gui = {
            style = r.term.style,
        }
        if r.term.fg then
            r.gui.fg = type(r.term.fg) == 'number' and palette.indexed[r.term.fg + 1]
                or palette.primary.fg
        end
        if r.term.bg then
            r.gui.bg = type(r.term.bg) == 'number' and palette.indexed[r.term.bg + 1]
                or palette.primary.bg
        end
    elseif r.gui and not r.term then
        r.term = {
            fg = r.gui.fg and (find_closest_index_in_palette(r.gui.fg, palette, true)) or nil,
            bg = r.gui.bg and (find_closest_index_in_palette(r.gui.bg, palette, false)) or nil,
            style = r.gui.style,
        }
    end

    ---@cast r HighlightInput
    return HighlightSetting.new(r)
end

--- Compile highlight settings transforming it into a table that NeoVim can understand.
---@param palette ColorGui[] Palette of the terminal.
---@return HighlightCompiled compiled Compiled highlight.
function HighlightSetting:compile(palette)
    local completed = self:complete(palette)
    if completed.link then
        return {
            link = self.link,
        }
    end

    ---@type HighlightCompiled
    local result = {
        fg = completed.gui and completed.gui.fg and completed.gui.fg:to_hex() or nil,
        bg = completed.gui and completed.gui.bg and completed.gui.bg:to_hex() or nil,
        sp = completed.gui and completed.gui.sp and completed.gui.sp:to_hex() or nil,
        ctermfg = completed.term and completed.term.fg or nil,
        ctermbg = completed.term and completed.term.bg or nil,
        cterm = completed.term and completed.term.style or nil,
    }
    for k, v in pairs(completed.gui and completed.gui.style or {}) do
        result[k] = v
    end

    return result
end

--#endregion

return HighlightSetting
