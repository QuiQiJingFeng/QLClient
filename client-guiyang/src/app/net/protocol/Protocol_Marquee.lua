local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

-- MarqueeOpType, 跑马灯同步协议中的操作类型
ns.MarqueeOpType = { ADD = 1, CHANGE = 2, REMOVE = 3 }

------------------------------------
-- Client跑马灯请求
------------------------------------
local CGMarqueeREQ = class("CGMarqueeREQ", ProtocolBase)
ns.CGMarqueeREQ = CGMarqueeREQ

CGMarqueeREQ.OP_CODE = net.ProtocolCode.P_CG_MARQUEE_REQ
CGMarqueeREQ.CLZ_CODE = "com.kodgames.message.proto.marquee.CGMarqueeREQ"

function CGMarqueeREQ:ctor(serverId, callback)
	self.super.ctor(self, CGMarqueeREQ.OP_CODE, serverId, callback)
end

function CGMarqueeREQ:setData(version)
	self:getProtocolBuf().version = version
end

------------------------------------
local GCMarqueeRES = class("GCMarqueeRES", ProtocolBase)
ns.GCMarqueeRES = GCMarqueeRES

GCMarqueeRES.OP_CODE = net.ProtocolCode.P_GC_MARQUE_RES
GCMarqueeRES.CLZ_CODE = "com.kodgames.message.proto.marquee.GCMarqueeRES"

function GCMarqueeRES:ctor(serverId, callback)
	self.super.ctor(self, GCMarqueeRES.OP_CODE, serverId, callback)
end

------------------------------------
-- Game->Client跑马灯信息同步
------------------------------------
local GCMarqueeVersionSYNC = class("GCMarqueeVersionSYNC", ProtocolBase)
ns.GCMarqueeVersionSYNC = GCMarqueeVersionSYNC

GCMarqueeVersionSYNC.OP_CODE = net.ProtocolCode.P_GC_MARQUEE_VERSION_SYNC
GCMarqueeVersionSYNC.CLZ_CODE = "com.kodgames.message.proto.marquee.GCMarqueeVersionSYNC"

function GCMarqueeVersionSYNC:ctor(serverId, callback)
	self.super.ctor(self, GCMarqueeVersionSYNC.OP_CODE, serverId, callback)
end

------------------------------------
-- Game->Client跑马灯信息同步
------------------------------------
local CLCMarqueeSYNC = class("CLCMarqueeSYNC", ProtocolBase)
ns.CLCMarqueeSYNC = CLCMarqueeSYNC

CLCMarqueeSYNC.OP_CODE = net.ProtocolCode.P_CLC_MARQUEE_SYNC
CLCMarqueeSYNC.CLZ_CODE = "com.kodgames.message.proto.marquee.CLCMarqueeSYNC"

function CLCMarqueeSYNC:ctor(serverId, callback)
	self.super.ctor(self, CLCMarqueeSYNC.OP_CODE, serverId, callback)
end