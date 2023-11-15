--- Apply highlights respecing deferring.
---@alias HighlightCompiledWithDefer {[1]: HighlightCompiled, [2]: boolean }
---@param highlights{[string]: HighlightCompiledWithDefer} Highlights to apply along with whether to defer them.
---@param delay_deferred integer | nil Time to defer the deferred highlights. Defautls to `50` ms.
local function apply(highlights, delay_deferred)
    delay_deferred = delay_deferred or 50

    for name, highlight in pairs(highlights) do
        local function apply_current()
            vim.api.nvim_set_hl(0, name, highlight[1])
        end

        apply_current()
        if highlight[2] then
            vim.defer_fn(apply_current, delay_deferred)
        end
    end
end

return apply
