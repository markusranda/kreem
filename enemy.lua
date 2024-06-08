local enemy = {}

function enemy.CreateEnemy(posX, posY)
    return {
        name = "ø",
        x = posX,
        y = posY,
        direction = { x = 0, y = -1 },
        speed = ENEMY_SPEED,
        radius = 25
    }
end

return enemy
