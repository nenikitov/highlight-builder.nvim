local HighlightSetting = require('highlight_builder.type.highlight_setting')
local ColorGui = require('highlight_builder.type.color_gui')

---@alias Set fun(name: string, highlight: HighlightInput)
---@alias Get fun(name: string): HighlightSetting
---@param builder fun(get: Get, set: Set)
---@param palette string[]
---@return {[string]: table}
return function(builder, palette)
    ---@type HighlightSetting[]
    local highlights = {}

    local paletteColorGui = vim.tbl_map(ColorGui.from_hex, palette)

    builder(
        function(name)
            highlights[name]:complete(paletteColorGui)
            return highlights[name]
        end,
        function(name, highlight)
            highlights[name] = HighlightSetting.new(highlight)
        end
    )

    return vim.tbl_map(
        ---@param h HighlightSetting
        function(h)
            return h:compile(paletteColorGui)
        end,
        highlights
    )
end
