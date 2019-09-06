local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")

-------------------------------------------------------
-- 关注和取消关注当前赛事列表变化
-------------------------------------------------------
local CCAFocusOnCampaignListREQ = class("CCAFocusOnCampaignListREQ", ProtocolBase)
ns.CCAFocusOnCampaignListREQ = CCAFocusOnCampaignListREQ

CCAFocusOnCampaignListREQ.OP_CODE = net.ProtocolCode.P_CCA_FOCUS_ON_CAMPAIGN_LIST_REQ
CCAFocusOnCampaignListREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAFocusOnCampaignListREQ"

-- @param serverId: number
-- @param callback: number
function CCAFocusOnCampaignListREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAFocusOnCampaignListREQ.OP_CODE, serverId, callback);
end

-- @param optype: number
function CCAFocusOnCampaignListREQ:setData(optype, areaId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.optype = optype;
    protocolBuf.area = areaId;
end

-- RES
local CACFocusOnCampaignListRES = class("CACFocusOnCampaignListRES", ProtocolBase)
ns.CACFocusOnCampaignListRES = CACFocusOnCampaignListRES

CACFocusOnCampaignListRES.OP_CODE = net.ProtocolCode.P_CAC_FOCUS_ON_CAMPAIGN_LIST_RES
CACFocusOnCampaignListRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACFocusOnCampaignListRES"

function CACFocusOnCampaignListRES:ctor(serverId, callback)
    self.super.ctor(self, CACFocusOnCampaignListRES.OP_CODE, serverId, callback)
end

-- SYN 当前赛事列表同步协议
local CACNotifyCampaignListSYN = class("CACNotifyCampaignListSYN", ProtocolBase)
ns.CACNotifyCampaignListSYN = CACNotifyCampaignListSYN

CACNotifyCampaignListSYN.OP_CODE = net.ProtocolCode.P_CCA_NOTIFY_CAMPAIGN_LIST_SYN
CACNotifyCampaignListSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACNotifyCampaignListSYN"

function CACNotifyCampaignListSYN:ctor(serverId, callback)
    self.super.ctor(self, CACNotifyCampaignListSYN.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 请求玩家当前的比赛状态
-------------------------------------------------------
local CCAPlayerStatusREQ = class("CCAPlayerStatusREQ", ProtocolBase)
ns.CCAPlayerStatusREQ = CCAPlayerStatusREQ

CCAPlayerStatusREQ.OP_CODE = net.ProtocolCode.P_CCA_PLAYER_STATUS_REQ
CCAPlayerStatusREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAPlayerStatusREQ"

-- @param serverId: number
-- @param callback: number
function CCAPlayerStatusREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAPlayerStatusREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCAPlayerStatusREQ:setData(campaignId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
end

-- RES
local CACPlayerStatusRES = class("CACPlayerStatusRES", ProtocolBase)
ns.CACPlayerStatusRES = CACPlayerStatusRES

CACPlayerStatusRES.OP_CODE = net.ProtocolCode.P_CAC_PLAYER_STATUS_RES
CACPlayerStatusRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACPlayerStatusRES"

function CACPlayerStatusRES:ctor(serverId, callback)
    self.super.ctor(self, CACPlayerStatusRES.OP_CODE, serverId, callback)
end

-- SYN
local CACPlayerStatusSYN = class("CACPlayerStatusSYN", ProtocolBase)
ns.CACPlayerStatusSYN = CACPlayerStatusSYN

CACPlayerStatusSYN.OP_CODE = net.ProtocolCode.P_CAC_PLAYER_STATUS_SYN
CACPlayerStatusSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACPlayerStatusSYN"

function CACPlayerStatusSYN:ctor(serverId, callback)
    self.super.ctor(self, CACPlayerStatusSYN.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 请求报名
-------------------------------------------------------
local CCASignUpREQ = class("CCASignUpREQ", ProtocolBase)
ns.CCASignUpREQ = CCASignUpREQ

CCASignUpREQ.OP_CODE = net.ProtocolCode.P_CCA_SIGN_UP_REQ
CCASignUpREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCASignUpREQ"

-- @param serverId: number
-- @param callback: number
function CCASignUpREQ:ctor(serverId, callback)
	self.super.ctor(self, CCASignUpREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCASignUpREQ:setData( campaignId, configId, key)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
    protocolBuf.configId = configId
    protocolBuf.key = key
end

--RES
local CACSignUpRES = class("CACSignUpRES", ProtocolBase)
ns.CACSignUpRES = CACSignUpRES

CACSignUpRES.OP_CODE = net.ProtocolCode.P_CAC_SIGN_UP_RES
CACSignUpRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACSignUpRES"

function CACSignUpRES:ctor(serverId, callback)
    self.super.ctor(self, CACSignUpRES.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 请求取消报名
-------------------------------------------------------
local CCASignUpCancelREQ = class("CCASignUpCancelREQ", ProtocolBase)
ns.CCASignUpCancelREQ = CCASignUpCancelREQ

CCASignUpCancelREQ.OP_CODE = net.ProtocolCode.P_CCA_SIGN_UP_CANCEL_REQ
CCASignUpCancelREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCASignUpCancelREQ"

-- @param serverId: number
-- @param callback: number
function CCASignUpCancelREQ:ctor(serverId, callback)
	self.super.ctor(self, CCASignUpCancelREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCASignUpCancelREQ:setData(campaignId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
end

--RES
local CACSignUpCancelRES = class("CACSignUpCancelRES", ProtocolBase)
ns.CACSignUpCancelRES = CACSignUpCancelRES

CACSignUpCancelRES.OP_CODE = net.ProtocolCode.P_CAC_SIGN_UP_CANCEL_RES
CACSignUpCancelRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACSignUpCancelRES"

function CACSignUpCancelRES:ctor(serverId, callback)
    self.super.ctor(self, CACSignUpCancelRES.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 请求放弃比赛
-------------------------------------------------------
local CCAGiveUpREQ = class("CCAGiveUpREQ", ProtocolBase)
ns.CCAGiveUpREQ = CCAGiveUpREQ

CCAGiveUpREQ.OP_CODE = net.ProtocolCode.P_CCA_GIVE_UP_REQ
CCAGiveUpREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAGiveUpREQ"

-- @param serverId: number
-- @param callback: number
function CCAGiveUpREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAGiveUpREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCAGiveUpREQ:setData(campaignId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
end

--RES
local CACGiveUpRES = class("CACGiveUpRES", ProtocolBase)
ns.CACGiveUpRES = CACGiveUpRES

CACGiveUpRES.OP_CODE = net.ProtocolCode.P_CAC_GIVE_UP_RES
CACGiveUpRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACGiveUpRES"

function CACGiveUpRES:ctor(serverId, callback)
    self.super.ctor(self, CACGiveUpRES.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 玩家请求历史战绩
-------------------------------------------------------
local CCACampaignHistoryREQ = class("CCACampaignHistoryREQ", ProtocolBase)
ns.CCACampaignHistoryREQ = CCACampaignHistoryREQ

CCACampaignHistoryREQ.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_HISTORY_REQ
CCACampaignHistoryREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignHistoryREQ"

-- @param serverId: number
-- @param callback: number
function CCACampaignHistoryREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignHistoryREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCACampaignHistoryREQ:setData(clubId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.clubId = clubId;
end

--RES
local CACCampaignHistoryRES = class("CACCampaignHistoryRES", ProtocolBase)
ns.CACCampaignHistoryRES = CACCampaignHistoryRES

CACCampaignHistoryRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_HISTORY_RES
CACCampaignHistoryRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignHistoryRES"

function CACCampaignHistoryRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignHistoryRES.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 同步信息
-------------------------------------------------------
-- SYN 同步排名变化信息
local CACRankChangeSYN = class("CACRankChangeSYN", ProtocolBase)
ns.CACRankChangeSYN = CACRankChangeSYN

CACRankChangeSYN.OP_CODE = net.ProtocolCode.P_CAC_RANK_CHANGE_SYN
CACRankChangeSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACRankChangeSYN"

function CACRankChangeSYN:ctor(serverId, callback)
    self.super.ctor(self, CACRankChangeSYN.OP_CODE, serverId, callback)
end

-- SYN 同步晋级信息
local CACPromotionSYN = class("CACPromotionSYN", ProtocolBase)
ns.CACPromotionSYN = CACPromotionSYN

CACPromotionSYN.OP_CODE = net.ProtocolCode.P_CAC_PROMOTION_SYN
CACPromotionSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACPromotionSYN"

function CACPromotionSYN:ctor(serverId, callback)
    self.super.ctor(self, CACPromotionSYN.OP_CODE, serverId, callback)
end

-- SYN 同步比赛房间
local CACEnterRoomSYN = class("CACEnterRoomSYN", ProtocolBase)
ns.CACEnterRoomSYN = CACEnterRoomSYN

CACEnterRoomSYN.OP_CODE = net.ProtocolCode.P_CAC_ENTER_ROOM_SYN
CACEnterRoomSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACEnterRoomSYN"

function CACEnterRoomSYN:ctor(serverId, callback)
    self.super.ctor(self, CACEnterRoomSYN.OP_CODE, serverId, callback)
end

-- SYN同步单局战绩
local CACResultSYN = class("CACResultSYN", ProtocolBase)
ns.CACResultSYN = CACResultSYN

CACResultSYN.OP_CODE = net.ProtocolCode.P_CAC_RESULT_SYN
CACResultSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACResultSYN"

function CACResultSYN:ctor(serverId, callback)
    self.super.ctor(self, CACResultSYN.OP_CODE, serverId, callback)
end

-- SYN MTT三分钟提示准备
local CACMttPrepareSYN = class("CACMttPrepareSYN", ProtocolBase)
ns.CACMttPrepareSYN = CACMttPrepareSYN

CACMttPrepareSYN.OP_CODE = net.ProtocolCode.P_CAC_MTT_PREPARE_SYN
CACMttPrepareSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACMttPrepareSYN"

function CACMttPrepareSYN:ctor(serverId, callback)
    self.super.ctor(self, CACMttPrepareSYN.OP_CODE, serverId, callback)
end

-------------------------------------------------------
-- 请求荣誉墙列表
-------------------------------------------------------
local CCAHonorWallREQ = class("CCAHonorWallREQ", ProtocolBase)
ns.CCAHonorWallREQ = CCAHonorWallREQ

CCAHonorWallREQ.OP_CODE = net.ProtocolCode.P_CCA_HONOR_WALL_REQ
CCAHonorWallREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAHonorWallREQ"

-- @param serverId: number
-- @param callback: number
function CCAHonorWallREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAHonorWallREQ.OP_CODE, serverId, callback);
end

-- 荣誉墙列表返回
--RES
local CACHonorWallRES = class("CACHonorWallRES", ProtocolBase)
ns.CACHonorWallRES = CACHonorWallRES

CACHonorWallRES.OP_CODE = net.ProtocolCode.P_CAC_HONOR_WALL_RES
CACHonorWallRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACHonorWallRES"

function CACHonorWallRES:ctor(serverId, callback)
    self.super.ctor(self, CACHonorWallRES.OP_CODE, serverId, callback)
end

-- SYN 打立赛淘汰下提高预警
local CACRaiseLinePreSYN = class("CACRaiseLinePreSYN", ProtocolBase)
ns.CACRaiseLinePreSYN = CACRaiseLinePreSYN

CACRaiseLinePreSYN.OP_CODE = net.ProtocolCode.P_CAC_RAISE_LINE_PRE_SYN
CACRaiseLinePreSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACRaiseLinePreSYN"

function CACRaiseLinePreSYN:ctor(serverId, callback)
    self.super.ctor(self, CACRaiseLinePreSYN.OP_CODE, serverId, callback)
end

-- SYN 打立赛提高淘汰线
local CACRaiseLineSYN = class("CACRaiseLineSYN", ProtocolBase)
ns.CACRaiseLineSYN = CACRaiseLineSYN

CACRaiseLineSYN.OP_CODE = net.ProtocolCode.P_CAC_RAISE_LINE_SYN
CACRaiseLineSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACRaiseLineSYN"

function CACRaiseLineSYN:ctor(serverId, callback)
    self.super.ctor(self, CACRaiseLineSYN.OP_CODE, serverId, callback)
end

-- SYN 打立赛晋级同步
local CACDaLiPromotionSYN = class("CACDaLiPromotionSYN", ProtocolBase)
ns.CACDaLiPromotionSYN = CACDaLiPromotionSYN

CACDaLiPromotionSYN.OP_CODE = net.ProtocolCode.P_CAC_DALI_PROMOTION_SYN
CACDaLiPromotionSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACDaLiPromotionSYN"

function CACDaLiPromotionSYN:ctor(serverId, callback)
    self.super.ctor(self, CACDaLiPromotionSYN.OP_CODE, serverId, callback)
end

-- REQ 本轮比赛详情请求
local CCARoundInfoREQ = class("CCARoundInfoREQ", ProtocolBase)
ns.CCARoundInfoREQ = CCARoundInfoREQ

CCARoundInfoREQ.OP_CODE = net.ProtocolCode.P_CCA_ROUND_INFO_REQ
CCARoundInfoREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCARoundInfoREQ"

-- @param serverId: number
-- @param callback: number
function CCARoundInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CCARoundInfoREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCARoundInfoREQ:setData(campaignId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
end

-- RES 本轮比赛详情回复
local CACRoundInfoRES = class("CACRoundInfoRES", ProtocolBase)
ns.CACRoundInfoRES = CACRoundInfoRES

CACRoundInfoRES.OP_CODE = net.ProtocolCode.P_CAC_ROUND_INFO_RES
CACRoundInfoRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACRoundInfoRES"

function CACRoundInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CACRoundInfoRES.OP_CODE, serverId, callback)
end

-- 玩家错过比赛提示
local CACRoleMissMttSYN = class("CACRoleMissMttSYN", ProtocolBase)
ns.CACRoleMissMttSYN = CACRoleMissMttSYN

CACRoleMissMttSYN.OP_CODE = net.ProtocolCode.P_CAC_ROLE_MISS_MTT_SYN
CACRoleMissMttSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACRoleMissMttSYN"

function CACRoleMissMttSYN:ctor(serverId, callback)
    self.super.ctor(self, CACRoleMissMttSYN.OP_CODE, serverId, callback)
end

----------------------------------------------------------------------
-- REQ 玩家领取待领取奖励请求
local CCAReceiveRewardREQ = class("CCAReceiveRewardREQ", ProtocolBase)
ns.CCAReceiveRewardREQ = CCAReceiveRewardREQ

CCAReceiveRewardREQ.OP_CODE = net.ProtocolCode.P_CCA_RECEIVE_REWARD_REQ
CCAReceiveRewardREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAReceiveRewardREQ"

-- @param serverId: number
-- @param callback: number
function CCAReceiveRewardREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAReceiveRewardREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCAReceiveRewardREQ:setData(campaignId, time)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = campaignId;
    protocolBuf.time = time;
end

-- RES 玩家领取待领取奖励请求
local CACReceiveRewardRES = class("CACReceiveRewardRES", ProtocolBase)
ns.CACReceiveRewardRES = CACReceiveRewardRES

CACReceiveRewardRES.OP_CODE = net.ProtocolCode.P_CAC_RECEIVE_REWARD_RES
CACReceiveRewardRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACReceiveRewardRES"

-- @param serverId: number
-- @param callback: number
function CACReceiveRewardRES:ctor(serverId, callback)
	self.super.ctor(self, CACReceiveRewardRES.OP_CODE, serverId, callback);
end

-- 自建赛相关

-- REQ 查看当前麻将馆所有的自建赛
local CCACampaignCreateListREQ = class("CCACampaignCreateListREQ", ProtocolBase)
ns.CCACampaignCreateListREQ = CCACampaignCreateListREQ

CCACampaignCreateListREQ.OP_CODE = net.ProtocolCode.P_CCA_CAMPAIGN_CREATE_LIST_REQ
CCACampaignCreateListREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignCreateListREQ"

-- @param serverId: number
-- @param callback: number
function CCACampaignCreateListREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignCreateListREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCACampaignCreateListREQ:setData(clubID)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.clubId = clubID;
end

-- RES 返回自建赛对应数据
local CACCampaignCreateListRES = class("CACCampaignCreateListRES", ProtocolBase)
ns.CACCampaignCreateListRES = CACCampaignCreateListRES

CACCampaignCreateListRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_CREATE_LIST_RES
CACCampaignCreateListRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignCreateListRES"

function CACCampaignCreateListRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignCreateListRES.OP_CODE, serverId, callback)
end

-- REQ 俱乐部经理创建赛事请求
local CCACampaignCreateREQ = class("CCACampaignCreateREQ", ProtocolBase)
ns.CCACampaignCreateREQ = CCACampaignCreateREQ

CCACampaignCreateREQ.OP_CODE = net.ProtocolCode.P_CCA_CAMPAIGN_CREATE_REQ
CCACampaignCreateREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignCreateREQ"

-- @param serverId: number
-- @param callback: number
function CCACampaignCreateREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignCreateREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCACampaignCreateREQ:setData(gameConfigId , gameName , startTime , clubID)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.id = gameConfigId;
    protocolBuf.name = gameName;
    protocolBuf.time = startTime;
    protocolBuf.clubId = clubID;
end

-- RES 俱乐部经理创建赛事回复
local CACCampaignCreateRES = class("CACCampaignCreateRES", ProtocolBase)
ns.CACCampaignCreateRES = CACCampaignCreateRES

CACCampaignCreateRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_CREATE_RES
CACCampaignCreateRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignCreateRES"

function CACCampaignCreateRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignCreateRES.OP_CODE, serverId, callback)
end

-- REQ 经理解散自建赛赛事请求
local CCACampaignCancelREQ = class("CCACampaignCancelREQ", ProtocolBase)
ns.CCACampaignCancelREQ = CCACampaignCancelREQ

CCACampaignCancelREQ.OP_CODE = net.ProtocolCode.P_CCA_CAMPAIGN_CANCEL_REQ
CCACampaignCancelREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignCancelREQ"

-- @param serverId: number
-- @param callback: number
function CCACampaignCancelREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignCancelREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCACampaignCancelREQ:setData(gameid, clubId)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.id = gameid;
    protocolBuf.clubId = clubId
end

-- RES 解散自建赛赛事回复
local CACCampaignCancelRES = class("CACCampaignCancelRES", ProtocolBase)
ns.CACCampaignCancelRES = CACCampaignCancelRES

CACCampaignCancelRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_CANCEL_RES
CACCampaignCancelRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignCancelRES"

function CACCampaignCancelRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignCancelRES.OP_CODE, serverId, callback)
end

-- REQ 客户端请求所有可以创建的自建赛
local CCACampaignConfigREQ = class("CCACampaignConfigREQ", ProtocolBase)
ns.CCACampaignConfigREQ = CCACampaignConfigREQ

CCACampaignConfigREQ.OP_CODE = net.ProtocolCode.P_CCA_CAMPAIGN_CONFIG_REQ
CCACampaignConfigREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignConfigREQ"

function CCACampaignConfigREQ:setData(area)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.area = area;
end
-- @param serverId: number
-- @param callback: number
function CCACampaignConfigREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignConfigREQ.OP_CODE, serverId, callback);
end

-- RES 自建赛赛事列表返回
local CACCampaignConfigRES = class("CACCampaignConfigRES", ProtocolBase)
ns.CACCampaignConfigRES = CACCampaignConfigRES

CACCampaignConfigRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_CONFIG_RES
CACCampaignConfigRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignConfigRES"

function CACCampaignConfigRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignConfigRES.OP_CODE, serverId, callback)
end

-- REQ 查看指定自建赛结束后的排名信息
local CCACampaignCreatePlayerREQ = class("CCACampaignCreatePlayerREQ", ProtocolBase)
ns.CCACampaignCreatePlayerREQ = CCACampaignCreatePlayerREQ

CCACampaignCreatePlayerREQ.OP_CODE = net.ProtocolCode.P_CCA_CAMPAIGN_CREATE_PLAYER_REQ
CCACampaignCreatePlayerREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCACampaignCreatePlayerREQ"

-- @param serverId: number
-- @param callback: number
function CCACampaignCreatePlayerREQ:ctor(serverId, callback)
	self.super.ctor(self, CCACampaignCreatePlayerREQ.OP_CODE, serverId, callback);
end

-- @param campaignId: number
function CCACampaignCreatePlayerREQ:setData(gameID)
	local protocolBuf = self:getProtocolBuf();
    protocolBuf.campaignId = gameID;
end

-- RES 自建赛排名信息返回
local CACCampaignCreatePlayerRES = class("CACCampaignCreatePlayerRES", ProtocolBase)
ns.CACCampaignCreatePlayerRES = CACCampaignCreatePlayerRES

CACCampaignCreatePlayerRES.OP_CODE = net.ProtocolCode.P_CAC_CAMPAIGN_CREATE_PLAYER_RES
CACCampaignCreatePlayerRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACCampaignCreatePlayerRES"

function CACCampaignCreatePlayerRES:ctor(serverId, callback)
    self.super.ctor(self, CACCampaignCreatePlayerRES.OP_CODE, serverId, callback)
end

-- arena
-- 请求arena比赛信息
local CCAArenaInfoREQ = class("CCAArenaInfoREQ", ProtocolBase)
ns.CCAArenaInfoREQ = CCAArenaInfoREQ

CCAArenaInfoREQ.OP_CODE = net.ProtocolCode.P_CCA_ARENA_INFO_REQ
CCAArenaInfoREQ.CLZ_CODE = "com.kodgames.message.proto.campaign.CCAArenaInfoREQ"

-- @param serverId: number
-- @param callback: number
function CCAArenaInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CCAArenaInfoREQ.OP_CODE, serverId, callback);
end

-- RES arena比赛信息返回
local CACArenaInfoRES = class("CACArenaInfoRES", ProtocolBase)
ns.CACArenaInfoRES = CACArenaInfoRES

CACArenaInfoRES.OP_CODE = net.ProtocolCode.P_CAC_ARENA_INFO_RES
CACArenaInfoRES.CLZ_CODE = "com.kodgames.message.proto.campaign.CACArenaInfoRES"

function CACArenaInfoRES:ctor(serverId, callback)
    self.super.ctor(self, CACArenaInfoRES.OP_CODE, serverId, callback)
end

-- SYN arena比赛晋级
local CACArenaPromotionSYN = class("CACArenaPromotionSYN", ProtocolBase)
ns.CACArenaPromotionSYN = CACArenaPromotionSYN

CACArenaPromotionSYN.OP_CODE = net.ProtocolCode.P_CAC_ARENA_PROMOTION_SYN
CACArenaPromotionSYN.CLZ_CODE = "com.kodgames.message.proto.campaign.CACArenaPromotionSYN"

function CACArenaPromotionSYN:ctor(serverId, callback)
    self.super.ctor(self, CACArenaPromotionSYN.OP_CODE, serverId, callback)
end
