local EventEmitter      = require('src.event_emitter') -- Adjust the path as necessary
local consts            = require('src.collision.consts')
local collision         = {
    CollisionEmitter = EventEmitter:new()
}

local collisionHandlers = {
    ["PlayerTeleport"] = function(player_data, teleport_data)
        collision.CollisionEmitter:emit(consts.COLLISION_PLAYER_TELEPORT, player_data, teleport_data)
    end,
    ["BulletWall"] = function(player_data, teleport_data)
        collision.CollisionEmitter:emit(consts.COLLISION_BULLET_WALL, player_data, teleport_data)
    end,
    ["BulletEnemy"] = function(bulletData, enemyData)
        collision.CollisionEmitter:emit(consts.COLLISION_BULLET_ENEMY, bulletData, enemyData)
    end,
    ["EnemyPlayer"] = function(enemy_data, player_data)
        collision.CollisionEmitter:emit(consts.COLLISION_ENEMY_PLAYER, enemy_data, player_data)
    end
}

function collision.BeginContact(a, b, coll)
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()

    if not userDataA or not userDataB then return end

    local key = userDataA.name .. userDataB.name
    local handler = collisionHandlers[key]

    if handler then
        handler(userDataA, userDataB)
    else
        -- Handle reversed pairs
        key = userDataB.name .. userDataA.name
        handler = collisionHandlers[key]
        if handler then
            handler(userDataB, userDataA)
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
