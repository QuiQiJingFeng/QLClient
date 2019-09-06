local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

------------------------------------
--  推送相关
------------------------------------
----------------------------
-- 查询玩家推送信息
----------------------------
local CPQueryRolePushInfoREQ = class("CPQueryRolePushInfoREQ", ProtocolBase)
ns.CPQueryRolePushInfoREQ = CPQueryRolePushInfoREQ

CPQueryRolePushInfoREQ.OP_CODE = net.ProtocolCode.P_CP_QUERY_ROLE_PUSHINFO_REQ;
CPQueryRolePushInfoREQ.CLZ_CODE = "com.kodgames.message.proto.push.CPQueryRolePushInfoREQ"

-- @param serverId: number
-- @param callback: number
function CPQueryRolePushInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CPQueryRolePushInfoREQ.OP_CODE, serverId, callback);
end

function CPQueryRolePushInfoREQ:setData(roleId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
end

----------------------------
local PCQueryRolePushInfoRES = class("PCQueryRolePushInfoRES", ProtocolBase)
ns.PCQueryRolePushInfoRES = PCQueryRolePushInfoRES

PCQueryRolePushInfoRES.OP_CODE = net.ProtocolCode.P_PC_QUERY_ROLE_PUSHINFO_RES;
PCQueryRolePushInfoRES.CLZ_CODE = "com.kodgames.message.proto.push.PCQueryRolePushInfoRES"

-- @param serverId: number
-- @param callback: number
function PCQueryRolePushInfoRES:ctor(serverId, callback)
	self.super.ctor(self, PCQueryRolePushInfoRES.OP_CODE, serverId, callback);
end

----------------------------
-- 注册推送信息
----------------------------
local CPUploadPushInfoREQ = class("CPUploadPushInfoREQ", ProtocolBase)
ns.CPUploadPushInfoREQ = CPUploadPushInfoREQ

CPUploadPushInfoREQ.OP_CODE = net.ProtocolCode.P_CP_UPLOAD_PUSHINFO_REQ;
CPUploadPushInfoREQ.CLZ_CODE = "com.kodgames.message.proto.push.CPUploadPushInfoREQ"

-- @param serverId: number
-- @param callback: number
function CPUploadPushInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CPUploadPushInfoREQ.OP_CODE, serverId, callback);
end

-- @param creatTime: string
-- @param roomId: number
-- @param recordIndex: number
function CPUploadPushInfoREQ:setData(roleId, channelId, pushRegisterId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.channelId = channelId
	protocolBuf.pushRegisterId = pushRegisterId
end

----------------------------
local PCUploadPushInfoRES = class("PCUploadPushInfoRES", ProtocolBase)
ns.PCUploadPushInfoRES = PCUploadPushInfoRES

PCUploadPushInfoRES.OP_CODE = net.ProtocolCode.P_PC_UPLOAD_PUSHINFO_RES;
PCUploadPushInfoRES.CLZ_CODE = "com.kodgames.message.proto.push.PCUploadPushInfoRES"

-- @param serverId: number
-- @param callback: number
function PCUploadPushInfoRES:ctor(serverId, callback)
	self.super.ctor(self, PCUploadPushInfoRES.OP_CODE, serverId, callback);
end

----------------------------
-- 上传玩家可以接收的推送类型
----------------------------
local CPUploadRolePushTypeREQ = class("CPUploadRolePushTypeREQ", ProtocolBase)
ns.CPUploadRolePushTypeREQ = CPUploadRolePushTypeREQ

CPUploadRolePushTypeREQ.OP_CODE = net.ProtocolCode.P_CP_UPLOAD_ROLE_PUSHTYPE_REQ;
CPUploadRolePushTypeREQ.CLZ_CODE = "com.kodgames.message.proto.push.CPUploadRolePushTypeREQ"

-- @param serverId: number
-- @param callback: number
function CPUploadRolePushTypeREQ:ctor(serverId, callback)
	self.super.ctor(self, CPUploadRolePushTypeREQ.OP_CODE, serverId, callback);
end

function CPUploadRolePushTypeREQ:setData(roleId, pushType)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.pushType = pushType
end

----------------------------
local PCUploadRolePushTypeRES = class("PCUploadRolePushTypeRES", ProtocolBase)
ns.PCUploadRolePushTypeRES = PCUploadRolePushTypeRES

PCUploadRolePushTypeRES.OP_CODE = net.ProtocolCode.P_PC_UPLOAD_ROLE_PUSHTYPE_RES;
PCUploadRolePushTypeRES.CLZ_CODE = "com.kodgames.message.proto.push.PCUploadRolePushTypeRES"

-- @param serverId: number
-- @param callback: number
function PCUploadRolePushTypeRES:ctor(serverId, callback)
	self.super.ctor(self, PCUploadRolePushTypeRES.OP_CODE, serverId, callback);
end


