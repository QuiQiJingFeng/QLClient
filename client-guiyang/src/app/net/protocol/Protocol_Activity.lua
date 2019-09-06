local ns = namespace("net.protocol")
local ProtocolBase = require("app.net.core.ProtocolBase")
local Code = net.ProtocolCode
local buildMessage = ProtocolBase.getBuildMessageFunction("com.kodgames.message.proto.activity")
local class = class


ns.activityType = {
	SCORE_RANK	= 300001,        --排行榜
	TURN_TABLE	= 300002,        --大转盘 -- 摇钱树
	WIN_PRIZE	= 300004,        --打牌赢奖
	MAINSCENE_SHARE = 300005,        --大厅分享
	WEIXIN_SHARE	= 300006,		 --微信分享
	NOCOST_CARD	= 300007,        --同ip免房卡
	NEWER_GUIADE	= 300003,        --新手引导+统计
	WEN_JUAN		= 300008,        --问卷调查
	UPDATE_REWARD = 300009,        --更新有奖互动
	LOTTERY 	= 300010, 		-- 竞彩活动
	TURN_CARD = 300011,			-- 翻牌有奖活动
	LUCKY_DRAW = 300012,			-- 抽奖活动
	WEEK_SIGN = 300013,			--七日签到活动
	QIXI_CHARGE = 300015,		-- 七夕充值活动
	QIXI_TWO_GAY = 300016,		-- 七夕二人世界活动
	MONTH_SIGN = 300017,		--月签到活动
    BIND_PHONE = 300018,		--绑定电话活动
    COMEBACK = 300020,          --回流活动
	BLESSING = 300021,			--圣诞祈福活动
	PRAY_SIGN = 300022,			--圣诞签到
	THROW_REWARD = 300023,		--圣诞礼包
	RED_PACK = 300019,			--拆红包活动
    SPRING_INVITED = 300024,    --春节邀新活动
    COLLECT_CODE = 300026,      -- 春节集码活动
	CLUB_WEEK_SIGN = 300025, -- 俱乐部七日签到
	UFO_CATCHER = 300027,		-- 抓娃娃
	CLUB_KOI = 300028, -- 俱乐部锦鲤活动
}

ns.activityServerType = 
{
    COME_BACK = "COME_BACK", -- 回流活动
    MONTH_SIGN = "MONTH_SIGN", -- 月签到
    TURN_CARD = "TURN_CARD", -- 翻牌
    LUCKY_DRAW = "LUCKY_DRAW", -- 抽奖
    WEEK_SIGN = "WEEK_SIGN", -- 周签到
    NEW_SHARE = "NEW_SHARE", -- 新分享
    BIND_PHONE = "BIND_PHONE", -- 手机绑定
    TANA_BATA = "TANA_BATA", -- 七夕
    GUIDE = "GUIDE", -- 答题
	CHRISTMAS = "CHRISTMAS", -- 元旦
	RED_PACK = "RED_PACK", -- 拆红包
	SPRING_INVITED = "SPRING_INVITED", -- 春节邀新活动
	CLUB_WEEK_SIGN = "CLUB_WEEK_SIGN", -- 俱乐部七日签到
    COLLECT_CODE = "COLLECT_CODE", -- 春节集码活动
    WEN_JUAN = "WEN_JUAN", -- 调查问卷
	UFO_CATCHER = "UFO_CATCHER", -- 抓娃娃
	CLUB_KOI = "CLUB_KOI", -- 俱乐部锦鲤活动
}

--竞彩相关 
--押注队伍
ns.stakeTeamType = {
	home = 1,
	away = 2,
	tied = 3,
}

--押注的比赛状态
ns.betStatus = {
	canReceive = 0,
	yes = 1,
	no = 2,
	wait = 3,
	huang = 4,
	dealing = 5,
}

ns.ProgressStatus={
	uncomplete = 0,
	completed = 1,
	received = 2
}


---------------------------------------------------------------------------
local GCNewLimitedCostlessActivitySYN = class("GCNewLimitedCostlessActivitySYN", ProtocolBase)
ns.GCNewLimitedCostlessActivitySYN = GCNewLimitedCostlessActivitySYN

GCNewLimitedCostlessActivitySYN.OP_CODE = net.ProtocolCode.P_GC_NEW_LIMITED_COSTLESS_ACTIVITY_SYN
GCNewLimitedCostlessActivitySYN.CLZ_CODE = "com.kodgames.message.proto.activity.GCNewLimitedCostlessActivitySYN"

-- @param serverId: number
-- @param callback: number
function GCNewLimitedCostlessActivitySYN:ctor(serverId, callback)
	self.super.ctor(self, GCNewLimitedCostlessActivitySYN.OP_CODE, serverId, callback);
end

---------------------------------------------------------------------------
local CGLimitedCostlessActivityREQ = class("CGLimitedCostlessActivityREQ", ProtocolBase)
ns.CGLimitedCostlessActivityREQ = CGLimitedCostlessActivityREQ

CGLimitedCostlessActivityREQ.OP_CODE = net.ProtocolCode.P_CG_LIMITED_COSTLESS_ACTIVITY_REQ
CGLimitedCostlessActivityREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CGLimitedCostlessActivityREQ"

-- @param serverId: number
-- @param callback: number
function CGLimitedCostlessActivityREQ:ctor(serverId, callback)
	self.super.ctor(self, CGLimitedCostlessActivityREQ.OP_CODE, serverId, callback);
end

---------------------------------------------------------------------------
local GCLimitedCostlessActivityRES = class("GCLimitedCostlessActivityRES", ProtocolBase)
ns.GCLimitedCostlessActivityRES = GCLimitedCostlessActivityRES

GCLimitedCostlessActivityRES.OP_CODE = net.ProtocolCode.P_GC_LIMITED_COSTLESS_ACTIVITY_RES
GCLimitedCostlessActivityRES.CLZ_CODE = "com.kodgames.message.proto.activity.GCLimitedCostlessActivityRES"

-- @param serverId: number
-- @param callback: number
function GCLimitedCostlessActivityRES:ctor(serverId, callback)
	self.super.ctor(self, GCLimitedCostlessActivityRES.OP_CODE, serverId, callback);
end

----------------------------
local CACQueryShareRewardsREQ = class("CACQueryShareRewardsREQ", ProtocolBase)
ns.CACQueryShareRewardsREQ = CACQueryShareRewardsREQ

CACQueryShareRewardsREQ.OP_CODE = net.ProtocolCode.P_CAC_QUERY_SHARE_REWARDS_REQ
CACQueryShareRewardsREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACQueryShareRewardsREQ"
-- @param serverId: number
-- @param callback: number
function CACQueryShareRewardsREQ:ctor(serverId, callback)
	self.super.ctor(self, CACQueryShareRewardsREQ.OP_CODE, serverId, callback);
end

----------------------------
local ACCQueryShareRewardsRES = class("ACCQueryShareRewardsRES", ProtocolBase)
ns.ACCQueryShareRewardsRES = ACCQueryShareRewardsRES

ACCQueryShareRewardsRES.OP_CODE = net.ProtocolCode.P_ACC_QUERY_SHARE_REWARDS_RES
ACCQueryShareRewardsRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCQueryShareRewardsRES"
-- @param serverId: number
-- @param callback: number
function ACCQueryShareRewardsRES:ctor(serverId, callback)
	self.super.ctor(self, ACCQueryShareRewardsRES.OP_CODE, serverId, callback);
end
----------------------------------------------------------------------
local CACQueryPickRewardREQ = class("CACQueryPickRewardREQ", ProtocolBase)
ns.CACQueryPickRewardREQ = CACQueryPickRewardREQ

CACQueryPickRewardREQ.OP_CODE = net.ProtocolCode.P_CAC_QUERY_PICK_REWARD_REQ
CACQueryPickRewardREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACQueryPickRewardREQ"

-- @param serverId: number
-- @param callback: number
function CACQueryPickRewardREQ:ctor(serverId, callback)
	self.super.ctor(self, CACQueryPickRewardREQ.OP_CODE, serverId, callback);
end

function CACQueryPickRewardREQ:setData( inviteType, pick)
    local protocolBuf = self:getProtocolBuf();
	protocolBuf.inviteType = inviteType
	protocolBuf.pick = pick
