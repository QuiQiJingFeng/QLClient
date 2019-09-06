local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

-- 亲友圈推送至客户端端的协议
local CLCClubDataSYN = class("CLCClubDataSYN", ProtocolBase)
ns.CLCClubDataSYN = CLCClubDataSYN

CLCClubDataSYN.OP_CODE = net.ProtocolCode.P_CLC_CLUB_DATA_SYN
CLCClubDataSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubDataSYN"

function CLCClubDataSYN:ctor(serverId, callback)
    self.super.ctor(self, CLCClubDataSYN.OP_CODE, serverId, callback)
end

----------------------------
-- 请求亲友圈信息
local CCLClubInfoREQ = class("CCLClubInfoREQ", ProtocolBase)
ns.CCLClubInfoREQ = CCLClubInfoREQ

CCLClubInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_INFO_REQ
CCLClubInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubInfoREQ"

function CCLClubInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubInfoREQ.OP_CODE, serverId, callback)
end

function CCLClubInfoREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end
--
local CLCClubInfoRES = class("CLCClubInfoRES", ProtocolBase)
ns.CLCClubInfoRES = CLCClubInfoRES

CLCClubInfoRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_INFO_RES
CLCClubInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubInfoRES"

function CLCClubInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubInfoRES.OP_CODE, serverId, callback)
end

----------------------------
-- 请求玩家的邀请信息列表
local CCLAllInvitationREQ = class("CCLAllInvitationREQ", ProtocolBase)
ns.CCLAllInvitationREQ = CCLAllInvitationREQ

CCLAllInvitationREQ.OP_CODE = net.ProtocolCode.P_CCL_ALL_INVITATION_REQ;
CCLAllInvitationREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLAllInvitationREQ"

function CCLAllInvitationREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLAllInvitationREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
function CCLAllInvitationREQ:setData(sourceType)
	self:getProtocolBuf().sourceType = sourceType;
end

-- 
local CLCAllInvitationRES = class("CLCAllInvitationRES", ProtocolBase)
ns.CLCAllInvitationRES = CLCAllInvitationRES

CLCAllInvitationRES.OP_CODE = net.ProtocolCode.P_CLC_ALL_INVITATION_RES;
CLCAllInvitationRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCAllInvitationRES"

function CLCAllInvitationRES:ctor(serverId, callback)
	self.super.ctor(self, CLCAllInvitationRES.OP_CODE, serverId, callback);
end

----------------------------
-- 同意或拒绝亲友圈邀请
local CCLClubInvitationResultREQ = class("CCLClubInvitationResultREQ", ProtocolBase)
ns.CCLClubInvitationResultREQ = CCLClubInvitationResultREQ

CCLClubInvitationResultREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_INVITATION_RESULT_REQ;
CCLClubInvitationResultREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubInvitationResultREQ"

function CCLClubInvitationResultREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLClubInvitationResultREQ.OP_CODE, serverId, callback);
end

function CCLClubInvitationResultREQ:setData(clubId, opType, areaId)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.clubId = clubId
	protocolBuf.opType = opType
    protocolBuf.areaId = areaId
end

local CLCClubInvitationResultRES = class("CLCClubInvitationResultRES", ProtocolBase)
ns.CLCClubInvitationResultRES = CLCClubInvitationResultRES

CLCClubInvitationResultRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_INVITATION_RESULT_RES;
CLCClubInvitationResultRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubInvitationResultRES"

-- @param serverId: number
-- @param callback: number
function CLCClubInvitationResultRES:ctor(serverId, callback)
	self.super.ctor(self, CLCClubInvitationResultRES.OP_CODE, serverId, callback);
end

----------------------------
-- 请求退出亲友圈
local CCLQuitClubREQ = class("CCLQuitClubREQ", ProtocolBase)
ns.CCLQuitClubREQ = CCLQuitClubREQ

CCLQuitClubREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_QUIT_REQ
CCLQuitClubREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQuitClubREQ"

function CCLQuitClubREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQuitClubREQ.OP_CODE, serverId, callback)
end

function CCLQuitClubREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end

--
local CLCQuitClubRES = class("CLCQuitClubRES", ProtocolBase)
ns.CLCQuitClubRES = CLCQuitClubRES

CLCQuitClubRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_QUIT_RES
CLCQuitClubRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQuitClubRES"

function CLCQuitClubRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQuitClubRES.OP_CODE, serverId, callback)
end

----------------------------
-- 从亲友圈发起邀请
local CCLSendClubInvitationREQ = class("CCLSendClubInvitationREQ", ProtocolBase)
ns.CCLSendClubInvitationREQ = CCLSendClubInvitationREQ

CCLSendClubInvitationREQ.OP_CODE = net.ProtocolCode.P_CCL_SEND_CLUB_INVITATION_REQ;
CCLSendClubInvitationREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLSendClubInvitationREQ"

-- @param serverId: number
-- @param callback: number
function CCLSendClubInvitationREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLSendClubInvitationREQ.OP_CODE, serverId, callback);
end

-- @param roleId: number
-- @param beInviterId: number
function CCLSendClubInvitationREQ:setData(clubId, beInviterId, sourceType, invitedMsg)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.clubId = clubId;
    protocolBuf.beInviterId = beInviterId;
    protocolBuf.sourceType = sourceType;
    protocolBuf.invitedMsg = invitedMsg;
end

----------------------------
local CLCSendClubInvitationRES = class("CLCSendClubInvitationRES", ProtocolBase)
ns.CLCSendClubInvitationRES = CLCSendClubInvitationRES

CLCSendClubInvitationRES.OP_CODE = net.ProtocolCode.P_CLC_SEND_CLUB_INVITATION_RES;
CLCSendClubInvitationRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCSendClubInvitationRES"

-- @param serverId: number
-- @param callback: number
function CLCSendClubInvitationRES:ctor(serverId, callback)
	self.super.ctor(self, CLCSendClubInvitationRES.OP_CODE, serverId, callback);
end

----------------------------
-- 请求亲友圈牌桌
local CCLClubTableREQ = class("CCLClubTableREQ", ProtocolBase)
ns.CCLClubTableREQ = CCLClubTableREQ

CCLClubTableREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_TABLE_REQ
CCLClubTableREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubTableREQ"

function CCLClubTableREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubTableREQ.OP_CODE, serverId, callback)
end

function CCLClubTableREQ:setData(roleId, clubId)
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().clubId = clubId
end

--
local CLCClubTableRES = class("CLCClubTableRES", ProtocolBase)
ns.CLCClubTableRES = CLCClubTableRES

CLCClubTableRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_TABLE_RES
CLCClubTableRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubTableRES"

function CLCClubTableRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubTableRES.OP_CODE, serverId, callback)
end

--------------------------
-- 创建亲友圈房间
local CCLCreateRoomREQ = class("CCLCreateRoomREQ", ProtocolBase)
ns.CCLCreateRoomREQ = CCLCreateRoomREQ

CCLCreateRoomREQ.OP_CODE = net.ProtocolCode.P_CCL_CREATE_ROOM_REQ
CCLCreateRoomREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCreateRoomREQ"

function CCLCreateRoomREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCreateRoomREQ.OP_CODE, serverId, callback)
end

function CCLCreateRoomREQ:setData(roomType, gameplays, roundType, clubId, managerId, isPrivate, privateRoleIds, createType, inviteeIds)
    self:getProtocolBuf().roomType = roomType
    self:getProtocolBuf().gameplays = gameplays
    self:getProtocolBuf().roundType = roundType
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().managerId = managerId
    self:getProtocolBuf().isPrivate = isPrivate
    self:getProtocolBuf().privateRoleIds = privateRoleIds
    self:getProtocolBuf().createType = createType
    self:getProtocolBuf().inviteeIds = inviteeIds
end

-- 
local CLCCreateRoomRES = class("CLCCreateRoomRES", ProtocolBase)
ns.CLCCreateRoomRES = CLCCreateRoomRES

CLCCreateRoomRES.OP_CODE = net.ProtocolCode.P_CLC_CREATE_ROOM_RES
CLCCreateRoomRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCreateRoomRES"

function CLCCreateRoomRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCreateRoomRES.OP_CODE, serverId, callback)
end

--------------------------
-- 请求亲友圈成员列表
local CCLClubMembersREQ = class("CCLClubMembersREQ", ProtocolBase)
ns.CCLClubMembersREQ = CCLClubMembersREQ

CCLClubMembersREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_MEMBERS_REQ
CCLClubMembersREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubMembersREQ"

function CCLClubMembersREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubMembersREQ.OP_CODE, serverId, callback)
end

function CCLClubMembersREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end

-- club 2 client 返回亲友圈成员
local CLCClubMembersRES = class("CLCClubMembersRES", ProtocolBase)
ns.CLCClubMembersRES = CLCClubMembersRES

CLCClubMembersRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_MEMBERS_RES
CLCClubMembersRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubMembersRES"

function CLCClubMembersRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubMembersRES.OP_CODE, serverId, callback)
end

--------------------------
-- 修改成员参数
local CCLKickOffMemberREQ = class("CCLKickOffMemberREQ", ProtocolBase)
ns.CCLKickOffMemberREQ = CCLKickOffMemberREQ

CCLKickOffMemberREQ.OP_CODE = net.ProtocolCode.P_CCL_KICK_OFF_MEMBER_REQ
CCLKickOffMemberREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLKickOffMemberREQ"

function CCLKickOffMemberREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLKickOffMemberREQ.OP_CODE, serverId, callback)
end

