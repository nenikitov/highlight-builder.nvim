---@meta

---@class HighlightCompiledDefinition: TextStyle Highlight properties necessary to create a new highlight group.
---@field fg string? Foreground color for GUI interfaces.
---@field bg string? Background color for GUI interfaces.
---@field sp string? Special color (used for underline) for GUI interfaces.
---@field ctermfg ColorTerm? Foreground color for terminal interfaces.
---@field ctermbg ColorTerm? Background color for terminal interfaces.
---@field cterm TextStyle? Text style for terminal interfaces.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@class HighlightCompiledLink Highlight properties necessary to create a link highlight.
---@field link string? Name of the highlight group to link this one to.
---@field default boolean? Whether to force this Highlight as "default" so no other highlight commands can overwrite it.

---@alias HighlightCompiled HighlightCompiledDefinition | HighlightCompiledLink
