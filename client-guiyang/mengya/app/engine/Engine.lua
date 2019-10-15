local Engine = class("Engile")

-- 单例支持
local _instance = nil
function Engine:getInstance()
    if _instance then
        return _instance
    end
    _instance = Engine.new()
    return _instance
end

function Engine:ctor()

end

function Engine:enterRoom(sceneName)
    Logger.debug("enterRoom ",sceneName)
    app.GameFSM:getInstance():enterState("GameState_Battle",sceneName)
end

function Engine:destroy()
    app.EventCenter:off(self)
    _instance = nil
end

return Engine