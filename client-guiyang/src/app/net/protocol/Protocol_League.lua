local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

----------------------------------------------------------------------------------------------
---------------------------------------  联盟  -----------------------------------------------
----------------------------------------------------------------------------------------------
-- 请求联盟信息
local CCLQueryLeagueREQ = class("CCLQueryLeagueREQ", ProtocolBase)
ns.CCLQueryLeagueREQ = CCLQueryLeagueREQ
CCLQueryLeagueREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_REQ
CCLQueryLeagueREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueREQ"
function CCLQueryLeagueREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeagueREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCQueryLeagueRES = class("CLCQueryLeagueRES", ProtocolBase)
ns.CLCQueryLeagueRES = CLCQueryLeagueRES
CLCQueryLeagueRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_RES
CLCQueryLeagueRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueRES"
function CLCQueryLeagueRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueRES.OP_CODE, serverId, callback)
end

-- 请求查看大联盟玩法
local CCLQueryLeagueGameplayREQ = class("CCLQueryLeagueGameplayREQ", ProtocolBase)
ns.CCLQueryLeagueGameplayREQ = CCLQueryLeagueGameplayREQ
CCLQueryLeagueGameplayREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_GAMEPLAY_REQ
CCLQueryLeagueGameplayREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueGameplayREQ"
function CCLQueryLeagueGameplayREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueGameplayREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeagueGameplayREQ:setData(leagueId, clubId, partnerId, removeZeroCost, title, type)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
    self:getProtocolBuf().removeZeroCost = removeZeroCost
    self:getProtocolBuf().title = title
    self:getProtocolBuf().type = type
end

local CLCQueryLeagueGameplayRES = class("CLCQueryLeagueGameplayRES", ProtocolBase)
ns.CLCQueryLeagueGameplayRES = CLCQueryLeagueGameplayRES
CLCQueryLeagueGameplayRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_GAMEPLAY_RES
CLCQueryLeagueGameplayRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueGameplayRES"
function CLCQueryLeagueGameplayRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueGameplayRES.OP_CODE, serverId, callback)
end

-- 请求修改大联盟玩法
local CCLModifyLeagueGameplayREQ = class("CCLModifyLeagueGameplayREQ", ProtocolBase)
ns.CCLModifyLeagueGameplayREQ = CCLModifyLeagueGameplayREQ
CCLModifyLeagueGameplayREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_LEAGUE_GAMEPLAY_REQ
CCLModifyLeagueGameplayREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyLeagueGameplayREQ"
function CCLModifyLeagueGameplayREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyLeagueGameplayREQ.OP_CODE, serverId, callback)
end

function CCLModifyLeagueGameplayREQ:setData(leagueId, id, gameplay)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().id = id
    self:getProtocolBuf().gameplay = gameplay
end

local CLCModifyLeagueGameplayRES = class("CLCModifyLeagueGameplayRES", ProtocolBase)
ns.CLCModifyLeagueGameplayRES = CLCModifyLeagueGameplayRES
CLCModifyLeagueGameplayRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_LEAGUE_GAMEPLAY_RES
CLCModifyLeagueGameplayRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyLeagueGameplayRES"
function CLCModifyLeagueGameplayRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyLeagueGameplayRES.OP_CODE, serverId, callback)
end

-- 请求删除大联盟玩法
local CCLDeleteLeagueGameplayREQ = class("CCLDeleteLeagueGameplayREQ", ProtocolBase)
ns.CCLDeleteLeagueGameplayREQ = CCLDeleteLeagueGameplayREQ
CCLDeleteLeagueGameplayREQ.OP_CODE = net.ProtocolCode.P_CCL_DELETE_LEAGUE_GAMEPLAY_REQ
CCLDeleteLeagueGameplayREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLDeleteLeagueGameplayREQ"
function CCLDeleteLeagueGameplayREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLDeleteLeagueGameplayREQ.OP_CODE, serverId, callback)
end

function CCLDeleteLeagueGameplayREQ:setData(leagueId, id)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().id = id
end

local CLCDeleteLeagueGameplayRES = class("CLCDeleteLeagueGameplayRES", ProtocolBase)
ns.CLCDeleteLeagueGameplayRES = CLCDeleteLeagueGameplayRES
CLCDeleteLeagueGameplayRES.OP_CODE = net.ProtocolCode.P_CLC_DELETE_LEAGUE_GAMEPLAY_RES
CLCDeleteLeagueGameplayRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCDeleteLeagueGameplayRES"
function CLCDeleteLeagueGameplayRES:ctor(serverId, callback)
    self.super.ctor(self, CLCDeleteLeagueGameplayRES.OP_CODE, serverId, callback)
end

-- 请求查看大联盟排行榜
local CCLQueryLeagueRankREQ = class("CCLQueryLeagueRankREQ", ProtocolBase)
ns.CCLQueryLeagueRankREQ = CCLQueryLeagueRankREQ
CCLQueryLeagueRankREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_RANK_REQ
CCLQueryLeagueRankREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueRankREQ"
function CCLQueryLeagueRankREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueRankREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeagueRankREQ:setData(leagueId, clubId, operatorType, date)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().operatorType = operatorType
    self:getProtocolBuf().date = date
end

local CLCQueryLeagueRankRES = class("CLCQueryLeagueRankRES", ProtocolBase)
ns.CLCQueryLeagueRankRES = CLCQueryLeagueRankRES
CLCQueryLeagueRankRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_RANK_RES
CLCQueryLeagueRankRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueRankRES"
function CLCQueryLeagueRankRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueRankRES.OP_CODE, serverId, callback)
end

-- 请求点赞
local CCLClickLikeREQ = class("CCLClickLikeREQ", ProtocolBase)
ns.CCLClickLikeREQ = CCLClickLikeREQ
CCLClickLikeREQ.OP_CODE = net.ProtocolCode.P_CCL_CLICK_LIKE_REQ
CCLClickLikeREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLClickLikeREQ"
function CCLClickLikeREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLClickLikeREQ.OP_CODE, serverId, callback)
end

