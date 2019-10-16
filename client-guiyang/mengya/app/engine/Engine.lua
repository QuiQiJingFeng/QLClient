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

--进入打牌场景
--@param maxPlayerNum:int 牌桌人数
function Engine:enterRoom(data)
    local BATTLE_SCENE = {
        [2] = "UIBattleSceneTwo",
        [3] = "UIBattleSceneThree",
        [4] = "UIBattleSceneFour",
    }
    local sceneName = BATTLE_SCENE[data.maxPlayerNum]
    app.GameFSM:getInstance():enterState("GameState_Battle",sceneName,data)
end



function Engine:destroy()
    app.EventCenter:off(self)
    _instance = nil
end

return Engine