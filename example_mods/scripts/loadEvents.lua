local alreadyPost = false
local eventsLoaded = {}
function onCreatePost()
    if getProperty('eventNotes.length') > 0 then
        for events = 0,getProperty('eventNotes.length')-1 do
            local event = getPropertyFromGroup('eventNotes',events,'event')
            if not detectEventExists(event) then
                table.insert(eventsLoaded,event)
            end
            --callOnLuas('onEventLoaded',event,getPropertyFromGroup('eventNotes',events,'strumTime'),getPropertyFromGroup('eventNotes',events,'value1'),getPropertyFromGroup('eventNotes',events,'value2'))
        end
    end
end
function detectEventExists(name)
    if #eventsLoaded > 0 then
        for i, evnt in eventsLoaded do
            if name == evnt then
                return true
            end
        end
    end
    return false
end
function onCreatePost()
    alreadyPost = true
end
function loadEvent(name)
    if not detectEventExists(name) then
        local directory = "custom_events/"..name
        addLuaScript(directory)
        if alreadyPost then
            callScript(directory,"onCreatePost",{})
        end
        table.insert(eventsLoaded,directory)
    end
end