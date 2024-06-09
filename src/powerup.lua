local powerup = {}

function powerup.CreatePowerup(xPos, yPos)
    return {
        sprite = love.graphics.newImage("assets/upgrade.png"),
        type = "shotgun",
        x = xPos,
        y = yPos,
        radius = 32,
    }
end

return powerup
