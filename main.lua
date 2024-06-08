local projectile = require("projectile")
local enemy = require("enemy")
local collision = require("collision")

SPEED = 200
BULLET_SPEED = 600
ENEMY_SPEED = 150
SHOOTING_COOLDOWN = 0.5
ENEMY_DMG_COOLDOWN = 0.5

Player = {}
Enemies = {}
Projectiles = {}
local spawn_timer = 0
local shooting_cooldown_timer = 0
local enemy_dmg_timer = {}

function love.load()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local player = {
        x = width / 2,
        y = height / 2,
        sprite = love.graphics.newImage("hat.png"),
        direction = { x = 0, y = -1 },
        dmg = 50,
        radius = 16,
        hp = 100
    }
    Player = player

    -- Load and play the soundtrack
    local soundtrack = love.audio.newSource("main_soundtrack.wav", "stream")
    soundtrack:setLooping(true)
    love.audio.play(soundtrack)
    love.audio.setVolume(0.25)
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
        local angle = math.atan2(enemy.direction.y, enemy.direction.x) + math.pi / 2
        love.graphics.draw(enemy.sprite, enemy.x, enemy.y, angle, 1, 1, enemy.sprite:getWidth() / 2,
            enemy.sprite:getHeight() / 2)
    end

    -- Draw UI
    love.graphics.print(string.format("HP: %s", Player.hp), 15, 15)
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
        local collided = false
        for key, enemy in pairs(Enemies) do
            collided = collision.CheckCircleCollision(projectile.x, projectile.y, projectile.radius, enemy.x,
                enemy.y,
                enemy.radius)

            if collided then
                enemy.hp = enemy.hp - Player.dmg
            end
        end

        projectile.x = projectile.x + projectile.direction.x * projectile.speed * dt
        projectile.y = projectile.y + projectile.direction.y * projectile.speed * dt

        -- Remove bullet if collision
        if collided then
            Projectiles[key] = nil
        end
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
    local enemy = enemy.CreateEnemy(posX, posY)
    enemy_dmg_timer[enemy.id] = 0
    table.insert(Enemies, enemy)
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
        if enemy.hp <= 0 then
            -- Clean up enemy
            enemy_dmg_timer[enemy.id] = nil
            Enemies[key] = nil
            goto continue
        end

        -- Calculate direction towards player
        local directionX = Player.x - enemy.x
        local directionY = Player.y - enemy.y
        enemy.direction.x, enemy.direction.y = normalizeVector(directionX, directionY)

        -- Update enemy position
        local updateX = enemy.x + enemy.direction.x * enemy.speed * dt
        local updateY = enemy.y + enemy.direction.y * enemy.speed * dt

        -- Don't update if too close to player
        local collided = collision.CheckCircleCollision(updateX, updateY, enemy.radius, Player.x, Player.y, Player
            .radius)

        if not collided then
            -- Move
            enemy.x = updateX
            enemy.y = updateY
        end

        if enemy_dmg_timer[enemy.id] <= 0 and collided then
            -- Damage the player
            Player.hp = Player.hp - enemy.dmg
            enemy_dmg_timer[enemy.id] = ENEMY_DMG_COOLDOWN
        end

        ::continue::
    end
end

local function handle_enemy_dmg_timers(dt)
    for key, timer in pairs(enemy_dmg_timer) do
        if timer > 0 then
            enemy_dmg_timer[key] = timer - dt
        end
    end
end

function love.update(dt)
    handle_movement(dt)
    handle_shooting(dt)
    handle_projectiles(dt)
    handle_enemy_dmg_timers(dt)
    handle_enemies(dt)

    spawn_timer = spawn_timer + dt
    if spawn_timer >= 5 then
        spawn_timer = spawn_timer - 5
        spawn_enemy()
    end
end
