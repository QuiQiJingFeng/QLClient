--[[ 跳转界面用的,每次都要去看不同地方要进行什么判断太麻烦所以写个通用的
--]]
local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst
local ns = namespace("uiSkip")
local Version = require("app.kod.util.Version")

--跳转类型
local SkipType = {
    lobby = "lobby",												--返回大厅
	club = net.protocol.ActivityTarget.CLUB,
    campaign = net.protocol.ActivityTarget.CAMPAIGN,
	campaign_tab1 = net.protocol.ActivityTarget.CAMPAIGN_1,
	campaign_tab2 = net.protocol.ActivityTarget.CAMPAIGN_2,
	campaign_tab3 = net.protocol.ActivityTarget.CAMPAIGN_3,
    gold = net.protocol.ActivityTarget.GOLD,
    turnCard = net.protocol.activityType.TURN_CARD,					-- 翻牌有奖  300011
	gamble = net.protocol.activityType.LOTTERY,						-- 竞彩   300010
	luckDraw = net.protocol.activityType.LUCKY_DRAW,				--摇一摇   300012
	qixiCharge = net.protocol.activityType.QIXI_CHARGE,				--七夕充值  300015
	qixiTwoGay = net.protocol.activityType.QIXI_TWO_GAY,			--七夕二丁拐  300016
	mainSceneShare = net.protocol.activityType.MAINSCENE_SHARE,		--大厅分享 300005
	moneyTree = net.protocol.activityType.TURN_TABLE,				--摇钱树  300002
	weekSign = net.protocol.activityType.WEEK_SIGN,					--七日签到  300013	
	wxShare = net.protocol.activityType.WEIXIN_SHARE,				--微信邀请（拉新活动）  300006
	monthSign = net.protocol.activityType.MONTH_SIGN,				--月签到
	redpack = net.protocol.activityType.REDPACK,					--
    createRoom = "createRoom ",
    joinRoom = "joinRoom",
}
local onEvent = function(key)
	game.service.DataEyeService.getInstance():onEvent(key)
end

local function isNewVersion()			
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.9.0")
	return currentVersion:compare(supportVersion) >= 0;		
end

ns.SkipType = SkipType

local UISkipTool = class("UISkipTool")

ns.UISkipTool = UISkipTool
ns.SkipType = SkipType

function UISkipTool.skipTo(type, extraTbl)
    extraTbl =extraTbl or {}
	local btnValue = game.service.LocalPlayerService.getInstance():getBtnValue()
	local areaId = game.service.LocalPlayerService:getInstance():getArea()

	-----------------大厅------------------------
	if type == SkipType.lobby then
		GameFSM.getInstance():enterState("GameState_Lobby");
	elseif type == SkipType.club then
		if(bit.band(btnValue, buttonConst.CLUB_BTN) == 0 and {false} or {true}) [1] then
			game.service.club.ClubService.getInstance():enterClub()
		else
			game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
		end
		--------------------比赛场-----------------------
	elseif type == SkipType.campaign then
		if areaId == 10006 then 
			game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
		else
			-- 统计点击比赛场按钮进入比赛的事件数
			game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Entrance);
			
			game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST, 1)
		end
	elseif type == SkipType.campaign_tab1 or type == SkipType.campaign_tab2 or type == SkipType.campaign_tab3 then
		if GameMain.getInstance():isReviewVersion() or game.service.CampaignService.getInstance():getId() == 0 or
				(bit.band(game.service.LocalPlayerService.getInstance():getBtnValue(), buttonConst.CAMPAIGN_BTN) ~= 0 and {false} or {true}) [1] then
			game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
		else
			-- 统计点击比赛场按钮进入比赛的事件数
			game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Campaign_Entrance);
			local tabId = 1
			if type == SkipType.campaign_tab2 then
				tabId = 2
			elseif type == SkipType.campaign_tab3 then
				tabId = 3
			end
			game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST, tabId)
		end
		---------------------金币场-----------------------------
    elseif type == SkipType.gold then
        local isOpen = bit.band(btnValue, buttonConst.GOLD_BTN) ~= 0 and false or true 
		if not isOpen then
			game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
		else
			game.service.DataEyeService.getInstance():onEvent("Enter_Gold")
			GameFSM.getInstance():enterState("GameState_Gold")
		end
	elseif type == SkipType.gamble then
		---------------------活动:竞彩   300010--------------------------
		--竞彩活动点击量
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Gamble_CLICK)
		UIManager.getInstance():show("UIGambleMain")
		
	elseif type == SkipType.turnCard then
		---------------------活动:翻牌有奖  300011-----------------------
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_CLICK)
		UIManager:getInstance():show("UITurnCard")
		
	elseif type == SkipType.luckDraw then
		---------------------活动:摇一摇   300012-----------------------
		UIManager:getInstance():show("UILuckyDraw")
		
	elseif type == SkipType.qixiCharge then
		---------------------活动:七夕充值  300015-----------------------
		UIManager:getInstance():show("UIQIXICharge")
		
	elseif type == SkipType.qixiTwoGay then
		---------------------活动:七夕二丁拐  300016-----------------------
		UIManager:getInstance():show("UIQiXiTwoGay")
		
	elseif type == SkipType.mainSceneShare then
		---------------------活动:大厅分享 300005-----------------------
		game.service.ActivityService.getInstance():queryMainSceneShareQuery()
		
	elseif type == SkipType.moneyTree then
		---------------------活动:摇钱树  300002-----------------------
		--可以抽奖
		local activityService = game.service.ActivityService.getInstance()
		if activityService:isActivitieswithin(net.protocol.activityType.TURN_TABLE) then
			UIManager:getInstance():show("UIMoneyTree");
			game.service.MoneyTreeService:getInstance():requestQueryTurntableInfo()
		else
			game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
		end
		
	elseif type == SkipType.weekSign then
		---------------------活动:七日签到  300013-----------------------
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Week_Sign_CLICK)
		UIManager:getInstance():show("UIWeekSign")
		
	elseif type == SkipType.wxShare then
		---------------------活动:微信邀请（拉新活动）  300006-----------------------
		-- 统计分享功能面板的唤出次数
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Hshare);
		game.service.ActivityService.getInstance():sendCACQueryShareRewardsREQ()
	elseif type == SkipType.monthSign then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.MonthSign_Cllick);
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryAcitivityInfo()
	elseif type == SkipType.redpack then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Redpack_Click)
		-- UIManager:getInstance():show("UIRedpackOpen")
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):setShowInvite(false)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryAcitivityInfo()
	elseif type == SkipType.createRoom then
		UIManager:getInstance():show("UICreateRoom")
	elseif type == SkipType.joinRoom then
		UIManager:getInstance():show("UIJoinRoom")
	end

	-- 这里加一个统一的上传
	for k, v in pairs(SkipType) do
		if v == type then
			onEvent("UISkipTool_Skip_" .. k)
			break
		end
	end
end

