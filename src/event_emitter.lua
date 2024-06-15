EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter:new()
    local self = setmetatable({}, EventEmitter)
    self.events = {}
    return self
end

function EventEmitter:on(event, listener)
    if not event then
        error("EventEmitter:on - event cannot be nil")
    end

    if not self.events[event] then
        self.events[event] = {}
    end

    table.insert(self.events[event], listener)
end

function EventEmitter:off(event, listener)
    if not self.events[event] then return end
    for i, registeredListener in ipairs(self.events[event]) do
        if registeredListener == listener then
            table.remove(self.events[event], i)
            break
        end
    end
end

function EventEmitter:emit(event, ...)
    if not self.events[event] then return end
    for _, listener in ipairs(self.events[event]) do
        listener(...)
    end
end

return EventEmitter