function CCLKickOffMemberREQ:setData(clubId, roleId, leagueId, partnerId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().partnerId = partnerId
end

-- 修改成员结果
local CLCKickOffMemberRES = class("CLCKickOffMemberRES", ProtocolBase)
ns.CLCKickOffMemberRES = CLCKickOffMemberRES

CLCKickOffMemberRES.OP_CODE = net.ProtocolCode.P_CLC_KICK_OFF_MEMBER_RES
CLCKickOffMemberRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCKickOffMemberRES"

function CLCKickOffMemberRES:ctor(serverId, callback)
    self.super.ctor(self, CLCKickOffMemberRES.OP_CODE, serverId, callback)
end

--------------------------
-- 请求公告
local CCLClubNoticeREQ = class("CCLClubNoticeREQ", ProtocolBase)
ns.CCLClubNoticeREQ = CCLClubNoticeREQ

CCLClubNoticeREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_NOTICE_REQ
CCLClubNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubNoticeREQ"

function CCLClubNoticeREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubNoticeREQ.OP_CODE, serverId, callback)
end

function CCLClubNoticeREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end

-- 修改公告结果
local CLCClubNoticeRES = class("CLCClubNoticeRES", ProtocolBase)
ns.CLCClubNoticeRES = CLCClubNoticeRES

CLCClubNoticeRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_NOTICE_RES
CLCClubNoticeRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubNoticeRES"

function CLCClubNoticeRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubNoticeRES.OP_CODE, serverId, callback)
end

--------------------------
-- 申请人列表
local CCLClubApplicantListREQ = class("CCLClubApplicantListREQ", ProtocolBase)
ns.CCLClubApplicantListREQ = CCLClubApplicantListREQ

CCLClubApplicantListREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_APPLICANTS_REQ
CCLClubApplicantListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubApplicantListREQ"

function CCLClubApplicantListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubApplicantListREQ.OP_CODE, serverId, callback)
end

function CCLClubApplicantListREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end

-- 申请人列表
local CLCClubApplicantListRES = class("CLCClubApplicantListRES", ProtocolBase)
ns.CLCClubApplicantListRES = CLCClubApplicantListRES

CLCClubApplicantListRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_APPLICANTS_RES
CLCClubApplicantListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubApplicantListRES"

function CLCClubApplicantListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubApplicantListRES.OP_CODE, serverId, callback)
end

--------------------------
-- 同意申请/拒绝
local CCLClubApplicantREQ = class("CCLClubApplicantREQ", ProtocolBase)
ns.CCLClubApplicantREQ = CCLClubApplicantREQ

CCLClubApplicantREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_APPLICANT_REQ
CCLClubApplicantREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubApplicantREQ"

function CCLClubApplicantREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubApplicantREQ.OP_CODE, serverId, callback)
end

function CCLClubApplicantREQ:setData(clubId, roleId, optype)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().optype = optype
end

--
local CLCClubApplicantRES = class("CLCClubApplicantRES", ProtocolBase)
ns.CLCClubApplicantRES = CLCClubApplicantRES

CLCClubApplicantRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_APPLICANT_RES
CLCClubApplicantRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubApplicantRES"

function CLCClubApplicantRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubApplicantRES.OP_CODE, serverId, callback)
end

-- 客户端主动请求加入亲友圈时获取亲友圈信息
local CCLAccedeToClubInfoREQ = class("CCLAccedeToClubInfoREQ", ProtocolBase)
ns.CCLAccedeToClubInfoREQ = CCLAccedeToClubInfoREQ

CCLAccedeToClubInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_ACCEDE_TO_CLUB_INFO_REQ
CCLAccedeToClubInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLAccedeToClubInfoREQ"

function CCLAccedeToClubInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLAccedeToClubInfoREQ.OP_CODE, serverId, callback)
end

function CCLAccedeToClubInfoREQ:setData(invitationCode)
    self:getProtocolBuf().invitationCode = invitationCode
end

-- 返回客户端请求加入亲友圈时获取亲友圈信息
local CLCAccedeToClubInfoRES = class("CLCAccedeToClubInfoRES", ProtocolBase)
ns.CLCAccedeToClubInfoRES = CLCAccedeToClubInfoRES

CLCAccedeToClubInfoRES.OP_CODE = net.ProtocolCode.P_CLC_ACCEDE_TO_CLUB_INFO_RES
CLCAccedeToClubInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCAccedeToClubInfoRES"

function CLCAccedeToClubInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCAccedeToClubInfoRES.OP_CODE, serverId, callback)
end

-- 通过邀请码加入亲友圈
local CCLAccedeToClubREQ = class("CCLAccedeToClubREQ", ProtocolBase)
ns.CCLAccedeToClubREQ = CCLAccedeToClubREQ

CCLAccedeToClubREQ.OP_CODE = net.ProtocolCode.P_CCL_ACCEDE_CLUB_REQ
CCLAccedeToClubREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLAccedeToClubREQ"

function CCLAccedeToClubREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLAccedeToClubREQ.OP_CODE, serverId, callback)
end

function CCLAccedeToClubREQ:setData(invitationCode, inviterId)
    self:getProtocolBuf().invitationCode = invitationCode
    self:getProtocolBuf().inviterId = inviterId
end

-- 返回亲友圈加入结果
local CLCAccedeToClubRES = class("CLCAccedeToClubRES", ProtocolBase)
ns.CLCAccedeToClubRES = CLCAccedeToClubRES

CLCAccedeToClubRES.OP_CODE = net.ProtocolCode.P_CLC_ACCEDE_CLUB_RES
CLCAccedeToClubRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCAccedeToClubRES"

function CLCAccedeToClubRES:ctor(serverId, callback)
    self.super.ctor(self, CLCAccedeToClubRES.OP_CODE, serverId, callback)
end

------------------------------
-- 请求解散亲友圈
------------------------------
local CCLDestroyRoomREQ = class("CCLDestroyRoomREQ", ProtocolBase)
ns.CCLDestroyRoomREQ = CCLDestroyRoomREQ

CCLDestroyRoomREQ.OP_CODE = net.ProtocolCode.P_CCL_DESTROY_ROOM_REQ
CCLDestroyRoomREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLDestroyRoomREQ"

function CCLDestroyRoomREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLDestroyRoomREQ.OP_CODE, serverId, callback)
end

function CCLDestroyRoomREQ:setData(roomId,clubId,leagueId)
    self:getProtocolBuf().roomId = roomId;
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().leagueId = leagueId;
end

-- 解散亲友圈返回
local CLCDestroyRoomRES = class("CLCDestroyRoomRES", ProtocolBase)
ns.CLCDestroyRoomRES = CLCDestroyRoomRES

CLCDestroyRoomRES.OP_CODE = net.ProtocolCode.P_CLC_DESTROY_ROOM_RES
CLCDestroyRoomRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCDestroyRoomRES"

function CLCDestroyRoomRES:ctor(serverId, callback)
    self.super.ctor(self, CLCDestroyRoomRES.OP_CODE, serverId, callback)
end


------------------------------
--  club 关注和取消关注亲友圈房间列表变化
------------------------------
local CCLFocusOnRoomListREQ = class("CCLFocusOnRoomListREQ", ProtocolBase)
ns.CCLFocusOnRoomListREQ = CCLFocusOnRoomListREQ

CCLFocusOnRoomListREQ.OP_CODE = net.ProtocolCode.P_CCL_FOCUS_ON_ROOM_LIST_REQ
CCLFocusOnRoomListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLFocusOnRoomListREQ"

function CCLFocusOnRoomListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLFocusOnRoomListREQ.OP_CODE, serverId, callback)
end

function CCLFocusOnRoomListREQ:setData(clubId, optype)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().optype = optype;
end

local CLCFocusOnRoomListRES = class("CLCFocusOnRoomListRES", ProtocolBase)
ns.CLCFocusOnRoomListRES = CLCFocusOnRoomListRES

CLCFocusOnRoomListRES.OP_CODE = net.ProtocolCode.P_CLC_FOCUS_ON_ROOM_LIST_RES
CLCFocusOnRoomListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCFocusOnRoomListRES"

function CLCFocusOnRoomListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCFocusOnRoomListRES.OP_CODE, serverId, callback)
end


-------------------------------
-- club 群主请求玩法禁用
-------------------------------
local CCLClubBanGameplayREQ = class("CCLClubBanGameplayREQ", ProtocolBase)
ns.CCLClubBanGameplayREQ = CCLClubBanGameplayREQ

CCLClubBanGameplayREQ.OP_CODE = net.ProtocolCode.P_CCL_CLUB_BAN_GAMEPLAY_REQ
CCLClubBanGameplayREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClubBanGameplayREQ"

function CCLClubBanGameplayREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClubBanGameplayREQ.OP_CODE, serverId, callback)
end

function CCLClubBanGameplayREQ:setData(clubId, areaId, gameplays)
    self:getProtocolBuf().clubId    = clubId;
    self:getProtocolBuf().areaId    = areaId;
    self:getProtocolBuf().gameplays = gameplays;
end

-- 返回
local CLCClubBanGameplayRES = class("CLCClubBanGameplayRES", ProtocolBase)
ns.CLCClubBanGameplayRES = CLCClubBanGameplayRES

CLCClubBanGameplayRES.OP_CODE = net.ProtocolCode.P_CLC_CLUB_BAN_GAMEPLAY_RES
CLCClubBanGameplayRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClubBanGameplayRES"

function CLCClubBanGameplayRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClubBanGameplayRES.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------------------------
-- 修改亲友圈名称、图标
local CCLModifyClubInfoREQ = class("CCLModifyClubInfoREQ", ProtocolBase)
ns.CCLModifyClubInfoREQ = CCLModifyClubInfoREQ

CCLModifyClubInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_CLUBINFO_REQ
CCLModifyClubInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyClubInfoREQ"

function CCLModifyClubInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyClubInfoREQ.OP_CODE, serverId, callback)
end

function CCLModifyClubInfoREQ:setData(clubId, clubName, clubIcon)
    self:getProtocolBuf().clubId        = clubId;
    self:getProtocolBuf().clubName      = clubName;
    self:getProtocolBuf().clubIcon      = clubIcon;
