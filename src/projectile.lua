local projectile = {}
local uuid = require("src.uuid")
uuid.seed()

function projectile.CreateProjectile(direction)
    return {
        sprite = love.graphics.newImage("assets/bullet.png"),
        x = Player.x + Player.sprite:getWidth() / 2,
        y = Player.y + Player.sprite:getHeight() / 2,
        direction = { x = direction.x, y = direction.y },
        speed = BULLET_SPEED,
        radius = 10,
        id = uuid.new()
    }
end

return projectile
