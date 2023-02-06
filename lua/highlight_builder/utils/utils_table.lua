--- Container for functions.
local U = {}


--- Convert a table to a string. Needs to be called recursively.
---@param t table Table to convert.
---@param level number Indentaion level.
---@return string string String representation of the table.
local function table_to_string(t, level)
    local function indent_to(l)
        return string.rep('    ', l)
    end

    local result = '{\n'

    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = t[k]
        local k_string =
            (type(k) == 'number')
            and ''
            or '[\'' .. k .. '\']' .. ' = '
        local v_string =
            (type(v) == 'table')
            and table_to_string(v, level + 1)
            or
                (type(v) == 'string')
                and '\'' .. v .. '\''
                or tostring(v)

        result = result .. indent_to(level + 1) .. k_string .. v_string .. ',\n'
    end


    if result:sub(-2) == ',\n' then
        result = result:sub(1, -3)
    end

    return result .. '\n' .. indent_to(level) .. '}'
end


--- Convert a table to string.
---@param table table Table to convert.
---@return string string String representation of the table.
function U.to_string(table)
    return table_to_string(table, 0)
end


--- Save a table into a require-able lua file.
---@param table table Table to save.
---@param path string Path of the file where to save.
function U.save_table(table, path)
    local file = io.open(path, 'w')

    if file then
        file:write(
            -- Table
            'return ' .. U.to_string(table) .. '\n'
        )

        file:close()
    end
end


return U

