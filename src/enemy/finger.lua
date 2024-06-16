local uuid           = require("src.uuid")
local consts         = require("src.collision.consts")
local kreem_audio    = require("src.kreem_audio")
local shotgun        = require("src.upgrade.shotgun")
local kreem_vector   = require("src.kreem_vector")
local enemy_finger   = {}
enemy_finger.__index = enemy_finger

function enemy_finger:update(dt)
    -- Calculate direction towards player
    if not self.body:isDestroyed() then
        local x, y = self.body:getPosition()
        local pX, pY = Player.body:getPosition()
        local dx = pX - x
        local dy = pY - y

        dx, dy = kreem_vector.normalize(dx, dy)

        -- Update self velocity
        local xVel = dx * self.speed
        local yVel = dy * self.speed
        self.body:setLinearVelocity(xVel, yVel)
        self.direction = { x = dx, y = dy }

        -- Update damage_timer
        if self.attack_timer > 0 then
            self.attack_timer = self.attack_timer - dt
        end
    else
        self:destroy()
    end
end

function enemy_finger:attack_player()
    if self.attack_timer <= 0 then
        Player.hp = Player.hp - self.dmg
        self.attack_timer = self.attack_cooldown
        kreem_audio.sounds.player_damage:stop()
        kreem_audio.sounds.player_damage:play()
    end
end

function enemy_finger:destroy()
    -- In some cases the enemies gets destroyed by world, then we need to skip this logic
    if not self.body:isDestroyed() then
        -- Check if player gets drop
        local rand = math.random()
        if rand <= self.loot_chance then
            local x, y = self.body:getPosition()
            local shotgun = shotgun:create(x, y)
            Upgrades[shotgun.id] = shotgun
        end

        self.body:destroy()
    end

    Enemies[self.id] = nil
end

function enemy_finger:create(posX, posY)
    local self = setmetatable({}, enemy_finger)
    self.radius = 16
    self.id = uuid.new()
    self.body = love.physics.newBody(World, posX, posY, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ name = "Enemy", body = self.body, id = self.id })
    self.fixture:setCategory(consts.COLLISION_CATEGORY_ENEMY)
    self.fixture:setMask(consts.COLLISION_CATEGORY_WALL, consts.COLLISION_CATEGORY_TELEPORT)
    self.sprite = love.graphics.newImage("assets/finger.png")
    self.direction = { x = 0, y = -1 }
    self.speed = 150
    self.hp = 100
    self.dmg = 10
    self.attack_timer = 0
    self.attack_cooldown = 0.5
    self.loot = "Shotgun"
    self.loot_chance = 1

    return self
end

return enemy_finger