end

local CLCModifyClubInfoRES = class("CLCClubBanGameplayRES", ProtocolBase)
ns.CLCModifyClubInfoRES = CLCModifyClubInfoRES

CLCModifyClubInfoRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_CLUBINFO_RES
CLCModifyClubInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyClubInfoRES"

function CLCModifyClubInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyClubInfoRES.OP_CODE, serverId, callback)
end


----------------------------------------------------------------------------------------
-- 亲友圈对话框协议
local CCLSendClubNoticeREQ = class("CCLSendClubNoticeREQ", ProtocolBase)
ns.CCLSendClubNoticeREQ = CCLSendClubNoticeREQ

CCLSendClubNoticeREQ.OP_CODE = net.ProtocolCode.P_CCL_SEND_CLUB_NOTICE_REQ
CCLSendClubNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLSendClubNoticeREQ"

function CCLSendClubNoticeREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLSendClubNoticeREQ.OP_CODE, serverId, callback)
end

function CCLSendClubNoticeREQ:setData(clubId, notice)
    self:getProtocolBuf().clubId        = clubId;
    self:getProtocolBuf().notice      = notice;
end

local CLCSendClubNoticeRES = class("CLCClubBanGameplayRES", ProtocolBase)
ns.CLCSendClubNoticeRES = CLCSendClubNoticeRES

CLCSendClubNoticeRES.OP_CODE = net.ProtocolCode.P_CLC_SEND_CLUB_NOTICE_RES
CLCSendClubNoticeRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCSendClubNoticeRES"

function CLCSendClubNoticeRES:ctor(serverId, callback)
    self.super.ctor(self, CLCSendClubNoticeRES.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------------------------
-- 亲友圈任务列表
local CCLQueryClubTaskListREQ = class("CCLQueryClubTaskListREQ", ProtocolBase)
ns.CCLQueryClubTaskListREQ = CCLQueryClubTaskListREQ

CCLQueryClubTaskListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_TASKLIST_REQ
CCLQueryClubTaskListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubTaskListREQ"

function CCLQueryClubTaskListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubTaskListREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubTaskListREQ:setData(clubId)
    self:getProtocolBuf().clubId        = clubId;
end

local CLCQueryClubTaskListRES = class("CLCQueryClubTaskListRES", ProtocolBase)
ns.CLCQueryClubTaskListRES = CLCQueryClubTaskListRES

CLCQueryClubTaskListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_TASKLIST_RES
CLCQueryClubTaskListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubTaskListRES"

function CLCQueryClubTaskListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubTaskListRES.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------------------------
-- 领取亲友圈任务奖励
local CCLObtainTaskRewardREQ = class("CCLObtainTaskRewardREQ", ProtocolBase)
ns.CCLObtainTaskRewardREQ = CCLObtainTaskRewardREQ

CCLObtainTaskRewardREQ.OP_CODE = net.ProtocolCode.P_CCL_OBTAIN_TASK_REWARD_REQ
CCLObtainTaskRewardREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLObtainTaskRewardREQ"

function CCLObtainTaskRewardREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLObtainTaskRewardREQ.OP_CODE, serverId, callback)
end

function CCLObtainTaskRewardREQ:setData(clubId, taskId)
    self:getProtocolBuf().clubId        = clubId;
    self:getProtocolBuf().taskId        = taskId;
end

local CLCObtainTaskRewardRES = class("CLCObtainTaskRewardRES", ProtocolBase)
ns.CLCObtainTaskRewardRES = CLCObtainTaskRewardRES

CLCObtainTaskRewardRES.OP_CODE = net.ProtocolCode.P_CLC_OBTAIN_TASK_REWARD_RES
CLCObtainTaskRewardRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCObtainTaskRewardRES"

function CLCObtainTaskRewardRES:ctor(serverId, callback)
    self.super.ctor(self, CLCObtainTaskRewardRES.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------------------------
-- 创建亲友圈
local CCLCreateClubREQ = class("CCLCreateClubREQ", ProtocolBase)
ns.CCLCreateClubREQ = CCLCreateClubREQ

CCLCreateClubREQ.OP_CODE = net.ProtocolCode.P_CCL_CREATE_CLUB_REQ
CCLCreateClubREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCreateClubREQ"

function CCLCreateClubREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCreateClubREQ.OP_CODE, serverId, callback)
end

function CCLCreateClubREQ:setData(clubName, clubIcon)
    self:getProtocolBuf().clubName       = clubName;
    self:getProtocolBuf().clubIcon       = clubIcon;
end

local CLCCreateClubRES = class("CLCCreateClubRES", ProtocolBase)
ns.CLCCreateClubRES = CLCCreateClubRES

CLCCreateClubRES.OP_CODE = net.ProtocolCode.P_CLC_CREATE_CLUB_RES
CLCCreateClubRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCreateClubRES"

function CLCCreateClubRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCreateClubRES.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------------------------
-- 解散亲友圈
local CCLRemoveClubREQ = class("CCLRemoveClubREQ", ProtocolBase)
ns.CCLRemoveClubREQ = CCLRemoveClubREQ

CCLRemoveClubREQ.OP_CODE = net.ProtocolCode.P_CCL_REMOVE_CLUB_REQ
CCLRemoveClubREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLRemoveClubREQ"

function CCLRemoveClubREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLRemoveClubREQ.OP_CODE, serverId, callback)
end

function CCLRemoveClubREQ:setData(clubId)
    self:getProtocolBuf().clubId      = clubId;
end

local CLCRemoveClubRES = class("CLCRemoveClubRES", ProtocolBase)
ns.CLCRemoveClubRES = CLCRemoveClubRES

CLCRemoveClubRES.OP_CODE = net.ProtocolCode.P_CLC_REMOVE_CLUB_RES
CLCRemoveClubRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCRemoveClubRES"

function CLCRemoveClubRES:ctor(serverId, callback)
    self.super.ctor(self, CLCRemoveClubRES.OP_CODE, serverId, callback)
end

---------------------------------------
----------    亲友圈管理    ----------
---------------------------------------
local CCLModifyMemberTitleREQ = class("CCLModifyMemberTitleREQ", ProtocolBase)
ns.CCLModifyMemberTitleREQ = CCLModifyMemberTitleREQ

CCLModifyMemberTitleREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_MEMBER_TITLE_REQ
CCLModifyMemberTitleREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyMemberTitleREQ"

function CCLModifyMemberTitleREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyMemberTitleREQ.OP_CODE, serverId, callback)
end

function CCLModifyMemberTitleREQ:setData(clubId, memberId, title)
    self:getProtocolBuf().clubId        = clubId;
    self:getProtocolBuf().memberId      = memberId;
    self:getProtocolBuf().title         = title;
end

local CLCModifyMemberTitleRES = class("CLCModifyMemberTitleRES", ProtocolBase)
ns.CLCModifyMemberTitleRES = CLCModifyMemberTitleRES

CLCModifyMemberTitleRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_MEMBER_TITLE_RES
CLCModifyMemberTitleRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyMemberTitleRES"

function CLCModifyMemberTitleRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyMemberTitleRES.OP_CODE, serverId, callback)
end


local CCLQueryOperationRecordREQ = class("CCLQueryOperationRecordREQ", ProtocolBase)
ns.CCLQueryOperationRecordREQ = CCLQueryOperationRecordREQ

CCLQueryOperationRecordREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_OPERATION_RECORD_REQ
CCLQueryOperationRecordREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryOperationRecordREQ"

function CCLQueryOperationRecordREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryOperationRecordREQ.OP_CODE, serverId, callback)
end

function CCLQueryOperationRecordREQ:setData(clubId)
    self:getProtocolBuf().clubId        = clubId;
 end

local CLCQueryOperationRecordRES = class("CLCQueryOperationRecordRES", ProtocolBase)
ns.CLCQueryOperationRecordRES = CLCQueryOperationRecordRES

CLCQueryOperationRecordRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_OPERATION_RECORD_RES
CLCQueryOperationRecordRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryOperationRecordRES"

function CLCQueryOperationRecordRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryOperationRecordRES.OP_CODE, serverId, callback)
end

-- 亲友圈公告
local CCLModifyClubNoticeREQ = class("CCLModifyClubNoticeREQ", ProtocolBase)
ns.CCLModifyClubNoticeREQ = CCLModifyClubNoticeREQ

CCLModifyClubNoticeREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_CLUB_NOTICE_REQ
CCLModifyClubNoticeREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyClubNoticeREQ"

function CCLModifyClubNoticeREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyClubNoticeREQ.OP_CODE, serverId, callback)
end

function CCLModifyClubNoticeREQ:setData(clubId, notice)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().notice = notice;
 end

local CLCModifyClubNoticeRES = class("CLCModifyClubNoticeRES", ProtocolBase)
ns.CLCModifyClubNoticeRES = CLCModifyClubNoticeRES

CLCModifyClubNoticeRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_CLUB_NOTICE_RES
CLCModifyClubNoticeRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyClubNoticeRES"

function CLCModifyClubNoticeRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyClubNoticeRES.OP_CODE, serverId, callback)
end

---------------------------------------------------------------------------------
----------------------------------亲友圈红包活动----------------------------------
-- 请求红包列表
local CCLQueryRedPacketListREQ = class("CCLQueryRedPacketListREQ", ProtocolBase)
ns.CCLQueryRedPacketListREQ = CCLQueryRedPacketListREQ

CCLQueryRedPacketListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_RED_PACKET_LIST_REQ
CCLQueryRedPacketListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryRedPacketListREQ"

function CCLQueryRedPacketListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryRedPacketListREQ.OP_CODE, serverId, callback)
end

function CCLQueryRedPacketListREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId;
 end

local CLCQueryRedPacketListRES = class("CLCQueryRedPacketListRES", ProtocolBase)
ns.CLCQueryRedPacketListRES = CLCQueryRedPacketListRES

CLCQueryRedPacketListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_RED_PACKET_LIST_RES
CLCQueryRedPacketListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryRedPacketListRES"

function CLCQueryRedPacketListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryRedPacketListRES.OP_CODE, serverId, callback)
end

-- 请求领取红包
local CCLGainClubRedPacketREQ = class("CCLGainClubRedPacketREQ", ProtocolBase)
ns.CCLGainClubRedPacketREQ = CCLGainClubRedPacketREQ

CCLGainClubRedPacketREQ.OP_CODE = net.ProtocolCode.P_CCL_GAIN_CLUB_RED_PACKET_REQ
CCLGainClubRedPacketREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLGainClubRedPacketREQ"

function CCLGainClubRedPacketREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLGainClubRedPacketREQ.OP_CODE, serverId, callback)
end

function CCLGainClubRedPacketREQ:setData(clubId, redPacketId)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().redPacketId = redPacketId;
 end

local CLCGainClubRedPacketRES = class("CLCGainClubRedPacketRES", ProtocolBase)
ns.CLCGainClubRedPacketRES = CLCGainClubRedPacketRES

CLCGainClubRedPacketRES.OP_CODE = net.ProtocolCode.P_CLC_GAIN_CLUB_RED_PACKET_RES
CLCGainClubRedPacketRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCGainClubRedPacketRES"

function CLCGainClubRedPacketRES:ctor(serverId, callback)
    self.super.ctor(self, CLCGainClubRedPacketRES.OP_CODE, serverId, callback)
end

-- 请求抽奖状态
local CCLQueryClubLotteryInfoREQ = class("CCLQueryClubLotteryInfoREQ", ProtocolBase)
ns.CCLQueryClubLotteryInfoREQ = CCLQueryClubLotteryInfoREQ

CCLQueryClubLotteryInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_LOTTERY_INFO_REQ
CCLQueryClubLotteryInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubLotteryInfoREQ"

function CCLQueryClubLotteryInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubLotteryInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubLotteryInfoREQ:setData(clubId, areaId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().areaId = areaId
 end

local CLCQueryClubLotteryInfoRES = class("CLCQueryClubLotteryInfoRES", ProtocolBase)
ns.CLCQueryClubLotteryInfoRES = CLCQueryClubLotteryInfoRES

CLCQueryClubLotteryInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_LOTTERY_INFO_RES
CLCQueryClubLotteryInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubLotteryInfoRES"

function CLCQueryClubLotteryInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubLotteryInfoRES.OP_CODE, serverId, callback)
end

-- 请求抽奖
local CCLDrawLotteryREQ = class("CCLDrawLotteryREQ", ProtocolBase)
ns.CCLDrawLotteryREQ = CCLDrawLotteryREQ

CCLDrawLotteryREQ.OP_CODE = net.ProtocolCode.P_CCL_DRAW_LOTTERY_REQ
CCLDrawLotteryREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLDrawLotteryREQ"

function CCLDrawLotteryREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLDrawLotteryREQ.OP_CODE, serverId, callback)
end

function CCLDrawLotteryREQ:setData(clubId, areaId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().areaId = areaId
 end

local CLCDrawLotteryRES = class("CLCDrawLotteryRES", ProtocolBase)
ns.CLCDrawLotteryRES = CLCDrawLotteryRES

CLCDrawLotteryRES.OP_CODE = net.ProtocolCode.P_CLC_DRAW_LOTTERY_RES
CLCDrawLotteryRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCDrawLotteryRES"

function CLCDrawLotteryRES:ctor(serverId, callback)
    self.super.ctor(self, CLCDrawLotteryRES.OP_CODE, serverId, callback)
end

-- 吐槽
local CCLManagerFeedbackREQ = class("CCLManagerFeedbackREQ", ProtocolBase)
ns.CCLManagerFeedbackREQ = CCLManagerFeedbackREQ

CCLManagerFeedbackREQ.OP_CODE = net.ProtocolCode.P_CCL_MANAGER_FEEDBACK_REQ
CCLManagerFeedbackREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLManagerFeedbackREQ"

function CCLManagerFeedbackREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLManagerFeedbackREQ.OP_CODE, serverId, callback)
end

function CCLManagerFeedbackREQ:setData(clubId, sex, ageGroup, content)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().sex = sex
    self:getProtocolBuf().ageGroup = ageGroup
    self:getProtocolBuf().content = content
 end

local CLCManagerFeedbackRES = class("CLCManagerFeedbackRES", ProtocolBase)
ns.CLCManagerFeedbackRES = CLCManagerFeedbackRES

CLCManagerFeedbackRES.OP_CODE = net.ProtocolCode.P_CLC_MANAGER_FEEDBACK_RES
CLCManagerFeedbackRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCManagerFeedbackRES"

function CLCManagerFeedbackRES:ctor(serverId, callback)
    self.super.ctor(self, CLCManagerFeedbackRES.OP_CODE, serverId, callback)
end

-- 亲友圈功能开关
local CCLModifyClubSwitchREQ = class("CCLModifyClubSwitchREQ", ProtocolBase)
ns.CCLModifyClubSwitchREQ = CCLModifyClubSwitchREQ

CCLModifyClubSwitchREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_CLUB_SWITCH_REQ
CCLModifyClubSwitchREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyClubSwitchREQ"

function CCLModifyClubSwitchREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyClubSwitchREQ.OP_CODE, serverId, callback)
end

function CCLModifyClubSwitchREQ:setData(clubId, switchType, switchValue)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().switchType = switchType
    self:getProtocolBuf().switchValue = switchValue
 end

local CLCModifyClubSwitchRES = class("CLCModifyClubSwitchRES", ProtocolBase)
ns.CLCModifyClubSwitchRES = CLCModifyClubSwitchRES

CLCModifyClubSwitchRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_CLUB_SWITCH_RES
CLCModifyClubSwitchRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyClubSwitchRES"

function CLCModifyClubSwitchRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyClubSwitchRES.OP_CODE, serverId, callback)
end

-- 请求发布推荐信息
local CCLReleaseRecommandInfoREQ = class("CCLReleaseRecommandInfoREQ", ProtocolBase)
ns.CCLReleaseRecommandInfoREQ = CCLReleaseRecommandInfoREQ

CCLReleaseRecommandInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_RELEASE_RECOMMAND_INFO_REQ
CCLReleaseRecommandInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLReleaseRecommandInfoREQ"

function CCLReleaseRecommandInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLReleaseRecommandInfoREQ.OP_CODE, serverId, callback)
end

function CCLReleaseRecommandInfoREQ:setData(areaId, releaseMsg, releaseMsgType)
    self:getProtocolBuf().areaId = areaId
    self:getProtocolBuf().releaseMsg = releaseMsg
    self:getProtocolBuf().releaseMsgType = releaseMsgType
 end

local CLCReleaseRecommandInfoRES = class("CLCReleaseRecommandInfoRES", ProtocolBase)
ns.CLCReleaseRecommandInfoRES = CLCReleaseRecommandInfoRES

CLCReleaseRecommandInfoRES.OP_CODE = net.ProtocolCode.P_CLC_RELEASE_RECOMMAND_INFO_RES
CLCReleaseRecommandInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCReleaseRecommandInfoRES"

function CLCReleaseRecommandInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCReleaseRecommandInfoRES.OP_CODE, serverId, callback)
end

-- 请求撤销推荐信息
local CCLCancelRecommandInfoREQ = class("CCLCancelRecommandInfoREQ", ProtocolBase)
ns.CCLCancelRecommandInfoREQ = CCLCancelRecommandInfoREQ

CCLCancelRecommandInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_CANCEL_RECOMMAND_INFO_REQ
CCLCancelRecommandInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCancelRecommandInfoREQ"

function CCLCancelRecommandInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCancelRecommandInfoREQ.OP_CODE, serverId, callback)
end

function CCLCancelRecommandInfoREQ:setData(areaId)
    self:getProtocolBuf().areaId = areaId
 end

local CLCCancelRecommandInfoRES = class("CLCCancelRecommandInfoRES", ProtocolBase)
ns.CLCCancelRecommandInfoRES = CLCCancelRecommandInfoRES

CLCCancelRecommandInfoRES.OP_CODE = net.ProtocolCode.P_CLC_CANCEL_RECOMMAND_INFO_RES
CLCCancelRecommandInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCancelRecommandInfoRES"

function CLCCancelRecommandInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCancelRecommandInfoRES.OP_CODE, serverId, callback)
end

-- 请求推荐玩家列表
local CCLQueryRecommendPlayerListREQ = class("CCLQueryRecommendPlayerListREQ", ProtocolBase)
ns.CCLQueryRecommendPlayerListREQ = CCLQueryRecommendPlayerListREQ

CCLQueryRecommendPlayerListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_RECOMMAND_PLAYER_LIST_REQ
CCLQueryRecommendPlayerListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryRecommendPlayerListREQ"

function CCLQueryRecommendPlayerListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryRecommendPlayerListREQ.OP_CODE, serverId, callback)
end

function CCLQueryRecommendPlayerListREQ:setData(areaId, clubId, opType, managerId)
    self:getProtocolBuf().areaId = areaId;
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().opType = opType;
    self:getProtocolBuf().managerId = managerId;
 end

local CLCQueryRecommendPlayerListRES = class("CLCQueryRecommendPlayerListRES", ProtocolBase)
ns.CLCQueryRecommendPlayerListRES = CLCQueryRecommendPlayerListRES

CLCQueryRecommendPlayerListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_RECOMMAND_PLAYER_LIST_RES
CLCQueryRecommendPlayerListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryRecommendPlayerListRES"

function CLCQueryRecommendPlayerListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryRecommendPlayerListRES.OP_CODE, serverId, callback)
end