end
----------------------------------------------------------------------
local CACQueryPickRewardRES = buildMessage("CACQueryPickRewardRES")
CACQueryPickRewardRES.OP_CODE = Code.P_ACC_QUERY_PICK_REWARD_RES

-- 请求竞彩信息
----------------------------
local CGQueryLotteryInfoREQ = class("CGQueryLotteryInfoREQ", ProtocolBase)
ns.CGQueryLotteryInfoREQ = CGQueryLotteryInfoREQ

CGQueryLotteryInfoREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_LOTTERY_INFO_REQ
CGQueryLotteryInfoREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CGQueryLotteryInfoREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryLotteryInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryLotteryInfoREQ.OP_CODE, serverId, callback);
end

function CGQueryLotteryInfoREQ:setData(area, operate)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area
	protocolBuf.operate = operate	
end

-- 请求竞彩信息返回
----------------------------
local GCQueryLotteryInfoRES = class("GCQueryLotteryInfoRES", ProtocolBase)
ns.GCQueryLotteryInfoRES = GCQueryLotteryInfoRES

GCQueryLotteryInfoRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_LOTTERY_INFO_RES
GCQueryLotteryInfoRES.CLZ_CODE = "com.kodgames.message.proto.activity.GCQueryLotteryInfoRES"

-- @param serverId: number
-- @param callback: number
function GCQueryLotteryInfoRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryLotteryInfoRES.OP_CODE, serverId, callback);
end



-- 请求押注
----------------------------
local CGQueryStakeREQ = class("CGQueryStakeREQ", ProtocolBase)
ns.CGQueryStakeREQ = CGQueryStakeREQ

CGQueryStakeREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_STAKE_REQ
CGQueryStakeREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CGQueryStakeREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryStakeREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryStakeREQ.OP_CODE, serverId, callback);
end

function CGQueryStakeREQ:setData(area, id, team, money)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area
	protocolBuf.id = id
	protocolBuf.team = team
	protocolBuf.money = money
end

-- 请求押注返回
----------------------------
local GCQueryStakeRES = class("GCQueryStakeRES", ProtocolBase)
ns.GCQueryStakeRES = GCQueryStakeRES

GCQueryStakeRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_STAKE_RES
GCQueryStakeRES.CLZ_CODE = "com.kodgames.message.proto.activity.GCQueryStakeRES"

-- @param serverId: number
-- @param callback: number
function GCQueryStakeRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryStakeRES.OP_CODE, serverId, callback);
end

-- 推送赔率变化
----------------------------
local GCOddsModifySYN = class("GCOddsModifySYN", ProtocolBase)
ns.GCOddsModifySYN = GCOddsModifySYN

GCOddsModifySYN.OP_CODE = net.ProtocolCode.P_GC_ODDS_MODIFY_SYN
GCOddsModifySYN.CLZ_CODE = "com.kodgames.message.proto.activity.GCOddsModifySYN"

-- @param serverId: number
-- @param callback: number
function GCOddsModifySYN:ctor(serverId, callback)
	self.super.ctor(self, GCOddsModifySYN.OP_CODE, serverId, callback);
end



-- 请求查询玩家押注信息
----------------------------
local CGQueryPlayerBetsREQ = class("CGQueryPlayerBetsREQ", ProtocolBase)
ns.CGQueryPlayerBetsREQ = CGQueryPlayerBetsREQ

CGQueryPlayerBetsREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_PLAYER_BETS_REQ
CGQueryPlayerBetsREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CGQueryPlayerBetsREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryPlayerBetsREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryPlayerBetsREQ.OP_CODE, serverId, callback);
end
function CGQueryPlayerBetsREQ:setData(area)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area
end

-- 请求查询玩家押注信息返回
----------------------------
local GCQueryPlayerBetsRES = class("GCQueryPlayerBetsRES", ProtocolBase)
ns.GCQueryPlayerBetsRES = GCQueryPlayerBetsRES

GCQueryPlayerBetsRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_PLAYER_BETS_RES
GCQueryPlayerBetsRES.CLZ_CODE = "com.kodgames.message.proto.activity.GCQueryPlayerBetsRES"

-- @param serverId: number
-- @param callback: number
function GCQueryPlayerBetsRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryPlayerBetsRES.OP_CODE, serverId, callback);
end





-- 请求领取奖励
----------------------------
local CGQueryReceiveREQ = class("CGQueryReceiveREQ", ProtocolBase)
ns.CGQueryReceiveREQ = CGQueryReceiveREQ

CGQueryReceiveREQ.OP_CODE = net.ProtocolCode.P_CG_QUERY_RECEIVE_REQ
CGQueryReceiveREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CGQueryReceiveREQ"

-- @param serverId: number
-- @param callback: number
function CGQueryReceiveREQ:ctor(serverId, callback)
	self.super.ctor(self, CGQueryReceiveREQ.OP_CODE, serverId, callback);
end
function CGQueryReceiveREQ:setData(area, id, odds)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = area
	protocolBuf.id = id
	protocolBuf.odds = odds
end

-- 请求领取奖励返回
----------------------------
local GCQueryReceiveRES = class("GCQueryReceiveRES", ProtocolBase)
ns.GCQueryReceiveRES = GCQueryReceiveRES

GCQueryReceiveRES.OP_CODE = net.ProtocolCode.P_GC_QUERY_RECEIVE_RES
GCQueryReceiveRES.CLZ_CODE = "com.kodgames.message.proto.activity.GCQueryReceiveRES"

-- @param serverId: number
-- @param callback: number
function GCQueryReceiveRES:ctor(serverId, callback)
	self.super.ctor(self, GCQueryReceiveRES.OP_CODE, serverId, callback);
end 



-- 同步给客户端用来显示红点
----------------------------
local GCLotteryRedDotSYN = class("GCLotteryRedDotSYN", ProtocolBase)
ns.GCLotteryRedDotSYN = GCLotteryRedDotSYN

GCLotteryRedDotSYN.OP_CODE = net.ProtocolCode.P_GC_LOTTERY_RED_DOT_SYN
GCLotteryRedDotSYN.CLZ_CODE = "com.kodgames.message.proto.activity.GCLotteryRedDotSYN"

-- @param serverId: number
-- @param callback: number
function GCLotteryRedDotSYN:ctor(serverId, callback)
	self.super.ctor(self, GCLotteryRedDotSYN.OP_CODE, serverId, callback);
end

--拆红包活动
----------------------------
local CACOpenRPInfoREQ = class("CACOpenRPInfoREQ", ProtocolBase)
ns.CACOpenRPInfoREQ = CACOpenRPInfoREQ

CACOpenRPInfoREQ.OP_CODE = net.ProtocolCode.P_CAC_OPEN_RP_INFO_REQ
CACOpenRPInfoREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACOpenRPInfoREQ"


function CACOpenRPInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CACOpenRPInfoREQ.OP_CODE, serverId, callback);
end

function CACOpenRPInfoREQ:setData(areaId)	--数组索引0,1,2,3...
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = areaId
end

--拆红包活动反馈
----------------------------
local ACCOpenRPInfoRES = class("ACCOpenRPInfoRES", ProtocolBase)
ns.ACCOpenRPInfoRES = ACCOpenRPInfoRES

ACCOpenRPInfoRES.OP_CODE = net.ProtocolCode.P_ACC_OPEN_RP_INFO_RES
ACCOpenRPInfoRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCOpenRPInfoRES"

-- @param serverId: number
-- @param callback: number
function ACCOpenRPInfoRES:ctor(serverId, callback)
    self.super.ctor(self, ACCOpenRPInfoRES.OP_CODE, serverId, callback);
end


--拆红包请求
----------------------------
local CACOpenRedPackageREQ = class("CACOpenRedPackageREQ", ProtocolBase)
ns.CACOpenRedPackageREQ = CACOpenRedPackageREQ

CACOpenRedPackageREQ.OP_CODE = net.ProtocolCode.P_CAC_OPEN_RED_PACKAGE_REQ
CACOpenRedPackageREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACOpenRedPackageREQ"


function CACOpenRedPackageREQ:ctor(serverId, callback)
    self.super.ctor(self, CACOpenRedPackageREQ.OP_CODE, serverId, callback);
end

function CACOpenRedPackageREQ:setData(areaId, nType)	
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = areaId
	protocolBuf.type = nType
