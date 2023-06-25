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

---@private
---@param palette ColorGui[]
---@return HighlightSetting
function HighlightSetting:complete(palette)
    if self.link then
        return { link = self.link }
    end

    local r = vim.tbl_deep_extend('keep', self, { term = {}, gui = {} })
    if r.term and not r.gui then
        r.term.style = r.term.style or {}
        r.gui = {
            fg = r.term.ctermfg and palette[r.term.ctermfg + 1] or nil,
            bg = r.term.ctermbg and palette[r.term.ctermbg + 1] or nil,
            gui = r.term.style,
        }
    elseif r.gui and not r.term then
        r.gui.style = r.gui.style or {}
        r.term = {
            ctermfg = r.gui.fg and (find_closest_index_in_palette(r.gui.fg, palette) - 1) or nil,
            ctermbg = r.gui.bg and (find_closest_index_in_palette(r.gui.bg, palette) - 1) or nil,
            cterm = r.gui.style,
        }
    end
    return r
end

--- Compile highlight settings transforming it into a table that NeoVim can understand.
---@param palette ColorGui[] Palette of the terminal.
---@return HighlightCompiled compiled Compiled highlight.
function HighlightSetting:compile(palette)
    local completed = self:complete(palette)
    if completed.link ~= nil then
        return {
            link = completed.link,
        }
    end

    ---@type HighlightCompiled
    local result = {
        fg = completed.gui.fg and completed.gui.fg:to_hex() or nil,
        bg = completed.gui.bg and completed.gui.bg:to_hex() or nil,
        sp = completed.gui.sp and completed.gui.sp:to_hex() or nil,
        ctermfg = completed.term.ctermfg,
        ctermbg = completed.term.ctermbg,
        cterm = completed.term.style,
    }
    for k, v in completed.gui.style do
        result[k] = v
    end

    return result
end
