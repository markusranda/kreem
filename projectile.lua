local projectile = {}
local uuid = require("uuid")
uuid.seed()

function projectile.CreateProjectile()
    return {
        name = "o",
        x = Player.x,
        y = Player.y,
        direction = { x = Player.direction.x, y = Player.direction.y },
        speed = BULLET_SPEED,
        radius = 10,
        id = uuid.new()
    }
end

return projectile
