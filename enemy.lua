local enemy = {}
local uuid = require("uuid")
uuid.seed()

function enemy.CreateEnemy(posX, posY)
    return {
        sprite = love.graphics.newImage("finger.png"),
        x = posX,
        y = posY,
        direction = { x = 0, y = -1 },
        speed = ENEMY_SPEED,
        radius = 25,
        hp = 100,
        id = uuid.new(),
        dmg = 10,
    }
end

return enemy
