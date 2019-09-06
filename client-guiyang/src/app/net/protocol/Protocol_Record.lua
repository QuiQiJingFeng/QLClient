local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

------------------------------
-- 亲友圈对账单查询功能
------------------------------
--请求查询亲友圈账单
local CCLCheckClubBillREQ = class("CCLCheckClubBillREQ", ProtocolBase)
ns.CCLCheckClubBillREQ = CCLCheckClubBillREQ

CCLCheckClubBillREQ.OP_CODE = net.ProtocolCode.P_CCL_CHECK_CLUB_BILL_REQ
CCLCheckClubBillREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CCLCheckClubBillREQ"

function CCLCheckClubBillREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCheckClubBillREQ.OP_CODE, serverId, callback)
end

function CCLCheckClubBillREQ:setData(clubId,startTime,endTime)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().startTime = startTime;
	self:getProtocolBuf().endTime = endTime;
end

-- 请求查询亲友圈账单返回
local CLCCheckClubBillRES = class("CLCCheckClubBillRES", ProtocolBase)
ns.CLCCheckClubBillRES = CLCCheckClubBillRES

CLCCheckClubBillRES.OP_CODE = net.ProtocolCode.P_CLC_CHECK_CLUB_BILL_RES
CLCCheckClubBillRES.CLZ_CODE = "com.kodgames.message.proto.replay.CLCCheckClubBillRES"

function CLCCheckClubBillRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCheckClubBillRES.OP_CODE, serverId, callback)
end

--请求查询今日亲友圈账单
local CCLCheckClubBillTodayREQ = class("CCLCheckClubBillTodayREQ", ProtocolBase)
ns.CCLCheckClubBillTodayREQ = CCLCheckClubBillTodayREQ

CCLCheckClubBillTodayREQ.OP_CODE = net.ProtocolCode.P_CCL_CHECK_CLUB_BILL_TODAY_REQ
CCLCheckClubBillTodayREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CCLCheckClubBillTodayREQ"

function CCLCheckClubBillTodayREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCheckClubBillTodayREQ.OP_CODE, serverId, callback)
end

function CCLCheckClubBillTodayREQ:setData(clubId)
	self:getProtocolBuf().clubId = clubId
end

--请求查询今日亲友圈账单返回
local CLCCheckClubBillTodayRES = class("CLCCheckClubBillTodayRES", ProtocolBase)
ns.CLCCheckClubBillTodayRES = CLCCheckClubBillTodayRES

CLCCheckClubBillTodayRES.OP_CODE = net.ProtocolCode.P_CLC_CHECK_CLUB_BILL_TODAY_RES
CLCCheckClubBillTodayRES.CLZ_CODE = "com.kodgames.message.proto.replay.CLCCheckClubBillTodayRES"

function CLCCheckClubBillTodayRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCheckClubBillTodayRES.OP_CODE, serverId, callback)
end


------------------------------------
-- 战绩相关-请求战绩房间列表
------------------------------------
local CRGameHistoryREQ = class("CRGameHistoryREQ", ProtocolBase)
ns.CRGameHistoryREQ = CRGameHistoryREQ

CRGameHistoryREQ.OP_CODE = net.ProtocolCode.P_CR_GAME_HISTORY_REQ
CRGameHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRGameHistoryREQ"

-- @param serverId: number
-- @param callback: number
function CRGameHistoryREQ:ctor(serverId, callback)
	self.super.ctor(self, CRGameHistoryREQ.OP_CODE, serverId, callback);
	self.bySelf = true
end

-- @param version: number
-- @param bySelf: bool
function CRGameHistoryREQ:setData(version, areaId, bySelf)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.version = version
	protocolBuf.areaId = areaId
	self.bySelf = bySelf
end

----------------------------
local RCGameHistoryRES = class("RCGameHistoryRES", ProtocolBase)
ns.RCGameHistoryRES = RCGameHistoryRES

RCGameHistoryRES.OP_CODE = net.ProtocolCode.P_RC_GAME_HISTORY_RES;
RCGameHistoryRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCGameHistoryRES"

-- @param serverId: number
-- @param callback: number
function RCGameHistoryRES:ctor(serverId, callback)
    self.super.ctor(self, RCGameHistoryRES.OP_CODE, serverId, callback);
end


------------------------------------
-- 战绩相关-请求牌局详情
------------------------------------
local CRHistoryRoomREQ = class("CRHistoryRoomREQ", ProtocolBase)
ns.CRHistoryRoomREQ = CRHistoryRoomREQ

CRHistoryRoomREQ.OP_CODE = net.ProtocolCode.P_CR_HISTORY_ROOM_REQ
CRHistoryRoomREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRHistoryRoomREQ"

