local player = {}

function player.CreatePlayer(xPos, yPos)
    return {
        x = xPos,
        y = yPos,
        sprite = love.graphics.newImage("assets/hat.png"),
        direction = { x = 0, y = -1 },
        dmg = 50,
        radius = 16,
        hp = 100,
        speed = 200,
        upgrades = {}
    }
end

return player
