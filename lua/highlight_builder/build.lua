local HighlightSetting = require('highlight_builder.highlight')

---@alias Set fun(name: string, highlight: HighlightInput)
---@alias Get fun(name: string): HighlightSetting
---@param palette Palette
---@param builder fun(get: Get, set: Set)
---@return {[string]: table}
return function(palette, builder)
    ---@type HighlightSetting[]
    local highlights = {}

    builder(function(name)
        highlights[name] = highlights[name]:complete(palette)
        return highlights[name]
    end, function(name, highlight)
        highlights[name] = HighlightSetting.new(highlight)
    end)

    return vim.tbl_map(
        ---@param h HighlightSetting
        function(h)
            return h:compile(palette)
        end,
        highlights
    )
end