function CCLClickLikeREQ:setData(leagueId, clubId, date, like)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().date = date
    self:getProtocolBuf().like = like
end

local CLCClickLikeRES = class("CLCClickLikeRES", ProtocolBase)
ns.CLCClickLikeRES = CLCClickLikeRES
CLCClickLikeRES.OP_CODE = net.ProtocolCode.P_CLC_CLICK_LIKE_RES
CLCClickLikeRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCClickLikeRES"
function CLCClickLikeRES:ctor(serverId, callback)
    self.super.ctor(self, CLCClickLikeRES.OP_CODE, serverId, callback)
end

-- 请求查看联盟列表
local CCLQueryLeaguesREQ = class("CCLQueryLeaguesREQ", ProtocolBase)
ns.CCLQueryLeaguesREQ = CCLQueryLeaguesREQ
CCLQueryLeaguesREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUES_REQ
CCLQueryLeaguesREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeaguesREQ"
function CCLQueryLeaguesREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeaguesREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeaguesREQ:setData(leagueId)
    self:getProtocolBuf().leagueId = leagueId
end

local CLCQueryLeaguesRES = class("CLCQueryLeaguesRES", ProtocolBase)
ns.CLCQueryLeaguesRES = CLCQueryLeaguesRES
CLCQueryLeaguesRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUES_RES
CLCQueryLeaguesRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeaguesRES"
function CLCQueryLeaguesRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeaguesRES.OP_CODE, serverId, callback)
end

-- 请求修改联盟信息
local CCLModifyLeagueREQ = class("CCLModifyLeagueREQ", ProtocolBase)
ns.CCLModifyLeagueREQ = CCLModifyLeagueREQ
CCLModifyLeagueREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_LEAGUE_REQ
CCLModifyLeagueREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyLeagueREQ"
function CCLModifyLeagueREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyLeagueREQ.OP_CODE, serverId, callback)
end

function CCLModifyLeagueREQ:setData(leagueId, clubId, currentScore, fireScoreRate, remark)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().currentScore = currentScore
    self:getProtocolBuf().fireScoreRate = fireScoreRate
    self:getProtocolBuf().remark = remark
end

local CLCModifyLeagueRES = class("CLCModifyLeagueRES", ProtocolBase)
ns.CLCModifyLeagueRES = CLCModifyLeagueRES
CLCModifyLeagueRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_LEAGUE_RES
CLCModifyLeagueRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyLeagueRES"
function CLCModifyLeagueRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyLeagueRES.OP_CODE, serverId, callback)
end

-- 请求暂停比赛
local CCLPauseGameREQ = class("CCLPauseGameREQ", ProtocolBase)
ns.CCLPauseGameREQ = CCLPauseGameREQ
CCLPauseGameREQ.OP_CODE = net.ProtocolCode.P_CCL_PAUSE_GAME_REQ
CCLPauseGameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLPauseGameREQ"
function CCLPauseGameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLPauseGameREQ.OP_CODE, serverId, callback)
end

function CCLPauseGameREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCPauseGameRES = class("CLCPauseGameRES", ProtocolBase)
ns.CLCPauseGameRES = CLCPauseGameRES
CLCPauseGameRES.OP_CODE = net.ProtocolCode.P_CLC_PAUSE_GAME_RES
CLCPauseGameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCPauseGameRES"
function CLCPauseGameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCPauseGameRES.OP_CODE, serverId, callback)
end

-- 请求恢复比赛
local CCLRestoreGameREQ = class("CCLRestoreGameREQ", ProtocolBase)
ns.CCLRestoreGameREQ = CCLRestoreGameREQ
CCLRestoreGameREQ.OP_CODE = net.ProtocolCode.P_CCL_RESOTRE_GAME_REQ
CCLRestoreGameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLRestoreGameREQ"
function CCLRestoreGameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLRestoreGameREQ.OP_CODE, serverId, callback)
end

function CCLRestoreGameREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCRestoreGameRES = class("CLCRestoreGameRES", ProtocolBase)
ns.CLCRestoreGameRES = CLCRestoreGameRES
CLCRestoreGameRES.OP_CODE = net.ProtocolCode.P_CLC_RESOTRE_GAME_RES
CLCRestoreGameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCRestoreGameRES"
function CLCRestoreGameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCRestoreGameRES.OP_CODE, serverId, callback)
end

-- 请求强制退赛
local CCLForceQuitGameREQ = class("CCLForceQuitGameREQ", ProtocolBase)
ns.CCLForceQuitGameREQ = CCLForceQuitGameREQ
CCLForceQuitGameREQ.OP_CODE = net.ProtocolCode.P_CCL_FORCE_QUIT_GAME_REQ
CCLForceQuitGameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLForceQuitGameREQ"
function CCLForceQuitGameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLForceQuitGameREQ.OP_CODE, serverId, callback)
end

function CCLForceQuitGameREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCForceQuitGameRES = class("CLCForceQuitGameRES", ProtocolBase)
ns.CLCForceQuitGameRES = CLCForceQuitGameRES
CLCForceQuitGameRES.OP_CODE = net.ProtocolCode.P_CLC_FORCE_QUIT_GAME_RES
CLCForceQuitGameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCForceQuitGameRES"
function CLCForceQuitGameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCForceQuitGameRES.OP_CODE, serverId, callback)
end

-- 请求联盟动态
local CCLQueryTrendREQ = class("CCLQueryTrendREQ", ProtocolBase)
ns.CCLQueryTrendREQ = CCLQueryTrendREQ
CCLQueryTrendREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_TREND_REQ
CCLQueryTrendREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryTrendREQ"
function CCLQueryTrendREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryTrendREQ.OP_CODE, serverId, callback)
end

