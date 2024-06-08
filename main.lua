local projectile = require("projectile")
local enemy = require("enemy")
local collision = require("collision")

SPEED = 200
BULLET_SPEED = 600
ENEMY_SPEED = 150
SHOOTING_COOLDOWN = 0.5

Player = {}
Enemies = {}
Projectiles = {}
local spawn_timer = 0
local shooting_cooldown_timer = 0

function love.load()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local player = {
        x = width / 2,
        y = height / 2,
        sprite = love.graphics.newImage("hat.png"),
        direction = { x = 0, y = -1 } -- Initial direction (up)
    }
    Player = player
end

function love.draw()
    -- Draw all entities

    -- Draw player
    local angle = math.atan2(Player.direction.y, Player.direction.x) - math.pi / 2
    love.graphics.draw(Player.sprite, Player.x, Player.y, angle, 1, 1, Player.sprite:getWidth() / 2,
        Player.sprite:getHeight() / 2)

    for key, projectile in pairs(Projectiles) do
        love.graphics.print(projectile.name, projectile.x, projectile.y)
    end

    for key, enemy in pairs(Enemies) do
        local angle = math.atan2(enemy.direction.y, enemy.direction.x) - math.pi / 2
        love.graphics.draw(enemy.sprite, enemy.x, enemy.y, angle, 1, 1, enemy.sprite:getWidth() / 2,
            enemy.sprite:getHeight() / 2)
    end
end

local function handle_movement(dt)
    local moveX, moveY = 0, 0

    if love.keyboard.isDown("w") then
        moveY = moveY - 1
    end
    if love.keyboard.isDown("s") then
        moveY = moveY + 1
    end
    if love.keyboard.isDown("a") then
        moveX = moveX - 1
    end
    if love.keyboard.isDown("d") then
        moveX = moveX + 1
    end

    -- Normalize diagonal movement
    if moveX ~= 0 and moveY ~= 0 then
        moveX = moveX * math.sqrt(0.5)
        moveY = moveY * math.sqrt(0.5)
    end

    if moveX ~= 0 or moveY ~= 0 then
        Player.direction = { x = moveX, y = moveY }
    end

    Player.x = Player.x + moveX * SPEED * dt
    Player.y = Player.y + moveY * SPEED * dt
end

local function handle_shooting(dt)
    if shooting_cooldown_timer > 0 then
        shooting_cooldown_timer = shooting_cooldown_timer - dt
    end

    if love.keyboard.isDown("space") and shooting_cooldown_timer <= 0 then
        table.insert(Projectiles, projectile.CreateProjectile())

        shooting_cooldown_timer = SHOOTING_COOLDOWN
    end
end

local function handle_projectiles(dt)
    for key, projectile in pairs(Projectiles) do
        local enemy_to_remove = nil
        for key, enemy in pairs(Enemies) do
            local collided = collision.CheckCircleCollision(projectile.x, projectile.y, projectile.radius, enemy.x,
                enemy.y,
                enemy.radius)

            if collided then
                enemy_to_remove = key
            end
        end

        if enemy_to_remove then
            Enemies[enemy_to_remove] = nil
        end

        projectile.x = projectile.x + projectile.direction.x * projectile.speed * dt
        projectile.y = projectile.y + projectile.direction.y * projectile.speed * dt
    end
end

local function spawn_enemy()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()

    -- Generate a random position within the window
    local function getRandomPosition()
        local x = love.math.random(0, width)
        local y = love.math.random(0, height)
        return x, y
    end

    local posX, posY = getRandomPosition()
    table.insert(Enemies, enemy.CreateEnemy(posX, posY))
end

local function normalizeVector(x, y)
    local length = math.sqrt(x * x + y * y)
    if length > 0 then
        return x / length, y / length
    else
        return 0, 0
    end
end

local function handle_enemies(dt)
    for key, enemy in pairs(Enemies) do
        -- Calculate direction towards player
        local directionX = Player.x - enemy.x
        local directionY = Player.y - enemy.y
        enemy.direction.x, enemy.direction.y = normalizeVector(directionX, directionY)

        -- Update enemy position
        enemy.x = enemy.x + enemy.direction.x * enemy.speed * dt
        enemy.y = enemy.y + enemy.direction.y * enemy.speed * dt
    end
end

function love.update(dt)
    handle_movement(dt)
    handle_shooting(dt)
    handle_projectiles(dt)
    handle_enemies(dt)

    spawn_timer = spawn_timer + dt
    if spawn_timer >= 5 then
        spawn_timer = spawn_timer - 5
        spawn_enemy()
    end
end
