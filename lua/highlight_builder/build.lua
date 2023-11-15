local HighlightSetting = require('highlight_builder.highlight')

---@alias HighlightSettingWithDefer {[1]: HighlightSetting, [2]: boolean }
---@alias Get fun(name: string): HighlightSetting
---@alias Set fun(name: string, highlight: HighlightInput, defer: true | nil)
---@param palette Palette
---@param builder fun(get: Get, set: Set)
---@return {[string]: {[1]: HighlightCompiled, [2]: boolean }}
return function(palette, builder)
    ---@type HighlightSettingWithDefer[]
    local highlights = {}

    builder(function(name)
        return highlights[name][1]
    end, function(name, highlight, defer)
        highlights[name] = { HighlightSetting.new(highlight):complete(palette), defer or false }
    end)

    return vim.tbl_map(
        ---@param h HighlightSettingWithDefer
        function(h)
            return { h[1]:compile(palette), h[2] }
        end,
        highlights
    )
end
