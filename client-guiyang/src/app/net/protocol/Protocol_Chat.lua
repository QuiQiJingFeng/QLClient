local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

------------------------------------
-- 聊天相关
------------------------------------
ns.ChatType = {
	BUILDIN = 1,	-- 常用语
	EMOTION = 2,	-- 表情
	CUSTOM = 3,		-- 自定义
	VOICE = 4,   	-- 语音
}

local CBChatREQ = class("CBChatREQ", ProtocolBase)
ns.CBChatREQ = CBChatREQ

CBChatREQ.OP_CODE = net.ProtocolCode.P_CB_CHAT_REQ;
CBChatREQ.CLZ_CODE = "com.kodgames.message.proto.chat.CBChatREQ"

-- @param serverId: number
-- @param callback: number
function CBChatREQ:ctor(serverId, callback)
	self.super.ctor(self, CBChatREQ.OP_CODE, serverId, callback);
end

-- @param type: number
-- @param type: content: string
-- @param type: code: number
function CBChatREQ:setData(type, content, code)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.type = type;
	protocolBuf.content = content;
	protocolBuf.code = code;
end

------------------------------------
local BCChatRES = class("BCChatRES", ProtocolBase)
ns.BCChatRES = BCChatRES

BCChatRES.OP_CODE = net.ProtocolCode.P_BC_CHAT_RES;
BCChatRES.CLZ_CODE = "com.kodgames.message.proto.chat.BCChatRES"

-- @param serverId: number
-- @param callback: number
function BCChatRES:ctor(serverId, callback)
    self.super.ctor(self, BCChatRES.OP_CODE, serverId, callback);
end

----------------------------
-- 聊天消息推送
----------------------------
local BCChatSYN = class("BCChatSYN", ProtocolBase)
ns.BCChatSYN = BCChatSYN

BCChatSYN.OP_CODE = net.ProtocolCode.P_BC_CHAT_SYN;
BCChatSYN.CLZ_CODE = "com.kodgames.message.proto.chat.BCChatSYN"

-- @param serverId: number
-- @param callback: number
function BCChatSYN:ctor(serverId, callback)
    self.super.ctor(self, BCChatSYN.OP_CODE, serverId, callback);
end