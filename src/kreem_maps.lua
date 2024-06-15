local sti = require("src.sti")
local player = require("src.player")

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
    }
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

-- print all map names
local function print_names()
    local maps = kreem_maps.maps
    for key, map in pairs(kreem_maps.maps) do
        print("Map name:", map.properties.name or "Unnamed map")
    end
end

print_names()


local function create_object_fixtures(map, layerName, objectName)
    local objectLayer = map.layers[layerName]

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
        end
    else
        print(layerName .. " layer or objects not found!")
    end
end

local function beginContact(a, b, coll)
    local userDataA = a:getUserData()
    local userDataB = b:getUserData()

    if userDataA and userDataB then
        if (userDataA.name == "Player" and userDataB.name == "Teleport") then
            kreem_maps.load_next_map(userDataB.properties.direction)
        elseif ((userDataA.name == "Teleport" and userDataB.name == "Player")) then
            kreem_maps.load_next_map(userDataA.properties.direction)
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
    create_object_fixtures(map, "Teleports", "Teleport")
    create_object_fixtures(map, "Walls")

    CurrentMap = map
    player.InitPlayer()
    World:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function kreem_maps.load_first_map()
    init_map(kreem_maps.maps["room_1"])
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

function kreem_maps.load_next_map(incoming_direction)
    print("Getting map for incoming_direction", incoming_direction)
    local direction = get_opposite_direction(incoming_direction)
    print(string.format("Exiting from %s, entering from %s", incoming_direction, direction))
    local maps = kreem_maps.maps_by_direction[direction]
    if #maps < 1 then
        error("No possible maps exist, please check maps configuration")
        return
    end
    local index = math.random(1, #maps)
    local map = maps[index]
    print(string.format("Exiting map  %s", CurrentMap.properties.name))
    init_map(map)
    print(string.format("Entering map %s", CurrentMap.properties.name))
end

return kreem_maps
