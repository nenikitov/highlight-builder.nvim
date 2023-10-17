local Tty = {}

local term = os.getenv('TERM')

function Tty.is_gui()
    return term ~= 'linux'
end

return Tty
