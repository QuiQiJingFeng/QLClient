--[[
协议包处理器
--]]
local RequestHandler = require("app.net.RequestHandler")
local ProtocolPacketHandler = class("ProtocolPacketHandler")

function ProtocolPacketHandler:ctor(connection)	
	self._connection = connection;
	self._requestHandler = RequestHandler.new(function()
		-- request响应超时处理
		self._connection:_connectionLost(net.ConnectionLostReason.REQUEST_TIME_OUT)
	end);
end

function ProtocolPacketHandler:dispose()    
end

function ProtocolPacketHandler:onRequest(req)
	self._requestHandler:onRequest(req)
end

function ProtocolPacketHandler:handlePacket(protocol)
	-- 解析protocol
--	local protocol = ProtocolBase.fromBuffer(buffer)
	if Macro.assetFalse(protocol ~= nil) then
		self._requestHandler:onResponse(net.NetworkResponse.new(protocol))
	end
end

function ProtocolPacketHandler:reset()
	self._requestHandler:reset();
end

return ProtocolPacketHandler