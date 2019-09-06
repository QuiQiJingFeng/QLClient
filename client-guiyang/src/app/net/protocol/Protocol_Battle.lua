local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

------------------------------------
-- Battle 向 Client 同步玩家操作信息
------------------------------------
local BCBattlePlayerInfoSYN = class("BCBattlePlayerInfoSYN", ProtocolBase)
ns.BCBattlePlayerInfoSYN = BCBattlePlayerInfoSYN

BCBattlePlayerInfoSYN.OP_CODE = net.ProtocolCode.P_BC_BATTLE_PLAYERINFO_SYN;
BCBattlePlayerInfoSYN.CLZ_CODE = "com.kodgames.message.proto.battle.BCBattlePlayerInfoSYN"

-- @param serverId: number
-- @param callback: number
function BCBattlePlayerInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, BCBattlePlayerInfoSYN.OP_CODE, serverId, callback);
end

------------------------------------
-- 打牌协议
------------------------------------
local CBPlayCardREQ = class("CBPlayCardREQ", ProtocolBase)
ns.CBPlayCardREQ = CBPlayCardREQ

CBPlayCardREQ.OP_CODE = net.ProtocolCode.P_CB_PLAYCARD_REQ;
CBPlayCardREQ.CLZ_CODE = "com.kodgames.message.proto.battle.CBPlayCardREQ"

-- @param serverId: number
-- @param callback: number
function CBPlayCardREQ:ctor(serverId, callback)
	self.super.ctor(self, CBPlayCardREQ.OP_CODE, serverId, callback);
end

-- @param playType: number
-- @param cards: number[]
function CBPlayCardREQ:setData(playType, cards)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.playType = playType;
	local string = ""
	for _, v in ipairs(cards) do
		string = string..string.char(v)
	end
    protocolBuf.cards = string;
end

------------------------------------
local BCPlayCardRES = class("BCPlayCardRES", ProtocolBase)
ns.BCPlayCardRES = BCPlayCardRES

BCPlayCardRES.OP_CODE = net.ProtocolCode.P_BC_PLAYCARD_RES;
BCPlayCardRES.CLZ_CODE = "com.kodgames.message.proto.battle.BCPlayCardRES"

-- @param serverId: number
-- @param callback: number
function BCPlayCardRES:ctor(serverId, callback)
    self.super.ctor(self, BCPlayCardRES.OP_CODE, serverId, callback);
end

------------------------------------
-- Battle 向 Client 同步玩家操作信息
------------------------------------
local BCPlayStepSYN = class("BCPlayStepSYN", ProtocolBase)
ns.BCPlayStepSYN = BCPlayStepSYN

BCPlayStepSYN.OP_CODE = net.ProtocolCode.P_BC_PLAYSTEP_SYN;
BCPlayStepSYN.CLZ_CODE = "com.kodgames.message.proto.battle.BCPlayStepSYN"

-- @param serverId: number
-- @param callback: number
function BCPlayStepSYN:ctor(serverId, callback)
    self.super.ctor(self, BCPlayStepSYN.OP_CODE, serverId, callback);
end

local BCMatchResultSYN = class("BCMatchResultSYN", ProtocolBase)
ns.BCMatchResultSYN = BCMatchResultSYN

BCMatchResultSYN.OP_CODE = net.ProtocolCode.P_BC_MATCHRESULT_SYN
BCMatchResultSYN.CLZ_CODE = "com.kodgames.message.proto.battle.BCMatchResultSYN"

function BCMatchResultSYN:ctor(serverId, callback)
    self.super.ctor(self, BCMatchResultSYN.OP_CODE, serverId, callback)
end

local BCFinalMatchResultSYN = class("BCFinalMatchResultSYN", ProtocolBase)
ns.BCFinalMatchResultSYN = BCFinalMatchResultSYN

BCFinalMatchResultSYN.OP_CODE = net.ProtocolCode.P_BC_FINALMATCHRESULT_SYN
BCFinalMatchResultSYN.CLZ_CODE = "com.kodgames.message.proto.battle.BCFinalMatchResultSYN"

function BCFinalMatchResultSYN:ctor(serverId, callback)
    self.super.ctor(self, BCFinalMatchResultSYN.OP_CODE, serverId, callback)
end