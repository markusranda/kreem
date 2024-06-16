local uuid                = require("src.uuid")
local kreem_audio         = require "src.kreem_audio"
local kreem_vector        = require "src.kreem_vector"
local collision           = require "src.collision.collision"
local consts              = require "src.collision.consts"
local enemy_finger_boss   = {}
enemy_finger_boss.__index = enemy_finger_boss

function enemy_finger_boss:update(dt)
    local x, y = self.body:getPosition()
    local pX, pY = Player.body:getPosition()

    if not self.body:isDestroyed() then
        -- Handle charge cooldown
        if self.attack_timer > 0 then
            self.attack_timer = self.attack_timer - dt
        end

        -- Handle moving state
        if self.state == "moving" then
            -- Update self velocity
            local dx = pX - x
            local dy = pY - y
            dx, dy = kreem_vector.normalize(dx, dy)
            local xVel = dx * self.speed
            local yVel = dy * self.speed
            self.body:setLinearVelocity(xVel, yVel)
            self.direction = { x = dx, y = dy }

            local isInChargeRadius = collision.CheckCircleCollision(x, y, self.attack_radius, pX, pY, Player.radius)
            if isInChargeRadius then
                self.state = "charging_windup"
                self.attack_windup_timer = self.attack_windup_limit
            end
        end

        -- Handle charging_windup state
        if self.state == "charging_windup" then
            -- Update direction towards player
            local dx, dy = kreem_vector.normalize(pX - x, pY - y)
            self.direction = { x = dx, y = dy }

            -- Update self velocity
            local dx = x - pX
            local dy = y - pY
            dx, dy = kreem_vector.normalize(dx, dy)
            local xVel = dx * self.windup_speed
            local yVel = dy * self.windup_speed
            self.body:setLinearVelocity(xVel, yVel)

            self.attack_windup_timer = self.attack_windup_timer - dt

            if self.attack_windup_timer <= 0 then
                self.state = "charging_attack"
                self.attack_windup_timer = 0
                self.attack_direction = self.direction
            end
        end

        -- Handle charging_attack state
        if self.state == "charging_attack" then
            if self.charge_distance_traveled == nil then
                self.charge_distance_traveled = 0
            end

            -- Update self velocity
            local xVel = self.attack_direction.x * self.charge_speed
            local yVel = self.attack_direction.y * self.charge_speed
            self.body:setLinearVelocity(xVel, yVel)

            -- Record distance traveled
            local vx, vy = self.body:getLinearVelocity()
            local distance = math.sqrt(vx * vx + vy * vy) * dt
            self.charge_distance_traveled = self.charge_distance_traveled + distance

            if self.charge_distance_traveled > 150 then
                self.attack_direction = nil
                self.charge_distance_traveled = nil
                self.state = "charging_cooldown"
                self.charging_cooldown_timer = self.charging_cooldown
            end
        end

        -- Handle charging_cooldown state
        if self.state == "charging_cooldown" then
            -- Deaccelerate the bastard
            local vx, vy = self.body:getLinearVelocity()
            local speed = math.sqrt(vx * vx + vy * vy)
            if speed > 0 then
                local decel = self.deac_speed * dt
                local newSpeed = speed - decel
                if newSpeed < 0 then newSpeed = 0 end
                local scale = newSpeed / speed
                self.body:setLinearVelocity(vx * scale, vy * scale)
            end

            if self.charging_cooldown_timer <= 0 then
                self.state = "moving"
                self.charging_cooldown_timer = 0
            else
                self.charging_cooldown_timer = self.charging_cooldown_timer - dt
            end
        end
    end
end

function enemy_finger_boss:attack_player()
    if self.attack_timer <= 0 then
        self.attack_timer = self.attack_cooldown

        -- Damage the player
        Player.hp = Player.hp - self.dmg
        self.attack_timer = self.attack_cooldown
    end

    self.attack_direction = nil
    self.distanceTravelled = nil
    self.state = "charging_cooldown"
    self.charging_cooldown_timer = self.attack_cooldown
end

function enemy_finger_boss:destroy()
    -- In some cases the enemies gets destroyed by world, then we need to skip this logic
    if not self.body:isDestroyed() then
        self.body:destroy()
    end

    KreemWorld[CurrentLevel].root.enemies[self.id] = nil
end

function enemy_finger_boss:create_body(xPos, yPos)
    self.body = love.physics.newBody(World, xPos, yPos, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ name = "Enemy", body = self.body, id = self.id })
    self.fixture:setCategory(consts.COLLISION_CATEGORY_ENEMY)
    self.fixture:setMask(consts.COLLISION_CATEGORY_WALL, consts.COLLISION_CATEGORY_TELEPORT)
end

function enemy_finger_boss:create(xPos, yPos)
    local self = setmetatable({}, enemy_finger_boss)
    self.sprite = love.graphics.newImage("assets/finger.png")
    self.direction = { x = 0, y = -1 }
    self.speed = 125
    self.deac_speed = 300
    self.windup_speed = self.speed * 0.5
    self.charge_speed = self.speed * 3
    self.charge_distance_traveled = nil
    self.radius = 32
    self.hp = 1000
    self.id = uuid.new()
    self.dmg = 25
    self.charging_cooldown = 1
    self.charging_cooldown_timer = 0
    self.attack_windup_limit = 0.5
    self.attack_windup_timer = 0
    self.attack_timer = 0
    self.attack_cooldown = 0.5
    self.attack_direction = { x = 0, y = 0 }
    self.attack_radius = 125
    self.state = "moving"
    self:create_body(xPos, yPos)

    return self
end

return enemy_finger_boss