-- @param serverId: number
-- @param callback: number
function CRHistoryRoomREQ:ctor(serverId, callback)
	self.super.ctor(self, CRHistoryRoomREQ.OP_CODE, serverId, callback);
end

-- @param roomId: number
-- @param createTime: number
-- @param queryRoleId: number
function CRHistoryRoomREQ:setData(createTime, roomId, queryRoleId, areaId, bySelf)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.createTime = createTime
	protocolBuf.roomId = roomId
	protocolBuf.queryRoleId = queryRoleId
	protocolBuf.areaId = areaId
	self.bySelf = bySelf
end

----------------------------
local RCHistoryRoomRES = class("RCHistoryRoomRES", ProtocolBase)
ns.RCHistoryRoomRES = RCHistoryRoomRES

RCHistoryRoomRES.OP_CODE = net.ProtocolCode.P_RC_HISTORY_ROOM_RES;
RCHistoryRoomRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCHistoryRoomRES"

-- @param serverId: number
-- @param callback: number
function RCHistoryRoomRES:ctor(serverId, callback)
    self.super.ctor(self, RCHistoryRoomRES.OP_CODE, serverId, callback);
end

------------------------------------
-- 战绩相关-牌局回放
------------------------------------
local CRHistoryPlaybackREQ = class("CRHistoryPlaybackREQ", ProtocolBase)
ns.CRHistoryPlaybackREQ = CRHistoryPlaybackREQ

CRHistoryPlaybackREQ.OP_CODE = net.ProtocolCode.P_CR_HISTORY_PLAYBACK_REQ
CRHistoryPlaybackREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRHistoryPlaybackREQ"

-- @param serverId: number
-- @param callback: number
function CRHistoryPlaybackREQ:ctor(serverId, callback)
	self.super.ctor(self, CRHistoryPlaybackREQ.OP_CODE, serverId, callback);
end

-- @param creatTime: number
-- @param roomId: number
-- @param recordIndex: number
function CRHistoryPlaybackREQ:setData(creatTime, roomId, recordIndex, areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.creatTime = creatTime
	protocolBuf.roomId = roomId
	protocolBuf.recordIndex = recordIndex
	protocolBuf.areaId = areaId
end

----------------------------
local RCHistoryPlaybackRES = class("RCHistoryPlaybackRES", ProtocolBase)
ns.RCHistoryPlaybackRES = RCHistoryPlaybackRES

RCHistoryPlaybackRES.OP_CODE = net.ProtocolCode.P_RC_HISTORY_PLAYBACK_RES;
RCHistoryPlaybackRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCHistoryPlaybackRES"

-- @param serverId: number
-- @param callback: number
function RCHistoryPlaybackRES:ctor(serverId, callback)
    self.super.ctor(self, RCHistoryPlaybackRES.OP_CODE, serverId, callback);
end

----------------------------
local CCLClubHistoryREQ = class("CCLClubHistoryREQ", ProtocolBase)
ns.CCLClubHistoryREQ = CCLClubHistoryREQ

CCLClubHistoryREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_HISTORY_REQ
CCLClubHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CCLClubHistoryREQ"

-- @param serverId: number
-- @param callback: number
function CCLClubHistoryREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubHistoryREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CCLClubHistoryREQ:setData(clubId, start, num, queryRoleId, queryTime, minScore, onlyAbnormalRoom)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.clubId = clubId
	protocolBuf.start = start
	protocolBuf.num = num
	protocolBuf.queryRoleId = queryRoleId
	--传的是时间戳
	protocolBuf.queryTime = queryTime and queryTime*1000
	protocolBuf.minScore = minScore
	protocolBuf.onlyAbnormalRoom = onlyAbnormalRoom
end

----------------------------
local CLCClubHistoryRES = class("CLCClubHistoryRES", ProtocolBase)
ns.CLCClubHistoryRES = CLCClubHistoryRES

CLCClubHistoryRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_HISTORY_RES
CLCClubHistoryRES.CLZ_CODE = "com.kodgames.message.proto.replay.CLCClubHistoryRES"

-- @param serverId: number
-- @param callback: number
function CLCClubHistoryRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubHistoryRES.OP_CODE, serverId, callback);
end

----------------------------
local CRShareHistoryREQ = class("CRShareHistoryREQ", ProtocolBase)
ns.CRShareHistoryREQ = CRShareHistoryREQ

