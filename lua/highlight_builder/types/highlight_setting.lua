---@class HighlightSettingLink Highlight properties necessary to create a link highlight.
---@field link string? Name of the highlight group to link this one to.

---@class HighlightSettingGui Style Highlight properties for GUI interfaces.
---@field fg ColorGui? Foreground color.
---@field bg ColorGui? Background color.
---@field sp ColorGui? Special color (used for underline).
---@field gui TextStyle? Text style.

---@class HighlightSettingTerm Highlight properties for terminal interfaces.
---@field ctermfg ColorTerm? Foreground color.
---@field ctermbg ColorTerm? Background color.
---@field cterm TextStyle? Text style.

---@class HighlightSetting Highlight properties for both GUI and terminal interfaces.
---@field gui HighlightSettingGui GUI properties.
---@field term HighlightSettingTerm Terminal properties.
local HighlightSetting = {}
HighlightSetting.__index = HighlightSetting

---@private
---@return HighlightSetting | HighlightSettingLink
function HighlightSetting:complete()
    local result = {}
    if (self.term ~= nil and self.gui == nil) then
        -- TODO
    elseif (self.gui ~= nil and self.term == nil) then
        -- TODO
    end
end

--- Compile
---@return HighlightCompiled | HighlightSettingLink compiled
function HighlightSetting:compile()
    local completed = self:complete()
    if completed.link ~= nil then
        return {
            link = completed.link
        }
    else
        ---@type HighlightCompiled
        local result = {
            fg = completed.gui.fg:to_hex(),
            bg = completed.gui.bg:to_hex(),
            sp = completed.gui.sp:to_hex(),
            ctermfg = completed.term.ctermfg,
            ctermbg = completed.term.ctermbg,
            cterm = completed.term.cterm
        }
        for k, v in completed.gui.gui do
            result[k] = v
        end
        return result
    end
end

