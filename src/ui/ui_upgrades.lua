local ui_upgrades = {}

function ui_upgrades.draw(Player)
    for key, bool in pairs(Player.upgrades) do
        local width = love.graphics.getWidth()
        love.graphics.print(key, width - 15 - love.graphics.getFont():getWidth(key), 15)
    end
end

return ui_upgrades
