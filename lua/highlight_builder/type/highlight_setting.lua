local ColorGui = require('highlight_builder.type.color_gui')

---@class HighlightSettingGui
---@field fg ColorGui?
---@field bg ColorGui?
---@field sp ColorGui?
---@field style TextStyle?

---@class HighlightSettingTerm Highlight properties for terminal interfaces.
---@field ctermfg ColorTerm? Foreground color.
---@field ctermbg ColorTerm? Background color.
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

---@class HighlightSetting Highlight properties for both GUI and terminal interfaces.
---@field gui HighlightSettingGui? GUI properties.
---@field term HighlightSettingTerm? Terminal properties.
---@field link string? Name of the highlight group to link this one to.
local HighlightSetting = {}
HighlightSetting.__index = HighlightSetting

---@param color ColorGui
---@param palette ColorGui[]
---@return integer closest_index
local function find_closest_index_in_palette(color, palette)
    local closest_index = nil
    local closest_distance = math.huge
    for i, v in ipairs(palette) do
        local distance = color:distance_squared(v)
        if distance < closest_distance then
            closest_index = i
            closest_distance = distance
        end
    end

    ---@diagnostic disable-next-line: return-type-mismatch -- It will not be `nil` because there will be at least 1 color in the palette
    return closest_index
end

---@param highlight HighlightInput
---@return HighlightSetting
function HighlightSetting.new(highlight)
    local self = setmetatable(highlight, HighlightSetting)

    if self.gui and self.gui.fg and type(self.gui.fg) == 'string' then
        ---@diagnostic disable-next-line: param-type-mismatch -- Type is checked in the if statement
        self.gui.fg = ColorGui.from_hex(self.gui.fg)
    end
    if self.gui and self.gui.bg and type(self.gui.bg) == 'string' then
        ---@diagnostic disable-next-line: param-type-mismatch -- Type is checked in the if statement
        self.gui.bg = ColorGui.from_hex(self.gui.bg)
    end
    if self.gui and self.gui.sp and type(self.gui.sp) == 'string' then
        ---@diagnostic disable-next-line: param-type-mismatch -- Type is checked in the if statement
        self.gui.sp = ColorGui.from_hex(self.gui.sp)
    end

    ---@diagnostic disable-next-line: return-type-mismatch -- Types match
    return self
end

---@param palette ColorGui[]
---@return HighlightSetting
function HighlightSetting:complete(palette)
    if self.link then
        return { link = self.link }
    end

    local r =  vim.tbl_deep_extend('force', self, {})
    if r.term and not r.gui then
        r.gui = {}
        r.gui = {
            fg = r.term.ctermfg and palette[r.term.ctermfg + 1] or nil,
            bg = r.term.ctermbg and palette[r.term.ctermbg + 1] or nil,
            style = r.term.style,
        }
    elseif r.gui and not r.term then
        r.term = {}
        r.term = {
            ctermfg = r.gui.fg and (find_closest_index_in_palette(r.gui.fg, palette) - 1) or nil,
            ctermbg = r.gui.bg and (find_closest_index_in_palette(r.gui.bg, palette) - 1) or nil,
            style = r.gui.style,
        }
    end

    return r
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
        ctermfg = completed.term and completed.term.ctermfg or nil,
        ctermbg = completed.term and completed.term.ctermbg or nil,
        cterm = completed.term and completed.term.style or nil,
    }
    for k, v in pairs(completed.gui and completed.gui.style or {}) do
        result[k] = v
    end

    return result
end

return HighlightSetting