-- 请求推荐信息发布的状态
local CCLQueryReleaseStatusREQ = class("CCLQueryReleaseStatusREQ", ProtocolBase)
ns.CCLQueryReleaseStatusREQ = CCLQueryReleaseStatusREQ

CCLQueryReleaseStatusREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_RELEASE_STATUS_REQ
CCLQueryReleaseStatusREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryReleaseStatusREQ"

function CCLQueryReleaseStatusREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryReleaseStatusREQ.OP_CODE, serverId, callback)
end

function CCLQueryReleaseStatusREQ:setData(areaId)
    self:getProtocolBuf().areaId = areaId;
 end

local CLCQueryReleaseStatusRES = class("CLCQueryReleaseStatusRES", ProtocolBase)
ns.CLCQueryReleaseStatusRES = CLCQueryReleaseStatusRES

CLCQueryReleaseStatusRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_RELEASE_STATUS_RES
CLCQueryReleaseStatusRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryReleaseStatusRES"

function CLCQueryReleaseStatusRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryReleaseStatusRES.OP_CODE, serverId, callback)
end

-- 请求亲友圈密友玩家信息列表
local CCLQueryPrivatePlayerListREQ = class("CCLQueryPrivatePlayerListREQ", ProtocolBase)
ns.CCLQueryPrivatePlayerListREQ = CCLQueryPrivatePlayerListREQ

CCLQueryPrivatePlayerListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_PRIVATE_PLAYER_LIST_REQ
CCLQueryPrivatePlayerListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryPrivatePlayerListREQ"

function CCLQueryPrivatePlayerListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryPrivatePlayerListREQ.OP_CODE, serverId, callback)
end

function CCLQueryPrivatePlayerListREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId;
 end

local CLCQueryPrivatePlayerListRES = class("CLCQueryPrivatePlayerListRES", ProtocolBase)
ns.CLCQueryPrivatePlayerListRES = CLCQueryPrivatePlayerListRES

CLCQueryPrivatePlayerListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_PRIVATE_PLAYER_LIST_RES
CLCQueryPrivatePlayerListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryPrivatePlayerListRES"

function CLCQueryPrivatePlayerListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryPrivatePlayerListRES.OP_CODE, serverId, callback)
end

-- 亲友圈预设玩法
local CCLModifyClubPresetGameplaysREQ = class("CCLModifyClubPresetGameplaysREQ", ProtocolBase)
ns.CCLModifyClubPresetGameplaysREQ = CCLModifyClubPresetGameplaysREQ

CCLModifyClubPresetGameplaysREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_CLUB_PRESET_GAMEPLAY_REQ
CCLModifyClubPresetGameplaysREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyClubPresetGameplaysREQ"

function CCLModifyClubPresetGameplaysREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyClubPresetGameplaysREQ.OP_CODE, serverId, callback)
end

function CCLModifyClubPresetGameplaysREQ:setData(clubId, opType, presetGameplay)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().opType = opType;
    self:getProtocolBuf().presetGameplay = presetGameplay;
end

local CLCModifyClubPresetGameplaysRES = class("CLCModifyClubPresetGameplaysRES", ProtocolBase)
ns.CLCModifyClubPresetGameplaysRES = CLCModifyClubPresetGameplaysRES

CLCModifyClubPresetGameplaysRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_CLUB_PRESET_GAMEPLAY_RES
CLCModifyClubPresetGameplaysRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyClubPresetGameplaysRES"

function CLCModifyClubPresetGameplaysRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyClubPresetGameplaysRES.OP_CODE, serverId, callback)
end

--------------------------------------活动系统-------------------------------------------------
-- 请求亲友圈活动列表
local CCLQueryManagerActivityListREQ = class("CCLQueryManagerActivityListREQ", ProtocolBase)
ns.CCLQueryManagerActivityListREQ = CCLQueryManagerActivityListREQ

CCLQueryManagerActivityListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_MANAGER_ACTIVITY_LIST_REQ
CCLQueryManagerActivityListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryManagerActivityListREQ"

function CCLQueryManagerActivityListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryManagerActivityListREQ.OP_CODE, serverId, callback)
end

function CCLQueryManagerActivityListREQ:setData(clubId, rankListCount)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().rankListCount = rankListCount;
end

local CLCQueryManagerActivityListRES = class("CLCQueryManagerActivityListRES", ProtocolBase)
ns.CLCQueryManagerActivityListRES = CLCQueryManagerActivityListRES

CLCQueryManagerActivityListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_MANAGER_ACTIVITY_LIST_RES
CLCQueryManagerActivityListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryManagerActivityListRES"

function CLCQueryManagerActivityListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryManagerActivityListRES.OP_CODE, serverId, callback)
end

-- 请求添加亲友圈活动
local CCLAddManagerActivityREQ = class("CCLAddManagerActivityREQ", ProtocolBase)
ns.CCLAddManagerActivityREQ = CCLAddManagerActivityREQ

CCLAddManagerActivityREQ.OP_CODE = net.ProtocolCode.P_CCL_ADD_MANAGER_ACTIVITY_REQ
CCLAddManagerActivityREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLAddManagerActivityREQ"

function CCLAddManagerActivityREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLAddManagerActivityREQ.OP_CODE, serverId, callback)
end

function CCLAddManagerActivityREQ:setData(clubId, title, type, startTime, endTime, minRoomCount)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().title = title;
    self:getProtocolBuf().type = type;
    self:getProtocolBuf().startTime = startTime;
    self:getProtocolBuf().endTime = endTime;
    self:getProtocolBuf().minRoomCount = minRoomCount;
end

local CLCAddManagerActivityRES = class("CLCAddManagerActivityRES", ProtocolBase)
ns.CLCAddManagerActivityRES = CLCAddManagerActivityRES

CLCAddManagerActivityRES.OP_CODE = net.ProtocolCode.P_CLC_ADD_MANAGER_ACTIVITY_RES
CLCAddManagerActivityRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCAddManagerActivityRES"

function CLCAddManagerActivityRES:ctor(serverId, callback)
    self.super.ctor(self, CLCAddManagerActivityRES.OP_CODE, serverId, callback)
end

-- 请求关闭或删除亲友圈活动
local CCLCloseManagerActivityREQ = class("CCLCloseManagerActivityREQ", ProtocolBase)
ns.CCLCloseManagerActivityREQ = CCLCloseManagerActivityREQ

CCLCloseManagerActivityREQ.OP_CODE = net.ProtocolCode.P_CCL_CLOSE_MANAGER_ACTIVITY_REQ
CCLCloseManagerActivityREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCloseManagerActivityREQ"

function CCLCloseManagerActivityREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCloseManagerActivityREQ.OP_CODE, serverId, callback)
end

function CCLCloseManagerActivityREQ:setData(clubId, optype, activityId)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().optype = optype;
    self:getProtocolBuf().activityId = activityId;
end

local CLCCloseManagerActivityRES = class("CLCCloseManagerActivityRES", ProtocolBase)
ns.CLCCloseManagerActivityRES = CLCCloseManagerActivityRES

CLCCloseManagerActivityRES.OP_CODE = net.ProtocolCode.P_CLC_CLOSE_MANAGER_ACTIVITY_RES
CLCCloseManagerActivityRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCloseManagerActivityRES"

function CLCCloseManagerActivityRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCloseManagerActivityRES.OP_CODE, serverId, callback)
end


-- 请求修改玩家备注
local CCLModifyMemberRemarkREQ = class("CCLModifyMemberRemarkREQ", ProtocolBase)
ns.CCLModifyMemberRemarkREQ = CCLModifyMemberRemarkREQ

CCLModifyMemberRemarkREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_MEMBER_REMARK_REQ
CCLModifyMemberRemarkREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyMemberRemarkREQ"

function CCLModifyMemberRemarkREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyMemberRemarkREQ.OP_CODE, serverId, callback)
end

function CCLModifyMemberRemarkREQ:setData(clubId, roleId, remark)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().roleId = roleId;
    self:getProtocolBuf().remark = remark;
end

local CLCModifyMemberRemarkRES = class("CLCModifyMemberRemarkRES", ProtocolBase)
ns.CLCModifyMemberRemarkRES = CLCModifyMemberRemarkRES

CLCModifyMemberRemarkRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_MEMBER_REMARK_RES
CLCModifyMemberRemarkRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyMemberRemarkRES"

function CLCModifyMemberRemarkRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyMemberRemarkRES.OP_CODE, serverId, callback)
end

------------------------------捉鸡寻宝-------------------------------
--请求捉鸡寻宝活动信息
local CCLQueryTreasureInfoREQ = class("CCLQueryTreasureInfoREQ", ProtocolBase)
ns.CCLQueryTreasureInfoREQ = CCLQueryTreasureInfoREQ

CCLQueryTreasureInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_TREASURE_INFO_REQ
CCLQueryTreasureInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryTreasureInfoREQ"

function CCLQueryTreasureInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLQueryTreasureInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryTreasureInfoREQ:setData(opType)
	self:getProtocolBuf().opType = opType;
end

local CLCQueryTreasureInfoRES = class("CLCQueryTreasureInfoRES", ProtocolBase)
ns.CLCQueryTreasureInfoRES = CLCQueryTreasureInfoRES

CLCQueryTreasureInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_TREASURE_INFO_RES
CLCQueryTreasureInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryTreasureInfoRES"

function CLCQueryTreasureInfoRES:ctor(serverId, callback)
	self.super.ctor(self, CLCQueryTreasureInfoRES.OP_CODE, serverId, callback)
end

--请求购买捉鸡寻宝消耗品
local CCLPurchaseCatcherREQ = class("CCLPurchaseCatcherREQ", ProtocolBase)
ns.CCLPurchaseCatcherREQ = CCLPurchaseCatcherREQ

CCLPurchaseCatcherREQ.OP_CODE = net.ProtocolCode.P_CCL_PURCHASE_CATCHER_REQ
CCLPurchaseCatcherREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLPurchaseCatcherREQ"

function CCLPurchaseCatcherREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLPurchaseCatcherREQ.OP_CODE, serverId, callback)
end

function CCLPurchaseCatcherREQ:setData(clubId, purchaseCount)
	self:getProtocolBuf().clubId = clubId;
	self:getProtocolBuf().purchaseCount = purchaseCount;
end

local CLCPurchaseCatcherRES = class("CLCPurchaseCatcherRES", ProtocolBase)
ns.CLCPurchaseCatcherRES = CLCPurchaseCatcherRES

CLCPurchaseCatcherRES.OP_CODE = net.ProtocolCode.P_CLC_PURCHASE_CATCHER_RES
CLCPurchaseCatcherRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCPurchaseCatcherRES"

function CLCPurchaseCatcherRES:ctor(serverId, callback)
	self.super.ctor(self, CLCPurchaseCatcherRES.OP_CODE, serverId, callback)
end


--请求捉鸡寻宝获奖信息
local CCLTreasureRewardInfoREQ = class("CCLTreasureRewardInfoREQ", ProtocolBase)
ns.CCLTreasureRewardInfoREQ = CCLTreasureRewardInfoREQ

CCLTreasureRewardInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_TREASURE_REWARD_INFO_REQ
CCLTreasureRewardInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLTreasureRewardInfoREQ"

function CCLTreasureRewardInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CCLTreasureRewardInfoREQ.OP_CODE, serverId, callback)
end
function CCLTreasureRewardInfoREQ:setData(areaId)
	self:getProtocolBuf().areaId = areaId
end


local CLCTreasureRewardInfoRES = class("CLCTreasureRewardInfoRES", ProtocolBase)
ns.CLCTreasureRewardInfoRES = CLCTreasureRewardInfoRES

CLCTreasureRewardInfoRES.OP_CODE = net.ProtocolCode.P_CLC_TREASURE_REWARD_INFO_RES
CLCTreasureRewardInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCTreasureRewardInfoRES"

function CLCTreasureRewardInfoRES:ctor(serverId, callback)
	self.super.ctor(self, CLCTreasureRewardInfoRES.OP_CODE, serverId, callback)
end

--
local CLCTreasureInfoSYN = class("CLCTreasureInfoSYN", ProtocolBase)
ns.CLCTreasureInfoSYN = CLCTreasureInfoSYN

CLCTreasureInfoSYN.OP_CODE = net.ProtocolCode.P_CLC_TREASURE_INFO_SYN
CLCTreasureInfoSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCTreasureInfoSYN"

function CLCTreasureInfoSYN:ctor(serverId, callback)
	self.super.ctor(self, CLCTreasureInfoSYN.OP_CODE, serverId, callback)
end

-- 排行榜
--  client 向 club 请求俱乐部数据日报信息
local CCLQueryStatisticsInfoREQ = class("CCLQueryStatisticsInfoREQ", ProtocolBase)
ns.CCLQueryStatisticsInfoREQ = CCLQueryStatisticsInfoREQ

CCLQueryStatisticsInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_STATISTICS_INFO_REQ
CCLQueryStatisticsInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryStatisticsInfoREQ"

function CCLQueryStatisticsInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryStatisticsInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryStatisticsInfoREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId;
end

local CLCQueryStatisticsInfoRES = class("CLCQueryStatisticsInfoRES", ProtocolBase)
ns.CLCQueryStatisticsInfoRES = CLCQueryStatisticsInfoRES

CLCQueryStatisticsInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_STATISTICS_INFO_RES
CLCQueryStatisticsInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryStatisticsInfoRES"

function CLCQueryStatisticsInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryStatisticsInfoRES.OP_CODE, serverId, callback)
end

-- client 向 club 请求俱乐部成员排行信息
local CCLQueryMemberRankInfoREQ = class("CCLQueryMemberRankInfoREQ", ProtocolBase)
ns.CCLQueryMemberRankInfoREQ = CCLQueryMemberRankInfoREQ

CCLQueryMemberRankInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_MEMBER_RANK_INFO_REQ
CCLQueryMemberRankInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryMemberRankInfoREQ"

function CCLQueryMemberRankInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryMemberRankInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryMemberRankInfoREQ:setData(clubId, rankType, startTime, endTime, winnerScore)
    self:getProtocolBuf().clubId = clubId;
    self:getProtocolBuf().rankType = rankType;
    self:getProtocolBuf().startTime = startTime;
    self:getProtocolBuf().endTime = endTime;
    self:getProtocolBuf().winnerScore = winnerScore;
end

local CLCQueryMemberRankInfoRES = class("CLCQueryMemberRankInfoRES", ProtocolBase)
ns.CLCQueryMemberRankInfoRES = CLCQueryMemberRankInfoRES

CLCQueryMemberRankInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_MEMBER_RANK_INFO_RES
CLCQueryMemberRankInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryMemberRankInfoRES"

function CLCQueryMemberRankInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryMemberRankInfoRES.OP_CODE, serverId, callback)
end

-- 请求俱乐部房间邀请信息列表
local CCLQueryRoomInvitedMembersREQ = class("CCLQueryRoomInvitedMembersREQ", ProtocolBase)
ns.CCLQueryRoomInvitedMembersREQ = CCLQueryRoomInvitedMembersREQ

CCLQueryRoomInvitedMembersREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_ROOM_INVITED_MEMBERS_REQ
CCLQueryRoomInvitedMembersREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryRoomInvitedMembersREQ"

function CCLQueryRoomInvitedMembersREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryRoomInvitedMembersREQ.OP_CODE, serverId, callback)
end

function CCLQueryRoomInvitedMembersREQ:setData(clubId, roomId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roomId = roomId
end

local CLCQueryRoomInvitedMembersRES = class("CLCQueryRoomInvitedMembersRES", ProtocolBase)
ns.CLCQueryRoomInvitedMembersRES = CLCQueryRoomInvitedMembersRES

CLCQueryRoomInvitedMembersRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_ROOM_INVITED_MEMBERS_RES
CLCQueryRoomInvitedMembersRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryRoomInvitedMembersRES"

function CLCQueryRoomInvitedMembersRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryRoomInvitedMembersRES.OP_CODE, serverId, callback)
end

-- 请求发送俱乐部房间邀请
local CCLSendRoomInvitationREQ = class("CCLSendRoomInvitationREQ", ProtocolBase)
ns.CCLSendRoomInvitationREQ = CCLSendRoomInvitationREQ

CCLSendRoomInvitationREQ.OP_CODE = net.ProtocolCode.P_CCL_SEND_ROOM_INVITATION_REQ
CCLSendRoomInvitationREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLSendRoomInvitationREQ"

function CCLSendRoomInvitationREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLSendRoomInvitationREQ.OP_CODE, serverId, callback)
end

function CCLSendRoomInvitationREQ:setData(clubId, roomId, inviteeId, gameplaysDesc)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roomId = roomId
    self:getProtocolBuf().inviteeId = inviteeId
    self:getProtocolBuf().gameplaysDesc = gameplaysDesc
end

local CLCSendRoomInvitationRES = class("CLCSendRoomInvitationRES", ProtocolBase)
ns.CLCSendRoomInvitationRES = CLCSendRoomInvitationRES

CLCSendRoomInvitationRES.OP_CODE = net.ProtocolCode.P_CLC_SEND_ROOM_INVITATIONS_RES
CLCSendRoomInvitationRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCSendRoomInvitationRES"

function CLCSendRoomInvitationRES:ctor(serverId, callback)
    self.super.ctor(self, CLCSendRoomInvitationRES.OP_CODE, serverId, callback)
end

-- 通知房间邀请信息
local CLCNotifyRoomInvitaitonSYN = class("CLCNotifyRoomInvitaitonSYN", ProtocolBase)
ns.CLCNotifyRoomInvitaitonSYN = CLCNotifyRoomInvitaitonSYN

CLCNotifyRoomInvitaitonSYN.OP_CODE = net.ProtocolCode.P_CLC_NOTIFY_ROOM_INVITATION_SYN
CLCNotifyRoomInvitaitonSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCNotifyRoomInvitaitonSYN"

function CLCNotifyRoomInvitaitonSYN:ctor(serverId, callback)
	self.super.ctor(self, CLCNotifyRoomInvitaitonSYN.OP_CODE, serverId, callback)
end

--------------------------------- 俱乐部小组 ---------------------------------------------
local CCLQueryClubGroupListREQ = class("CCLQueryClubGroupListREQ", ProtocolBase)
ns.CCLQueryClubGroupListREQ = CCLQueryClubGroupListREQ

CCLQueryClubGroupListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_GROUP_LIST_REQ
CCLQueryClubGroupListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubGroupListREQ"

function CCLQueryClubGroupListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubGroupListREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubGroupListREQ:setData(clubId, startTime, endTime)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().startTime = startTime
    self:getProtocolBuf().endTime = endTime
end

local CLCQueryClubGroupListRES = class("CLCQueryClubGroupListRES", ProtocolBase)
ns.CLCQueryClubGroupListRES = CLCQueryClubGroupListRES

CLCQueryClubGroupListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_GROUP_LIST_RES
CLCQueryClubGroupListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubGroupListRES"

function CLCQueryClubGroupListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubGroupListRES.OP_CODE, serverId, callback)
end

local CCLCheckCreateGroupREQ = class("CCLCheckCreateGroupREQ", ProtocolBase)
ns.CCLCheckCreateGroupREQ = CCLCheckCreateGroupREQ

CCLCheckCreateGroupREQ.OP_CODE = net.ProtocolCode.P_CCL_CHECK_CREATE_GROUP_REQ
CCLCheckCreateGroupREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCheckCreateGroupREQ"

function CCLCheckCreateGroupREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCheckCreateGroupREQ.OP_CODE, serverId, callback)
end