end

--拆红包反馈
----------------------------
local ACCOpenRedPackageRES = class("ACCOpenRPInfoRES", ProtocolBase)
ns.ACCOpenRedPackageRES = ACCOpenRedPackageRES

ACCOpenRedPackageRES.OP_CODE = net.ProtocolCode.P_ACC_OPEN_RED_PACKAGE_RES
ACCOpenRedPackageRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCOpenRedPackageRES"

-- @param serverId: number
-- @param callback: number
function ACCOpenRedPackageRES:ctor(serverId, callback)
    self.super.ctor(self, ACCOpenRedPackageRES.OP_CODE, serverId, callback);
end

--提现请求
----------------------------
local CACWithdrawREQ = class("CACWithdrawREQ", ProtocolBase)
ns.CACWithdrawREQ = CACWithdrawREQ

CACWithdrawREQ.OP_CODE = net.ProtocolCode.P_CAC_WITHDRAW_REQ
CACWithdrawREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACWithdrawREQ"


function CACWithdrawREQ:ctor(serverId, callback)
    self.super.ctor(self, CACWithdrawREQ.OP_CODE, serverId, callback);
end

function CACWithdrawREQ:setData(areaId, money, longitude, latitude, deviceId, bNew)	--area，钱，经度，维度，设备号
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = areaId
	protocolBuf.money = money
	protocolBuf.longitude = longitude
	protocolBuf.latitude = latitude
	protocolBuf.deviceId = deviceId
	protocolBuf.isNew = bNew
end

--提现反馈
----------------------------
local ACCWithdrawRES = class("ACCWithdrawRES", ProtocolBase)
ns.ACCWithdrawRES = ACCWithdrawRES

ACCWithdrawRES.OP_CODE = net.ProtocolCode.P_ACC_WITHDRAW_RES
ACCWithdrawRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCWithdrawRES"

-- @param serverId: number
-- @param callback: number
function ACCWithdrawRES:ctor(serverId, callback)
    self.super.ctor(self, ACCWithdrawRES.OP_CODE, serverId, callback);
end


--拆记录请求
----------------------------
local CACWithdrawRecordREQ = class("CACWithdrawRecordREQ", ProtocolBase)
ns.CACWithdrawRecordREQ = CACWithdrawRecordREQ

CACWithdrawRecordREQ.OP_CODE = net.ProtocolCode.P_CAC_WITHDRAW_RECORD_REQ
CACWithdrawRecordREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACWithdrawRecordREQ"


function CACWithdrawRecordREQ:ctor(serverId, callback)
    self.super.ctor(self, CACWithdrawRecordREQ.OP_CODE, serverId, callback);
end

function CACWithdrawRecordREQ:setData(areaId)	--area
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.area = areaId
end

--提现反馈
----------------------------
local ACCWithdrawRecordRES = class("ACCWithdrawRecordRES", ProtocolBase)
ns.ACCWithdrawRecordRES = ACCWithdrawRecordRES

ACCWithdrawRecordRES.OP_CODE = net.ProtocolCode.P_ACC_WITHDRAW_RECORD_RES
ACCWithdrawRecordRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCWithdrawRecordRES"

-- @param serverId: number
-- @param callback: number
function ACCWithdrawRecordRES:ctor(serverId, callback)
    self.super.ctor(self, ACCWithdrawRecordRES.OP_CODE, serverId, callback);
end

-- 活动信息同步
local ACCActivityInfoSYN = buildMessage("ACCActivityInfoSYN")
ACCActivityInfoSYN.OP_CODE = Code.P_ACC_ACTIVITY_INFO_SYN

local ACCActivityInfoUpdateSYN = buildMessage("ACCActivityInfoUpdateSYN")
ACCActivityInfoUpdateSYN.OP_CODE = Code.P_ACC_ACTIVITY_INFO_UPDATE_SYN

-- 请求大厅分享活动
local CACMainSceneShareQueryREQ = buildMessage("CACMainSceneShareQueryREQ")
CACMainSceneShareQueryREQ.OP_CODE = Code.P_CAC_MAINSCENE_SHARE_QUERY_REQ

local ACCMainSceneShareQueryRES = buildMessage("ACCMainSceneShareQueryRES")
ACCMainSceneShareQueryRES.OP_CODE = Code.P_ACC_MAINSCENE_SHARE_QUERY_RES
ACCMainSceneShareQueryRES.SUCCESS_CODE = Code.ACC_MAINSCENE_SHARE_QUERY_SUCCESS

-- 请求领取大厅分享活动奖励
local CACMainSceneSharePickREQ = buildMessage("CACMainSceneSharePickREQ")
CACMainSceneSharePickREQ.OP_CODE = Code.P_CAC_MAINSCENE_SHARE_PICK_REQ

local ACCMainSceneSharePickRES = buildMessage("ACCMainSceneSharePickRES")
ACCMainSceneSharePickRES.OP_CODE = Code.P_ACC_MAINSCENE_SHARE_PICK_RES
ACCMainSceneSharePickRES.SUCCESS_CODE = Code.ACC_MAINSCENE_SHARE_PICK_SUCCESS

-- 请求提交新玩家标记答案
local CACNewPlayerInfoREQ = class("CACNewPlayerInfoREQ", ProtocolBase)
ns.CACNewPlayerInfoREQ = CACNewPlayerInfoREQ
CACNewPlayerInfoREQ.OP_CODE = net.ProtocolCode.P_CAC_NEW_PLAYER_INFO_REQ
CACNewPlayerInfoREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACNewPlayerInfoREQ"
function CACNewPlayerInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CACNewPlayerInfoREQ.OP_CODE, serverId, callback);
end
function CACNewPlayerInfoREQ:setData(answer)
	local protocolBuf = self:getProtocolBuf();
	protocolBuf.answer = answer
end

local ACCNewPlayerInfoRES = class("ACCNewPlayerInfoRES", ProtocolBase)
ns.ACCNewPlayerInfoRES = ACCNewPlayerInfoRES
ACCNewPlayerInfoRES.OP_CODE = net.ProtocolCode.P_ACC_NEW_PLAYER_INFO_RES
ACCNewPlayerInfoRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCNewPlayerInfoRES"
function ACCNewPlayerInfoRES:ctor(serverId, callback)
	self.super.ctor(self, ACCNewPlayerInfoRES.OP_CODE, serverId, callback);
end

-- 同步玩家礼券数量
local ACCPlayWinPrizeSYN = buildMessage("ACCPlayWinPrizeSYN")
ACCPlayWinPrizeSYN.OP_CODE = Code.P_ACC_PLAY_WIN_PRIZE_SYN

-- 请求问卷调查
local CACQueryQuestionnaireREQ = class("CACQueryQuestionnaireREQ", ProtocolBase)
ns.CACQueryQuestionnaireREQ = CACQueryQuestionnaireREQ
CACQueryQuestionnaireREQ.OP_CODE = net.ProtocolCode.P_CAC_QUERY_QUESTIONNAIRE_REQ
CACQueryQuestionnaireREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACQueryQuestionnaireREQ"
function CACQueryQuestionnaireREQ:ctor(serverId, callback)
	self.super.ctor(self, CACQueryQuestionnaireREQ.OP_CODE, serverId, callback);
end

local ACCQueryQuestionnaireRES = class("ACCQueryQuestionnaireRES", ProtocolBase)
ns.ACCQueryQuestionnaireRES = ACCQueryQuestionnaireRES
ACCQueryQuestionnaireRES.OP_CODE = net.ProtocolCode.P_ACC_QUERY_QUESTIONNAIRE_RES
ACCQueryQuestionnaireRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCQueryQuestionnaireRES"
function ACCQueryQuestionnaireRES:ctor(serverId, callback)
	self.super.ctor(self, ACCQueryQuestionnaireRES.OP_CODE, serverId, callback);
end

-- 同步调查问卷结果
local ACCQuestionnaireResultSYN = buildMessage("ACCQuestionnaireResultSYN")
ACCQuestionnaireResultSYN.OP_CODE = Code.P_ACC_QUESTIONNAIRE_RESULT_SYN

-- 领取问卷调查奖励
local CACQuestionnaireRewardREQ = buildMessage("CACQuestionnaireRewardREQ")
CACQuestionnaireRewardREQ.OP_CODE = Code.P_CAC_QUESTIONNAIRE_REWARD_REQ

