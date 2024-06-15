local EventEmitter = require('src.event_emitter') -- Adjust the path as necessary
local consts       = require('src.collision.consts')
local collision    = {
    CollisionEmitter = EventEmitter:new()
}

function collision.BeginContact(a, b, coll)
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()

    if userDataA and userDataB then
        if (userDataA.name == "Player" and userDataB.name == "Teleport") then
            collision.CollisionEmitter:emit(consts.COLLISION_PLAYER_TELEPORT, userDataA, userDataB)
        elseif ((userDataA.name == "Teleport" and userDataB.name == "Player")) then
            collision.CollisionEmitter:emit(consts.COLLISION_PLAYER_TELEPORT, userDataB, userDataA)
        end
    end
end

function collision.CheckCircleCollision(x1, y1, r1, x2, y2, r2)
    local dx = x2 - x1
    local dy = y2 - y1
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < r1 + r2
end

function collision.CheckRectanglesOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
        x2 < x1 + w1 and
        y1 < y2 + h2 and
        y2 < y1 + h1
end

return collision