function CCLQueryTrendREQ:setData(leagueId, clubId, title)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().title = title
end

local CLCQueryTrendRES = class("CLCQueryTrendRES", ProtocolBase)
ns.CLCQueryTrendRES = CLCQueryTrendRES
CLCQueryTrendRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_TREND_RES
CLCQueryTrendRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryTrendRES"
function CLCQueryTrendRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryTrendRES.OP_CODE, serverId, callback)
end

-- 请求审批列表
local CCLQueryApprovalREQ = class("CCLQueryApprovalREQ", ProtocolBase)
ns.CCLQueryApprovalREQ = CCLQueryApprovalREQ
CCLQueryApprovalREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_APPROVAL_REQ
CCLQueryApprovalREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryApprovalREQ"
function CCLQueryApprovalREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryApprovalREQ.OP_CODE, serverId, callback)
end

function CCLQueryApprovalREQ:setData(leagueId)
    self:getProtocolBuf().leagueId = leagueId
end

local CLCQueryApprovalRES = class("CLCQueryApprovalRES", ProtocolBase)
ns.CLCQueryApprovalRES = CLCQueryApprovalRES
CLCQueryApprovalRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_APPROVAL_RES
CLCQueryApprovalRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryApprovalRES"
function CLCQueryApprovalRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryApprovalRES.OP_CODE, serverId, callback)
end

-- 请求操作审批
local CCLApprovalREQ = class("CCLApprovalREQ", ProtocolBase)
ns.CCLApprovalREQ = CCLApprovalREQ
CCLApprovalREQ.OP_CODE = net.ProtocolCode.P_CCL_APPROVAL_REQ
CCLApprovalREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLApprovalREQ"
function CCLApprovalREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLApprovalREQ.OP_CODE, serverId, callback)
end

function CCLApprovalREQ:setData(leagueId, clubId, agree)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().agree = agree
end

local CLCApprovalRES = class("CLCApprovalRES", ProtocolBase)
ns.CLCApprovalRES = CLCApprovalRES
CLCApprovalRES.OP_CODE = net.ProtocolCode.P_CLC_APPROVAL_RES
CLCApprovalRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCApprovalRES"
function CLCApprovalRES:ctor(serverId, callback)
    self.super.ctor(self, CLCApprovalRES.OP_CODE, serverId, callback)
end

-- 请求修改联盟名称
local CCLModifyLeagueNameREQ = class("CCLModifyLeagueNameREQ", ProtocolBase)
ns.CCLModifyLeagueNameREQ = CCLModifyLeagueNameREQ
CCLModifyLeagueNameREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_LEAGUE_NAME_REQ
CCLModifyLeagueNameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyLeagueNameREQ"
function CCLModifyLeagueNameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyLeagueNameREQ.OP_CODE, serverId, callback)
end

function CCLModifyLeagueNameREQ:setData(leagueId, name)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().name = name
end

local CLCModifyLeagueNameRES = class("CLCModifyLeagueNameRES", ProtocolBase)
ns.CLCModifyLeagueNameRES = CLCModifyLeagueNameRES
CLCModifyLeagueNameRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_LEAGUE_NAME_RES
CLCModifyLeagueNameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyLeagueNameRES"
function CLCModifyLeagueNameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyLeagueNameRES.OP_CODE, serverId, callback)
end

-- 请求参赛大联盟
local CCLQueryJoinLeagueREQ = class("CCLQueryJoinLeagueREQ", ProtocolBase)
ns.CCLQueryJoinLeagueREQ = CCLQueryJoinLeagueREQ
CCLQueryJoinLeagueREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_JOIN_LEAGUE_REQ
CCLQueryJoinLeagueREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryJoinLeagueREQ"
function CCLQueryJoinLeagueREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryJoinLeagueREQ.OP_CODE, serverId, callback)
end

function CCLQueryJoinLeagueREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCQueryJoinLeagueRES = class("CLCQueryJoinLeagueRES", ProtocolBase)
ns.CLCQueryJoinLeagueRES = CLCQueryJoinLeagueRES
CLCQueryJoinLeagueRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_JOIN_LEAGUE_RES
CLCQueryJoinLeagueRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryJoinLeagueRES"
function CLCQueryJoinLeagueRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryJoinLeagueRES.OP_CODE, serverId, callback)
end

-- 请求成员信息
local CCLQueryMembersREQ = class("CCLQueryMembersREQ", ProtocolBase)
ns.CCLQueryMembersREQ = CCLQueryMembersREQ
CCLQueryMembersREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_MEMBERS_REQ
CCLQueryMembersREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryMembersREQ"
function CCLQueryMembersREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryMembersREQ.OP_CODE, serverId, callback)
end

function CCLQueryMembersREQ:setData(leagueId, clubId, days, type, title, partnerId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().days = days
    self:getProtocolBuf().type = type
    self:getProtocolBuf().title = title
    self:getProtocolBuf().partnerId = partnerId
end

local CLCQueryMembersRES = class("CLCQueryMembersRES", ProtocolBase)
ns.CLCQueryMembersRES = CLCQueryMembersRES
CLCQueryMembersRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_MEMBERS_RES
CLCQueryMembersRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryMembersRES"
function CLCQueryMembersRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryMembersRES.OP_CODE, serverId, callback)
end

-- 请求调整玩家分数
local CCLModifyMemberScoreREQ = class("CCLModifyMemberScoreREQ", ProtocolBase)
ns.CCLModifyMemberScoreREQ = CCLModifyMemberScoreREQ
CCLModifyMemberScoreREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_MEMBER_REQ
CCLModifyMemberScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyMemberScoreREQ"
function CCLModifyMemberScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyMemberScoreREQ.OP_CODE, serverId, callback)
end

function CCLModifyMemberScoreREQ:setData(leagueId, clubId, roleId, type, score)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().type = type
    self:getProtocolBuf().score = score