local ACCQuestionnaireRewardRES = buildMessage("ACCQuestionnaireRewardRES")
ACCQuestionnaireRewardRES.OP_CODE = Code.P_ACC_QUESTIONNAIRE_REWARD_RES
ACCQuestionnaireRewardRES.SUCCESS_CODE = Code.ACC_QUESTIONNAIRE_REWARD_SUCCESS

-- 请求翻牌有奖活动信息
local CACFlopHavePrizeREQ = buildMessage("CACFlopHavePrizeREQ")
CACFlopHavePrizeREQ.OP_CODE = Code.P_CAC_FLOP_HAVE_PRIZE_REQ

local ACCFlopHavePrizeRES = buildMessage("ACCFlopHavePrizeRES")
ACCFlopHavePrizeRES.OP_CODE = Code.P_ACC_FLOP_HAVE_PRIZE_RES
ACCFlopHavePrizeRES.SUCCESS_CODE = Code.ACC_FLOP_HAVE_PRIZE_SUCCESS

-- 请求抽奖(请求翻牌)
local CACSelectPrizeREQ = buildMessage("CACSelectPrizeREQ")
CACSelectPrizeREQ.OP_CODE = Code.P_CAC_SELECT_PRIZE_REQ

local ACCSelectPrizeRES = buildMessage("ACCSelectPrizeRES")
ACCSelectPrizeRES.OP_CODE = Code.P_ACC_SELECT_PRIZE_RES
ACCSelectPrizeRES.SUCCESS_CODE = Code.ACC_SELECT_PRIZE_SUCCESS

-- 请求翻牌有奖任务信息
local CACFlopHavePrizeTaskREQ = buildMessage("CACFlopHavePrizeTaskREQ")
CACFlopHavePrizeTaskREQ.OP_CODE = Code.P_CAC_FLOP_HAVE_PRIZE_TASK_REQ

local ACCFlopHavePrizeTaskRES = buildMessage("ACCFlopHavePrizeTaskRES")
ACCFlopHavePrizeTaskRES.OP_CODE = Code.P_ACC_FLOP_HAVE_PRIZE_TASK_RES
ACCFlopHavePrizeTaskRES.SUCCESS_CODE = Code.ACC_FLOP_HAVE_PRIZE_TASK_SUCCESS

-- 请求翻牌有奖活动获奖记录
local CACFlopGetPrizeRecordREQ = buildMessage("CACFlopGetPrizeRecordREQ")
CACFlopGetPrizeRecordREQ.OP_CODE = Code.P_CAC_FLOP_GET_PRIZE_RECORD_REQ

local ACCFlopGetPrizeRecordRES = buildMessage("ACCFlopGetPrizeRecordRES")
ACCFlopGetPrizeRecordRES.OP_CODE = Code.P_ACC_FLOP_GET_PRIZE_RECORD_RES
ACCFlopGetPrizeRecordRES.SUCCESS_CODE = Code.ACC_FLOP_GET_PRIZE_RECORD_SUCCESS

-- 请求翻牌分享任务
local CACShareFlopPrizeREQ = buildMessage("CACShareFlopPrizeREQ")
CACShareFlopPrizeREQ.OP_CODE = Code.P_CAC_SHARE_FLOP_PRIZE_REQ

local ACCShareFlopPrizeRES = buildMessage("ACCShareFlopPrizeRES")
ACCShareFlopPrizeRES.OP_CODE = Code.P_ACC_SHARE_FLOP_PRIZE_RES
ACCShareFlopPrizeRES.SUCCESS_CODE = Code.ACC_SHARE_FLOP_PRIZE_SUCCESS

-- 请求查询翻牌幸运名单
local CACFlopWinnerListREQ = buildMessage("CACFlopWinnerListREQ")
CACFlopWinnerListREQ.OP_CODE = Code.P_CAC_FLOP_WINNER_LIST_REQ

local ACCFlopWinnerListRES = buildMessage("ACCFlopWinnerListRES")
ACCFlopWinnerListRES.OP_CODE = Code.P_ACC_FLOP_WINNER_LIST_RES
ACCFlopWinnerListRES.SUCCESS_CODE = Code.ACC_FLOP_WINNER_LIST_SUCCESS

-- 请求翻牌礼包信息
local CACFlopGiftPackageInfoREQ = buildMessage("CACFlopGiftPackageInfoREQ")
CACFlopGiftPackageInfoREQ.OP_CODE = Code.P_CAC_FLOP_GIFT_PACKAGE_INFO_REQ

local ACCFlopGiftPackageInfoRES = buildMessage("ACCFlopGiftPackageInfoRES")
ACCFlopGiftPackageInfoRES.OP_CODE = Code.P_ACC_FLOP_GIFT_PACKAGE_INFO_RES
ACCFlopGiftPackageInfoRES.SUCCESS_CODE = Code.ACC_FLOP_GIFT_PACKAGE_INFO_SUCCESS

-- 请求领取礼包
local CACFlopReceiveGiftPackageREQ = buildMessage("CACFlopReceiveGiftPackageREQ")
CACFlopReceiveGiftPackageREQ.OP_CODE = Code.P_CAC_FLOP_RECEIVE_GIFT_PACKAGE_REQ

local ACCFlopReceiveGiftPackageRES = buildMessage("ACCFlopReceiveGiftPackageRES")
ACCFlopReceiveGiftPackageRES.OP_CODE = Code.P_ACC_FLOP_RECEIVE_GIFT_PACKAGE_RES
ACCFlopReceiveGiftPackageRES.SUCCESS_CODE = Code.ACC_FLOP_RECEIVE_GIFT_PACKAGE_SUCCESS

-- 请求房卡兑换抽奖机会
local CACFlopCardBuyREQ = buildMessage("CACFlopCardBuyREQ")
CACFlopCardBuyREQ.OP_CODE = Code.P_CAC_FLOP_CARD_BUY_REQ

local ACCFlopCardBuyRES = buildMessage("ACCFlopCardBuyRES")
ACCFlopCardBuyRES.OP_CODE = Code.P_ACC_FLOP_CARD_BUY_RES
ACCFlopCardBuyRES.SUCCESS_CODE = Code.ACC_FLOP_CARD_BUY_SUCCESS

-- 请求摇一摇信息
local CACQueryLuckyDrawREQ = buildMessage("CACQueryLuckyDrawREQ")
CACQueryLuckyDrawREQ.OP_CODE = Code.P_CAC_QUERY_LUCKY_DRAW_REQ

local ACCQueryLuckyDrawRES = buildMessage("ACCQueryLuckyDrawRES")
ACCQueryLuckyDrawRES.OP_CODE = Code.P_ACC_QUERY_LUCKY_DRAW_RES
ACCQueryLuckyDrawRES.SUCCESS_CODE = Code.ACC_QUERY_LUCKY_DRAW_SUCCESS

-- 请求摇奖
local CACQueryDrawREQ = buildMessage("CACQueryDrawREQ")
CACQueryDrawREQ.OP_CODE = Code.P_CAC_QUERY_DRAW_REQ

local ACCQueryDrawRES = buildMessage("ACCQueryDrawRES")
ACCQueryDrawRES.OP_CODE = Code.P_ACC_QUERY_DRAW_RES
ACCQueryDrawRES.SUCCESS_CODE = Code.ACC_QUERY_DRAW_SUCCESS

-- 请求查询摇一摇记录
local CACQueryDrawRecordREQ = buildMessage("CACQueryDrawRecordREQ")
CACQueryDrawRecordREQ.OP_CODE = Code.P_CAC_QUERY_DRAW_RECORD_REQ

local ACCQueryDrawRecordRES = buildMessage("ACCQueryDrawRecordRES")
ACCQueryDrawRecordRES.OP_CODE = Code.P_ACC_QUERY_DRAW_RECORD_RES
ACCQueryDrawRecordRES.SUCCESS_CODE = Code.ACC_QUERY_DRAW_RECORD_SUCCESS

-- 请求查询活动(七天登录)
local CACQueryWeekREQ = buildMessage("CACQueryWeekREQ")
CACQueryWeekREQ.OP_CODE = Code.P_CAC_QUERY_WEEK_REQ

