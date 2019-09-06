local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

-- Game to Client, 同步服务器公告
local GCNoticeVersionSYN = class("GCNoticeVersionSYN", ProtocolBase)
ns.GCNoticeVersionSYN = GCNoticeVersionSYN

GCNoticeVersionSYN.OP_CODE = net.ProtocolCode.P_GC_NOTICE_SYN
GCNoticeVersionSYN.CLZ_CODE = "com.kodgames.message.proto.notice.GCNoticeVersionSYN"

function GCNoticeVersionSYN:ctor(serverId, callback)
    self.super.ctor(self, GCNoticeVersionSYN.OP_CODE, serverId, callback)
end

-- Client to Game, 客户端发送公告请求
local CGNoticeREQ = class("CGNoticeREQ", ProtocolBase)
ns.CGNoticeREQ = CGNoticeREQ

CGNoticeREQ.OP_CODE = net.ProtocolCode.P_CG_NOTICE_REQ
CGNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.notice.CGNoticeREQ"

function CGNoticeREQ:ctor(serverId, callback)
    self.super.ctor(self, CGNoticeREQ.OP_CODE, serverId, callback)
end

function CGNoticeREQ:setData(version)
    self:getProtocolBuf().version = version
end

-- Game to Client, 客户端响应公告请求
local GCNoticeRES = class("GCNoticeRES", ProtocolBase)
ns.GCNoticeRES = GCNoticeRES

function GCNoticeRES:ctor(serverId, callback)
    self.super.ctor(self, GCNoticeRES.OP_CODE, serverId, callback)
end

GCNoticeRES.OP_CODE = net.ProtocolCode.P_GC_NOTICE_RES
GCNoticeRES.CLZ_CODE = "com.kodgames.message.proto.notice.GCNoticeRES"

-- Game to Client, 客户端响应常驻公告请求
local GCMainNoticeRES = class("GCMainNoticeRES", ProtocolBase)
ns.GCMainNoticeRES = GCMainNoticeRES

function GCMainNoticeRES:ctor(serverId, callback)
    self.super.ctor(self, GCMainNoticeRES.OP_CODE, serverId, callback)
end

GCMainNoticeRES.OP_CODE = net.ProtocolCode.P_GC_MAIN_NOTICE_RES
GCMainNoticeRES.CLZ_CODE = "com.kodgames.message.proto.notice.GCMainNoticeRES"

-- client to Game, 客户端请求常驻公告
local CGMainNoticeREQ = class("CGMainNoticeREQ", ProtocolBase)
ns.CGMainNoticeREQ = CGMainNoticeREQ

function CGMainNoticeREQ:ctor(serverId, callback)
    self.super.ctor(self, CGMainNoticeREQ.OP_CODE, serverId, callback)
end

CGMainNoticeREQ.OP_CODE = net.ProtocolCode.P_CG_MAIN_NOTICE_REQ
CGMainNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.notice.CGMainNoticeREQ"
