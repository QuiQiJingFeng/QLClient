-- 处理玩家数据相关逻辑
local RoomService = class("RoomService")

local _instance = nil
function RoomService:getInstance()
	if not _instance then
		_instance = RoomService.new()
	end
	return _instance
end

function RoomService:ctor()
    app.EventCenter:on("CreateRoomRES",handler(self,self.onCreateRoomRES))
    app.EventCenter:on("EnterRoomRES",handler(self,self.onEnterRoomRES))
    app.EventCenter:on("RoomPlayerInfoSYN",handler(self,self.onRoomPlayerInfoSYN))
end

function RoomService:getRoomSettings()
    return self._settings
end

function RoomService:getRoomId()
    return self._roomId
end

function RoomService:getRoomServerId()
    return self._roomServerId
end

function RoomService:getRoomClubId()
    return self._roomClubId
end

function RoomService:getRoomType()
    return self._roomType
end

function RoomService:getCreateTime()
    return self._createTime
end

function RoomService:getCreateRoleId()
    return self._createRoleId
end

--获取房间规则解析器
function RoomService:getRuleParse()
    return self._ruleParse
end

function RoomService:sendCreaterRoomREQ(settings)
    --FYD TEST
    self:onEnterRoomRES({
        roomId = 234534,
        settings = settings,
        createRoleId = 2345235,
    })
end

function RoomService:onCreateRoomRES(proto)
    local roomId = proto.roomId
end

function RoomService:sendEnterRoomREQ(roomId)

end

function RoomService:onEnterRoomRES(proto)
    self._roomId = proto.roomId
    self._settings = proto.settings
    self._roomServerId = proto.roomServerId
    self._roomClubId = proto.roomClubId
    self._roomType = proto.roomType
    self._createTime = proto.createTime
    self._createRoleId = proto.createRoleId
     
    
    
    local data = clone(proto)
    
    self._parse = app.RuleParse.new(self._settings)
    local maxPlayerNum = self._parse:getMaxPlayerNum()
    data.maxPlayerNum = maxPlayerNum
    data.descript = self._parse:getDescript()
    app.Engine:getInstance():enterRoom(data)
end

--获取当前的回合数
function RoomService:getNowRoundCount()
    return self._nowRoundCount
end

--获取总回合数
function RoomService:getNowRoundCount()
    return self._totalRoundCount
end

--获取玩家信息
function RoomService:getPlayerInfos()
    return self._playerInfos
end

function RoomService:onRoomPlayerInfoSYN(proto)
    self._nowRoundCount = proto.nowRoundCount
    self._totalRoundCount = proto.totalRoundCount
    self._playerInfos = proto.playerInfo
end



return RoomService