local ACCQueryWeekRES = buildMessage("ACCQueryWeekRES")
ACCQueryWeekRES.OP_CODE = Code.P_ACC_QUERY_WEEK_RES
ACCQueryWeekRES.SUCCESS_CODE = Code.ACC_QUERY_WEEK_SUCCESS

-- 请求签到、补签、分享等
local CACQuerySignInREQ = buildMessage("CACQuerySignInREQ")
CACQuerySignInREQ.OP_CODE = Code.P_CAC_QUERY_SIGN_IN_REQ

local ACCQuerySignInRES = buildMessage("ACCQuerySignInRES")
ACCQuerySignInRES.OP_CODE = Code.P_ACC_QUERY_SING_IN_RES
ACCQuerySignInRES.SUCCESS_CODE = Code.ACC_QUERY_SING_IN_SUCCESS

-- 请求查询玩家分享活动进度
local CACShareActivityInfoREQ = buildMessage("CACShareActivityInfoREQ")
CACShareActivityInfoREQ.OP_CODE = Code.P_CAC_SHARE_ACTIVITY_INFO_REQ

local ACCShareActivityInfoRES = buildMessage("ACCShareActivityInfoRES")
ACCShareActivityInfoRES.OP_CODE = Code.P_ACC_SHARE_ACTIVITY_INFO_RES
ACCShareActivityInfoRES.SUCCESS_CODE = Code.ACC_SHARE_ACTIVITY_INFO_SUCCESS

-- 请求领取分享活动奖励
local CACReceiveShareActivityRewardREQ = buildMessage("CACReceiveShareActivityRewardREQ")
CACReceiveShareActivityRewardREQ.OP_CODE = Code.P_CAC_RECEIVE_SHARE_ACTIVITY_REWARD_REQ

local ACCReceiveShareActivityRewardRES = buildMessage("ACCReceiveShareActivityRewardRES")
ACCReceiveShareActivityRewardRES.OP_CODE = Code.P_ACC_RECEIVE_SHARE_ACTIVITY_REWARD_RES
ACCReceiveShareActivityRewardRES.SUCCESS_CODE = Code.ACC_RECEIVE_SHARE_ACTIVITY_REWARD_SUCCESS

-- 请求七夕充值活动信息
local CACMagpieRechargeActivityREQ = buildMessage("CACMagpieRechargeActivityREQ")
CACMagpieRechargeActivityREQ.OP_CODE = Code.P_CAC_MAGPIE_RECHARGE_ACTIVITY_REQ

local ACCMagpieRechargeActivityRES = buildMessage("ACCMagpieRechargeActivityRES")
ACCMagpieRechargeActivityRES.OP_CODE = Code.P_ACC_MAGPIE_RECHARGE_ACTIVITY_RES
ACCMagpieRechargeActivityRES.SUCCESS_CODE = Code.ACC_MAGPIE_RECHARGE_ACTIVITY_SUCCESS

-- 七夕充值成功通知
local ACCMagpieRewardSYN = buildMessage("ACCMagpieRewardSYN")
ACCMagpieRewardSYN.OP_CODE = Code.P_ACC_MAGPIE_REWARD_SYN

-- 请求查询七夕二丁拐完成进度
local CACMagpieWorldProgressREQ = buildMessage("CACMagpieWorldProgressREQ")
CACMagpieWorldProgressREQ.OP_CODE = Code.P_CAC_MAGPIE_WORLD_PROGRESS_REQ

local ACCMagpieWorldProgressRES = buildMessage("ACCMagpieWorldProgressRES")
ACCMagpieWorldProgressRES.OP_CODE = Code.P_ACC_MAGPIE_WORLD_PROGRESS_RES
ACCMagpieWorldProgressRES.SUCCESS_CODE = Code.ACC_MAGPIE_WORLD_PROGRESS_SUCCESS

-- 请求查询七夕二丁拐奖励名单
local CACMagpieWorldWinnerListREQ = buildMessage("CACMagpieWorldWinnerListREQ")
CACMagpieWorldWinnerListREQ.OP_CODE = Code.P_CAC_MAGPIE_WORLD_WINNER_LIST_REQ

local ACCMagpieWorldWinnerListRES = buildMessage("ACCMagpieWorldWinnerListRES")
ACCMagpieWorldWinnerListRES.OP_CODE = Code.P_ACC_MAGPIE_WORLD_WINNER_LIST_RES
ACCMagpieWorldWinnerListRES.SUCCESS_CODE = Code.ACC_MAGPIE_WORLD_WINNER_LIST_SUCCESS

-- 请求领取进度奖励
local CACMagpieWorldReceiveRewardREQ = buildMessage("CACMagpieWorldReceiveRewardREQ")
CACMagpieWorldReceiveRewardREQ.OP_CODE = Code.P_CAC_MAGPIE_WORLD_RECEIVE_REWARD_REQ

local ACCMagpieWorldReceiveRewardRES = buildMessage("ACCMagpieWorldReceiveRewardRES")
ACCMagpieWorldReceiveRewardRES.OP_CODE = Code.P_ACC_MAGPIE_WORLD_RECEIVE_REWARD_RES
ACCMagpieWorldReceiveRewardRES.SUCCESS_CODE = Code.ACC_MAGPIE_WORLD_RECEIVE_REWARD_SUCCESS

-- 请求查询二丁拐中奖纪录
local CACMagpiePrizeRecordREQ = buildMessage("CACMagpiePrizeRecordREQ")
CACMagpiePrizeRecordREQ.OP_CODE = Code.P_CAC_MAGPIE_PRIZE_RECORD_REQ

local ACCMagpiePrizeRecordRES = buildMessage("ACCMagpiePrizeRecordRES")
ACCMagpiePrizeRecordRES.OP_CODE = Code.P_ACC_MAGPIE_PRIZE_RECORD_RES
ACCMagpiePrizeRecordRES.SUCCESS_CODE = Code.ACC_MAGPIE_PRIZE_RECORD_SUCCESS

-- 请求查询月签到状态
local CACMonthSignInfoREQ = buildMessage("CACMonthSignInfoREQ")
CACMonthSignInfoREQ.OP_CODE = Code.P_CAC_MONTH_SIGN_INFO_REQ

local ACCMonthSignInfoRES = buildMessage("ACCMonthSignInfoRES")
ACCMonthSignInfoRES.OP_CODE = Code.P_ACC_MONTH_SIGN_INFO_RES
ACCMonthSignInfoRES.SUCCESS_CODE = Code.ACC_MONTH_SIGN_INFO_SUCCESS

-- 请求签到或补签
local CACMonthSignInREQ = buildMessage("CACMonthSignInREQ")
CACMonthSignInREQ.OP_CODE = Code.P_CAC_MONTH_SIGN_IN_REQ

local ACCMonthSignInRES = buildMessage("ACCMonthSignInRES")
ACCMonthSignInRES.OP_CODE = Code.P_ACC_MONTH_SIGN_IN_RES
ACCMonthSignInRES.SUCCESS_CODE = Code.ACC_MONTH_SIGN_IN_SUCCESS

-- 求领取奖励
local CACMonthReceiveRewardREQ = buildMessage("CACMonthReceiveRewardREQ")
CACMonthReceiveRewardREQ.OP_CODE = Code.P_CAC_MONTH_RECEIVE_REWARD_REQ

local ACCMonthReceiveRewardRES = buildMessage("ACCMonthReceiveRewardRES")
ACCMonthReceiveRewardRES.OP_CODE = Code.P_ACC_MONTH_RECEIVE_REWARD_RES
ACCMonthReceiveRewardRES.SUCCESS_CODE = Code.ACC_MONTH_RECEIVE_REWARD_SUCCESS

-- 请求绑定手机
local CACPhoneBindREQ = buildMessage("CACPhoneBindREQ")
CACPhoneBindREQ.OP_CODE = Code.P_CAC_PHONE_BIND_REQ

local ACCPhoneBindRES = buildMessage("ACCPhoneBindRES")
ACCPhoneBindRES.OP_CODE = Code.P_ACC_PHONE_BIND_RES
-- ACCPhoneBindRES.SUCCESS_CODE = Code.

-- 回流每日分享请求
local CACBackShareREQ = buildMessage("CACBackShareREQ")
CACBackShareREQ.OP_CODE = Code.P_CAC_BACK_SHARE_REQ

