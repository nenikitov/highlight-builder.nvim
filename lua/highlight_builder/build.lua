local HighlightSetting = require('highlight_builder.highlight')
local ColorGui = require('highlight_builder.color')

---@alias Set fun(name: string, highlight: HighlightInput)
---@alias Get fun(name: string): HighlightSetting
---@param palette string[]
---@param builder fun(get: Get, set: Set)
---@return {[string]: table}
return function(palette, builder)
    ---@type HighlightSetting[]
    local highlights = {}

    local paletteColorGui = vim.tbl_map(ColorGui.from_hex, palette)

    builder(function(name)
        highlights[name] = highlights[name]:complete(paletteColorGui)
        return highlights[name]
    end, function(name, highlight)
        highlights[name] = HighlightSetting.new(highlight)
    end)

    return vim.tbl_map(
        ---@param h HighlightSetting
        function(h)
            return h:compile(paletteColorGui)
        end,
        highlights
    )
end
