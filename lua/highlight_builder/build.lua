local HighlightSetting = require('highlight_builder.highlight')

---@alias HighlightSettingWithDefer {[1]: HighlightSetting, [2]: boolean }
---@alias Get fun(name: string, traverse: true | nil): HighlightSetting
---@alias Set fun(name: string, highlight: HighlightInput, defer: true | nil)
---@param palette Palette
---@param builder fun(get: Get, set: Set)
---@return {[string]: {[1]: HighlightCompiled, [2]: boolean }}
return function(palette, builder)
    ---@type HighlightSettingWithDefer[]
    local highlights = {}

    ---@type Get
    local function get(name, traverse)
        local h = highlights[name][1]
        if h.link and traverse then
            return get(h.link, traverse)
        else
            return h
        end
    end

    ---@type Set
    local function set(name, highlight, defer)
        highlights[name] = { HighlightSetting.new(highlight):complete(palette), defer or false }
    end

    builder(get, set)

    return vim.tbl_map(
        ---@param h HighlightSettingWithDefer
        function(h)
            return { h[1]:compile(palette), h[2] }
        end,
        highlights
    )
end