local ACCBackShareRES = buildMessage("ACCBackShareRES")
ACCBackShareRES.OP_CODE = Code.P_ACC_BACK_SHARE_RES
ACCBackShareRES.SUCCESS_CODE = Code.ACC_BACK_SHARE_SUCCESS

-- 通用户活动信息请求
local CACBackInfoOrdinaryUserREQ = buildMessage("CACBackInfoOrdinaryUserREQ")
CACBackInfoOrdinaryUserREQ.OP_CODE = Code.P_CAC_BACK_INFO_ORDINARY_USER_REQ

local ACCBackInfoOrdinaryUserRES = buildMessage("ACCBackInfoOrdinaryUserRES")
ACCBackInfoOrdinaryUserRES.OP_CODE = Code.P_ACC_BACK_INFO_ORDINARY_USER_RES
ACCBackInfoOrdinaryUserRES.SUCCESS_CODE = Code.ACC_BACK_INFO_ORDINARY_USER_SUCCESS

-- 请求签到
local CACBackSignREQ = buildMessage("CACBackSignREQ")
CACBackSignREQ.OP_CODE = Code.P_CAC_BACK_SIGN_REQ

local ACCBackSignRES = buildMessage("ACCBackSignRES")
ACCBackSignRES.OP_CODE = Code.P_ACC_BACK_SIGN_RES
ACCBackSignRES.SUCCESS_CODE = Code.ACC_BACK_SIGN_SUCCESS

-- 俱乐部经理活动信息请求
local CACBackInfoClubManagerREQ = buildMessage("CACBackInfoClubManagerREQ")
CACBackInfoClubManagerREQ.OP_CODE = Code.P_CAC_BACK_INFO_CLUB_MANAGER_REQ

local ACCBackInfoClubManagerRES = buildMessage("ACCBackInfoClubManagerRES")
ACCBackInfoClubManagerRES.OP_CODE = Code.P_ACC_BACK_INFO_CLUB_MANAGER_RES
ACCBackInfoClubManagerRES.SUCCESS_CODE = Code.ACC_BACK_INFO_CLUB_MANAGER_SUCCESS

-- 查询经理邀请到的回流用户
local CACBackCheckBindUserREQ = buildMessage("CACBackCheckBindUserREQ")
CACBackCheckBindUserREQ.OP_CODE = Code.P_CAC_BACK_CHECK_BIND_USER_REQ

local ACCBackCheckBindUserRES = buildMessage("ACCBackCheckBindUserRES")
ACCBackCheckBindUserRES.OP_CODE = Code.P_ACC_BACK_CHECK_BIND_USER_RES
ACCBackCheckBindUserRES.SUCCESS_CODE = Code.ACC_BACK_CHECK_BIND_USER_SUCCESS

-- 提取房卡数量请求
local CACBackExtractCardREQ = buildMessage("CACBackExtractCardREQ")
CACBackExtractCardREQ.OP_CODE = Code.P_CAC_BACK_EXTRACT_CARD_REQ

local ACCBackExtractCardRES = buildMessage("ACCBackExtractCardRES")
ACCBackExtractCardRES.OP_CODE = Code.P_ACC_BACK_EXTRACT_CARD_RES
ACCBackExtractCardRES.SUCCESS_CODE = Code.ACC_BACK_EXTRACT_CARD_SUCCESS

-- 俱乐部回流活动延长通知
local ACCBackClubDelaySYN = buildMessage("ACCBackClubDelaySYN")
ACCBackClubDelaySYN.OP_CODE = Code.P_ACC_BACK_CLUB_DELAY_SYN

-- 祈福活动信息请求
local CACPrayInfoREQ = buildMessage("CACPrayInfoREQ")
CACPrayInfoREQ.OP_CODE = Code.P_CAC_PRAY_INFO_REQ

local ACCPrayInfoRES = buildMessage("ACCPrayInfoRES")
ACCPrayInfoRES.OP_CODE = Code.P_ACC_PRAY_INFO_RES
ACCPrayInfoRES.SUCCESS_CODE = Code.ACC_PRAY_INFO_SUCCESS

-- 祈福请求
local CACPrayREQ = buildMessage("CACPrayREQ")
CACPrayREQ.OP_CODE = Code.P_CAC_PRAY_REQ

local ACCPrayRES = buildMessage("ACCPrayRES")
ACCPrayRES.OP_CODE = Code.P_ACC_PRAY_RES
ACCPrayRES.SUCCESS_CODE = Code.ACC_PRAY_SUCCESS

-- 祈福签到活动信息请求
local CACPraySignInfoREQ = buildMessage("CACPraySignInfoREQ")
CACPraySignInfoREQ.OP_CODE = Code.P_CAC_PRAY_SIGN_INFO_REQ

local ACCPraySignInfoRES = buildMessage("ACCPraySignInfoRES")
ACCPraySignInfoRES.OP_CODE = Code.P_ACC_PRAY_SIGN_INFO_RES
ACCPraySignInfoRES.SUCCESS_CODE = Code.ACC_PRAY_SIGN_INFO_SUCCESS

-- 请求签到
local CACPraySignREQ = buildMessage("CACPraySignREQ")
CACPraySignREQ.OP_CODE = Code.P_CAC_PRAY_SIGN_REQ

local ACCPraySignRES = buildMessage("ACCPraySignRES")
ACCPraySignRES.OP_CODE = Code.P_ACC_PRAY_SIGN_RES
ACCPraySignRES.SUCCESS_CODE = Code.ACC_PRAY_SIGN_SUCCESS

-- 请求洒落礼包
local CACThrowRewardInfoREQ = buildMessage("CACThrowRewardInfoREQ")
CACThrowRewardInfoREQ.OP_CODE = Code.P_CAC_THROW_REWARD_INFO_REQ

local ACCThrowRewardInfoRES = buildMessage("ACCThrowRewardInfoRES")
ACCThrowRewardInfoRES.OP_CODE = Code.P_ACC_THROW_REWARD_INFO_RES
ACCThrowRewardInfoRES.SUCCESS_CODE = Code.ACC_THROW_REWARD_INFO_SUCCESS

-- 请求拆礼包
local CACThrowRewardOpenREQ = buildMessage("CACThrowRewardOpenREQ")
CACThrowRewardOpenREQ.OP_CODE = Code.P_CAC_THROW_REWARD_OPEN_REQ

local ACCThrowRewardOpenRES = buildMessage("ACCThrowRewardOpenRES")
ACCThrowRewardOpenRES.OP_CODE = Code.P_ACC_THROW_REWARD_OPEN_RES
ACCThrowRewardOpenRES.SUCCESS_CODE = Code.ACC_THROW_REWARD_OPEN_SUCCESS

-- 洒落礼包分享
local CACThrowRewardShareREQ = buildMessage("CACThrowRewardShareREQ")
CACThrowRewardShareREQ.OP_CODE = Code.P_CAC_THROW_REWARD_SHARE_REQ

local ACCThrowRewardShareRES = buildMessage("ACCThrowRewardShareRES")
ACCThrowRewardShareRES.OP_CODE = Code.P_ACC_THROW_REWARD_SHARE_RES
ACCThrowRewardShareRES.SUCCESS_CODE = Code.ACC_THROW_REWARD_SHARE_SUCCESS

-- 春节邀新相关协议
----------------------------
-- 请求拜财神活动信息
local CACGodOfWealthInfoREQ = class("CACGodOfWealthInfoREQ", ProtocolBase)
ns.CACGodOfWealthInfoREQ = CACGodOfWealthInfoREQ

CACGodOfWealthInfoREQ.OP_CODE = net.ProtocolCode.P_CAC_GOD_OF_WEALTH_INFO_REQ
CACGodOfWealthInfoREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACGodOfWealthInfoREQ"


function CACGodOfWealthInfoREQ:ctor(serverId, callback)
    self.super.ctor(self, CACGodOfWealthInfoREQ.OP_CODE, serverId, callback);
end

-- RES
local ACCGodOfWealthInfoRES = class("ACCGodOfWealthInfoRES", ProtocolBase)
ns.ACCGodOfWealthInfoRES = ACCGodOfWealthInfoRES

ACCGodOfWealthInfoRES.OP_CODE = net.ProtocolCode.P_ACC_GOD_OF_WEALTH_INFO_RES
ACCGodOfWealthInfoRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCGodOfWealthInfoRES"

