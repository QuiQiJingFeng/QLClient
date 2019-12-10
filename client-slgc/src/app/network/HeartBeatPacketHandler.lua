--[[
协议包处理器
--]]
local HeartBeatPacketHandler = class("HeartBeatPacketHandler")

local HEART_BEAT_MESSAGE_TYPE  = 0x05
local HEART_BEAT_MAX_TRY_TIMES = 2  -- 心跳包丢失多少个触发断线
local HEART_BEAT_TRY_INTERVAL  = 5  -- 每个心跳包检测周期

function HeartBeatPacketHandler:ctor()	
	self._beatheartTask = nil
		
	game.EventCenter:on("EVENT_CONNECTION_CREATED", handler(self, self._onConnectionCreated), self);
	game.EventCenter:on("EVENT_CONNECTION_LOST", handler(self, self._onConnectionLost), self);
	game.EventCenter:on("EVENT_CONNECTION_HEART", handler(self, self._connectionReceiveHeartPacket), self);	
end

function HeartBeatPacketHandler:dispose()
	self:_endHeartbeatTask()
	
	game.EventCenter:off(self)
end

function HeartBeatPacketHandler:reset()
	self:_endHeartbeatTask()
end

-- 链接成功的内部回调函数
function HeartBeatPacketHandler:_onConnectionCreated()
	self:_startHeartbeatTask()
end

-- 连接断开的内部回调函数
function HeartBeatPacketHandler:_onConnectionLost()
	self:_endHeartbeatTask()
end

-- 收到网络消息
function HeartBeatPacketHandler:_connectionReceiveHeartPacket()
	self:_restartHeartbeatTask()
end

-- IPacketHandlerBase接口
function HeartBeatPacketHandler:handlePacket(protocol)
	-- 返回心跳包
	self._connection:sendHeartBeatPacket(HEART_BEAT_MESSAGE_TYPE)
end

-- 开启心跳检测
function HeartBeatPacketHandler:_startHeartbeatTask()
	self:_restartHeartbeatTask()
end

-- 规划下一次心跳检测
function HeartBeatPacketHandler:_restartHeartbeatTask()
	self:_endHeartbeatTask()
	-- 心跳
	local missingHeartbeatCount = 0
    local heartbeatFunc = function()
		missingHeartbeatCount = missingHeartbeatCount + 1
		if missingHeartbeatCount >= HEART_BEAT_MAX_TRY_TIMES then
			-- 心跳超时, 触发网络断开
			self._connection:_connectionLost(net.ConnectionLostReason.HEART_BEAT_TIME_OUT)
			return
		end
	end
	self._beatheartTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(heartbeatFunc, HEART_BEAT_TRY_INTERVAL, false)
end

-- 关闭心跳检测
function HeartBeatPacketHandler:_endHeartbeatTask()
	if self._beatheartTask then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._beatheartTask)
		self._beatheartTask = nil
	end
end

return HeartBeatPacketHandler