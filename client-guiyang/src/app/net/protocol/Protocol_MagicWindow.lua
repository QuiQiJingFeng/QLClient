local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

local GCInviterRoomInfoRES = class("GCInviterRoomInfoRES", ProtocolBase)
ns.GCInviterRoomInfoRES = GCInviterRoomInfoRES
GCInviterRoomInfoRES.OP_CODE = net.ProtocolCode.P_GC_INVITER_ROOMINFO_RES
GCInviterRoomInfoRES.CLZ_CODE = "com.kodgames.message.proto.game.GCInviterRoomInfoRES"

function  GCInviterRoomInfoRES:ctor(serverId, callback)
    self.super.ctor(self, GCInviterRoomInfoRES.OP_CODE, serverId, callback)
end

local CGInviterRoomInfoREQ = class("CGInviterRoomInfoREQ", ProtocolBase)
ns.CGInviterRoomInfoREQ = CGInviterRoomInfoREQ
CGInviterRoomInfoREQ.OP_CODE = net.ProtocolCode.P_CG_INVITER_ROOMINFO_REQ
CGInviterRoomInfoREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGInviterRoomInfoREQ"

function  CGInviterRoomInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CGInviterRoomInfoREQ.OP_CODE, serverId, callback)
end

function CGInviterRoomInfoREQ:setData(roomId)
    self:getProtocolBuf().roomId = roomId
end
