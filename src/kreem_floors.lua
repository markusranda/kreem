local kreem_floors = {}
local maps = require "src.kreem_maps"
local debug_print = require("src.debug_print.print_table")

local directions = {
    { 0,  -1 }, -- north
    { 1,  0 },  -- east
    { 0,  1 },  -- south
    { -1, 0 },  -- west
}

local function neighbors(room, grid, callback)
    for i, direction in ipairs(directions) do
        local coords = { room.x + direction[1], room.y + direction[2] }
        local neighbor = grid[coords.x] and grid[coords.x][coords.y]
        callback(neighbor, i)
    end
end

local function get_opposite_direction(directionIndex)
    local result = (directionIndex + 2) % 4
    if result == 0 then
        result = 4
    end
    return result
end

local function create_floor_plan(level)
    -- test that get_opposite_direction works
    for i = 1, 4 do
        print("Opposite of", i, get_opposite_direction(i))
    end

    local grid_x_size = 12
    local grid_y_size = 12
    local grid = {}

    local max_number_of_rooms = 16

    local middle_room = {
        x = math.floor(grid_x_size / 2),
        y = math.floor(grid_y_size / 2)
    }

    grid[middle_room.x] = {}
    grid[middle_room.x][middle_room.y] = {
        x = middle_room.x,
        y = middle_room.y,
        neighbors = {}
    }

    local room_queue = { grid[middle_room.x][middle_room.y] }

    print("Creating floor plan", max_number_of_rooms)

    for index, room in ipairs(room_queue) do
        print("Room", index)
        debug_print.table(room)
        local rooms_generated = {}
        neighbors(room, grid, function(neighbor, directionIndex)
            -- criteria for adding a room
            local random_chance = math.random(100)
            if neighbor == nil then
                neighbor = {
                    x = room.x + directions[directionIndex][1],
                    y = room.y + directions[directionIndex][2],
                    neighbors = { get_opposite_direction(directionIndex) }
                }
            end

            if #neighbor.neighbors >= 2 then
                return
            end

            if #room_queue + #rooms_generated >= max_number_of_rooms then
                return
            end

            if random_chance > 50 then
                return
            end

            -- add the room if it doesn't exist
            if not (grid[neighbor.x] and grid[neighbor.x][neighbor.y]) then
                table.insert(rooms_generated, neighbor)
                table.insert(room.neighbors, directionIndex)
                if not grid[neighbor.x] then
                    grid[neighbor.x] = {}
                end
                grid[neighbor.x][neighbor.y] = neighbor
            end
        end)

        if #rooms_generated > 0 then
            -- seed the queue
            for _, new_room in ipairs(rooms_generated) do
                table.insert(room_queue, new_room)
            end
        else
            room.dead_end = true
        end
    end

    return grid
end

local function assign_special_rooms()

end

local function assign_room_types()

end

function kreem_floors:generate_floor(level)
    local grid = create_floor_plan(level)
    assign_special_rooms()
    assign_room_types()

    return grid
end

return kreem_floors
