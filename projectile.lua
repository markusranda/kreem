local projectile = {}

function projectile.CreateProjectile()
    return {
        name = "o",
        x = Player.x,
        y = Player.y,
        direction = { x = Player.direction.x, y = Player.direction.y },
        speed = BULLET_SPEED,
        radius = 10
    }
end

return projectile
