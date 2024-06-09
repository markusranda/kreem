local projectile = require("src.projectile")
local enemy = require("src.enemy")
local collision = require("src.collision")
local powerup = require("src.powerup")
local sti = require("src.sti")
local player = require("src.player")
local kreem = {}

SPEED = 200
BULLET_SPEED = 600
ENEMY_SPEED = 150
SHOOTING_COOLDOWN = 0.5
ENEMY_DMG_COOLDOWN = 0.5

Camera = {
    x = 0,
    y = 0
}
Zoom = 2
Player = {}
Enemies = {}
Projectiles = {}
Powerups = {}
Map = {}
AtlasImage = {}
local spawn_timer = 0
local shooting_cooldown_timer = 0
local enemy_dmg_timer = {}

Sounds = {}

function kreem.load()
    -- Load map
    Map = sti("assets/maps/room_1.lua")

    local mapWidth = Map.width * Map.tilewidth
    local mapHeight = Map.height * Map.tileheight
    Player = player.CreatePlayer(mapWidth / 2, mapHeight / 2)

    -- Load and play the soundtrack
    local soundtrack = love.audio.newSource("assets/main_soundtrack.wav", "stream")
    Sounds["shoot"] = love.audio.newSource("assets/shoot.wav", "stream")
    Sounds["player_damage"] = love.audio.newSource("assets/damage_2.wav", "stream")
    Sounds["enemy_damage"] = love.audio.newSource("assets/enemy_damage.wav", "stream")
    Sounds["enemy_death"] = love.audio.newSource("assets/enemy_death.wav", "stream")

    soundtrack:setLooping(true)
    love.audio.play(soundtrack)
    love.audio.setVolume(0.25)
end

function kreem.draw()
    -- Translate the coordinate system by the negative camera position
    love.graphics.push()
    love.graphics.translate(-Camera.x, -Camera.y)
    love.graphics.scale(Zoom, Zoom)

    -- Draw map
    Map:draw(-Camera.x, -Camera.y, Zoom, Zoom)

    -- Draw player
    local angle = math.atan2(Player.direction.y, Player.direction.x) - math.pi / 2
    love.graphics.draw(Player.sprite, Player.x, Player.y, angle, 1, 1, Player.sprite:getWidth() / 2,
        Player.sprite:getHeight() / 2)

    -- Draw upgrades
    for key, curPowerup in pairs(Powerups) do
        love.graphics.draw(curPowerup.sprite, curPowerup.x, curPowerup.y)
    end

    -- Draw projectiles
    for key, projectile in pairs(Projectiles) do
        love.graphics.print(projectile.name, projectile.x, projectile.y)
    end

    -- Draw enemies
    for key, curEnemy in pairs(Enemies) do
        local angle = math.atan2(curEnemy.direction.y, curEnemy.direction.x) + math.pi / 2
        love.graphics.draw(curEnemy.sprite, curEnemy.x, curEnemy.y, angle, 1, 1, curEnemy.sprite:getWidth() / 2,
            curEnemy.sprite:getHeight() / 2)
    end

    -- Restore the previous coordinate system
    love.graphics.pop()

    -- Draw UI
    love.graphics.print(string.format("HP: %s", Player.hp), 15, 15)
    love.graphics.print(string.format("Coords: [%s, %s]", Player.x, Player.y), 15, 25)
    for key, bool in pairs(Player.upgrades) do
        local width = love.graphics.getWidth()
        love.graphics.print(key, width - 15 - love.graphics.getFont():getWidth(key), 15)
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

local function handle_projectiles(dt)
    for key, projectile in pairs(Projectiles) do
        local collided = false
        for key, enemy in pairs(Enemies) do
            collided = collision.CheckCircleCollision(projectile.x, projectile.y, projectile.radius, enemy.x,
                enemy.y,
                enemy.radius)

            if collided then
                enemy.hp = enemy.hp - Player.dmg
                Sounds.enemy_damage:play()
                if enemy.hp <= 0 then
                    Sounds.enemy_death:play()
                end
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
    if rand <= 1 then
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
        Sounds.player_damage:stop()
        Sounds.player_damage:play()
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

local function fire_single_shot(x, y)
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

local function fire_shotgun_shot(x, y)
    -- Calculate the difference in coordinates
    local dx = x - Player.x
    local dy = y - Player.y
    local length = math.sqrt(dx * dx + dy * dy)

    -- Normalize the vector (make it unit length)
    if length ~= 0 then
        dx = dx / length
        dy = dy / length
    end

    -- Create three directions with a slight angle offset
    local angleOffset = math.rad(10) -- 10 degree offset
    local baseAngle = math.atan2(dy, dx)
    local directions = {
        { x = math.cos(baseAngle - angleOffset), y = math.sin(baseAngle - angleOffset) },
        { x = dx,                                y = dy }, -- original direction
        { x = math.cos(baseAngle + angleOffset), y = math.sin(baseAngle + angleOffset) }
    }

    -- Create and insert three projectiles with the different directions
    for _, dir in ipairs(directions) do
        table.insert(Projectiles, projectile.CreateProjectile(dir))
    end

    shooting_cooldown_timer = SHOOTING_COOLDOWN
end

function kreem.mousepressed(x, y, button, istouch, presses)
    -- 1 represents the left mouse button
    if button == 1 and shooting_cooldown_timer <= 0 then
        if Player.upgrades["shotgun"] ~= nil then
            fire_shotgun_shot(x, y)
        else
            fire_single_shot(x, y)
        end

        Sounds.shoot:stop()
        Sounds.shoot:play()
    end
end

local function handle_shooting_timer(dt)
    if shooting_cooldown_timer > 0 then
        shooting_cooldown_timer = shooting_cooldown_timer - dt
    end
end

local function handle_player_collision(dt)
    for key, curPowerup in pairs(Powerups) do
        local collided = collision.CheckCircleCollision(Player.x, Player.y, Player.radius, curPowerup.x, curPowerup.y,
            curPowerup.radius)
        if collided then
            Player.upgrades["shotgun"] = true
            Powerups[key] = nil
        end
    end
end

local function handle_camera()
    -- Center on player
    Camera.x = (Player.x * Zoom) - (love.graphics.getWidth() / 2)
    Camera.y = (Player.y * Zoom) - (love.graphics.getHeight() / 2)
end

function kreem.update(dt)
    Map:update(dt)
    handle_movement(dt)
    handle_shooting_timer(dt)
    handle_projectiles(dt)
    handle_enemy_dmg_timers(dt)
    handle_enemies(dt)
    handle_player_collision(dt)
    handle_camera()

    spawn_timer = spawn_timer + dt
    if spawn_timer >= 5 then
        spawn_timer = spawn_timer - 5
        spawn_enemy()
    end
end

return kreem