end

local CLCModifyMemberScoreRES = class("CLCModifyMemberScoreRES", ProtocolBase)
ns.CLCModifyMemberScoreRES = CLCModifyMemberScoreRES
CLCModifyMemberScoreRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_MEMBER_RES
CLCModifyMemberScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyMemberScoreRES"
function CLCModifyMemberScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyMemberScoreRES.OP_CODE, serverId, callback)
end

-- 请求暂停成员参赛
local CCLPauseMemberGameREQ = class("CCLPauseMemberGameREQ", ProtocolBase)
ns.CCLPauseMemberGameREQ = CCLPauseMemberGameREQ
CCLPauseMemberGameREQ.OP_CODE = net.ProtocolCode.P_CCL_PAUSE_MEMBER_REQ
CCLPauseMemberGameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLPauseMemberGameREQ"
function CCLPauseMemberGameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLPauseMemberGameREQ.OP_CODE, serverId, callback)
end

function CCLPauseMemberGameREQ:setData(leagueId, clubId, roleId, type, pause)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().type = type
    self:getProtocolBuf().pause = pause
end

local CLCPauseMemberGameRES = class("CLCPauseMemberGameRES", ProtocolBase)
ns.CLCPauseMemberGameRES = CLCPauseMemberGameRES
CLCPauseMemberGameRES.OP_CODE = net.ProtocolCode.P_CLC_PAUSE_MEMBER_RES
CLCPauseMemberGameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCPauseMemberGameRES"
function CLCPauseMemberGameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCPauseMemberGameRES.OP_CODE, serverId, callback)
end

-- 请求创建联盟房间
local CCLCreateLeagueRoomREQ = class("CCLCreateLeagueRoomREQ", ProtocolBase)
ns.CCLCreateLeagueRoomREQ = CCLCreateLeagueRoomREQ
CCLCreateLeagueRoomREQ.OP_CODE = net.ProtocolCode.P_CCL_CREATE_LEAGUE_ROOM_REQ
CCLCreateLeagueRoomREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLCreateLeagueRoomREQ"
function CCLCreateLeagueRoomREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLCreateLeagueRoomREQ.OP_CODE, serverId, callback)
end

function CCLCreateLeagueRoomREQ:setData(leagueId, leaderId, clubId, gameplayId, createType)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().leaderId = leaderId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().gameplayId = gameplayId
    self:getProtocolBuf().createType = createType
end

local CLCCreateLeagueRoomRES = class("CLCCreateLeagueRoomRES", ProtocolBase)
ns.CLCCreateLeagueRoomRES = CLCCreateLeagueRoomRES
CLCCreateLeagueRoomRES.OP_CODE = net.ProtocolCode.P_CLC_CREATE_LEAGUE_ROOM_RES
CLCCreateLeagueRoomRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCCreateLeagueRoomRES"
function CLCCreateLeagueRoomRES:ctor(serverId, callback)
    self.super.ctor(self, CLCCreateLeagueRoomRES.OP_CODE, serverId, callback)
end

-- 关注联盟房间
local CCLFocusOnLeagueRoomREQ = class("CCLFocusOnLeagueRoomREQ", ProtocolBase)
ns.CCLFocusOnLeagueRoomREQ = CCLFocusOnLeagueRoomREQ
CCLFocusOnLeagueRoomREQ.OP_CODE = net.ProtocolCode.P_CCL_FOCUS_ON_LEAGUE_ROOM_REQ
CCLFocusOnLeagueRoomREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLFocusOnLeagueRoomREQ"
function CCLFocusOnLeagueRoomREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLFocusOnLeagueRoomREQ.OP_CODE, serverId, callback)
end

function CCLFocusOnLeagueRoomREQ:setData(leagueId, optype)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().optype = optype
end

local CLCFocusOnLeagueRoomRES = class("CLCFocusOnLeagueRoomRES", ProtocolBase)
ns.CLCFocusOnLeagueRoomRES = CLCFocusOnLeagueRoomRES
CLCFocusOnLeagueRoomRES.OP_CODE = net.ProtocolCode.P_CLC_FOCUS_ON_LEAGUE_ROOM_RES
CLCFocusOnLeagueRoomRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCFocusOnLeagueRoomRES"
function CLCFocusOnLeagueRoomRES:ctor(serverId, callback)
    self.super.ctor(self, CLCFocusOnLeagueRoomRES.OP_CODE, serverId, callback)
end

-- 通知客户端变化的联盟房间
local CLCNotifyLeagueRoomSYN = class("CLCNotifyLeagueRoomSYN", ProtocolBase)
ns.CLCNotifyLeagueRoomSYN = CLCNotifyLeagueRoomSYN

CLCNotifyLeagueRoomSYN.OP_CODE = net.ProtocolCode.P_CLC_NOTIFY_LEAGUE_ROOM_SYN
CLCNotifyLeagueRoomSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCNotifyLeagueRoomSYN"

function CLCNotifyLeagueRoomSYN:ctor(serverId, callback)
    self.super.ctor(self, CLCNotifyLeagueRoomSYN.OP_CODE, serverId, callback)
end

-- 是否显示开局牌桌
local CCLShowStartTableREQ = class("CCLShowStartTableREQ", ProtocolBase)
ns.CCLShowStartTableREQ = CCLShowStartTableREQ
CCLShowStartTableREQ.OP_CODE = net.ProtocolCode.P_CCL_SHOW_START_TABLE_REQ
CCLShowStartTableREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLShowStartTableREQ"
function CCLShowStartTableREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLShowStartTableREQ.OP_CODE, serverId, callback)
end

function CCLShowStartTableREQ:setData(leagueId, show)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().show = show
end

