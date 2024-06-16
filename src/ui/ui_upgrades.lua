local ui_upgrades = {}

function ui_upgrades.draw(Player)
    local margin = 30
    for key, bool in pairs(Player.upgrades) do
        local width = love.graphics.getWidth()
        love.graphics.print(key, width - 15 - love.graphics.getFont():getWidth(key), margin)
        margin = margin + 15
    end
end

return ui_upgrades
