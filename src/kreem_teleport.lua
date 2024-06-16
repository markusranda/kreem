local kreem_maps = require "src.kreem_maps"
local kreem_teleport = {}

local function get_next_player_teleport_coords(box, target_dir)
    local x, y = box.x, box.y
    local margin = 10
    local boxWidth, boxHeight = box.width, box.height

    -- Calculate the width and height of the player sprite
    local playerHeight = Player.sprite:getHeight()

    if target_dir == "north" then
        return { x = x + (boxWidth / 2), y = y + playerHeight + margin }
    elseif target_dir == "south" then
        return { x = x + (boxWidth / 2), y = y - boxHeight }
    elseif target_dir == "west" then
        return { x = x + 16 + boxWidth, y = y + (boxHeight / 2) }
    elseif target_dir == "east" then
        return { x = x - 16, y = y + (boxHeight / 2) }
    else
        error("Invalid target_dir")
    end
end

local function get_next_player_coords(structure, direction)
    for _, object in ipairs(structure.layer.objects) do
        if object.properties.direction == direction then
            local targetCoords = get_next_player_teleport_coords(object, direction)
            return targetCoords.x, targetCoords.y
        end
    end
end

function kreem_teleport.teleport_player(direction)
    local new_coords = nil
    for key, object in pairs(CurrentMap.layers["Teleports"].objects) do
        if object.properties.direction == direction then
            local xPos, yPos = get_next_player_coords(object, direction)
            new_coords = {
                x = xPos,
                y = yPos
            }
            break
        end
    end
    if not new_coords then
        error("No teleport was found in next room")
    end

    return new_coords
end

return kreem_teleport