local CLCShowStartTableRES = class("CLCShowStartTableRES", ProtocolBase)
ns.CLCShowStartTableRES = CLCShowStartTableRES
CLCShowStartTableRES.OP_CODE = net.ProtocolCode.P_CLC_SHOW_START_TABLE_RES
CLCShowStartTableRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCShowStartTableRES"
function CLCShowStartTableRES:ctor(serverId, callback)
    self.super.ctor(self, CLCShowStartTableRES.OP_CODE, serverId, callback)
end

-- 请求大联盟名称
local CCLQueryLeagueNameREQ = class("CCLQueryLeagueNameREQ", ProtocolBase)
ns.CCLQueryLeagueNameREQ = CCLQueryLeagueNameREQ
CCLQueryLeagueNameREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_NAME_REQ
CCLQueryLeagueNameREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueNameREQ"
function CCLQueryLeagueNameREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueNameREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeagueNameREQ:setData(leagueId)
    self:getProtocolBuf().leagueId = leagueId
end

local CLCQueryLeagueNameRES = class("CLCQueryLeagueNameRES", ProtocolBase)
ns.CLCQueryLeagueNameRES = CLCQueryLeagueNameRES
CLCQueryLeagueNameRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_NAME_RES
CLCQueryLeagueNameRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueNameRES"
function CLCQueryLeagueNameRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueNameRES.OP_CODE, serverId, callback)
end

-- 请求大联盟牌桌详细信息
local CCLQueryRoomDetailsREQ = class("CCLQueryRoomDetailsREQ", ProtocolBase)
ns.CCLQueryRoomDetailsREQ = CCLQueryRoomDetailsREQ
CCLQueryRoomDetailsREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_ROOM_DETAILS_REQ
CCLQueryRoomDetailsREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryRoomDetailsREQ"
function CCLQueryRoomDetailsREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryRoomDetailsREQ.OP_CODE, serverId, callback)
end

function CCLQueryRoomDetailsREQ:setData(leagueId, roomIds)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().roomIds = roomIds
end

local CLCQueryRoomDetailsRES = class("CLCQueryRoomDetailsRES", ProtocolBase)
ns.CLCQueryRoomDetailsRES = CLCQueryRoomDetailsRES
CLCQueryRoomDetailsRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_ROOM_DETAILS_RES
CLCQueryRoomDetailsRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryRoomDetailsRES"
function CLCQueryRoomDetailsRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryRoomDetailsRES.OP_CODE, serverId, callback)
end

-- 联盟相关推送消息
local CLCLeagueInfoSYN = class("CLCLeagueInfoSYN", ProtocolBase)
ns.CLCLeagueInfoSYN = CLCLeagueInfoSYN

CLCLeagueInfoSYN.OP_CODE = net.ProtocolCode.P_CLC_LEAGUE_INFO_SYN
CLCLeagueInfoSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCLeagueInfoSYN"

function CLCLeagueInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, CLCLeagueInfoSYN.OP_CODE, serverId, callback)
end


-- 请求大联盟积分详情
local CCLQueryLeagueScoreREQ = class("CCLQueryLeagueScoreREQ", ProtocolBase)
ns.CCLQueryLeagueScoreREQ = CCLQueryLeagueScoreREQ
CCLQueryLeagueScoreREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_SCORE_REQ
CCLQueryLeagueScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueScoreREQ"
function CCLQueryLeagueScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueScoreREQ.OP_CODE, serverId, callback)
end

function CCLQueryLeagueScoreREQ:setData(leagueId, clubId, partnerId, operatorType)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
    self:getProtocolBuf().type = operatorType
end

local CLCQueryLeagueScoreRES = class("CLCQueryLeagueScoreRES", ProtocolBase)
ns.CLCQueryLeagueScoreRES = CLCQueryLeagueScoreRES
CLCQueryLeagueScoreRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_SCORE_RES
CLCQueryLeagueScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueScoreRES"
function CLCQueryLeagueScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueScoreRES.OP_CODE, serverId, callback)
end

-- 请求大联盟积分详情
local CCLQueryScoreRecordREQ = class("CCLQueryScoreRecordREQ", ProtocolBase)
ns.CCLQueryScoreRecordREQ = CCLQueryScoreRecordREQ
CCLQueryScoreRecordREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_SCORE_RECORD_REQ
CCLQueryScoreRecordREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryScoreRecordREQ"
function CCLQueryScoreRecordREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryScoreRecordREQ.OP_CODE, serverId, callback)
end

function CCLQueryScoreRecordREQ:setData(leagueId, clubId, partnerId, roleId, operatorType, scoreType, date, endDate)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
    self:getProtocolBuf().roleId = roleId
    self:getProtocolBuf().type = operatorType
    self:getProtocolBuf().scoreType = scoreType
    self:getProtocolBuf().date = date
    self:getProtocolBuf().endDate = endDate
end

local CLCQueryScoreRecordRES = class("CLCQueryScoreRecordRES", ProtocolBase)
ns.CLCQueryScoreRecordRES = CLCQueryScoreRecordRES
CLCQueryScoreRecordRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_SCORE_RECORD_RES
CLCQueryScoreRecordRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryScoreRecordRES"
function CLCQueryScoreRecordRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryScoreRecordRES.OP_CODE, serverId, callback)
end


-- 请求大联盟成员积分/俱乐部成员积分
local CCLQueryClubRecordREQ = class("CCLQueryClubRecordREQ", ProtocolBase)
ns.CCLQueryClubRecordREQ = CCLQueryClubRecordREQ
CCLQueryClubRecordREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_RECORD_REQ
CCLQueryClubRecordREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubRecordREQ"
function CCLQueryClubRecordREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubRecordREQ.OP_CODE, serverId, callback)
end

function CCLQueryClubRecordREQ:setData(leagueId, clubId, partnerId, operatorType, queryType)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
    self:getProtocolBuf().type = operatorType
    self:getProtocolBuf().queryType = queryType
end

