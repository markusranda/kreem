local uuid = require("src.uuid")
local consts = require("src.collision.consts")
local enemy_finger = {}
enemy_finger.__index = enemy_finger

function enemy_finger:update()
    -- Calculate direction towards player
    if not self.body:isDestroyed() then
        local x, y = self.body:getPosition()
        local pX, pY = Player.body:getPosition()
        local dx = pX - x
        local dy = pY - y
        local length = math.sqrt(dx * dx + dy * dy)

        -- Normalize the vector (make it unit length)
        if length ~= 0 then
            dx = dx / length
            dy = dy / length
        end

        -- Update self velocity
        local xVel = dx * self.speed
        local yVel = dy * self.speed
        self.body:setLinearVelocity(xVel, yVel)
        self.direction = { x = dx, y = dy }
    else
        self:destroy()
    end

    -- MOVE SOMEWHERE ELSE
    -- if enemy_dmg_timer[selectedEnemy.id] <= 0 then
    --     -- Damage the player
    --     Player.hp = Player.hp - selectedEnemy.dmg
    --     enemy_dmg_timer[selectedEnemy.id] = ENEMY_DMG_COOLDOWN
    --     kreem_audio.sounds.player_damage:stop()
    --     kreem_audio.sounds.player_damage:play()
    -- end
end

function enemy_finger:destroy()
    Enemies[self.id] = nil
    if not self.body:isDestroyed() then
        self.body:destroy()
    end
end

function enemy_finger.create(posX, posY)
    local self = setmetatable({}, enemy_finger)
    self.radius = 16
    self.id = uuid.new()
    self.body = love.physics.newBody(World, posX, posY, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ name = "Enemy", body = self.body, id = self.id })
    self.sprite = love.graphics.newImage("assets/finger.png")
    self.direction = { x = 0, y = -1 }
    self.speed = 150
    self.hp = 100
    self.dmg = 10
    self.fixture:setCategory(consts.COLLISION_CATEGORY_ENEMY)
    self.fixture:setMask(consts.COLLISION_CATEGORY_WALL)

    return self
end

return enemy_finger
