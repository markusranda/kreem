local projectile = {}
local uuid = require("src.uuid")
local consts = require("src.collision.consts")
uuid.seed()

function projectile.CreateProjectile(direction)
    local pro = {}
    pro.sprite = love.graphics.newImage("assets/bullet.png")
    pro.direction = { x = direction.x, y = direction.y }
    pro.speed = 600
    pro.radius = 3
    pro.id = uuid.new()

    local x, y = Player.body:getPosition()
    pro.body = love.physics.newBody(World, x, y, "dynamic")
    pro.body:setBullet(true)
    pro.shape = love.physics.newCircleShape(pro.radius)
    pro.fixture = love.physics.newFixture(pro.body, pro.shape)
    pro.fixture:setUserData({ name = "Bullet", body = pro.body, id = pro.id })

    -- Set initial speed
    local xVel = pro.direction.x * pro.speed
    local yVel = pro.direction.y * pro.speed
    pro.body:setLinearVelocity(xVel, yVel)

    -- Proper categories
    pro.fixture:setCategory(consts.COLLISION_CATEGORY_PROJECTILE)
    pro.fixture:setMask(consts.COLLISION_CATEGORY_PLAYER)

    -- Ensure no damping to prevent slowing down
    pro.body:setLinearDamping(0)
    pro.body:setAngularDamping(0)

    return pro
end

return projectile
