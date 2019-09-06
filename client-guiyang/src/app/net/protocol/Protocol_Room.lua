local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

------------------------------------
-- 创建房间
------------------------------------

local CGCreateRoomREQ = class("CGCreateRoomREQ", ProtocolBase)
ns.CGCreateRoomREQ = CGCreateRoomREQ

CGCreateRoomREQ.OP_CODE = net.ProtocolCode.P_CG_CREATE_ROOM_REQ;
CGCreateRoomREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGCreateRoomREQ"

-- @param serverId: number
-- @param callback: number
function CGCreateRoomREQ:ctor(serverId, callback)
	self.super.ctor(self, CGCreateRoomREQ.OP_CODE, serverId, callback);
end

-- @param roomType: number
-- @param roundCount: number
-- @param gameplays: number[]
function CGCreateRoomREQ:setData(roomType, roundType, gameplays, freeActivityId, createType, inviteeIds)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.roomType = roomType;
    protocolBuf.roundType = roundType;
    protocolBuf.gameplays = gameplays;
    protocolBuf.freeActivityId = freeActivityId
	protocolBuf.createType = createType
	protocolBuf.inviteeIds = inviteeIds
end

------------------------------------
local GCCreateRoomRES = class("GCCreateRoomRES", ProtocolBase)
ns.GCCreateRoomRES = GCCreateRoomRES

GCCreateRoomRES.OP_CODE = net.ProtocolCode.P_GC_CREATE_ROOM_RES;
GCCreateRoomRES.CLZ_CODE = "com.kodgames.message.proto.game.GCCreateRoomRES"

