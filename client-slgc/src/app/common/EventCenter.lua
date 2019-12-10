
local EventCenter = {}
local __listeners = {}
function EventCenter:on(eventName, listener, tag)
    if __listeners[eventName] == nil then
        __listeners[eventName] = {}
    end
    tag = tag or ""
    table.insert(__listeners[eventName],{listener, tag})
 
    return #__listeners[eventName]
end
 

function EventCenter:dispatch(eventName,...)
    eventName = string.upper(tostring(eventName))
    assert(__listeners[eventName],"not register event "..eventName)
 
    for handle, listener in pairs(__listeners[eventName]) do
        -- listener[1] = listener
        -- listener[2] = tag
        local isStop = listener[1](...)
        if isStop then
            break
        end
    end
end

function EventCenter:removeEventByHandle(handleToRemove)
    for eventName, listenersForEvent in pairs(__listeners) do
        for handle, _ in pairs(listenersForEvent) do
            if handle == handleToRemove then
                table.remove(listenersForEvent,handle)
                return
            end
        end
    end
end

function EventCenter:removeEventListenersByTag(tagToRemove)
    for eventName, listenersForEvent in pairs(__listeners) do
        for handle = #listenersForEvent, 1, -1 do
            local listener = listenersForEvent[handle]
            if listener[2] == tagToRemove then
                table.remove(listenersForEvent,handle)
            end
        end
    end
end

EventCenter.off = EventCenter.removeEventListenersByTag

function EventCenter:removeEventListenersByEventName(eventName)
    __listeners[string.upper(eventName)] = nil
end

function EventCenter:clear()
    __listeners = {}
end

function EventCenter:hasEventCenterListener(eventName)
    eventName = string.upper(tostring(eventName))
    local t = __listeners[eventName]
    for _, __ in pairs(t) do
        return true
    end
    return false
end

return EventCenter
