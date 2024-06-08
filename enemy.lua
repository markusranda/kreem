local enemy = {}

function enemy.CreateEnemy(posX, posY)
    return {
        sprite = love.graphics.newImage("finger.png"),
        x = posX,
        y = posY,
        direction = { x = 0, y = -1 },
        speed = ENEMY_SPEED,
        radius = 25
    }
end

return enemy
