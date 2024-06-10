local projectile = require("src.projectile")
local enemy = require("src.enemy")
local collision = require("src.collision")
local powerup = require("src.powerup")
local sti = require("src.sti")
local player = require("src.player")
local kreem_audio = require("src.kreem_audio")
local kreem = {}

BULLET_SPEED = 600
ENEMY_SPEED = 150
SHOOTING_COOLDOWN = 0.5
ENEMY_DMG_COOLDOWN = 0.5

Camera = {
    x = 0,
    y = 0,
    zoom = 2
}
Player = {}
Enemies = {}
Projectiles = {}
Powerups = {}
Map = {}
World = {}
local spawn_timer = 0
local shooting_cooldown_timer = 0
enemy_dmg_timer = {}

local function beginContact(a, b, coll)
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()

    if userDataA and userDataB then
        if (userDataA == "Player" and userDataB == "Teleport") or (userDataA == "Teleport" and userDataB == "Player") then
            print("TELEPORT TIME!")
        end
    end
end

local function create_object_fixtures(layerName, objectName)
    local objectLayer = Map.layers[layerName]

    if objectLayer and objectLayer.objects then
        for _, object in ipairs(objectLayer.objects) do
            local body = love.physics.newBody(World, object.x + object.width / 2, object.y + object.height / 2, "static")
            local shape = love.physics.newRectangleShape(object.width, object.height)
            local fixture = love.physics.newFixture(body, shape)
            if objectName then
                fixture:setUserData(objectName)
            else
                fixture:setUserData(object.name)
            end
        end
    else
        print(layerName .. " layer or objects not found!")
    end
end

function kreem.load()
    -- Setup window
    love.window.setMode(1280, 1024, { fullscreen = false, resizable = true })

    -- Setup sounds
    kreem_audio.Init()
    kreem_audio.PlayMainSoundtrack()

    -- Initialize physics world
    World = love.physics.newWorld(0, 0, true)

    -- Set world meter size (in pixels)
    love.physics.setMeter(32)

    -- Load map
    Map = sti("assets/maps/room_1.lua", { "box2d" })

    -- Create Box2D collision objects
    Map:box2d_init(World)

    -- Initialize player
    local mapWidth = Map.width * Map.tilewidth
    local mapHeight = Map.height * Map.tileheight
    Player = player.CreatePlayer(mapWidth / 2, mapHeight / 2)

    -- Make player a physics object
    Player.body = love.physics.newBody(World, Player.x, Player.y, "dynamic")
    Player.shape = love.physics.newCircleShape(Player.radius)
    Player.fixture = love.physics.newFixture(Player.body, Player.shape)
    Player.fixture:setUserData("Player")

    -- Create fixtures for objects in the Teleports layer
    create_object_fixtures("Teleports", "Teleport")
    create_object_fixtures("Walls")

    -- Set collision callback
    World:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function kreem.draw()
    love.graphics.push()
    love.graphics.scale(Camera.zoom, Camera.zoom)
    love.graphics.translate(-Camera.x, -Camera.y)

    -- Draw map
    love.graphics.setColor(1, 1, 1)
    Map:draw(-Camera.x, -Camera.y, Camera.zoom, Camera.zoom)

    -- Draw Collision Map (useful for debugging)
    love.graphics.setColor(1, 0, 0)
    Map:box2d_draw()
    love.graphics.setColor(1, 1, 1)

    -- Draw player
    local angle = math.atan2(Player.direction.y, Player.direction.x) - math.pi / 2
    love.graphics.draw(Player.sprite, Player.x, Player.y, angle, 1, 1, Player.sprite:getWidth() / 2,
        Player.sprite:getHeight() / 2)

    -- Draw upgrades
    for key, curPowerup in pairs(Powerups) do
        love.graphics.draw(curPowerup.sprite, curPowerup.x, curPowerup.y, 0, 1, 1, curPowerup.sprite:getWidth() / 2,
            curPowerup.sprite:getHeight() / 2)
    end

    -- Draw projectiles
    for key, projectile in pairs(Projectiles) do
        love.graphics.draw(projectile.sprite, projectile.x, projectile.y, 0, 1, 1, projectile.sprite:getWidth() / 2,
            projectile.sprite:getHeight() / 2)
    end

    -- Draw enemies
    for key, curEnemy in pairs(Enemies) do
        local angle = math.atan2(curEnemy.direction.y, curEnemy.direction.x) + math.pi / 2
        love.graphics.draw(curEnemy.sprite, curEnemy.x, curEnemy.y, angle, 1, 1, curEnemy.sprite:getWidth() / 2,
            curEnemy.sprite:getHeight() / 2)
    end

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

    -- Apply force to the physics body
    Player.body:setLinearVelocity(moveX * Player.speed, moveY * Player.speed)
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
                kreem_audio.sounds.enemy_damage:play()
                if enemy.hp <= 0 then
                    kreem_audio.sounds.enemy_death:play()
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
    -- spawnn random enemy
    local random = love.math.random(1, 10)

    local createdEnemy = {}
    if random < 2 then
        createdEnemy = enemy.CreateEnemyFingerBoss(posX, posY)
    else
        createdEnemy = enemy.CreateEnemyFinger(posX, posY)
    end

    enemy_dmg_timer[createdEnemy.id] = 0
    table.insert(Enemies, createdEnemy)
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

    selectedEnemy.update(selectedEnemy, dt)
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

local function windowToWorld(wx, wy)
    -- Example conversion, adjust according to your camera/view setup
    local worldX = (wx / Camera.zoom) + Camera.x
    local worldY = (wy / Camera.zoom) + Camera.y

    return worldX, worldY
end

function kreem.mousepressed(x, y, button, istouch, presses)
    -- 1 represents the left mouse button
    if button == 1 and shooting_cooldown_timer <= 0 then
        local wx, wy = windowToWorld(x, y)
        if Player.upgrades["shotgun"] ~= nil then
            fire_shotgun_shot(wx, wy)
        else
            fire_single_shot(wx, wy)
        end

        kreem_audio.sounds.shoot:stop()
        kreem_audio.sounds.shoot:play()
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
    Camera.x = Player.x - (love.graphics.getWidth() / 2) / Camera.zoom
    Camera.y = Player.y - (love.graphics.getHeight() / 2) / Camera.zoom
end

function kreem.update(dt)
    Map:update(dt)
    World:update(dt)

    -- Sync player position with physics
    Player.x, Player.y = Player.body:getPosition()

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
