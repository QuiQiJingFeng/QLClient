local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local RoomSeat = class(RoomSeat)

function RoomSeat:ctor(chairType, uiRoomSeat)
	self._chairType = chairType;	-- 座位类型(东南西北)
	self._uiRoomSeat = uiRoomSeat;	
	self._player = nil;	
end

function RoomSeat:getChairType() 
	return self._chairType 
end

function RoomSeat:getSeatUI()
	return self._uiRoomSeat;
end

function RoomSeat:isLocalSeat()
	return self._chairType == CardDefines.Chair.Down;
end

function RoomSeat:reset()
end

function RoomSeat:hasPlayer()
	return self._player ~= nil;
end

function RoomSeat:getPlayer()
	return self._player;
end

function RoomSeat:setPlayer(player)	
	self:reset();
	self._player = player;
	-- 更新界面
	if player == nil then
		self._uiRoomSeat:clearSeat()
	else
		self._uiRoomSeat:setPlayerData(player)
	end	
end

return RoomSeat