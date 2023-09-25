local HighlightSetting = require('highlight_builder.type.highlight_setting')
local ColorGui = require('highlight_builder.type.color_gui')

---@alias Set fun(name: string, highlight: HighlightSetting)
---@alias Get fun(name: string): HighlightSetting
---@param builder fun(get: Get, set: Set)
---@return {[string]: table}
return function(builder)
    ---@type HighlightSetting[]
    local highlights = {}

    local palette = vim.tbl_map(
        ColorGui.new_with_hex,
        require('highlight_builder.color_table.gui').indexed
    )

    builder(
        function(name)
            highlights[name]:complete(palette)
            return highlights[name]
        end,
        function(name, highlight)
            highlights[name] = HighlightSetting.new(highlight)
        end
    )

    return vim.tbl_map(
        ---@param h HighlightSetting
        function(h)
            return h:compile(palette)
        end,
        highlights
    )
end
