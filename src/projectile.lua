local projectile = {}
local uuid = require("src.uuid")
uuid.seed()

function projectile.CreateProjectile(direction)
    return {
        name = "o",
        x = Player.x,
        y = Player.y,
        direction = { x = direction.x, y = direction.y },
        speed = BULLET_SPEED,
        radius = 10,
        id = uuid.new()
    }
end

return projectile