function ACCGodOfWealthInfoRES:ctor(serverId, callback)
    self.super.ctor(self, ACCGodOfWealthInfoRES.OP_CODE, serverId, callback);
end

-- 请求拜财神
local CACGodOfWealthOpenREQ = class("CACGodOfWealthOpenREQ", ProtocolBase)
ns.CACGodOfWealthOpenREQ = CACGodOfWealthOpenREQ

CACGodOfWealthOpenREQ.OP_CODE = net.ProtocolCode.P_CAC_GOD_OF_WEALTH_OPEN_REQ
CACGodOfWealthOpenREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACGodOfWealthOpenREQ"


function CACGodOfWealthOpenREQ:ctor(serverId, callback)
    self.super.ctor(self, CACGodOfWealthOpenREQ.OP_CODE, serverId, callback);
end

-- RES
local ACCGodOfWealthOpenRES = class("ACCGodOfWealthOpenRES", ProtocolBase)
ns.ACCGodOfWealthOpenRES = ACCGodOfWealthOpenRES

ACCGodOfWealthOpenRES.OP_CODE = net.ProtocolCode.P_ACC_GOD_OF_WEALTH_OPEN_RES
ACCGodOfWealthOpenRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCGodOfWealthOpenRES"

function ACCGodOfWealthOpenRES:ctor(serverId, callback)
    self.super.ctor(self, ACCGodOfWealthOpenRES.OP_CODE, serverId, callback);
end

-- 请求拜财神记录
local CACGodOfWealthRecordREQ = class("CACGodOfWealthRecordREQ", ProtocolBase)
ns.CACGodOfWealthRecordREQ = CACGodOfWealthRecordREQ

CACGodOfWealthRecordREQ.OP_CODE = net.ProtocolCode.P_CAC_GOD_OF_WEALTH_RECORD_REQ
CACGodOfWealthRecordREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACGodOfWealthRecordREQ"


function CACGodOfWealthRecordREQ:ctor(serverId, callback)
    self.super.ctor(self, CACGodOfWealthRecordREQ.OP_CODE, serverId, callback);
end

-- RES
local ACCGodOfWealthRecordRES = class("ACCGodOfWealthRecordRES", ProtocolBase)
ns.ACCGodOfWealthRecordRES = ACCGodOfWealthRecordRES

ACCGodOfWealthRecordRES.OP_CODE = net.ProtocolCode.P_ACC_GOD_OF_WEALTH_RECORD_RES
ACCGodOfWealthRecordRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCGodOfWealthRecordRES"

function ACCGodOfWealthRecordRES:ctor(serverId, callback)
    self.super.ctor(self, ACCGodOfWealthRecordRES.OP_CODE, serverId, callback);
end

--SYN
local ACCGodOfWealthSYNC = class("ACCGodOfWealthSYNC", ProtocolBase)
ns.ACCGodOfWealthSYNC = ACCGodOfWealthSYNC

ACCGodOfWealthSYNC.OP_CODE = net.ProtocolCode.P_ACC_GOD_OF_WEALTH_SYNC
ACCGodOfWealthSYNC.CLZ_CODE = "com.kodgames.message.proto.activity.ACCGodOfWealthSYNC"

function ACCGodOfWealthSYNC:ctor(serverId, callback)
    self.super.ctor(self, ACCGodOfWealthSYNC.OP_CODE, serverId, callback);
end

-------------  俱乐部七日签到  ------------------------
local CACQueryClubWeekSignInfoREQ = class("CACQueryClubWeekSignInfoREQ", ProtocolBase)
ns.CACQueryClubWeekSignInfoREQ = CACQueryClubWeekSignInfoREQ

CACQueryClubWeekSignInfoREQ.OP_CODE = net.ProtocolCode.P_CAC_QUERY_CLUB_WEEK_SIGN_INFO_REQ
CACQueryClubWeekSignInfoREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACQueryClubWeekSignInfoREQ"

function CACQueryClubWeekSignInfoREQ:ctor(serverId, callback)
	self.super.ctor(self, CACQueryClubWeekSignInfoREQ.OP_CODE, serverId, callback)
end

function CACQueryClubWeekSignInfoREQ:setData(area)
	self:getProtocolBuf().area = area
end

local ACCQueryClubWeekSignInfoRES = class("ACCQueryClubWeekSignInfoRES", ProtocolBase)
ns.ACCQueryClubWeekSignInfoRES = ACCQueryClubWeekSignInfoRES

ACCQueryClubWeekSignInfoRES.OP_CODE = net.ProtocolCode.P_ACC_QUERY_CLUB_WEEK_SIGN_INFO_RES
ACCQueryClubWeekSignInfoRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCQueryClubWeekSignInfoRES"

function ACCQueryClubWeekSignInfoRES:ctor(serverId, callback)
	self.super.ctor(self, ACCQueryClubWeekSignInfoRES.OP_CODE, serverId, callback);
end

local CACSelectClubWeekRewardPackageREQ = class("CACSelectClubWeekRewardPackageREQ", ProtocolBase)
ns.CACSelectClubWeekRewardPackageREQ = CACSelectClubWeekRewardPackageREQ

CACSelectClubWeekRewardPackageREQ.OP_CODE = net.ProtocolCode.P_CAC_SELECT_CLUB_WEEK_REWARD_PACKAGE_REQ
CACSelectClubWeekRewardPackageREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACSelectClubWeekRewardPackageREQ"

function CACSelectClubWeekRewardPackageREQ:ctor(serverId, callback)
	self.super.ctor(self, CACSelectClubWeekRewardPackageREQ.OP_CODE, serverId, callback)
end

function CACSelectClubWeekRewardPackageREQ:setData(area, packageId)
	self:getProtocolBuf().area = area
	self:getProtocolBuf().packageId = packageId
end

local ACCSelectClubWeekRewardPackageRES = class("ACCSelectClubWeekRewardPackageRES", ProtocolBase)
ns.ACCSelectClubWeekRewardPackageRES = ACCSelectClubWeekRewardPackageRES

ACCSelectClubWeekRewardPackageRES.OP_CODE = net.ProtocolCode.P_ACC_SELECT_CLUB_WEEK_REWARD_PACKAGE_RES
ACCSelectClubWeekRewardPackageRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCSelectClubWeekRewardPackageRES"

function ACCSelectClubWeekRewardPackageRES:ctor(serverId, callback)
	self.super.ctor(self, ACCSelectClubWeekRewardPackageRES.OP_CODE, serverId, callback);
end

local CACPickClubWeekSignRewardREQ = class("CACPickClubWeekSignRewardREQ", ProtocolBase)
ns.CACPickClubWeekSignRewardREQ = CACPickClubWeekSignRewardREQ

CACPickClubWeekSignRewardREQ.OP_CODE = net.ProtocolCode.P_CAC_PICK_CLUB_WEEK_SIGN_REWARD_REQ
CACPickClubWeekSignRewardREQ.CLZ_CODE = "com.kodgames.message.proto.activity.CACPickClubWeekSignRewardREQ"

function CACPickClubWeekSignRewardREQ:ctor(serverId, callback)
	self.super.ctor(self, CACPickClubWeekSignRewardREQ.OP_CODE, serverId, callback)
end

function CACPickClubWeekSignRewardREQ:setData(area, day)
	self:getProtocolBuf().area = area
	self:getProtocolBuf().day = day
end

local ACCPickClubWeekSignRewardRES = class("ACCPickClubWeekSignRewardRES", ProtocolBase)
ns.ACCPickClubWeekSignRewardRES = ACCPickClubWeekSignRewardRES

ACCPickClubWeekSignRewardRES.OP_CODE = net.ProtocolCode.P_ACC_PICK_CLUB_WEEK_SIGN_REWARD_RES
ACCPickClubWeekSignRewardRES.CLZ_CODE = "com.kodgames.message.proto.activity.ACCPickClubWeekSignRewardRES"

function ACCPickClubWeekSignRewardRES:ctor(serverId, callback)
	self.super.ctor(self, ACCPickClubWeekSignRewardRES.OP_CODE, serverId, callback);
end

---
--- 春节集码活动
---
-- 请求集码活动信息
local CACCollectCodeInfoREQ = buildMessage("CACCollectCodeInfoREQ")
CACCollectCodeInfoREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_INFO_REQ

