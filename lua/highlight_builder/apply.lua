--- Apply highlights respecing deferring.
---@param highlights{[string]: {[1]: HighlightCompiled, [2]: boolean }} Highlights to apply along with whether to defer them.
---@param delay_deferred integer | nil Time to defer the deferred highlights. Defautls to `100` ms.
local function apply(highlights, delay_deferred)
    delay_deferred = delay_deferred or 100

    for name, highlight in pairs(highlights) do
        local function apply_current()
            vim.api.nvim_set_hl(0, name, highlight[1])
        end

        if highlight[2] then
            vim.defer_fn(apply_current, delay_deferred)
        else
            apply_current()
        end
    end
end

return apply
