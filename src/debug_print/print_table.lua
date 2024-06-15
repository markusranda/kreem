local debug_print = {}

function debug_print.table(t, indent, visited, depth)
    indent = indent or 0
    visited = visited or {}
    depth = depth or 0
    local indentation = string.rep("  ", indent)
    local MAX_DEPTH = 10 -- Set a reasonable maximum depth to avoid hanging

    if type(t) ~= "table" then
        print(indentation .. tostring(t))
        return
    end

    if visited[t] then
        print(indentation .. "*Cyclic reference detected*")
        return
    end

    visited[t] = true

    if depth > MAX_DEPTH then
        print(indentation .. "*Max depth reached*")
        return
    end

    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indentation .. tostring(key) .. ":")
            debug_print.table(value, indent + 1, visited, depth + 1)
        else
            print(indentation .. tostring(key) .. ": " .. tostring(value))
        end
    end

    visited[t] = nil
end

return debug_print
