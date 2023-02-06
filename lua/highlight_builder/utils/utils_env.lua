--- Container for functions.
local U = {}


--- Get the path to the current lua file.
---@return string path Path of the lua file.
function U.script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end


--- Execute a shell command.
---@param command string Shell command.
---@return string | nil output Output from the command.
function U.execute_shell(command)
    local handle = io.popen(command)
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result
    end
end


local is_unix = package.config:sub(1, 1) == '/'
local path_separator = is_unix and '/' or '\\'


--- Join paths with correct platform-dependent separator.
---@param ... string Paths to join.
---@return string path Joined path.
function U.path_join(...)
    local paths = {}
    for _, p in ipairs({...}) do
        if (p:sub(-1) == path_separator) then
            p = p:sub(1, -2)
        end
        table.insert(paths, p)
    end
    return table.concat(paths, path_separator)
end


return U

