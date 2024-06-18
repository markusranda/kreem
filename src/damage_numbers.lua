
DamageNumbers = {}

function DamageNumbers.add_damage_number(x, y, dmg)
    table.insert(DamageNumbers, { x = x, y = y, dmg = dmg, timer = 1 })
end

function DamageNumbers:draw()
    for i, damage_number in ipairs(DamageNumbers) do
        love.graphics.setColor(1, 0, 0, damage_number.timer)
        love.graphics.print(damage_number.dmg, damage_number.x, damage_number.y)
    end
end

-- Update function to handle the damage numbers' timers
function DamageNumbers:update(dt)
    for i = #DamageNumbers, 1, -1 do
        local dmg = DamageNumbers[i]
        dmg.timer = dmg.timer - dt
        if dmg.timer <= 0 then
            table.remove(DamageNumbers, i)
        else
            dmg.y = dmg.y - 30 * dt -- Move the damage number upwards
        end
    end
end

return DamageNumbers