local projectile = require("projectile")
local enemy = require("enemy")
local collision = require("collision")
local powerup = require("powerup")

SPEED = 200
BULLET_SPEED = 600
ENEMY_SPEED = 150
SHOOTING_COOLDOWN = 0.5
ENEMY_DMG_COOLDOWN = 0.5

Player = {}
Enemies = {}
Projectiles = {}
Powerups = {}
local spawn_timer = 0
local shooting_cooldown_timer = 0
local enemy_dmg_timer = {}

function love.load()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local player = {
        x = width / 2,
        y = height / 2,
        sprite = love.graphics.newImage("assets/hat.png"),
        direction = { x = 0, y = -1 },
        dmg = 50,
        radius = 16,
        hp = 100
    }
    Player = player

    -- Load and play the soundtrack
    local soundtrack = love.audio.newSource("assets/main_soundtrack.wav", "stream")
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

    for key, curPowerup in pairs(Powerups) do
        love.graphics.draw(curPowerup.sprite, curPowerup.x, curPowerup.y)
    end

    for key, curEnemy in pairs(Enemies) do
        local angle = math.atan2(curEnemy.direction.y, curEnemy.direction.x) + math.pi / 2
        love.graphics.draw(curEnemy.sprite, curEnemy.x, curEnemy.y, angle, 1, 1, curEnemy.sprite:getWidth() / 2,
            curEnemy.sprite:getHeight() / 2)
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
    local function getRandomBorderPosition()
        local side = love.math.random(1, 4)
        local x, y

        if side == 1 then -- top
            x = love.math.random(0, width)
            y = 0
        elseif side == 2 then -- right
            x = width
            y = love.math.random(0, height)
        elseif side == 3 then -- bottom
            x = love.math.random(0, width)
            y = height
        else -- left
            x = 0
            y = love.math.random(0, height)
        end

        return x, y
    end
    local posX, posY = getRandomBorderPosition()
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

local function remove_enemy(key, selectedEnemy)
    enemy_dmg_timer[selectedEnemy.id] = nil
    Enemies[key] = nil

    local rand = math.random()
    if rand <= 0.10 then
        local powerupEntity = powerup.CreatePowerup(selectedEnemy.x, selectedEnemy.y)
        table.insert(Powerups, powerupEntity)
    end
end

local function handle_enemy(key, selectedEnemy, dt)
    if selectedEnemy.hp <= 0 then
        remove_enemy(key, selectedEnemy)
        return
    end

    -- Calculate direction towards player
    local directionX = Player.x - selectedEnemy.x
    local directionY = Player.y - selectedEnemy.y
    selectedEnemy.direction.x, selectedEnemy.direction.y = normalizeVector(directionX, directionY)

    -- Update selectedEnemy position
    local updateX = selectedEnemy.x + selectedEnemy.direction.x * selectedEnemy.speed * dt
    local updateY = selectedEnemy.y + selectedEnemy.direction.y * selectedEnemy.speed * dt

    -- Don't update if too close to player
    local collided = collision.CheckCircleCollision(updateX, updateY, selectedEnemy.radius, Player.x, Player.y, Player
        .radius)

    if not collided then
        -- Move
        selectedEnemy.x = updateX
        selectedEnemy.y = updateY
    end

    if enemy_dmg_timer[selectedEnemy.id] <= 0 and collided then
        -- Damage the player
        Player.hp = Player.hp - selectedEnemy.dmg
        enemy_dmg_timer[selectedEnemy.id] = ENEMY_DMG_COOLDOWN
    end
end

local function handle_enemies(dt)
    for key, enemy in pairs(Enemies) do
        handle_enemy(key, enemy, dt)
    end
end

local function handle_enemy_dmg_timers(dt)
    for key, timer in pairs(enemy_dmg_timer) do
        if timer > 0 then
            enemy_dmg_timer[key] = timer - dt
        end
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- 1 represents the left mouse button
    if button == 1 and shooting_cooldown_timer <= 0 then
        -- Calculate the difference in coordinates
        local dx = x - Player.x
        local dy = y - Player.y
        local length = math.sqrt(dx * dx + dy * dy)

        -- Normalize the vector (make it unit length)
        if length ~= 0 then
            dx = dx / length
            dy = dy / length
        end

        local direction = { x = dx, y = dy }
        table.insert(Projectiles, projectile.CreateProjectile(direction))
        shooting_cooldown_timer = SHOOTING_COOLDOWN
    end
end

local function handle_shooting_timer(dt)
    if shooting_cooldown_timer > 0 then
        shooting_cooldown_timer = shooting_cooldown_timer - dt
    end
end


function love.update(dt)
    handle_movement(dt)
    handle_shooting_timer(dt)
    handle_projectiles(dt)
    handle_enemy_dmg_timers(dt)
    handle_enemies(dt)

    spawn_timer = spawn_timer + dt
    if spawn_timer >= 5 then
        spawn_timer = spawn_timer - 5
        spawn_enemy()
    end
end
