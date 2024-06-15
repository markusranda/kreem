local upgrade_consts    = require "src.upgrade.upgrade_consts"
local uuid              = require("src.uuid")
local upgrade_shotgun   = {}
upgrade_shotgun.__index = upgrade_shotgun

function upgrade_shotgun:destroy()
    Upgrades[self.id] = nil
    self.body:destroy()
end

function upgrade_shotgun:create(xPos, yPos)
    local self = setmetatable({}, upgrade_shotgun)
    self.id = uuid.new()
    self.sprite = love.graphics.newImage("assets/upgrade.png")
    self.type = upgrade_consts.UPGRADE_SHOTGUN
    self.radius = 16
    self.body = love.physics.newBody(World, xPos, yPos, "static")
    self.shape = love.physics.newCircleShape(self.radius)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData({ name = "Upgrade", body = self.body, type = upgrade_consts.UPGRADE_SHOTGUN, id = self.id })

    return self
end

return upgrade_shotgun
