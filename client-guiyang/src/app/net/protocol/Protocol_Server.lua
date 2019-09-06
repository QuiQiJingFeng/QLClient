local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

----------------------------
-- 服务器统一错误返回协议 
----------------------------
local ServerExceptionSYNC = class("ServerExceptionSYNC", ProtocolBase)
ns.ServerExceptionSYNC = ServerExceptionSYNC

ServerExceptionSYNC.OP_CODE = net.ProtocolCode.P_SERVER_EXCEPTION_SYNC;
ServerExceptionSYNC.CLZ_CODE = "com.kodgames.message.proto.server.ServerExceptionSYNC"

-- @param serverId: number
-- @param callback: number
function ServerExceptionSYNC:ctor(serverId, callback)
    self.super.ctor(self, ServerExceptionSYNC.OP_CODE, serverId, callback);
end