-- @param serverId: number
-- @param callback: number
function GCCreateRoomRES:ctor(serverId, callback)
    self.super.ctor(self, GCCreateRoomRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 请求房间所在的服务器Id
------------------------------------
local CGQueryBattleIdREQ = class("CGQueryBattleIdREQ", ProtocolBase)
ns.CGQueryBattleIdREQ = CGQueryBattleIdREQ

CGQueryBattleIdREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_BATTLEID_REQ;
CGQueryBattleIdREQ.CLZ_CODE = "com.kodgames.message.proto.game.CGQueryBattleIdREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryBattleIdREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryBattleIdREQ.OP_CODE, serverId, callback);
end

-- @param  roomId: number
-- @return self
function CGQueryBattleIdREQ:setData(roomId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.roomId = roomId;
	return self
end

------------------------------------
local GCQueryBattleIdRES = class("GCQueryBattleIdRES", ProtocolBase)
ns.GCQueryBattleIdRES = GCQueryBattleIdRES

GCQueryBattleIdRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_BATTLEID_RES;
GCQueryBattleIdRES.CLZ_CODE = "com.kodgames.message.proto.game.GCQueryBattleIdRES"

-- @param serverId: number
-- @param callback: number
function GCQueryBattleIdRES:ctor(serverId, callback)
    self.super.ctor(self, GCQueryBattleIdRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 进入房间
------------------------------------
local CBEnterRoomREQ = class("CBEnterRoomREQ", ProtocolBase)
ns.CBEnterRoomREQ = CBEnterRoomREQ

CBEnterRoomREQ.OP_CODE = net.ProtocolCode.P_CB_ENTER_ROOM_REQ;
CBEnterRoomREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBEnterRoomREQ"

-- @param serverId: number
-- @param callback: number
function CBEnterRoomREQ:ctor(serverId, callback)
	self.super.ctor(self, CBEnterRoomREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
-- @param roomId: number
-- @param nickname: string
-- @param headImageUrl: string
-- @param sex: number
-- @param isWatcher 观战传true，其他传false
-- @return self
function CBEnterRoomREQ:setData(roleId, roomId, nickname, headImageUrl, sex, isWatcher, isIdentity, headFrame, joinType, specialEffect, clubId ,enterRoomPlayerGps)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.roleId = roleId;
    protocolBuf.roomId = roomId;
    protocolBuf.nickname = nickname;
    protocolBuf.headImageUrl = headImageUrl;
    protocolBuf.sex = sex;
	protocolBuf.isWatcher = isWatcher;
	protocolBuf.isIdentity = isIdentity;
	protocolBuf.headFrame = headFrame
	protocolBuf.joinType = joinType
	protocolBuf.specialEffect = specialEffect
    protocolBuf.clubId = clubId
    protocolBuf.enterRoomPlayerGps = enterRoomPlayerGps
	return self
end

------------------------------------
local BCEnterRoomRES = class("BCEnterRoomRES", ProtocolBase)
ns.BCEnterRoomRES = BCEnterRoomRES

BCEnterRoomRES.OP_CODE = net.ProtocolCode.P_BC_ENTER_ROOM_RES;
BCEnterRoomRES.CLZ_CODE = "com.kodgames.message.proto.room.BCEnterRoomRES"

-- @param serverId: number
-- @param callback: number
function BCEnterRoomRES:ctor(serverId, callback)
    self.super.ctor(self, BCEnterRoomRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 退出房间
------------------------------------
local CBQuitRoomREQ = class("CBQuitRoomREQ", ProtocolBase)
ns.CBQuitRoomREQ = CBQuitRoomREQ

CBQuitRoomREQ.OP_CODE = net.ProtocolCode.P_CB_QUIT_ROOM_REQ;
CBQuitRoomREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBQuitRoomREQ"

-- @param serverId: number
-- @param callback: number
function CBQuitRoomREQ:ctor(serverId, callback)
	self.super.ctor(self, CBQuitRoomREQ.OP_CODE, serverId, callback);
end

function CBQuitRoomREQ:setData(isDestroyRoom)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.isDestroyRoom = isDestroyRoom;
	return self
end

------------------------------------
local BCQuitRoomRES = class("BCQuitRoomRES", ProtocolBase)
ns.BCQuitRoomRES = BCQuitRoomRES

BCQuitRoomRES.OP_CODE = net.ProtocolCode.P_BC_QUIT_ROOM_RES;
BCQuitRoomRES.CLZ_CODE = "com.kodgames.message.proto.room.BCQuitRoomRES"

-- @param serverId: number
-- @param callback: number
function BCQuitRoomRES:ctor(serverId, callback)
    self.super.ctor(self, BCQuitRoomRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 服务器通知房间销毁消息
------------------------------------
local BCDestroyRoomSYN = class("BCDestroyRoomSYN", ProtocolBase)
ns.BCDestroyRoomSYN = BCDestroyRoomSYN

BCDestroyRoomSYN.OP_CODE = net.ProtocolCode.P_BC_DESTROY_ROOM_SYN;
BCDestroyRoomSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCDestroyRoomSYN"

BCDestroyRoomSYN.ReasonForDestoryRoom = {
        CREATOR   = 1, 	-- 房主解散
        VOTE 	  = 2,	-- 投票解散
        GAMEOVER  = 3,	-- 牌局结束解散
        GMT 	  = 4,	-- GMT 解散
        EXCEPTION = 5,	-- 服务器异常
		CLUB_MANAGER_DESTROY = 6,	-- 亲友圈群主强制解散
		CAMPAIGN_STOP_DESTORY = 7,	-- 比赛房间解散
		ACTING_ROOM_TIME_OUT = 9, -- 俱乐部代开房间超时自动解散
		LEAGUE_DESTROY = 10, -- 联盟强制解散
		LEAGUE_LEADER_DESTROY = 11, --联盟盟主强制解散
		LEAGUE_SCORE_LESS_DESTROY = 13,       -- 联盟结算分数过低解散
		LEAGUE_LOW_MEN_KAN_DESTROY = 14,        -- 联盟分数低于门槛解散
		TRUSTEESHIP_DESTROY = 15, 				-- 房间内有玩家托管
}

-- @param serverId: number
-- @param callback: number
function BCDestroyRoomSYN:ctor(serverId, callback)
    self.super.ctor(self, BCDestroyRoomSYN.OP_CODE, serverId, callback);
end

------------------------------------
-- 发起投票销毁房间
------------------------------------
local CBStartVoteDestroyREQ = class("CBStartVoteDestroyREQ", ProtocolBase)
ns.CBStartVoteDestroyREQ = CBStartVoteDestroyREQ

CBStartVoteDestroyREQ.OP_CODE = net.ProtocolCode.P_CB_START_VOTE_DESTROY_REQ;
CBStartVoteDestroyREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBStartVoteDestroyREQ"

-- @param serverId: number
-- @param callback: number
function CBStartVoteDestroyREQ:ctor(serverId, callback)
	self.super.ctor(self, CBStartVoteDestroyREQ.OP_CODE, serverId, callback);
end

function CBStartVoteDestroyREQ:setData(phoneNumber, reasons)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.phoneNumber = phoneNumber;
	protocolBuf.reasons = reasons;
end

------------------------------------
local BCStartVoteDestroyRES = class("BCStartVoteDestroyRES", ProtocolBase)
ns.BCStartVoteDestroyRES = BCStartVoteDestroyRES

BCStartVoteDestroyRES.OP_CODE = net.ProtocolCode.P_BC_START_VOTE_DESTROY_RES;
BCStartVoteDestroyRES.CLZ_CODE = "com.kodgames.message.proto.room.BCStartVoteDestroyRES"

-- @param serverId: number
-- @param callback: number
function BCStartVoteDestroyRES:ctor(serverId, callback)
    self.super.ctor(self, BCStartVoteDestroyRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 投票是否解散
------------------------------------
local CBVoteDestroyREQ = class("CBVoteDestroyREQ", ProtocolBase)
ns.CBVoteDestroyREQ = CBVoteDestroyREQ

CBVoteDestroyREQ.OP_CODE = net.ProtocolCode.P_CB_VOTE_DESTROY_REQ;
CBVoteDestroyREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBVoteDestroyREQ"

-- @param serverId: number
-- @param callback: number
function CBVoteDestroyREQ:ctor(serverId, callback)
	self.super.ctor(self, CBVoteDestroyREQ.OP_CODE, serverId, callback);
end

-- @param agree: boolean
-- @return self
function CBVoteDestroyREQ:setData(agree)
	local protocolBuf = self:getProtocolBuf();
	if agree then
		protocolBuf.type = 1
	else
		protocolBuf.type = 2
	end
	return self	
end

------------------------------------
local BCVoteDestroyRES = class("BCVoteDestroyRES", ProtocolBase)
ns.BCVoteDestroyRES = BCVoteDestroyRES

BCVoteDestroyRES.OP_CODE = net.ProtocolCode.P_BC_VOTE_DESTROY_RES;
BCVoteDestroyRES.CLZ_CODE = "com.kodgames.message.proto.room.BCVoteDestroyRES"

-- @param serverId: number
-- @param callback: number
function BCVoteDestroyRES:ctor(serverId, callback)
    self.super.ctor(self, BCVoteDestroyRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 服务器同步投票信息
------------------------------------
local BCVoteDestroyInfoSYN = class("BCVoteDestroyInfoSYN", ProtocolBase)
ns.BCVoteDestroyInfoSYN = BCVoteDestroyInfoSYN

BCVoteDestroyInfoSYN.OP_CODE = net.ProtocolCode.P_BC_VOTE_DESTROYINFO_SYN;
BCVoteDestroyInfoSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCVoteDestroyInfoSYN"

-- @param serverId: number
-- @param callback: number
function BCVoteDestroyInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, BCVoteDestroyInfoSYN.OP_CODE, serverId, callback);
end

----------------------------
-- 房间玩家信息同步消息
----------------------------
local BCRoomPlayerInfoSYN = class("BCRoomPlayerInfoSYN", ProtocolBase)
ns.BCRoomPlayerInfoSYN = BCRoomPlayerInfoSYN

BCRoomPlayerInfoSYN.OP_CODE = net.ProtocolCode.P_BC_ROOM_PLAYERINFO_SYN;
BCRoomPlayerInfoSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCRoomPlayerInfoSYN"

-- @param serverId: number
-- @param callback: number
function BCRoomPlayerInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, BCRoomPlayerInfoSYN.OP_CODE, serverId, callback);
end

----------------------------
-- 服务器同IP提示同步消息
----------------------------
local BCSameIpSYN = class("BCSameIpSYN", ProtocolBase)
ns.BCSameIpSYN = BCSameIpSYN

BCSameIpSYN.OP_CODE = net.ProtocolCode.P_BC_SAME_IP_SYN;
BCSameIpSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCSameIpSYN"

-- @param serverId: number
-- @param callback: number
function BCSameIpSYN:ctor(serverId, callback)
    self.super.ctor(self, BCSameIpSYN.OP_CODE, serverId, callback);
end

----------------------------
-- 服务器Gps同步消息
----------------------------
local BCSecureDetectSYN = class("BCSecureDetectSYN", ProtocolBase)
ns.BCSecureDetectSYN = BCSecureDetectSYN

BCSecureDetectSYN.OP_CODE = net.ProtocolCode.P_BC_SECUREDETECTSYN_RES;
BCSecureDetectSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCSecureDetectSYN"

-- @param serverId: number
-- @param callback: number
function BCSecureDetectSYN:ctor(serverId, callback)
    self.super.ctor(self, BCSecureDetectSYN.OP_CODE, serverId, callback);
end

------------------------------------
-- 更新玩家GPS信息
------------------------------------
local CBGpsInfoREQ = class("CBGpsInfoREQ", ProtocolBase)
ns.CBGpsInfoREQ = CBGpsInfoREQ

CBGpsInfoREQ.OP_CODE = net.ProtocolCode.P_CB_GPS_INFO_REQ;
CBGpsInfoREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBGpsInfoREQ"

-- @param serverId: number
-- @param callback: number
function CBGpsInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CBGpsInfoREQ.OP_CODE, serverId, callback);
end

function CBGpsInfoREQ:setData(status, latitude, longitude)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.status = status;
	protocolBuf.latitude = latitude;
	protocolBuf.longitude = longitude;
end

------------------------------------
-- 更新玩家GPS信息
------------------------------------
local BCGpsInfoRES = class("BCGpsInfoRES", ProtocolBase)
ns.BCGpsInfoRES = BCGpsInfoRES

BCGpsInfoRES.OP_CODE = net.ProtocolCode.P_BC_GPS_INFO_RES;
BCGpsInfoRES.CLZ_CODE = "com.kodgames.message.proto.room.BCGpsInfoRES"

-- @param serverId: number
-- @param callback: number
function BCGpsInfoRES:ctor(serverId, callback)
	self.super.ctor(self, BCGpsInfoRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 更新房间玩家状态
------------------------------------
local CBUpdateStatusREQ = class("CBUpdateStatusREQ", ProtocolBase)
ns.CBUpdateStatusREQ = CBUpdateStatusREQ

CBUpdateStatusREQ.OP_CODE = net.ProtocolCode.P_CB_UPDATE_PLAYERSTATUS_REQ;
CBUpdateStatusREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBUpdateStatusREQ"

-- @param serverId: number
-- @param callback: number
function CBUpdateStatusREQ:ctor(serverId, callback)
	self.super.ctor(self, CBUpdateStatusREQ.OP_CODE, serverId, callback);
end

-- @param status: number
function CBUpdateStatusREQ:setData(status)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.status = status;
end

------------------------------------
local BCUpdateStatusRES = class("BCUpdateStatusRES", ProtocolBase)
ns.BCUpdateStatusRES = BCUpdateStatusRES

BCUpdateStatusRES.OP_CODE = net.ProtocolCode.P_BC_UPDATE_PLAYERSTATUS_RES;
BCUpdateStatusRES.CLZ_CODE = "com.kodgames.message.proto.room.BCUpdateStatusRES"

-- @param serverId: number
-- @param callback: number
function BCUpdateStatusRES:ctor(serverId, callback)
    self.super.ctor(self, BCUpdateStatusRES.OP_CODE, serverId, callback);
end

----------------------------
-- 服务器实时语音同步消息
----------------------------
local BCRealTimeVoiceSYN = class("BCRealTimeVoiceSYN", ProtocolBase)
ns.BCRealTimeVoiceSYN = BCRealTimeVoiceSYN

BCRealTimeVoiceSYN.OP_CODE = net.ProtocolCode.P_BC_REAL_TIME_VOICE_SYN;
BCRealTimeVoiceSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCRealTimeVoiceSYN"

-- @param serverId: number
-- @param callback: number
function BCRealTimeVoiceSYN:ctor(serverId, callback)
    self.super.ctor(self, BCRealTimeVoiceSYN.OP_CODE, serverId, callback);
end

------------------------------------
-- 更新玩家实时语音信息
------------------------------------
local CBRealTimeVoiceREQ = class("CBRealTimeVoiceREQ", ProtocolBase)
ns.CBRealTimeVoiceREQ = CBRealTimeVoiceREQ

CBRealTimeVoiceREQ.OP_CODE = net.ProtocolCode.P_CB_REAL_TIME_VOICE_REQ;
CBRealTimeVoiceREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBRealTimeVoiceREQ"

-- @param serverId: number
-- @param callback: number
function CBRealTimeVoiceREQ:ctor(serverId, callback)
	self.super.ctor(self, CBRealTimeVoiceREQ.OP_CODE, serverId, callback);
end

function CBRealTimeVoiceREQ:setData(memberId, status)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.memberId = memberId;
	protocolBuf.status = status;
end

------------------------------------
-- 更新玩家实时语音信息
------------------------------------
local BCRealTimeVoiceRES = class("BCRealTimeVoiceRES", ProtocolBase)
ns.BCRealTimeVoiceRES = BCRealTimeVoiceRES

BCRealTimeVoiceRES.OP_CODE = net.ProtocolCode.P_BC_REAL_TIME_VOICE_RES;
BCRealTimeVoiceRES.CLZ_CODE = "com.kodgames.message.proto.room.BCRealTimeVoiceRES"

-- @param serverId: number
-- @param callback: number
function BCRealTimeVoiceRES:ctor(serverId, callback)
	self.super.ctor(self, BCRealTimeVoiceRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 亲友圈观战相关,请求退出观战
------------------------------------
local CBQuitWatchBattleREQ = class("CBQuitWatchBattleREQ", ProtocolBase)
ns.CBQuitWatchBattleREQ = CBQuitWatchBattleREQ
CBQuitWatchBattleREQ.OP_CODE = net.ProtocolCode.P_CB_QUIT_WATCH_BATTLE_REQ;
CBQuitWatchBattleREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBQuitWatchBattleREQ"

-- @param serverId: number
-- @param callback: number
function CBQuitWatchBattleREQ:ctor(serverId, callback)
	self.super.ctor(self, CBQuitWatchBattleREQ.OP_CODE, serverId, callback);
end

function CBQuitWatchBattleREQ:setData(roomId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roomId = roomId;
end

-- 亲友圈请求退出观战回应
local BCQuitWatchBattleRES = class("BCQuitWatchBattleRES", ProtocolBase)
ns.BCQuitWatchBattleRES = BCQuitWatchBattleRES
BCQuitWatchBattleRES.OP_CODE = net.ProtocolCode.P_BC_QUIT_WATCH_BATTLE_RES;
BCQuitWatchBattleRES.CLZ_CODE = "com.kodgames.message.proto.room.BCQuitWatchBattleRES"

-- @param serverId: number
-- @param callback: number
function BCQuitWatchBattleRES:ctor(serverId, callback)
	self.super.ctor(self, BCQuitWatchBattleRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 同ip免房卡活动
------------------------------------
-- 发送请求玩家ip相同或相近
local CBIpSameREQ = class("CBIpSameREQ", ProtocolBase)
ns.CBIpSameREQ = CBIpSameREQ
CBIpSameREQ.OP_CODE = net.ProtocolCode.P_CB_IP_SAME_REQ;
CBIpSameREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBIpSameREQ"

-- @param serverId: number
-- @param callback: number
function CBIpSameREQ:ctor(serverId, callback)
	self.super.ctor(self, CBIpSameREQ.OP_CODE, serverId, callback);
end

function CBIpSameREQ:setData(ipSameCount,gpsConflictCount)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.ipSameCount  = ipSameCount;
	protocolBuf.gpsConflictCount  = gpsConflictCount;
end

-- 返回玩家ip相同或相近
local BCIpSameRES = class("BCIpSameRES", ProtocolBase)
ns.BCIpSameRES = BCIpSameRES
BCIpSameRES.OP_CODE = net.ProtocolCode.P_BC_IP_SAME_RES;
BCIpSameRES.CLZ_CODE = "com.kodgames.message.proto.room.BCIpSameRES"

-- @param serverId: number
-- @param callback: number
function BCIpSameRES:ctor(serverId, callback)
	self.super.ctor(self, BCIpSameRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 出牌延时
------------------------------------
-- 请求出牌延时服务器记录
local CBQueryPlayerOPInfoREQ = class("CBQueryPlayerOPInfoREQ", ProtocolBase)
ns.CBQueryPlayerOPInfoREQ = CBQueryPlayerOPInfoREQ
CBQueryPlayerOPInfoREQ.OP_CODE = net.ProtocolCode.P_CB_QUERY_PLAYER_OP_INFO_REQ;
CBQueryPlayerOPInfoREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBQueryPlayerOPInfoREQ"

-- @param serverId: number
-- @param callback: number
function CBQueryPlayerOPInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CBQueryPlayerOPInfoREQ.OP_CODE, serverId, callback);
end

-- 返回出牌延时服务器记录
local BCQueryPlayerOPInfoRES = class("BCQueryPlayerOPInfoRES", ProtocolBase)
ns.BCQueryPlayerOPInfoRES = BCQueryPlayerOPInfoRES
BCQueryPlayerOPInfoRES.OP_CODE = net.ProtocolCode.P_BC_QUERY_PLAYER_OP_INFO_RES;
BCQueryPlayerOPInfoRES.CLZ_CODE = "com.kodgames.message.proto.room.BCQueryPlayerOPInfoRES"

-- @param serverId: number
-- @param callback: number
function BCQueryPlayerOPInfoRES:ctor(serverId, callback)
	self.super.ctor(self, BCQueryPlayerOPInfoRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 提前开局
------------------------------------

local CBStartBattleInAdvanceREQ = class("CBStartBattleInAdvanceREQ", ProtocolBase)
ns.CBStartBattleInAdvanceREQ = CBStartBattleInAdvanceREQ
CBStartBattleInAdvanceREQ.OP_CODE = net.ProtocolCode.P_CB_START_BATTLE_IN_ADVANCE_REQ;
CBStartBattleInAdvanceREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBStartBattleInAdvanceREQ"


function CBStartBattleInAdvanceREQ:ctor(serverId, callback)
	self.super.ctor(self, CBStartBattleInAdvanceREQ.OP_CODE, serverId, callback);
end

function CBStartBattleInAdvanceREQ:setData(roomId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.roomId  = roomId;
end

local BCStartBattleInAdvanceRES = class("BCStartBattleInAdvanceRES", ProtocolBase)
ns.BCStartBattleInAdvanceRES = BCStartBattleInAdvanceRES
BCStartBattleInAdvanceRES.OP_CODE = net.ProtocolCode.P_BC_START_BATTLE_IN_ADVANCE_RES;
BCStartBattleInAdvanceRES.CLZ_CODE = "com.kodgames.message.proto.room.BCStartBattleInAdvanceRES"

function BCStartBattleInAdvanceRES:ctor(serverId, callback)
	self.super.ctor(self, BCStartBattleInAdvanceRES.OP_CODE, serverId, callback);
end


-- 请求提前开局投票
local CBVoteStartBattleREQ = class("CBVoteStartBattleREQ", ProtocolBase)
ns.CBVoteStartBattleREQ = CBVoteStartBattleREQ
CBVoteStartBattleREQ.OP_CODE = net.ProtocolCode.P_CB_VOTE_START_BATTLE_REQ;
CBVoteStartBattleREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBVoteStartBattleREQ"


function CBVoteStartBattleREQ:ctor(serverId, callback)
	self.super.ctor(self, CBVoteStartBattleREQ.OP_CODE, serverId, callback);
end

function CBVoteStartBattleREQ:setData(type)
	local protocolBuf = self:getProtocolBuf();
	if type then
		protocolBuf.type = 1
	else
		protocolBuf.type = 2
	end
end

local BCVoteStartBattleRES = class("BCVoteStartBattleRES", ProtocolBase)
ns.BCVoteStartBattleRES = BCVoteStartBattleRES
BCVoteStartBattleRES.OP_CODE = net.ProtocolCode.P_BC_VOTE_START_BATTLE_RES;
BCVoteStartBattleRES.CLZ_CODE = "com.kodgames.message.proto.room.BCVoteStartBattleRES"

function BCVoteStartBattleRES:ctor(serverId, callback)
	self.super.ctor(self, BCVoteStartBattleRES.OP_CODE, serverId, callback);
end

-- 提前开局投票同步
local BCVoteStartBattleInfoSYN = class("BCVoteStartBattleInfoSYN", ProtocolBase)
ns.BCVoteStartBattleInfoSYN = BCVoteStartBattleInfoSYN

BCVoteStartBattleInfoSYN.OP_CODE = net.ProtocolCode.P_BC_VOTE_START_BATTLE_INFO_SYN;
BCVoteStartBattleInfoSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCVoteStartBattleInfoSYN"

-- @param serverId: number
-- @param callback: number
function BCVoteStartBattleInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, BCVoteStartBattleInfoSYN.OP_CODE, serverId, callback);
end

-- 告诉服务器是否胡牌
--------------------------------------------------------------------------------
local CBOpenAutoHuREQ = class("CBOpenAutoHuREQ", ProtocolBase)
ns.CBOpenAutoHuREQ = CBOpenAutoHuREQ

function CBOpenAutoHuREQ:ctor(serverId, callback)
	self.super.ctor(self, CBOpenAutoHuREQ.OP_CODE, serverId, callback);
end

CBOpenAutoHuREQ.OP_CODE = net.ProtocolCode.P_CB_OPEN_AUTO_HU_REQ
CBOpenAutoHuREQ.CLZ_CODE = "com.kodgames.message.proto.room.CBOpenAutoHuREQ"

-- @param playType: number
-- @param cards: number[]
function CBOpenAutoHuREQ:setData(isOpen)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.isOpen = isOpen
end

local BCOpenAutoHuRES = class("BCOpenAutoHuRES", ProtocolBase)
ns.BCOpenAutoHuRES = BCOpenAutoHuRES

BCOpenAutoHuRES.OP_CODE = net.ProtocolCode.P_BC_OPEN_AUTO_HU_RES;
BCOpenAutoHuRES.CLZ_CODE = "com.kodgames.message.proto.room.BCOpenAutoHuRES"

-- @param serverId: number
-- @param callback: number
function BCOpenAutoHuRES:ctor(serverId, callback)
    self.super.ctor(self, BCOpenAutoHuRES.OP_CODE, serverId, callback);
end

-- 提前开局信息同步
--------------------------------------------------------------------------------
local BCAdvanceInfoSYN = class("BCAdvanceInfoSYN", ProtocolBase)
ns.BCAdvanceInfoSYN = BCAdvanceInfoSYN

BCAdvanceInfoSYN.OP_CODE = net.ProtocolCode.P_BC_ADVANCE_INFO_SYN;
BCAdvanceInfoSYN.CLZ_CODE = "com.kodgames.message.proto.room.BCAdvanceInfoSYN"

-- @param serverId: number
-- @param callback: number
function BCAdvanceInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, BCAdvanceInfoSYN.OP_CODE, serverId, callback);
end
