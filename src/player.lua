local anim8 = require("src.anim8")
local consts = require("src.collision.consts")
local kreem_audio = require("src.kreem_audio")
local player = {}
player.__index = player

function player:update(dt)
    if self.state == "idle" then
        self.idle_anim:update(dt)
    elseif self.state == "run" then
        self.run_anim:update(dt)
    end

    if (self.hp <= 0) then
        DeathScreenJob = { duration = DEATH_SCREEN_DURATION, running = true }
    end

    if (self.prev_hp ~= self.hp) then
        kreem_audio.sounds.player_damage:stop()
        kreem_audio.sounds.player_damage:play()
        self.taken_dmg_timer = self.taken_dmg_duration
    end

    self.taken_dmg_timer = self.taken_dmg_timer - dt
    self.prev_hp = self.hp
end

function player:draw()
    local scaleX = self.direction.x < 0 and -1 or 1
    local originX = 32 / 2
    local originY = 32 / 2 + (self.radius / 2)

    local maxArmLength = 5
    local x, y = self.body:getPosition()
    local aimOffsetX = (self.aimPos.x - x) * (maxArmLength / love.graphics.getWidth()) * self.direction.x
    local aimOffsetY = (self.aimPos.y - y) * (maxArmLength / love.graphics.getHeight())
    local frontArmX = originX - 22 - aimOffsetX
    local backArmX = frontArmX - 3
    local armY = originY - 22 - aimOffsetY

    self.arm_sprite:draw(self.player_sheet, x, y, 0, scaleX, 1, backArmX, armY)

    if self.state == "idle" then
        self.idle_anim:draw(self.player_sheet, x, y, 0, scaleX, 1, originX, originY)
    elseif self.state == "run" then
        self.run_anim:draw(self.player_sheet, x, y, 0, scaleX, 1, originX, originY)
    else
        error(string.format("Invalid state: %s", self.state))
    end

    self.arm_sprite:draw(self.player_sheet, x, y, 0, scaleX, 1, frontArmX, armY)
end

function player:create()
    self.player_sheet = love.graphics.newImage('assets/player-sheet.png')
    self.g = anim8.newGrid(32, 32, self.player_sheet:getWidth(), self.player_sheet:getHeight())
    self.idle_anim = anim8.newAnimation(self.g('2-3', 1), 1)
    self.run_anim = anim8.newAnimation(self.g('2-8', 2), 0.08)
    self.arm_sprite = anim8.newAnimation(self.g('2-2', 3), 10)
    self.sprite = love.graphics.newImage("assets/hat.png")
    self.direction = { x = 0, y = -1 }
    self.aimPos = { x = 0, y = 0 }
    self.dmg = 50
    self.radius = 10
    self.hp = 100
    self.hp_max = 100
    self.prev_hp = 100
    self.speed = 200
    self.upgrades = {}
    self.state = "idle"
    self.taken_dmg_timer = 0
    self.taken_dmg_duration = 1
    self:create_body()

    return self
end

function player:create_body(xPos, yPos)
    -- Initialize player
    local mapWidth = CurrentMap.width * CurrentMap.tilewidth
    local mapHeight = CurrentMap.height * CurrentMap.tileheight
    if not xPos then
        xPos = mapWidth / 2
    end
    if not yPos then
        yPos = mapHeight / 2
    end

    -- Make player a physics object
    self.body = love.physics.newBody(World, xPos, yPos, "dynamic")
    self.shape = love.physics.newCircleShape(self.radius)

    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ name = "Player" })
    self.fixture:setCategory(consts.COLLISION_CATEGORY_PLAYER)
    self.fixture:setMask(consts.COLLISION_CATEGORY_PROJECTILE)
end

return player
