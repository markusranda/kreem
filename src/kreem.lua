local projectile              = require("src.projectile")
local enemy_finger            = require("src.enemy.finger")
local enemy_finger_boss       = require("src.enemy.finger_boss")
local collision               = require("src.collision.collision")
local kreem_audio             = require("src.kreem_audio")
local kreem_maps              = require("src.kreem_maps")
local ui_hp                   = require("src.ui.ui_hp")
local consts                  = require("src.collision.consts")
local upgrade_consts          = require("src.upgrade.upgrade_consts")
local kreem_teleport          = require("src.kreem_teleport")
local player                  = require("src.player")
local kreem                   = {}

local level_state_consts      = {
    RUNNING = "RUNNING",
    LOADING = "LOADING"
}
MAX_ENEMIES                   = 4
LEVEL_LOAD_TIME               = 0.5
ChangeLevelJob                = { duration = 0, direction = "", loaded = true }
LevelState                    = level_state_consts.RUNNING
SHOOTING_COOLDOWN             = 0.5
Camera                        = {
    x = 0,
    y = 0,
    zoom = 2
}
Player                        = {}
Projectiles                   = {}
Upgrades                      = {}
CurrentMap                    = {}
World                         = {}

-- Level -> Room ->
KreemWorld                    = {
    level_1 = {
        root = {}
    }
}
CurrentLevel                  = "level_1"
local shooting_cooldown_timer = 0


local function place_randomly_within_map(object)
    local width, height = CurrentMap.width * CurrentMap.tilewidth, CurrentMap.height * CurrentMap.tileheight
    local x, y
    local isValidPosition = false

    while not isValidPosition do
        local side = love.math.random(1, 4)

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

        -- Set the position of the object
        object.body:setPosition(x, y)

        -- Check for collisions with walls
        isValidPosition = true
        World:queryBoundingBox(x - object.radius, y - object.radius, x + object.radius, y + object.radius,
            function(fixture)
                if fixture:getUserData().name == "Wall" then
                    isValidPosition = false
                    return false -- Terminate the query
                end
                return true
            end)
    end
end

local function spawn_enemy()
    local newEnemy = nil
    local rnd = math.random()
    if rnd <= 0.05 then
        newEnemy = enemy_finger_boss:create(0, 0)
    else
        newEnemy = enemy_finger:create(0, 0)
    end

    place_randomly_within_map(newEnemy)
    KreemWorld[CurrentLevel].root.enemies[newEnemy.id] = newEnemy
    KreemWorld[CurrentLevel].root.enemy_count = KreemWorld[CurrentLevel].root.enemy_count + 1
end

local function handle_spawn_enemies()
    -- Add all untill full
    for i = KreemWorld[CurrentLevel].root.enemy_count, MAX_ENEMIES do
        spawn_enemy()
    end
end


function kreem.load()
    -- Setup window
    love.window.setMode(1280, 1024, { fullscreen = false, resizable = true })
    love.window.setTitle("KREEM")

    -- Setup sounds
    kreem_audio.Init()
    kreem_audio.PlayMainSoundtrack()

    -- Initialize physics world
    World = love.physics.newWorld(0, 0, true)

    -- Set world meter size (in pixels)
    love.physics.setMeter(32)

    -- Load map
    kreem_maps.load_first_map()

    -- Load player
    Player = player:create()

    -- Spawn all enemies for this room
    handle_spawn_enemies()
end

local function draw_damage_indicator()
    if Player.taken_dmg_timer > 0 then
        local transparency = (Player.taken_dmg_timer / Player.taken_dmg_duration) - 0.5
        local camWidth = love.graphics.getWidth() / Camera.zoom
        local camHeight = love.graphics.getHeight() / Camera.zoom
        local camX = Camera.x
        local camY = Camera.y

        love.graphics.setColor(1, 0, 0, transparency)
        love.graphics.rectangle("fill", camX, camY, camWidth, camHeight)
    end
end