CRShareHistoryREQ.OP_CODE = net.ProtocolCode.P_CR_SHARE_HISTORY_REQ
CRShareHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRShareHistoryREQ"
-- @param serverId: number
-- @param callback: number
function CRShareHistoryREQ:ctor(serverId, callback)
    self.super.ctor(self, CRShareHistoryREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CRShareHistoryREQ:setData(roleId, roomId, roundNumber, createTime, clubId, areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roleId = roleId
	protocolBuf.roomId = roomId
	protocolBuf.roundNumber = roundNumber
	protocolBuf.clubId = clubId
	protocolBuf.createTime = createTime
	protocolBuf.areaId = areaId
end

----------------------------
local RCShareHistoryRES = class("RCShareHistoryRES", ProtocolBase)
ns.RCShareHistoryRES = RCShareHistoryRES

RCShareHistoryRES.OP_CODE = net.ProtocolCode.P_RC_SHARE_HISTORY_RES
RCShareHistoryRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCShareHistoryRES"
-- @param serverId: number
-- @param callback: number
function RCShareHistoryRES:ctor(serverId, callback)
    self.super.ctor(self, RCShareHistoryRES.OP_CODE, serverId, callback);
end

-- 处理战绩
local CRProcessHistoryREQ = class("CRProcessHistoryREQ", ProtocolBase)
ns.CRProcessHistoryREQ = CRProcessHistoryREQ

CRProcessHistoryREQ.OP_CODE = net.ProtocolCode.P_CR_PROCESS_HISTORY_REQ
CRProcessHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRProcessHistoryREQ"
function CRProcessHistoryREQ:ctor(serverId, callback)
    self.super.ctor(self, CRProcessHistoryREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CRProcessHistoryREQ:setData(roomId, createTime, isProcessed, areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roomId = roomId
	protocolBuf.createTime = createTime
	protocolBuf.isProcessed = isProcessed
	protocolBuf.areaId = areaId
end

----------------------------
local RCProcessHistoryRES = class("RCProcessHistoryRES", ProtocolBase)
ns.RCProcessHistoryRES = RCProcessHistoryRES

RCProcessHistoryRES.OP_CODE = net.ProtocolCode.P_RC_PROCESS_HISTORY_RES
RCProcessHistoryRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCProcessHistoryRES"
-- @param serverId: number
-- @param callback: number
function RCProcessHistoryRES:ctor(serverId, callback)
    self.super.ctor(self, RCProcessHistoryRES.OP_CODE, serverId, callback);
end

-- 战绩解散原因
local CRQueryRoomDestroyInfoREQ = class("CRQueryRoomDestroyInfoREQ", ProtocolBase)
ns.CRQueryRoomDestroyInfoREQ = CRQueryRoomDestroyInfoREQ

CRQueryRoomDestroyInfoREQ.OP_CODE = net.ProtocolCode.P_CR_QUERY_ROOM_DESTROY_INFO_REQ
CRQueryRoomDestroyInfoREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRQueryRoomDestroyInfoREQ"
function CRQueryRoomDestroyInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CRQueryRoomDestroyInfoREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CRQueryRoomDestroyInfoREQ:setData(roomId, createTime, areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roomId = roomId
	protocolBuf.createTime = createTime
	protocolBuf.areaId = areaId
end

----------------------------
local RCQueryRoomDestroyInfoRES = class("RCQueryRoomDestroyInfoRES", ProtocolBase)
ns.RCQueryRoomDestroyInfoRES = RCQueryRoomDestroyInfoRES

RCQueryRoomDestroyInfoRES.OP_CODE = net.ProtocolCode.P_RC_QUERY_ROOM_DESTROY_INFO_RES
RCQueryRoomDestroyInfoRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCQueryRoomDestroyInfoRES"
-- @param serverId: number
-- @param callback: number
function RCQueryRoomDestroyInfoRES:ctor(serverId, callback)
    self.super.ctor(self, RCQueryRoomDestroyInfoRES.OP_CODE, serverId, callback);
end

--FYD START ----------------------

--------------------------------------------
-- Client 向 Replay 请求分享房间战绩信息
local CRShareHistoryRoundForCodeREQ = class("CRShareHistoryRoundForCodeREQ", ProtocolBase)
ns.CRShareHistoryRoundForCodeREQ = CRShareHistoryRoundForCodeREQ

CRShareHistoryRoundForCodeREQ.OP_CODE = net.ProtocolCode.P_CR_SHARE_HISTORY_FOR_CODE_REQ
CRShareHistoryRoundForCodeREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRShareHistoryRoundForCodeREQ"
function CRShareHistoryRoundForCodeREQ:ctor(serverId, callback)
    self.super.ctor(self, CRShareHistoryRoundForCodeREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CRShareHistoryRoundForCodeREQ:setData(roomId, createTime, roundIndex,clubId,areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.roomId = roomId
	protocolBuf.createTime = createTime
	protocolBuf.roundIndex = roundIndex
	protocolBuf.clubId = clubId
	protocolBuf.areaId = areaId
end

--------------------------
--Replay 向 Client 应答分享房间战绩请求（返回回放码）
local RCShareHistoryRoundForCodeRES = class("RCShareHistoryRoundForCodeRES", ProtocolBase)
ns.RCShareHistoryRoundForCodeRES = RCShareHistoryRoundForCodeRES

RCShareHistoryRoundForCodeRES.OP_CODE = net.ProtocolCode.P_RC_SHARE_HISTORY_FOR_CODE_RES
RCShareHistoryRoundForCodeRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCShareHistoryRoundForCodeRES"
-- @param serverId: number
-- @param callback: number
function RCShareHistoryRoundForCodeRES:ctor(serverId, callback)
    self.super.ctor(self, RCShareHistoryRoundForCodeRES.OP_CODE, serverId, callback);
end


-----------------------------
-- Client 向 Replay 请求房间战绩信息(通过回放码)
local CRHistoryRoomByCodeREQ = class("CRHistoryRoomByCodeREQ", ProtocolBase)
ns.CRHistoryRoomByCodeREQ = CRHistoryRoomByCodeREQ

CRHistoryRoomByCodeREQ.OP_CODE = net.ProtocolCode.P_CR_HISTORY_BY_CODE_REQ
CRHistoryRoomByCodeREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CRHistoryRoomByCodeREQ"
function CRHistoryRoomByCodeREQ:ctor(serverId, callback)
    self.super.ctor(self, CRHistoryRoomByCodeREQ.OP_CODE, serverId, callback);
end
--optional string playbackCode = 1;				    // 回放码
-- @param roleId: number
function CRHistoryRoomByCodeREQ:setData(playbackCode, areaId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.playbackCode = playbackCode
	protocolBuf.areaId = areaId
end




---------------------------------------------------
--Replay 向 Client 应答房间战绩请求
local RCHistoryRoomByCodeRES = class("RCHistoryRoomByCodeRES", ProtocolBase)
ns.RCHistoryRoomByCodeRES = RCHistoryRoomByCodeRES

RCHistoryRoomByCodeRES.OP_CODE = net.ProtocolCode.P_RC_HISTORY_BY_CODE_RES
RCHistoryRoomByCodeRES.CLZ_CODE = "com.kodgames.message.proto.replay.RCHistoryRoomByCodeRES"
-- @param serverId: number
-- @param callback: number
function RCHistoryRoomByCodeRES:ctor(serverId, callback)
    self.super.ctor(self, RCHistoryRoomByCodeRES.OP_CODE, serverId, callback);
end

-- 请求联盟战绩
local CCLQueryLeagueRoomHistoryREQ = class("CCLQueryLeagueRoomHistoryREQ", ProtocolBase)
ns.CCLQueryLeagueRoomHistoryREQ = CCLQueryLeagueRoomHistoryREQ
CCLQueryLeagueRoomHistoryREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_ROOM_HISTORY_REQ
CCLQueryLeagueRoomHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.replay.CCLQueryLeagueRoomHistoryREQ"
function CCLQueryLeagueRoomHistoryREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLQueryLeagueRoomHistoryREQ.OP_CODE, serverId, callback);
end

function CCLQueryLeagueRoomHistoryREQ:setData(leagueId, clubId, start, num, queryTime, minScore, onlyAbnormalRoom, queryRoleId, roomId)
	local protocolBuf = self:getProtocolBuf()
	protocolBuf.leagueId = leagueId
	protocolBuf.clubId = clubId
	protocolBuf.start = start
	protocolBuf.num = num
	protocolBuf.queryTime = queryTime and queryTime * 1000
	protocolBuf.minScore = minScore
    protocolBuf.onlyAbnormalRoom = onlyAbnormalRoom
    protocolBuf.queryRoleId = queryRoleId
	protocolBuf.roomId = roomId
end

local CLCQueryLeagueRoomHistoryRES = class("CLCQueryLeagueRoomHistoryRES", ProtocolBase)
ns.CLCQueryLeagueRoomHistoryRES = CLCQueryLeagueRoomHistoryRES
CLCQueryLeagueRoomHistoryRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_ROOM_HISTORY_RES
CLCQueryLeagueRoomHistoryRES.CLZ_CODE = "com.kodgames.message.proto.replay.CLCQueryLeagueRoomHistoryRES"
function CLCQueryLeagueRoomHistoryRES:ctor(serverId, callback)
	self.super.ctor(self, CLCQueryLeagueRoomHistoryRES.OP_CODE, serverId, callback);
end