-- 应答集码活动信息
local ACCCollectCodeInfoRES = buildMessage("ACCCollectCodeInfoRES")
ACCCollectCodeInfoRES.OP_CODE = Code.P_ACC_COLLECT_CODE_INFO_RES
ACCCollectCodeInfoRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_INFO_SUCCESS

-- 请求分享
local CACCollectCodeShareREQ = buildMessage("CACCollectCodeShareREQ")
CACCollectCodeShareREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_SHARE_REQ

-- 应答分享
local ACCCollectCodeShareRES= buildMessage("ACCCollectCodeShareRES")
ACCCollectCodeShareRES.OP_CODE = Code.P_ACC_COLLECT_CODE_SHARE_RES
ACCCollectCodeShareRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_SHARE_SUCCESS

-- 请求抽取幸运码
local CACCollectCodeLotteryREQ = buildMessage("CACCollectCodeLotteryREQ")
CACCollectCodeLotteryREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_LOTTERY_REQ

-- 应答抽取幸运码
local ACCCollectCodeLotteryRES= buildMessage("ACCCollectCodeLotteryRES")
ACCCollectCodeLotteryRES.OP_CODE = Code.P_ACC_COLLECT_CODE_LOTTERY_RES
ACCCollectCodeLotteryRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_LOTTERY_SUCCESS

-- 领取奖励请求
local CACCollectCodeReceiveTaskRewardREQ = buildMessage("CACCollectCodeReceiveTaskRewardREQ")
CACCollectCodeReceiveTaskRewardREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_RECEIVE_TASK_REWARD_REQ

-- 领取奖励请求
local ACCCollectCodeReceiveTaskRewardRES = buildMessage("ACCCollectCodeReceiveTaskRewardRES")
ACCCollectCodeReceiveTaskRewardRES.OP_CODE = Code.P_ACC_COLLECT_CODE_RECEIVE_TASK_REWARD_RES
ACCCollectCodeReceiveTaskRewardRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_RECEIVE_TASK_REWARD_SUCCESS

-- 请求查询幸运码
local CACCollectCodeQueryCodeREQ = buildMessage("CACCollectCodeQueryCodeREQ")
CACCollectCodeQueryCodeREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_QUERY_CODE_REQ

-- 应答查询幸运码
local ACCCollectCodeQueryCodeRES = buildMessage("ACCCollectCodeQueryCodeRES")
ACCCollectCodeQueryCodeRES.OP_CODE = Code.P_ACC_COLLECT_CODE_QUERY_CODE_RES
ACCCollectCodeQueryCodeRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_QUERY_CODE_SUCCESS

-- 查询本期中奖名单
local CACCollectCodeLuckyRecordREQ = buildMessage("CACCollectCodeLuckyRecordREQ")
CACCollectCodeLuckyRecordREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_LUCKY_RECORD_REQ

-- 应答本期中奖名单
local ACCCollectCodeLuckyRecordRES = buildMessage("ACCCollectCodeLuckyRecordRES")
ACCCollectCodeLuckyRecordRES.OP_CODE = Code.P_ACC_COLLECT_CODE_LUCKY_RECORD_RES
ACCCollectCodeLuckyRecordRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_LUCKY_RECORD_SUCCESS

-- 请求领取摇奖码奖励
local CACCollectCodeReceiveLotteryRewardREQ = buildMessage("CACCollectCodeReceiveLotteryRewardREQ")
CACCollectCodeReceiveLotteryRewardREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_RECEIVE_LOTTERY_REWARD_REQ

-- 应答领取摇奖码奖励
local ACCCollectCodeReceiveLotteryRewardRES = buildMessage("ACCCollectCodeReceiveLotteryRewardRES")
ACCCollectCodeReceiveLotteryRewardRES.OP_CODE = Code.P_ACC_COLLECT_CODE_RECEIVE_LOTTERY_REWARD_RES
ACCCollectCodeReceiveLotteryRewardRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_RECEIVE_LOTTERY_REWARD_SUCCESS

-- 请求查询历史幸运码
local CACCollectCodeQueryHistoryCodeREQ = buildMessage("CACCollectCodeQueryHistoryCodeREQ")
CACCollectCodeQueryHistoryCodeREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_QUERY_HISTORY_CODE_REQ

-- 应答查询历史幸运码
local ACCCollectCodeQueryHistoryCodeRES = buildMessage("ACCCollectCodeQueryHistoryCodeRES")
ACCCollectCodeQueryHistoryCodeRES.OP_CODE = Code.P_ACC_COLLECT_CODE_QUERY_HISTORY_CODE_RES
ACCCollectCodeQueryHistoryCodeRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_QUERY_HISTORY_CODE_SUCCESS

-- 请求历史开奖纪录
local CACCollectCodeHistoryLuckyRecordREQ = buildMessage("CACCollectCodeHistoryLuckyRecordREQ")
CACCollectCodeHistoryLuckyRecordREQ.OP_CODE = Code.P_CAC_COLLECT_CODE_HISTORY_LUCKY_RECORD_REQ

-- 回复历史开奖纪录
local ACCCollectCodeHistoryLuckyRecordRES = buildMessage("ACCCollectCodeHistoryLuckyRecordRES")
ACCCollectCodeHistoryLuckyRecordRES.OP_CODE = Code.P_ACC_COLLECT_CODE_HISTORY_LUCKY_RECORD_RES
ACCCollectCodeHistoryLuckyRecordRES.SUCCESS_CODE = Code.ACC_COLLECT_CODE_HISTORY_LUCKY_RECORD_SUCCESS

---
--- 抓娃娃机活动
---
-- 请求娃娃机活动信息
buildMessage("CACCatchDollInfoREQ", Code.P_CAC_CATCH_DOLL_INFO_REQ)
-- 应答娃娃机活动信息
buildMessage("ACCCatchDollInfoRES", Code.P_ACC_CATCH_DOLL_INFO_RES, Code.ACC_CATCH_DOLL_INFO_SUCCESS)
-- 请求抓娃娃
buildMessage("CACCatchDollREQ", Code.P_CAC_CATCH_DOLL_REQ)
-- 应答抓娃娃
buildMessage("ACCCatchDollRES", Code.P_ACC_CATCH_DOLL_RES, Code.ACC_CATCH_DOLL_SUCCESS)
-- 请求娃娃机任务信息
buildMessage("CACCatchDollTaskREQ", Code.P_CAC_CATCH_DOLL_TASK_REQ)
-- 应答娃娃机任务信息
buildMessage("ACCCatchDollTaskRES", Code.P_ACC_CATCH_DOLL_TASK_RES, Code.ACC_CATCH_DOLL_TASK_SUCCESS)
-- 请求购买抓娃娃次数
buildMessage("CACBuyCatchDollREQ", Code.P_CAC_BUG_CATCH_DOLL_REQ)
-- 应答购买抓娃娃次数
buildMessage("ACCBuyCatchDollRES", Code.P_ACC_BUG_CATCH_DOLL_RES, Code.ACC_BUG_CATCH_DOLL_SUCCESS)
-- 查询娃娃机获奖记录
buildMessage("CACCatchRecordREQ", Code.P_CAC_CATCH_RECORD_REQ)
-- 应答娃娃机获奖记录
buildMessage("ACCCatchRecordRES", Code.P_ACC_CATCH_RECORD_RES, Code.ACC_CATCH_RECORD_SUCCESS)

---
-- 俱乐部锦鲤活动
---
-- 查询锦鲤活动数据
buildMessage("CACQueryKoiFishActivityInfoREQ", Code.P_CAC_QUERY_KOI_FISH_ACTIVITY_INFO_REQ)
-- 返回锦鲤活动数据
buildMessage("ACCQueryKoiFishActivityInfoRES", Code.P_ACC_QUERY_KOI_FISH_ACTIVITY_INFO_RES, Code.ACC_QUERY_KOI_FISH_ACTIVITY_INFO_SUCCESS)
-- 查询锦鲤活动数据
buildMessage("CACPickKoiFishActivityAwardREQ", Code.P_CAC_PICK_KOI_FISH_ACTIVITY_AWARD_REQ)
-- 返回锦鲤活动数据
buildMessage("ACCPickKoiFishActivityAwardRES", Code.P_ACC_PICK_KOI_FISH_ACTIVITY_AWARD_RES, Code.ACC_PICK_KOI_FISH_ACTIVITY_AWARD_SUCCESS)