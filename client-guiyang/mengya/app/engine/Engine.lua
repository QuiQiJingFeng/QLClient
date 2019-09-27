local Engine = class("Engile")

local BATTLE_SCENE = {
    [2] = "UIBattleSceneTwo",
    [3] = "UIBattleSceneThree",
    [4] = "UIBattleSceneFour",
}

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

function Engine:enterRoom(proto)
    local roomId = proto.roomId
    local settings = proto.settings
    local roomServerId = proto.roomServerId
    local roomClubId = proto.roomClubId
    local roomType = proto.roomType
    local createTime = proto.createTime
    local createRoleId = proto.createRoleId

    app.DataSet:getInstance():setRoomSettings(settings)
    app.DataSet:getInstance():setRoomId(roomId)
    app.DataSet:getInstance():setRoomServerId(roomServerId)
    app.DataSet:getInstance():setRoomClubId(roomClubId)
    app.DataSet:getInstance():setRoomType(roomType)
    app.DataSet:getInstance():setCreateTime(createTime)
    app.DataSet:getInstance():setCreateRoleId(createRoleId)

    local parse = app.RuleParse.new(settings)
    app.DataSet:getInstance():setRuleParse(parse)

    local maxPlayerNum = parse:getMaxPlayerNum()
    local sceneName = BATTLE_SCENE[maxPlayerNum]
    assert(sceneName,"not support playerNums")
    app.GameFSM:getInstance():enterState("GameState_Battle",sceneName)
end

function Engine:destroy()
    app.EventCenter:off(self)
    _instance = nil
end

return Engine