function CCLCheckCreateGroupREQ:setData(clubId, groupName, leaderId, minScore)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupName = groupName
    self:getProtocolBuf().leaderId = leaderId
    self:getProtocolBuf().minScore = minScore
end

local CLCCheckCreateGroupRES = class("CLCCheckCreateGroupRES", ProtocolBase)
ns.CLCCheckCreateGroupRES = CLCCheckCreateGroupRES

CLCCheckCreateGroupRES.OP_CODE = net.ProtocolCode.P_CLC_CHECK_CREATE_GROUP_RES
CLCCheckCreateGroupRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCheckCreateGroupRES"

function CLCCheckCreateGroupRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCheckCreateGroupRES.OP_CODE, serverId, callback)
end

local CCLCreateClubGroupREQ = class("CCLCreateClubGroupREQ", ProtocolBase)
ns.CCLCreateClubGroupREQ = CCLCreateClubGroupREQ

CCLCreateClubGroupREQ.OP_CODE = net.ProtocolCode.P_CCL_CREATE_CLUB_GROUP_REQ
CCLCreateClubGroupREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCreateClubGroupREQ"

function CCLCreateClubGroupREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCreateClubGroupREQ.OP_CODE, serverId, callback)
end

function CCLCreateClubGroupREQ:setData(clubId, groupName, leaderId, minScore)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupName = groupName
    self:getProtocolBuf().leaderId = leaderId
    self:getProtocolBuf().minScore = minScore
end

local CLCCreateClubGroupRES = class("CLCCreateClubGroupRES", ProtocolBase)
ns.CLCCreateClubGroupRES = CLCCreateClubGroupRES

CLCCreateClubGroupRES.OP_CODE = net.ProtocolCode.P_CLC_CREATE_CLUB_GROUP_RES
CLCCreateClubGroupRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCreateClubGroupRES"

function CLCCreateClubGroupRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCreateClubGroupRES.OP_CODE, serverId, callback)
end

local CCLDeleteClubGroupREQ = class("CCLDeleteClubGroupREQ", ProtocolBase)
ns.CCLDeleteClubGroupREQ = CCLDeleteClubGroupREQ

CCLDeleteClubGroupREQ.OP_CODE = net.ProtocolCode.P_CCL_DELETE_CLUB_GROUP_REQ
CCLDeleteClubGroupREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLDeleteClubGroupREQ"

function CCLDeleteClubGroupREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLDeleteClubGroupREQ.OP_CODE, serverId, callback)
end

function CCLDeleteClubGroupREQ:setData(clubId, groupId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupId = groupId

end

local CLCDeleteClubGroupRES = class("CLCDeleteClubGroupRES", ProtocolBase)
ns.CLCDeleteClubGroupRES = CLCDeleteClubGroupRES

CLCDeleteClubGroupRES.OP_CODE = net.ProtocolCode.P_CLC_DELETE_CLUB_GROUP_RES
CLCDeleteClubGroupRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCDeleteClubGroupRES"

function CLCDeleteClubGroupRES:ctor(serverId, callback)
    self.super.ctor(self, CLCDeleteClubGroupRES.OP_CODE, serverId, callback)
end

local CCLModifyClubGroupREQ = class("CCLModifyClubGroupREQ", ProtocolBase)
ns.CCLModifyClubGroupREQ = CCLModifyClubGroupREQ

CCLModifyClubGroupREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_CLUB_GROUP_REQ
CCLModifyClubGroupREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyClubGroupREQ"

function CCLModifyClubGroupREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyClubGroupREQ.OP_CODE, serverId, callback)
end

function CCLModifyClubGroupREQ:setData(clubId, groupId, groupName, minWinnerScore)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupId = groupId
    self:getProtocolBuf().groupName = groupName
    self:getProtocolBuf().minWinnerScore = minWinnerScore
end

local CLCModifyClubGroupRES = class("CLCModifyClubGroupRES", ProtocolBase)
ns.CLCModifyClubGroupRES = CLCModifyClubGroupRES

CLCModifyClubGroupRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_CLUB_GROUP_RES
CLCModifyClubGroupRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyClubGroupRES"

function CLCModifyClubGroupRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyClubGroupRES.OP_CODE, serverId, callback)
end

local CCLQueryGroupMembersREQ = class("CCLQueryGroupMembersREQ", ProtocolBase)
ns.CCLQueryGroupMembersREQ = CCLQueryGroupMembersREQ

CCLQueryGroupMembersREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_GROUP_MEMBERS_REQ
CCLQueryGroupMembersREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryGroupMembersREQ"

function CCLQueryGroupMembersREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryGroupMembersREQ.OP_CODE, serverId, callback)
end

function CCLQueryGroupMembersREQ:setData(clubId, groupId, startTime, endTime)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupId = groupId
    self:getProtocolBuf().startTime = startTime
    self:getProtocolBuf().endTime = endTime
end

local CLCQueryGroupMembersRES = class("CLCQueryGroupMembersRES", ProtocolBase)
ns.CLCQueryGroupMembersRES = CLCQueryGroupMembersRES

CLCQueryGroupMembersRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_GROUP_MEMBERS_RES
CLCQueryGroupMembersRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryGroupMembersRES"

function CLCQueryGroupMembersRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryGroupMembersRES.OP_CODE, serverId, callback)
end

local CCLQueryImportClubInfoREQ = class("CCLQueryImportClubInfoREQ", ProtocolBase)
ns.CCLQueryImportClubInfoREQ = CCLQueryImportClubInfoREQ

CCLQueryImportClubInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_IMPORT_CLUB_INFO_REQ
CCLQueryImportClubInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryImportClubInfoREQ"

function CCLQueryImportClubInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryImportClubInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryImportClubInfoREQ:setData(clubId, leaderId, leagueId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().leaderId = leaderId
    self:getProtocolBuf().leagueId = leagueId
end

local CLCQueryImportClubInfoRES = class("CLCQueryImportClubInfoRES", ProtocolBase)
ns.CLCQueryImportClubInfoRES = CLCQueryImportClubInfoRES

CLCQueryImportClubInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_IMPORT_CLUB_INFO_RES
CLCQueryImportClubInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryImportClubInfoRES"

function CLCQueryImportClubInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryImportClubInfoRES.OP_CODE, serverId, callback)
end

local CCLImportGroupMemberREQ = class("CCLImportGroupMemberREQ", ProtocolBase)
ns.CCLImportGroupMemberREQ = CCLImportGroupMemberREQ

CCLImportGroupMemberREQ.OP_CODE = net.ProtocolCode.P_CCL_IMPORT_GROUP_MEMBER_REQ
CCLImportGroupMemberREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLImportGroupMemberREQ"

function CCLImportGroupMemberREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLImportGroupMemberREQ.OP_CODE, serverId, callback)
end

function CCLImportGroupMemberREQ:setData(groupId, leagueId, targetClubId, sourceClubId, importRoleList)
    self:getProtocolBuf().groupId = groupId
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().targetClubId = targetClubId
    self:getProtocolBuf().sourceClubId = sourceClubId
    self:getProtocolBuf().importRoleList = importRoleList
end

local CLCImportGroupMemberRES = class("CLCImportGroupMemberRES", ProtocolBase)
ns.CLCImportGroupMemberRES = CLCImportGroupMemberRES

CLCImportGroupMemberRES.OP_CODE = net.ProtocolCode.P_CLC_IMPORT_GROUP_MEMBER_RES
CLCImportGroupMemberRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCImportGroupMemberRES"

function CLCImportGroupMemberRES:ctor(serverId, callback)
    self.super.ctor(self, CLCImportGroupMemberRES.OP_CODE, serverId, callback)
end

local CCLQueryGroupInfoREQ = class("CCLQueryGroupInfoREQ", ProtocolBase)
ns.CCLQueryGroupInfoREQ = CCLQueryGroupInfoREQ

CCLQueryGroupInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_GROUP_INFO_REQ
CCLQueryGroupInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryGroupInfoREQ"

function CCLQueryGroupInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryGroupInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryGroupInfoREQ:setData(clubId, groupId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().groupId = groupId
end

local CLCQueryGroupInfoRES = class("CLCQueryGroupInfoRES", ProtocolBase)
ns.CLCQueryGroupInfoRES = CLCQueryGroupInfoRES

CLCQueryGroupInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_GROUP_INFO_RES
CLCQueryGroupInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryGroupInfoRES"

function CLCQueryGroupInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryGroupInfoRES.OP_CODE, serverId, callback)
end

local CCLQueryFirstCreateAwardREQ = class("CCLQueryFirstCreateAwardREQ", ProtocolBase)
ns.CCLQueryFirstCreateAwardREQ = CCLQueryFirstCreateAwardREQ
CCLQueryFirstCreateAwardREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_FIRST_CREATE_AWARD_REQ
CCLQueryFirstCreateAwardREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryFirstCreateAwardREQ"
function CCLQueryFirstCreateAwardREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryFirstCreateAwardREQ.OP_CODE, serverId, callback)
end

local CLCQueryFirstCreateAwardRES = class("CLCQueryFirstCreateAwardRES", ProtocolBase)
ns.CLCQueryFirstCreateAwardRES = CLCQueryFirstCreateAwardRES
CLCQueryFirstCreateAwardRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_FIRST_CREATE_AWARD_RES
CLCQueryFirstCreateAwardRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryFirstCreateAwardRES"
function CLCQueryFirstCreateAwardRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryFirstCreateAwardRES.OP_CODE, serverId, callback)
end

local CCLSendRoomInvitedResultREQ = class("CCLSendRoomInvitedResultREQ", ProtocolBase)
ns.CCLSendRoomInvitedResultREQ = CCLSendRoomInvitedResultREQ

