local sti        = require("src.sti")
local collision  = require("src.collision.collision")
local consts     = require("src.collision.consts")
local MapNode    = require("src.map_node")
local kreem_maps = {
    maps = {
        room_1 = sti("assets/maps/room_1.lua", { "box2d" }),
        room_2 = sti("assets/maps/room_2.lua", { "box2d" }),
        room_3 = sti("assets/maps/room_3.lua", { "box2d" }),
        room_4 = sti("assets/maps/room_4.lua", { "box2d" }),
        room_5 = sti("assets/maps/room_5.lua", { "box2d" })
    },
    maps_by_direction = {
        south = {},
        north = {},
        west = {},
        east = {},
    },
}

-- Init maps_by_direction
(function()
    for key, map in pairs(kreem_maps.maps) do
        -- Find the "Teleports" layer
        local layer = map.layers["Teleports"]

        if layer then
            -- Check if the layer has properties
            if layer.properties then
                for key, value in pairs(layer.properties) do
                    if value == true then
                        table.insert(kreem_maps.maps_by_direction[key], map)
                    end
                end
            else
                print("The 'Teleports' layer has no properties.")
            end
        else
            print("Layer 'Teleports' not found.")
        end
    end
end)()

local function create_object_fixtures(map, layer_name, objectName, category)
    local objectLayer = map.layers[layer_name]

    if objectLayer and objectLayer.objects then
        for _, object in ipairs(objectLayer.objects) do
            local body = love.physics.newBody(World, object.x + object.width / 2, object.y + object.height / 2, "static")
            local shape = love.physics.newRectangleShape(object.width, object.height)
            local fixture = love.physics.newFixture(body, shape)
            local userData = {
                properties = object.properties,
            }
            if objectName then
                userData.name = objectName
            else
                userData.name = object.name
            end

            fixture:setUserData(userData)
            fixture:setCategory(category)
        end
    else
        print(layer_name .. " layer or objects not found!")
    end
end

local function create_tile_fixtures(map, layer_name, name, category)
    local collisionLayer = map.layers[layer_name]
    if collisionLayer and collisionLayer.chunks then
        for _, chunk in ipairs(collisionLayer.chunks) do
            local chunkX = chunk.x * map.tilewidth * chunk.width
            local chunkY = chunk.y * map.tileheight * chunk.height
            for tileY = 1, chunk.height do
                local row = chunk.data[tileY]
                if row then
                    for tileX = 1, chunk.width do
                        local tile = row[tileX]
                        if tile and tile.gid and tile.gid > 0 then
                            local worldX = chunkX + (tileX - 1) * map.tilewidth
                            local worldY = chunkY + (tileY - 1) * map.tileheight

                            local body = love.physics.newBody(World, worldX + map.tilewidth / 2,
                                worldY + map.tileheight / 2, "static")
                            local shape = love.physics.newRectangleShape(0, 0, map.tilewidth, map.tileheight)
                            local fixture = love.physics.newFixture(body, shape)
                            local userData = {
                                name = name,
                            }
                            fixture:setUserData(userData)
                            fixture:setCategory(category)
                        end
                    end
                end
            end
        end
    end
end


local function init_map(map)
    if CurrentMap then
        -- Clear current Box2D world
        World:destroy()
        World = love.physics.newWorld(0, 0)
    end

    -- Create Box2D collision objects
    map:box2d_init(World)

    -- Create fixtures for objects in the Teleports layer
    create_object_fixtures(map, "Teleports", "Teleport", consts.COLLISION_CATEGORY_TELEPORT)
    create_tile_fixtures(map, "Walls", "Wall", consts.COLLISION_CATEGORY_WALL)

    CurrentMap = map
    World:setCallbacks(collision.BeginContact)
end

function kreem_maps.load_first_map()
    -- Setup root node
    local map = kreem_maps.maps["room_1"]
    local root_node = MapNode:new("room_1", map)
    KreemWorld[CurrentLevel].root = root_node
    KreemWorld[CurrentLevel].root = root_node

    init_map(map)
end

local function get_opposite_direction(incoming_direction)
    local dirs = {
        north = "south",
        south = "north",
        east = "west",
        west = "east",
    }

    local dir = dirs[incoming_direction]
    if not dir then
        error("No oppsite direction exists for", incoming_direction)
    end

    return dir
end

local function get_random_map(direction)
    local possible_maps = kreem_maps.maps_by_direction[direction]
    local map = possible_maps[math.random(1, #possible_maps)]

    return map, map.properties.name
end

function kreem_maps.load_next_map(incoming_direction)
    local direction = get_opposite_direction(incoming_direction)
    local current_node = KreemWorld[CurrentLevel].root

    -- Get next node from current_node if possible
    local next_node = current_node:getNeighbor(direction)
    if not next_node then
        -- Get a new random map
        local next_map, map_name = get_random_map(direction)
        next_node = MapNode:new(map_name, next_map)
        current_node:addNeighbor(direction, next_node)
        next_node:addNeighbor(incoming_direction, current_node)
    end

    KreemWorld[CurrentLevel].root = next_node
    init_map(next_node.map)

    return direction
end

return kreem_maps
