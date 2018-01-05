-- Function that calculates the length of a table
local table_utils = {}

function table_utils.length(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

return table_utils