function kreem.draw()
    love.graphics.push()
    love.graphics.scale(Camera.zoom, Camera.zoom)
    love.graphics.translate(-Camera.x, -Camera.y)

    -- Draw map
    love.graphics.setColor(1, 1, 1)
    CurrentMap:draw(-Camera.x, -Camera.y, Camera.zoom, Camera.zoom)

    -- Draw player
    Player:draw()

    -- Draw upgrades
    for key, curPowerup in pairs(Upgrades) do
        if not curPowerup.body:isDestroyed() then
            local x, y = curPowerup.body:getPosition()
            love.graphics.draw(curPowerup.sprite, x, y, 0, 1, 1, curPowerup.sprite:getWidth() / 2,
                curPowerup.sprite:getHeight() / 2)
        end
    end

    -- Draw projectiles
    for key, projectile in pairs(Projectiles) do
        if not projectile.body:isDestroyed() then
            local x, y = projectile.body:getPosition()
            love.graphics.draw(projectile.sprite, x, y, 0, 1, 1, projectile.sprite:getWidth() / 2,
                projectile.sprite:getHeight() / 2)
        end
    end

    -- Draw enemies
    for key, curEnemy in pairs(KreemWorld[CurrentLevel].root.enemies) do
        local angle = math.atan2(curEnemy.direction.y, curEnemy.direction.x) + math.pi / 2
        if not curEnemy.body:isDestroyed() then
            local original_radius = curEnemy.sprite:getWidth() / 2 -- Assuming the sprite is square
            local scale_factor = curEnemy.radius / original_radius

            local x, y = curEnemy.body:getPosition()
            local w, h = curEnemy.sprite:getWidth() / 2, curEnemy.sprite:getHeight() / 2
            love.graphics.draw(curEnemy.sprite, x, y, angle, scale_factor, scale_factor, w, h)
        end
    end

    -- Draw the entire scene with the blur effect
    local transparency = ChangeLevelJob.duration / LEVEL_LOAD_TIME
    local camWidth = love.graphics.getWidth() / Camera.zoom
    local camHeight = love.graphics.getHeight() / Camera.zoom
    local camX = Camera.x
    local camY = Camera.y

    love.graphics.setColor(0, 0, 0, transparency)
    love.graphics.rectangle("fill", camX, camY, camWidth, camHeight)

    draw_damage_indicator()

    -- Draw physics shapes for debugging
    -- for _, body in pairs(World:getBodies()) do
    --     for _, fixture in pairs(body:getFixtures()) do
    --         local shape = fixture:getShape()
    --         if shape:typeOf("PolygonShape") then
    --             love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
    --         end
    --     end
    -- end

    love.graphics.pop()

    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    ui_hp.draw_hp(Player)
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

    local joysticks = love.joystick.getJoysticks()
    if #joysticks > 0 and moveX == 0 and moveY == 0 then
        local joystick = joysticks[1]
        moveX = moveX + joystick:getGamepadAxis("leftx")
        moveY = moveY + joystick:getGamepadAxis("lefty")
    end

    -- Normalize diagonal movement
    if moveX ~= 0 and moveY ~= 0 then
        moveX = moveX * math.sqrt(0.5)
        moveY = moveY * math.sqrt(0.5)
    end

    if moveX ~= 0 or moveY ~= 0 then
        Player.direction = { x = moveX, y = moveY }
        Player.state = "run"
    else
        Player.state = "idle"
    end

    -- Apply force to the physics body
    local xVel = moveX * Player.speed
    local yVel = moveY * Player.speed
    Player.body:setLinearVelocity(xVel, yVel)
end

local function handle_enemies(dt)
    for key, selectedEnemy in pairs(KreemWorld[CurrentLevel].root.enemies) do
        if selectedEnemy.hp <= 0 or selectedEnemy.body:isDestroyed() then
            selectedEnemy:destroy()
            return
        end

        selectedEnemy:update(dt)
    end
end

local function fire_single_shot(x, y)
    -- Calculate the difference in coordinates
    local xP, yP = Player.body:getPosition()
    local dx = x - xP
    local dy = y - yP
    local length = math.sqrt(dx * dx + dy * dy)

    -- Normalize the vector (make it unit length)
    if length ~= 0 then
        dx = dx / length
        dy = dy / length
    end

    local dir = { x = dx, y = dy }
    local pro = projectile.CreateProjectile(dir)
    Projectiles[pro.id] = pro
    shooting_cooldown_timer = SHOOTING_COOLDOWN
end

local function fire_shotgun_shot(x, y)
    -- Calculate the difference in coordinates
    local xP, yP = Player.body:getPosition()
    local dx = x - xP
    local dy = y - yP
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
        local pro = projectile.CreateProjectile(dir)
        Projectiles[pro.id] = pro
    end

    shooting_cooldown_timer = SHOOTING_COOLDOWN
end

local function windowToWorld(wx, wy)
    -- Example conversion, adjust according to your camera/view setup
    local worldX = (wx / Camera.zoom) + Camera.x
    local worldY = (wy / Camera.zoom) + Camera.y

    return worldX, worldY
end