local CLCQueryClubRecordRES = class("CLCQueryClubRecordRES", ProtocolBase)
ns.CLCQueryClubRecordRES = CLCQueryClubRecordRES
CLCQueryClubRecordRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_RECORD_RES
CLCQueryClubRecordRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubRecordRES"
function CLCQueryClubRecordRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubRecordRES.OP_CODE, serverId, callback)
end


-- 请求转换活跃值
local CCLConversionScoreREQ = class("CCLConversionScoreREQ", ProtocolBase)
ns.CCLConversionScoreREQ = CCLConversionScoreREQ
CCLConversionScoreREQ.OP_CODE = net.ProtocolCode.P_CCL_CONVERSION_SCORE_REQ
CCLConversionScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubRecordREQ"
function CCLConversionScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLConversionScoreREQ.OP_CODE, serverId, callback)
end

function CCLConversionScoreREQ:setData(leagueId, clubId, partnerId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
end

local CLCConversionScoreRES = class("CLCConversionScoreRES", ProtocolBase)
ns.CLCConversionScoreRES = CLCConversionScoreRES
CLCConversionScoreRES.OP_CODE = net.ProtocolCode.P_CLC_CONVERSION_SCORE_RES
CLCConversionScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCConversionScoreRES"
function CLCConversionScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCConversionScoreRES.OP_CODE, serverId, callback)
end

-- 请求活跃值
local CCLQueryFireScoreREQ = class("CCLQueryFireScoreREQ", ProtocolBase)
ns.CCLQueryFireScoreREQ = CCLQueryFireScoreREQ
CCLQueryFireScoreREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_FIRE_SCORE_REQ
CCLQueryFireScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryFireScoreREQ"
function CCLQueryFireScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryFireScoreREQ.OP_CODE, serverId, callback)
end

function CCLQueryFireScoreREQ:setData(leagueId, clubId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
end

local CLCQueryFireScoreRES = class("CLCQueryFireScoreRES", ProtocolBase)
ns.CLCQueryFireScoreRES = CLCQueryFireScoreRES
CLCQueryFireScoreRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_FIRE_SCORE_RES
CLCQueryFireScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryFireScoreRES"
function CLCQueryFireScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryFireScoreRES.OP_CODE, serverId, callback)
end

-----盟主数据界面协议
local CCLQueryLeagueMatchActivityInfoREQ  = class("CCLQueryLeagueMatchActivityInfoREQ", ProtocolBase)
ns.CCLQueryLeagueMatchActivityInfoREQ  = CCLQueryLeagueMatchActivityInfoREQ 
CCLQueryLeagueMatchActivityInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_MATCH_ACTIVITY_INFO_REQ
CCLQueryLeagueMatchActivityInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueMatchActivityInfoREQ"
function CCLQueryLeagueMatchActivityInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueMatchActivityInfoREQ.OP_CODE, serverId, callback)
end
function CCLQueryLeagueMatchActivityInfoREQ:setData(leagueId)
    self:getProtocolBuf().leagueId = leagueId
end

local CLCQueryLeagueMatchActivityInfoRES = class("CLCQueryLeagueMatchActivityInfoRES", ProtocolBase)
ns.CLCQueryLeagueMatchActivityInfoRES = CLCQueryLeagueMatchActivityInfoRES
CLCQueryLeagueMatchActivityInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_MATCH_ACTIVITY_INFO_RES
CLCQueryLeagueMatchActivityInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueMatchActivityInfoRES"
function CLCQueryLeagueMatchActivityInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueMatchActivityInfoRES.OP_CODE, serverId, callback)
end

--群主数据界面协议
local CCLQueryLeagueClubActivityInfoREQ = class("CCLQueryLeagueClubActivityInfoREQ", ProtocolBase)
ns.CCLQueryLeagueClubActivityInfoREQ = CCLQueryLeagueClubActivityInfoREQ
CCLQueryLeagueClubActivityInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_LEAGUE_CLUB_ACTIVITY_INFO_REQ
CCLQueryLeagueClubActivityInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryLeagueClubActivityInfoREQ"
function CCLQueryLeagueClubActivityInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryLeagueClubActivityInfoREQ.OP_CODE, serverId, callback)
end
function CCLQueryLeagueClubActivityInfoREQ:setData(leagueId, clubId,date)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().date = date
end

local CLCQueryLeagueClubActivityInfoRES = class("CLCQueryLeagueClubActivityInfoRES", ProtocolBase)
ns.CLCQueryLeagueClubActivityInfoRES = CLCQueryLeagueClubActivityInfoRES
CLCQueryLeagueClubActivityInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_LEAGUE_CLUB_ACTIVITY_INFO_RES
CLCQueryLeagueClubActivityInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryLeagueClubActivityInfoRES"
function CLCQueryLeagueClubActivityInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryLeagueClubActivityInfoRES.OP_CODE, serverId, callback)
end

---成员数据协议
local CCLQueryClubMemberActivityInfoREQ = class("CCLQueryClubMemberActivityInfoREQ", ProtocolBase)
ns.CCLQueryClubMemberActivityInfoREQ = CCLQueryClubMemberActivityInfoREQ
CCLQueryClubMemberActivityInfoREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_CLUB_MEMBER_ACTIVITY_INFO_REQ
CCLQueryClubMemberActivityInfoREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryClubMemberActivityInfoREQ"
function CCLQueryClubMemberActivityInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryClubMemberActivityInfoREQ.OP_CODE, serverId, callback)
end
function CCLQueryClubMemberActivityInfoREQ:setData(leagueId, clubId,date)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().date = date
end

