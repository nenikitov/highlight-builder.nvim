local ColorGui = require('highlight_builder.type.color_gui')

---@class HighlightSettingGui Style Highlight properties for GUI interfaces.
---@field fg ColorGui? Foreground color.
---@field bg ColorGui? Background color.
---@field sp ColorGui? Special color (used for underline).
---@field style TextStyle? Text style.

---@class HighlightSettingTerm Highlight properties for terminal interfaces.
---@field ctermfg ColorTerm? Foreground color.
---@field ctermbg ColorTerm? Background color.
---@field style TextStyle? Text style.

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
    return closest_index
end

---@param highlight HighlightSetting
---@return HighlightSetting
function HighlightSetting.new(highlight)
    local self = setmetatable(highlight, HighlightSetting)

    if self.gui and self.gui.fg and type(self.gui.fg) == 'string' then
        self.gui.fg = ColorGui.new_with_hex(self.gui.fg)
    end
    if self.gui and self.gui.bg and type(self.gui.bg) == 'string' then
        self.gui.bg = ColorGui.new_with_hex(self.gui.bg)
    end
    if self.gui and self.gui.sp and type(self.gui.sp) == 'string' then
        self.gui.sp = ColorGui.new_with_hex(self.gui.sp)
    end

    return self
end

---@param palette ColorGui[]
function HighlightSetting:complete(palette)
    if self.link then
        self = { link = self.link }
    end

    if self.term and not self.gui then
        self.gui = {}
        self.term.style = self.term.style or {}
        self.gui = {
            fg = self.term.ctermfg and palette[self.term.ctermfg + 1] or nil,
            bg = self.term.ctermbg and palette[self.term.ctermbg + 1] or nil,
            style = self.term.style,
        }
    elseif self.gui and not self.term then
        self.term = {}
        self.gui.style = self.gui.style or {}
        self.term = {
            ctermfg = self.gui.fg and (find_closest_index_in_palette(self.gui.fg, palette) - 1) or nil,
            ctermbg = self.gui.bg and (find_closest_index_in_palette(self.gui.bg, palette) - 1) or nil,
            style = self.gui.style,
        }
    end
end

--- Compile highlight settings transforming it into a table that NeoVim can understand.
---@param palette ColorGui[] Palette of the terminal.
---@return HighlightCompiled compiled Compiled highlight.
function HighlightSetting:compile(palette)
    self:complete(palette)
    if self.link ~= nil then
        return {
            link = self.link,
        }
    end

    ---@type HighlightCompiled
    local result = {
        fg = self.gui and self.gui.fg and self.gui.fg:to_hex() or nil,
        bg = self.gui and self.gui.bg and self.gui.bg:to_hex() or nil,
        sp = self.gui and self.gui.sp and self.gui.sp:to_hex() or nil,
        ctermfg = self.term and self.term.ctermfg or nil,
        ctermbg = self.term and self.term.ctermbg or nil,
        cterm = self.term and self.term.style or nil,
    }
    for k, v in pairs(self.gui and self.gui.style or {}) do
        result[k] = v
    end

    return result
end

return HighlightSetting
