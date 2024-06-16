local kreem_vector = {}

function kreem_vector.normalize(dx, dy)
    local length = math.sqrt(dx * dx + dy * dy)

    -- Normalize the vector (make it unit length)
    if length ~= 0 then
        dx = dx / length
        dy = dy / length
    end

    return dx, dy
end

return kreem_vector
