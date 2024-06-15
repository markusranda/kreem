local ui_hp = {}

function ui_hp.draw_hp(player)
    love.graphics.print(string.format("HP: %s", player.hp), 15, 15)
end

return ui_hp
