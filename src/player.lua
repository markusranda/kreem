local player = {}
local anim8 = require("src.anim8")
local consts = require("src.collision.consts")

PlayerSheet = {}
IdleAnim = {}
RunAnim = {}

local function loadSprites()
    PlayerSheet = love.graphics.newImage('assets/player-sheet.png')
    local g = anim8.newGrid(32, 32, PlayerSheet:getWidth(), PlayerSheet:getHeight())

    IdleAnim = anim8.newAnimation(g('2-3', 1), 1)
    RunAnim = anim8.newAnimation(g('2-8', 2), 0.08)
    ArmSprite = anim8.newAnimation(g('2-2', 3), 10)
end

local function updatePlayer(self, dt)
    if self.state == "idle" then
        IdleAnim:update(dt)
    elseif self.state == "run" then
        RunAnim:update(dt)
    end
end

local function drawPlayer(self)
    local scaleX = self.direction.x < 0 and -1 or 1
    local originX = 32 / 2
    local originY = 32 / 2 + (self.radius / 2)

    local maxArmLength = 5
    local x, y = Player.body:getPosition()
    local aimOffsetX = (self.aimPos.x - x) * (maxArmLength / love.graphics.getWidth()) * self.direction.x
    local aimOffsetY = (self.aimPos.y - y) * (maxArmLength / love.graphics.getHeight())
    local frontArmX = originX - 22 - aimOffsetX
    local backArmX = frontArmX - 3
    local armY = originY - 22 - aimOffsetY

    ArmSprite:draw(PlayerSheet, x, y, 0, scaleX, 1, backArmX, armY)

    if self.state == "idle" then
        IdleAnim:draw(PlayerSheet, x, y, 0, scaleX, 1, originX, originY)
    elseif self.state == "run" then
        RunAnim:draw(PlayerSheet, x, y, 0, scaleX, 1, originX, originY)
    else
        error("Invalid state> ", self.state)
    end

    ArmSprite:draw(PlayerSheet, x, y, 0, scaleX, 1, frontArmX, armY)
end


local function create_player()
    loadSprites()
    return {
        sprite = love.graphics.newImage("assets/hat.png"),
        direction = { x = 0, y = -1 },
        aimPos = { x = 0, y = 0 },
        dmg = 50,
        radius = 10,
        hp = 100,
        speed = 200,
        upgrades = {},
        update = updatePlayer,
        draw = drawPlayer,
        state = "idle"
    }
end

function player.InitPlayer(xPos, yPos)
    -- Initialize player
    local mapWidth = CurrentMap.width * CurrentMap.tilewidth
    local mapHeight = CurrentMap.height * CurrentMap.tileheight
    Player = create_player()
    if not xPos then
        xPos = mapWidth / 2
    end
    if not yPos then
        yPos = mapHeight / 2
    end

    -- Make player a physics object
    Player.body = love.physics.newBody(World, xPos, yPos, "dynamic")
    Player.shape = love.physics.newCircleShape(Player.radius)

    Player.fixture = love.physics.newFixture(Player.body, Player.shape)
    Player.fixture:setUserData({ name = "Player" })
    Player.fixture:setCategory(consts.COLLISION_CATEGORY_PLAYER)
    Player.fixture:setMask(consts.COLLISION_CATEGORY_PROJECTILE)
end

return player
