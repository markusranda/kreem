local MapNode = {}
MapNode.__index = MapNode

function MapNode:new(name, map)
    return setmetatable({
        name = name,
        map = map,
        neighbors = {},
        enemies = {},
        enemy_count = 0
    }, MapNode)
end

function MapNode:addNeighbor(direction, neighbor)
    self.neighbors[direction] = neighbor
end

function MapNode:getNeighbor(direction)
    return self.neighbors[direction]
end

return MapNode
