local DataSet = class("DataSet")

local _instance = nil
function DataSet:getInstance()
    if _instance then
        return _instance
    end
    _instance = DataSet.new()
    return _instance
end

function DataSet:ctor()
    
end

function DataSet:setRoomSettings(settings)
    self._settings = settings
end

function DataSet:getRoomSettings()
    return self._settings
end

function DataSet:setRoomId(roomId)
    self._roomId = roomId
end

function DataSet:getRoomId()
    return self._roomId
end

function DataSet:setRoomServerId(roomServerId)
    self._roomServerId = roomServerId
end

function DataSet:getRoomServerId(roomServerId)
    return self._roomServerId
end

function DataSet:setRoomClubId(roomClubId)
    self._roomClubId = roomClubId
end

function DataSet:getRoomClubId(roomClubId)
    return self._roomClubId
end

function DataSet:setRoomType(roomType)
    self._roomType = roomType
end

function DataSet:getRoomType(roomType)
    return self._roomType
end

function DataSet:setCreateTime(createTime)
    self._createTime = createTime
end

function DataSet:getCreateTime(createTime)
    return self._createTime
end

function DataSet:setCreateRoleId(createRoleId)
    self._createRoleId = createRoleId
end

function DataSet:getCreateRoleId(createRoleId)
    return self._createRoleId
end

function DataSet:setRuleParse(ruleParse)
    self._ruleParse = ruleParse
end

function DataSet:getRuleParse()
    return self._ruleParse
end
 

return DataSet