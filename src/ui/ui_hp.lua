local ui_hp = {}

function ui_hp.draw(player)
    local margin = 15
    local max_width = love.graphics.getWidth() - 2 * margin
    local health_width = math.max(0, (player.hp / player.hp_max) * max_width)

    love.graphics.rectangle("line", margin, margin, max_width, margin)
    love.graphics.setColor(0.792156862745098, 0.01568627450980392, 0.06666666666666667)
    love.graphics.rectangle("fill", margin, margin, health_width, margin)
    love.graphics.setColor(1, 1, 1)
end

return ui_hp