local CLCQueryClubMemberActivityInfoRES = class("CLCQueryClubMemberActivityInfoRES", ProtocolBase)
ns.CLCQueryClubMemberActivityInfoRES = CLCQueryClubMemberActivityInfoRES
CLCQueryClubMemberActivityInfoRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_CLUB_MEMBER_ACTIVITY_INFO_RES
CLCQueryClubMemberActivityInfoRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryClubMemberActivityInfoRES"
function CLCQueryClubMemberActivityInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryClubMemberActivityInfoRES.OP_CODE, serverId, callback)
end

-- 请求修改团队玩法开启GPS规则
local CCLModifyLeagueGpsRuleREQ = class("CCLModifyLeagueGpsRuleREQ", ProtocolBase)
ns.CCLModifyLeagueGpsRuleREQ = CCLModifyLeagueGpsRuleREQ
CCLModifyLeagueGpsRuleREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_LEAGUE_GPS_RULE_REQ
CCLModifyLeagueGpsRuleREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyLeagueGpsRuleREQ"
function CCLModifyLeagueGpsRuleREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyLeagueGpsRuleREQ.OP_CODE, serverId, callback)
end

function CCLModifyLeagueGpsRuleREQ:setData(leagueId, isOpenGps)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().isOpenGPS = isOpenGps
end

local CLCModifyLeagueGpsRuleRES = class("CLCModifyLeagueGpsRuleRES", ProtocolBase)
ns.CLCModifyLeagueGpsRuleRES = CLCModifyLeagueGpsRuleRES
CLCModifyLeagueGpsRuleRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_LEAGUE_GPS_RULE_RES
CLCModifyLeagueGpsRuleRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyLeagueGpsRuleRES"
function CLCModifyLeagueGpsRuleRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyLeagueGpsRuleRES.OP_CODE, serverId, callback)
end

--请求玩法活跃值赠送
local CCLModifyGamePlayClubFireScoreREQ = class("CCLModifyGamePlayClubFireScoreREQ", ProtocolBase)
ns.CCLModifyGamePlayClubFireScoreREQ = CCLModifyGamePlayClubFireScoreREQ
--暂时没有填写
CCLModifyGamePlayClubFireScoreREQ.OP_CODE = net.ProtocolCode.P_C_CL_MODIFY_GAME_PLAY_CLUB_FIRE_SCORE_REQ
CCLModifyGamePlayClubFireScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyGamePlayClubFireScoreREQ"
function CCLModifyGamePlayClubFireScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyGamePlayClubFireScoreREQ.OP_CODE, serverId, callback)
end

function CCLModifyGamePlayClubFireScoreREQ:setData(leagueId, clubId, gameplayId,startScore,endScore,changeClubFireScore,playerCount)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().gameplayId = gameplayId
    self:getProtocolBuf().startScore = startScore
    self:getProtocolBuf().endScore = endScore
    self:getProtocolBuf().changeClubFireScore = changeClubFireScore
    self:getProtocolBuf().playerCount = playerCount
end

local CLCModifyGamePlayClubFireScoreRES = class("CLCModifyGamePlayClubFireScoreRES", ProtocolBase)
ns.CLCModifyGamePlayClubFireScoreRES = CLCModifyGamePlayClubFireScoreRES
CLCModifyGamePlayClubFireScoreRES.OP_CODE = net.ProtocolCode.P_CL_C_MODIFY_GAME_PLAY_CLUB_FIRE_SCORE_RES
CLCModifyGamePlayClubFireScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyGamePlayClubFireScoreRES"
function CLCModifyGamePlayClubFireScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyGamePlayClubFireScoreRES.OP_CODE, serverId, callback)
end

-- 请求任命或撤职搭档
local CCLOrderPartnerREQ = class("CCLOrderPartnerREQ", ProtocolBase)
ns.CCLOrderPartnerREQ = CCLOrderPartnerREQ
CCLOrderPartnerREQ.OP_CODE = net.ProtocolCode.P_CCL_ORDER_PARTNER_REQ
CCLOrderPartnerREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLOrderPartnerREQ"
function CCLOrderPartnerREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLOrderPartnerREQ.OP_CODE, serverId, callback)
end

function CCLOrderPartnerREQ:setData(leagueId, clubId, memberId, order)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().memberId = memberId
    self:getProtocolBuf().order = order
end

local CLCOrderPartnerRES = class("CLCOrderPartnerRES", ProtocolBase)
ns.CLCOrderPartnerRES = CLCOrderPartnerRES
CLCOrderPartnerRES.OP_CODE = net.ProtocolCode.P_CLC_ORDER_PARTNER_RES
CLCOrderPartnerRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCOrderPartnerRES"
function CLCOrderPartnerRES:ctor(serverId, callback)
    self.super.ctor(self, CLCOrderPartnerRES.OP_CODE, serverId, callback)
end

-- 请求给搭档调整分数
local CCLModifyPartnerScoreREQ = class("CCLModifyPartnerScoreREQ", ProtocolBase)
ns.CCLModifyPartnerScoreREQ = CCLModifyPartnerScoreREQ
CCLModifyPartnerScoreREQ.OP_CODE = net.ProtocolCode.P_CCL_MODIFY_PARTNER_SCORE_REQ
CCLModifyPartnerScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyPartnerScoreREQ"
function CCLModifyPartnerScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyPartnerScoreREQ.OP_CODE, serverId, callback)
end

function CCLModifyPartnerScoreREQ:setData(leagueId, clubId, memberId, type, score)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().memberId = memberId
    self:getProtocolBuf().type = type
    self:getProtocolBuf().score = score
end

local CLCModifyPartnerScoreRES = class("CLCModifyPartnerScoreRES", ProtocolBase)
ns.CLCModifyPartnerScoreRES = CLCModifyPartnerScoreRES
CLCModifyPartnerScoreRES.OP_CODE = net.ProtocolCode.P_CLC_MODIFY_PARTNER_SCORE_RES
CLCModifyPartnerScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyPartnerScoreRES"
function CLCModifyPartnerScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyPartnerScoreRES.OP_CODE, serverId, callback)
end

