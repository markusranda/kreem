local player = {}
local anim8 = require("src.anim8")

local function loadSprites()
    print("Loading player")
    playerSheet = love.graphics.newImage('assets/player-sheet.png')
    local g = anim8.newGrid(32, 32, playerSheet:getWidth(), playerSheet:getHeight())

    idleAnim = anim8.newAnimation(g('2-3', 1), 1)
    runAnim = anim8.newAnimation(g('2-3', 2), 0.2)
    armSprite = anim8.newAnimation(g('2-2', 3), 10)
end

local function updatePlayer(self, dt)
    if self.state == "idle" then
        idleAnim:update(dt)
    elseif self.state == "run" then
        runAnim:update(dt)
    end
end

local function drawPlayer(self)
    local scaleX = self.direction.x < 0 and -1 or 1
    local originX = 32 / 2
    local originY = 32 / 2 + (self.radius / 2)

    local maxArmLength = 3
    local aimOffsetX = (self.aimPos.x - self.x) * (maxArmLength / love.graphics.getWidth()) * self.direction.x
    local aimOffsetY = (self.aimPos.y - self.y) * (maxArmLength / love.graphics.getHeight())
    local frontArmX = originX - 21 - aimOffsetX
    local backArmX = frontArmX - 3
    local armY = originY - 20 - aimOffsetY

    print(aimOffsetX)

    if self.shape then
        -- draw the players physics shape (shape from love2d physics package)
        local circle = self.shape
        local radius = circle:getRadius()
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.circle("fill", self.x, self.y, radius)
        love.graphics.setColor(1, 1, 1, 1)
    end

    armSprite:draw(playerSheet, self.x, self.y, 0, scaleX, 1, backArmX, armY)

    if self.state == "idle" then
        idleAnim:draw(playerSheet, self.x, self.y, 0, scaleX, 1, originX, originY)
    elseif self.state == "run" then
        runAnim:draw(playerSheet, self.x, self.y, 0, scaleX, 1, originX, originY)
    else
        print("Invalid state> ", state)
    end

    armSprite:draw(playerSheet, self.x, self.y, 0, scaleX, 1, frontArmX, armY)

end


function player.CreatePlayer(xPos, yPos)
    loadSprites()
    return {
        x = xPos,
        y = yPos,
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

return player
