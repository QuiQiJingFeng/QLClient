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
    app.EventCenter:on("EnterRoomRES",handler(self,self.onEnterRoomRES))
    app.EventCenter:on("CreateRoomRES",handler(self,self.onCreateRoomRES))
    app.EventCenter:on("RoomInfoSYN",handler(self,self.onRoomInfoSYN))
end

function RoomService:sendCreaterRoomREQ(settings)
    
end

function RoomService:onCreateRoomRES(proto)
    local roomId = proto.roomId
    self:sendEnterRoomREQ(roomId)
end

function RoomService:sendEnterRoomREQ(roomId)

end

function RoomService:onEnterRoomRES(proto)
    app.Engine:getInstance():enterRoom(proto)
end

function RoomService:onRoomInfoSYN(proto)
    
end



return RoomService