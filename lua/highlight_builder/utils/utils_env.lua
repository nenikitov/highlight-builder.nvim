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

return U