local function initiate_shoot(x, y)
    if Player.upgrades[upgrade_consts.UPGRADE_SHOTGUN] ~= nil then
        fire_shotgun_shot(x, y)
    else
        fire_single_shot(x, y)
    end

    kreem_audio.sounds.shoot:stop()
    kreem_audio.sounds.shoot:play()
end

function kreem.mousepressed(x, y, button, istouch, presses)
    -- 1 represents the left mouse button
    if button == 1 and shooting_cooldown_timer <= 0 then
        local wx, wy = windowToWorld(x, y)
        initiate_shoot(wx, wy);
    end
end

function kreem.mousemoved(x, y, dx, dy, istouch)
    local wx, wy = windowToWorld(x, y)
    Player.aimPos = { x = wx, y = wy }
end

local function handle_shooting_timer(dt)
    if shooting_cooldown_timer > 0 then
        shooting_cooldown_timer = shooting_cooldown_timer - dt
    end
end

local function handle_shooting_joystick(dt)
    if shooting_cooldown_timer <= 0 then
        local joysticks = love.joystick.getJoysticks()
        if #joysticks > 0 then
            local joystick = joysticks[1]
            local x = joystick:getGamepadAxis("rightx")
            local y = joystick:getGamepadAxis("righty")

            if math.abs(x) < 0.1 and math.abs(y) < 0.1 then
                x = 0
                y = 0
            else
                local px, py = Player.body:getPosition()
                Player.aimPos = { x = px + x, y = py + y }
                local wx, wy = Player.aimPos.x, Player.aimPos.y
                initiate_shoot(wx, wy);
            end
        end
    end
end

local function handle_camera()
    -- Center on player
    local x, y = Player.body:getPosition()
    Camera.x = x - (love.graphics.getWidth() / 2) / Camera.zoom
    Camera.y = y - (love.graphics.getHeight() / 2) / Camera.zoom
end

local function restore_enemies()
    for key, enemy in pairs(KreemWorld[CurrentLevel].root.enemies) do
        enemy:create_body(0, 0)
        place_randomly_within_map(enemy)
    end
end


local function handle_change_level(dt)
    if ChangeLevelJob.duration > 0 then
        LevelState = level_state_consts.LOADING
        ChangeLevelJob.duration = ChangeLevelJob.duration - dt

        if not ChangeLevelJob.loaded then
            local direction = kreem_maps.load_next_map(ChangeLevelJob.direction)
            local new_coords = kreem_teleport.teleport_player(direction)
            Player:create_body(new_coords.x, new_coords.y)
            Player.state = "idle"
            handle_camera()

            restore_enemies()
            -- Spawn all enemies for this room
            handle_spawn_enemies()


            ChangeLevelJob.loaded = true
        end
    else
        LevelState = level_state_consts.RUNNING
    end
end

function kreem.update(dt)
    if LevelState == level_state_consts.RUNNING then
        CurrentMap:update(dt)
        World:update(dt)

        handle_movement(dt)
        handle_shooting_timer(dt)
        handle_shooting_joystick(dt)
        handle_enemies(dt)
        handle_camera()
    end
    handle_change_level(dt)

    Player:update(dt)
end

collision.CollisionEmitter:on(consts.COLLISION_BULLET_WALL, function(bullet_data, wallData)
    bullet_data.body:destroy()
    Projectiles[bullet_data.id] = nil
end)

collision.CollisionEmitter:on(consts.COLLISION_BULLET_ENEMY, function(bullet_data, enemy_data)
    local enemy = KreemWorld[CurrentLevel].root.enemies[enemy_data.id]
    local pro = Projectiles[bullet_data.id]
    if pro then
        enemy.hp = enemy.hp - pro.dmg
    end

    -- Cleanup projectile
    bullet_data.body:destroy()
    Projectiles[bullet_data.id] = nil
end)

collision.CollisionEmitter:on(consts.COLLISION_ENEMY_PLAYER, function(enemy_data, player_data)
    KreemWorld[CurrentLevel].root.enemies[enemy_data.id]:attack_player()
end)

collision.CollisionEmitter:on(consts.COLLISION_UPGRADE_PLAYER, function(upgrade_data, player_data)
    Player.upgrades[upgrade_data.type] = true
    Upgrades[upgrade_data.id]:destroy()
end)

collision.CollisionEmitter:on(consts.COLLISION_PLAYER_TELEPORT, function(player_data, teleport_data)
    ChangeLevelJob = { direction = teleport_data.properties.direction, duration = LEVEL_LOAD_TIME, loaded = false }
end)

return kreem
