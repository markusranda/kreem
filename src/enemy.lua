-- local enemy = {}
-- local uuid = require("src.uuid")
-- local collision = require("src.collision.collision")
-- local kreem_audio = require("src.kreem_audio")
-- local debug_print = require("src.debug_print.print_table")

-- local function bossEnemyUpdate(selectedEnemy, dt)
-- if selectedEnemy.charge_cooldown > 0 then
--     selectedEnemy.charge_cooldown = selectedEnemy.charge_cooldown - dt
-- end
-- if selectedEnemy.state.name == "moving" then
--     selectedEnemy.speed = ENEMY_SPEED * 0.8
--     local directionX = Player.x - selectedEnemy.x
--     local directionY = Player.y - selectedEnemy.y
--     selectedEnemy.direction.x, selectedEnemy.direction.y = normalizeVector(directionX, directionY)

--     -- Update selectedEnemy position
--     local updateX = selectedEnemy.x + selectedEnemy.direction.x * selectedEnemy.speed * dt
--     local updateY = selectedEnemy.y + selectedEnemy.direction.y * selectedEnemy.speed * dt

--     selectedEnemy.x = updateX
--     selectedEnemy.y = updateY

--     local isInChargeRadius = collision.CheckCircleCollision(selectedEnemy.x, selectedEnemy.y, 75, Player.x, Player
--         .y,
--         Player.radius)

--     if isInChargeRadius then
--         selectedEnemy.state.name = "charging_windup"
--         selectedEnemy.state.timer = 0
--     end
-- elseif selectedEnemy.state.name == "charging_windup" then
--     selectedEnemy.speed = ENEMY_SPEED * .5
--     if selectedEnemy.charge_direction == nil then
--         selectedEnemy.charge_direction = { x = 0, y = 0 }
--         selectedEnemy.charge_direction.x, selectedEnemy.charge_direction.y = normalizeVector(
--             selectedEnemy.direction.x,
--             selectedEnemy.direction.y)
--     end
--     selectedEnemy.state.timer = selectedEnemy.state.timer + dt

--     local updateX = (selectedEnemy.x - selectedEnemy.charge_direction.x * selectedEnemy.speed * dt)
--     local updateY = (selectedEnemy.y - selectedEnemy.charge_direction.y * selectedEnemy.speed * dt)
--     selectedEnemy.x = updateX
--     selectedEnemy.y = updateY

--     if selectedEnemy.state.timer > 0.5 then
--         selectedEnemy.state.name = "charging_attack"
--     end
-- elseif selectedEnemy.state.name == "charging_attack" then
--     if selectedEnemy.state.distanceTravelled == nil then
--         selectedEnemy.state.distanceTravelled = 0
--     end
--     selectedEnemy.speed = ENEMY_SPEED * 3
--     local updateX = selectedEnemy.x + selectedEnemy.charge_direction.x * selectedEnemy.speed * dt
--     local updateY = selectedEnemy.y + selectedEnemy.charge_direction.y * selectedEnemy.speed * dt
--     selectedEnemy.x = updateX
--     selectedEnemy.y = updateY
--     selectedEnemy.state.distanceTravelled = selectedEnemy.state.distanceTravelled + selectedEnemy.speed * dt
--     local collided = collision.CheckCircleCollision(updateX, updateY, selectedEnemy.radius, Player.x, Player.y,
--         Player.radius)
--     if collided or selectedEnemy.state.distanceTravelled > 175 then
--         selectedEnemy.charge_direction = nil
--         selectedEnemy.state.distanceTravelled = nil
--         selectedEnemy.state.name = "charging_cooldown"
--         selectedEnemy.speed = ENEMY_SPEED * 0.8
--     end
-- elseif selectedEnemy.state.name == "charging_cooldown" then
--     selectedEnemy.speed = ENEMY_SPEED * 0.1
--     selectedEnemy.state.timer = selectedEnemy.state.timer + dt
--     if selectedEnemy.state.timer > 1 then
--         selectedEnemy.state.name = "moving"
--     end
-- end

-- if enemy_dmg_timer[selectedEnemy.id] <= 0 and collided then
--     -- Damage the player
--     Player.hp = Player.hp - selectedEnemy.dmg
--     enemy_dmg_timer[selectedEnemy.id] = ENEMY_DMG_COOLDOWN
--     kreem_audio.sounds.player_damage:stop()
--     kreem_audio.sounds.player_damage:play()
--     end
-- end


-- function enemy.CreateEnemyFingerBoss(posX, posY)
--     local boss = {
--         sprite = love.graphics.newImage("assets/finger.png"),
--         x = posX,
--         y = posY,
--         direction = { x = 0, y = -1 },
--         speed = ENEMY_SPEED * 0.8,
--         radius = 25,
--         hp = 1000,
--         id = uuid.new(),
--         dmg = 10,
--         charge_cooldown = 0,
--         charge_direction = nil,
--         state = { name = "moving", timer = 0 },
--         update = bossEnemyUpdate
--     }

--     boss.body = love.physics.newBody(World, posX, posY, "dynamic")
--     boss.shape = love.physics.newCircleShape(boss.radius)
--     boss.fixture = love.physics.newFixture(boss.body, boss.shape)
--     boss.fixture:setUserData({ name = "Bullet", body = boss.body, id = boss.id })

--     return boss
-- end

-- return enemy