CCLSendRoomInvitedResultREQ.OP_CODE = net.ProtocolCode.P_CCL_SEND_ROOM_INVITED_RESULT_REQ
CCLSendRoomInvitedResultREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLSendRoomInvitedResultREQ"

function CCLSendRoomInvitedResultREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLSendRoomInvitedResultREQ.OP_CODE, serverId, callback)
end

function CCLSendRoomInvitedResultREQ:setData(clubId, roomId, opType, areaId, inviterId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roomId = roomId
    self:getProtocolBuf().opType = opType
    self:getProtocolBuf().areaId = areaId
    self:getProtocolBuf().inviterId = inviterId
end

local CLCSendRoomInvitedResultRES = class("CLCSendRoomInvitedResultRES", ProtocolBase)
ns.CLCSendRoomInvitedResultRES = CLCSendRoomInvitedResultRES

CLCSendRoomInvitedResultRES.OP_CODE = net.ProtocolCode.P_CLC_SEND_ROOM_INVITED_RESULT_RES
CLCSendRoomInvitedResultRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCSendRoomInvitedResultRES"

function CLCSendRoomInvitedResultRES:ctor(serverId, callback)
    self.super.ctor(self, CLCSendRoomInvitedResultRES.OP_CODE, serverId, callback)
end

local CCLQueryClubRankListREQ = class("CCLQueryClubRankListREQ", ProtocolBase)
ns.CCLQueryClubRankListREQ = CCLQueryClubRankListREQ

CCLQueryClubRankListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_RANK_LIST_REQ
CCLQueryClubRankListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubRankListREQ"

function CCLQueryClubRankListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubRankListREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubRankListREQ:setData(opType)
    self:getProtocolBuf().opType = opType
end

local CLCQueryClubRankListRES = class("CLCQueryClubRankListRES", ProtocolBase)
ns.CLCQueryClubRankListRES = CLCQueryClubRankListRES

CLCQueryClubRankListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_RANK_LIST_RES
CLCQueryClubRankListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubRankListRES"

function CLCQueryClubRankListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubRankListRES.OP_CODE, serverId, callback)
end

local CCLQueryClubRankInfoREQ = class("CCLQueryClubRankInfoREQ", ProtocolBase)
ns.CCLQueryClubRankInfoREQ = CCLQueryClubRankInfoREQ

CCLQueryClubRankInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_RANK_INFO_REQ
CCLQueryClubRankInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubRankInfoREQ"

function CCLQueryClubRankInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubRankInfoREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubRankInfoREQ:setData(clubId, rankType)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().rankType = rankType
end

local CLCQueryClubRankInfoRES = class("CLCQueryClubRankInfoRES", ProtocolBase)
ns.CLCQueryClubRankInfoRES = CLCQueryClubRankInfoRES

CLCQueryClubRankInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_RANK_INFO_RES
CLCQueryClubRankInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubRankInfoRES"

function CLCQueryClubRankInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubRankInfoRES.OP_CODE, serverId, callback)
end

local CCLQueryRankRewardListREQ = class("CCLQueryRankRewardListREQ", ProtocolBase)
ns.CCLQueryRankRewardListREQ = CCLQueryRankRewardListREQ

CCLQueryRankRewardListREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_RANK_REWARD_LIST_REQ
CCLQueryRankRewardListREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryRankRewardListREQ"

function CCLQueryRankRewardListREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryRankRewardListREQ.OP_CODE, serverId, callback)
end

function CCLQueryRankRewardListREQ:setData(opType)
    self:getProtocolBuf().opType = opType
end

local CLCQueryRankRewardListRES = class("CLCQueryRankRewardListRES", ProtocolBase)
ns.CLCQueryRankRewardListRES = CLCQueryRankRewardListRES

CLCQueryRankRewardListRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_RANK_REWARD_LIST_RES
CLCQueryRankRewardListRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryRankRewardListRES"

function CLCQueryRankRewardListRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryRankRewardListRES.OP_CODE, serverId, callback)
end

local CCLPickClubRankRewardREQ = class("CCLPickClubRankRewardREQ", ProtocolBase)
ns.CCLPickClubRankRewardREQ = CCLPickClubRankRewardREQ

CCLPickClubRankRewardREQ.OP_CODE = net.ProtocolCode.P_CCL_PICK_CLUB_RANK_REWARD_REQ
CCLPickClubRankRewardREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLPickClubRankRewardREQ"

function CCLPickClubRankRewardREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLPickClubRankRewardREQ.OP_CODE, serverId, callback)
end

function CCLPickClubRankRewardREQ:setData(clubId, opType, rankType)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().opType = opType
    self:getProtocolBuf().rankType = rankType
end

local CLCPickClubRankRewardRES = class("CLCPickClubRankRewardRES", ProtocolBase)
ns.CLCPickClubRankRewardRES = CLCPickClubRankRewardRES

CLCPickClubRankRewardRES.OP_CODE = net.ProtocolCode.P_CLC_PICK_CLUB_RANK_REWARD_RES
CLCPickClubRankRewardRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCPickClubRankRewardRES"

function CLCPickClubRankRewardRES:ctor(serverId, callback)
    self.super.ctor(self, CLCPickClubRankRewardRES.OP_CODE, serverId, callback)
end

local CCLQueryMemberInfosForGroupREQ = class("CCLQueryMemberInfosForGroupREQ", ProtocolBase)
ns.CCLQueryMemberInfosForGroupREQ = CCLQueryMemberInfosForGroupREQ

CCLQueryMemberInfosForGroupREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_MEMBER_INFOS_FOR_GROUP_REQ
CCLQueryMemberInfosForGroupREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryMemberInfosForGroupREQ"

function CCLQueryMemberInfosForGroupREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryMemberInfosForGroupREQ.OP_CODE, serverId, callback)
end

function CCLQueryMemberInfosForGroupREQ:setData(clubId)
    self:getProtocolBuf().clubId = clubId
end

local CLCQueryMemberInfosForGroupRES = class("CLCQueryMemberInfosForGroupRES", ProtocolBase)
ns.CLCQueryMemberInfosForGroupRES = CLCQueryMemberInfosForGroupRES

CLCQueryMemberInfosForGroupRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_MEMBER_INFOS_FOR_GROUP_RES
CLCQueryMemberInfosForGroupRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryMemberInfosForGroupRES"

function CLCQueryMemberInfosForGroupRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryMemberInfosForGroupRES.OP_CODE, serverId, callback)
end

local CCLModifyGroupMemberREQ = class("CCLModifyGroupMemberREQ", ProtocolBase)
ns.CCLModifyGroupMemberREQ = CCLModifyGroupMemberREQ

CCLModifyGroupMemberREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_GROUP_MEMBER_REQ
CCLModifyGroupMemberREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyGroupMemberREQ"

function CCLModifyGroupMemberREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyGroupMemberREQ.OP_CODE, serverId, callback)
end

function CCLModifyGroupMemberREQ:setData(clubId, opType, memberId, groupId)
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().opType = opType
    self:getProtocolBuf().memberId = memberId
    self:getProtocolBuf().groupId = groupId
end

local CLCModifyGroupMemberRES = class("CLCModifyGroupMemberRES", ProtocolBase)
ns.CLCModifyGroupMemberRES = CLCModifyGroupMemberRES

CLCModifyGroupMemberRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_GROUP_MEMBER_RES
CLCModifyGroupMemberRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyGroupMemberRES"

function CLCModifyGroupMemberRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyGroupMemberRES.OP_CODE, serverId, callback)
end

local CCLUpdateOfflineInvitedSwitchREQ = class("CCLUpdateOfflineInvitedSwitchREQ", ProtocolBase)
ns.CCLUpdateOfflineInvitedSwitchREQ = CCLUpdateOfflineInvitedSwitchREQ

CCLUpdateOfflineInvitedSwitchREQ.OP_CODE = net.ProtocolCode.P_CCL_UPDATE_OFFLINE_INVITED_SWITCH_REQ
CCLUpdateOfflineInvitedSwitchREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLUpdateOfflineInvitedSwitchREQ"

function CCLUpdateOfflineInvitedSwitchREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLUpdateOfflineInvitedSwitchREQ.OP_CODE, serverId, callback)
end

function CCLUpdateOfflineInvitedSwitchREQ:setData(switchStatus)
    self:getProtocolBuf().switchStatus = switchStatus
end

local CLCUpdateOfflineInvitedSwitchRES = class("CLCUpdateOfflineInvitedSwitchRES", ProtocolBase)
ns.CLCUpdateOfflineInvitedSwitchRES = CLCUpdateOfflineInvitedSwitchRES

CLCUpdateOfflineInvitedSwitchRES.OP_CODE = net.ProtocolCode.P_CLC_UPDATE_OFFLINE_INVITED_SWITCHT_RES
CLCUpdateOfflineInvitedSwitchRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCUpdateOfflineInvitedSwitchRES"

function CLCUpdateOfflineInvitedSwitchRES:ctor(serverId, callback)
    self.super.ctor(self, CLCUpdateOfflineInvitedSwitchRES.OP_CODE, serverId, callback)
end

local CCLQueryClubInfosREQ = class("CCLQueryClubInfosREQ", ProtocolBase)
ns.CCLQueryClubInfosREQ = CCLQueryClubInfosREQ

CCLQueryClubInfosREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_INFOS_REQ
CCLQueryClubInfosREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubInfosREQ"

function CCLQueryClubInfosREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubInfosREQ.OP_CODE, serverId, callback)
end

local CLCQueryClubInfosRES = class("CLCQueryClubInfosRES", ProtocolBase)
ns.CLCQueryClubInfosRES = CLCQueryClubInfosRES

CLCQueryClubInfosRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_INFOS_RES
CLCQueryClubInfosRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubInfosRES"

function CLCQueryClubInfosRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubInfosRES.OP_CODE, serverId, callback)
end