-- 请求邀请玩家到联盟俱乐部的搭档成员中
local CCLInvitePartnerMemberREQ = class("CCLInvitePartnerMemberREQ", ProtocolBase)
ns.CCLInvitePartnerMemberREQ = CCLInvitePartnerMemberREQ
CCLInvitePartnerMemberREQ.OP_CODE = net.ProtocolCode.P_CCL_INVITE_PARTNER_MEMBER_REQ
CCLInvitePartnerMemberREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLInvitePartnerMemberREQ"
function CCLInvitePartnerMemberREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLInvitePartnerMemberREQ.OP_CODE, serverId, callback)
end

function CCLInvitePartnerMemberREQ:setData(leagueId, clubId, memberId)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().memberId = memberId
end

local CLCInvitePartnerMemberRES = class("CLCInvitePartnerMemberRES", ProtocolBase)
ns.CLCInvitePartnerMemberRES = CLCInvitePartnerMemberRES
CLCInvitePartnerMemberRES.OP_CODE = net.ProtocolCode.P_CLC_INVITE_PARTNER_MEMBER_RES
CLCInvitePartnerMemberRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCInvitePartnerMemberRES"
function CLCInvitePartnerMemberRES:ctor(serverId, callback)
    self.super.ctor(self, CLCInvitePartnerMemberRES.OP_CODE, serverId, callback)
end

-- 请求修改联盟中俱乐部搭档活跃值赠送
local CCLModifyGamePlayPartnerFireScoreREQ = class("CCLModifyGamePlayPartnerFireScoreREQ", ProtocolBase)
ns.CCLModifyGamePlayPartnerFireScoreREQ = CCLModifyGamePlayPartnerFireScoreREQ
CCLModifyGamePlayPartnerFireScoreREQ.OP_CODE = net.ProtocolCode.P_C_CL_MODIFY_GAME_PLAY_PARTNER_FIRE_SCORE_REQ
CCLModifyGamePlayPartnerFireScoreREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLModifyGamePlayPartnerFireScoreREQ"
function CCLModifyGamePlayPartnerFireScoreREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLModifyGamePlayPartnerFireScoreREQ.OP_CODE, serverId, callback)
end

function CCLModifyGamePlayPartnerFireScoreREQ:setData(leagueId, clubId, partnerId, gameplayId, startScore, endScore, changeClubFireScore)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().clubId = clubId
    self:getProtocolBuf().partnerId = partnerId
    self:getProtocolBuf().gameplayId = gameplayId
    self:getProtocolBuf().startScore = startScore
    self:getProtocolBuf().endScore = endScore
    self:getProtocolBuf().changeClubFireScore = changeClubFireScore

end

local CLCModifyGamePlayPartnerFireScoreRES = class("CLCModifyGamePlayPartnerFireScoreRES", ProtocolBase)
ns.CLCModifyGamePlayPartnerFireScoreRES = CLCModifyGamePlayPartnerFireScoreRES
CLCModifyGamePlayPartnerFireScoreRES.OP_CODE = net.ProtocolCode.P_CL_C_MODIFY_GAME_PLAY_PARTNER_FIRE_SCORE_RES
CLCModifyGamePlayPartnerFireScoreRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCModifyGamePlayPartnerFireScoreRES"
function CLCModifyGamePlayPartnerFireScoreRES:ctor(serverId, callback)
    self.super.ctor(self, CLCModifyGamePlayPartnerFireScoreRES.OP_CODE, serverId, callback)
end

--同步联盟玩法信息
local CLCLeagueGameplayInfoSYN = class("CLCLeagueGameplayInfoSYN",ProtocolBase)
ns.CLCLeagueGameplayInfoSYN = CLCLeagueGameplayInfoSYN
CLCLeagueGameplayInfoSYN.OP_CODE = net.ProtocolCode.CL_C_LEAGUE_GAMEPLAY_INFO_SYN
CLCLeagueGameplayInfoSYN.CLZ_CODE = "com.kodgames.message.proto.club.CLCLeagueGamePlayInfoSYN"
function CLCLeagueGameplayInfoSYN:ctor(serverId, callback)
    self.super.ctor(self, CLCLeagueGameplayInfoSYN.OP_CODE, serverId, callback)
end


--盟主请求玩法统计数据 
local CCLQueryGameplayStatisticsREQ = class("CCLQueryGameplayStatisticsREQ", ProtocolBase)
ns.CCLQueryGameplayStatisticsREQ  = CCLQueryGameplayStatisticsREQ 
CCLQueryGameplayStatisticsREQ.OP_CODE = net.ProtocolCode.P_CCL_QUERY_GAMEPLAY_STATISTICS_REQ 
CCLQueryGameplayStatisticsREQ.CLZ_CODE = "com.kodgames.message.proto.club.CCLQueryGameplayStatisticsREQ"
function CCLQueryGameplayStatisticsREQ:ctor(serverId, callback)
    self.super.ctor(self, CCLQueryGameplayStatisticsREQ.OP_CODE, serverId, callback)
end

function CCLQueryGameplayStatisticsREQ:setData(leagueId, date)
    self:getProtocolBuf().leagueId = leagueId
    self:getProtocolBuf().date = date

end

local CLCQueryGameplayStatisticsRES = class("CLCQueryGameplayStatisticsRES", ProtocolBase)
ns.CLCQueryGameplayStatisticsRES = CLCQueryGameplayStatisticsRES
CLCQueryGameplayStatisticsRES.OP_CODE = net.ProtocolCode.P_CLC_QUERY_GAMEPLAY_STATISTICS_RES
CLCQueryGameplayStatisticsRES.CLZ_CODE = "com.kodgames.message.proto.club.CLCQueryGameplayStatisticsRES"
function CLCQueryGameplayStatisticsRES:ctor(serverId, callback)
    self.super.ctor(self, CLCQueryGameplayStatisticsRES.OP_CODE, serverId, callback)
end

