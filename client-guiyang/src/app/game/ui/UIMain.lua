local CurrencyHelper = require("app.game.util.CurrencyHelper")
local csbPath = "ui/csb/UIMain.csb"
local super = require("app.game.ui.UIBase")
local MultiArea = require("app.gameMode.config.MultiArea")
local buttonConst = require("app.gameMode.mahjong.core.Constants").ButtonConst
local UIElemNotice = import(".element.UIElemNotice")
local ShareNode = require("app.game.ui.element.UIElemShareNode")
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local Version = require("app.kod.util.Version")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local h5login = require("app.game.service.h5login")
local UIMain_LGC = require("app.game.ui.UIMain_LGC")

local UIMain = class("UIMain", super, function() return kod.LoadCSBNode(csbPath) end)

local UIMainElemTag = require("app.game.ui.lobby.mainTag.UIMainElemTag")


-- 互通相关
local startDay = 1

-- nil 表示全员
local function getWaringAndForceId(id)
	local time = game.service.TimeService:getInstance():getCurrentTime();
	local date = os.date("*t", time);
	
	Logger.info("InterflowIosLimit====>roleId:" .. id .. ",date:" .. date.day)
	if device.platform == "windows" then
		return {},{}
	end
	if date.month == 1 then
		if date.day == startDay then
			if device.platform == "android" or device.platform == "windows" then
				return {0, 1, 2}, {}
			elseif device.platform == "ios" then
				return {1, 2}, {}
			end
		elseif date.day == startDay + 1 then
			if device.platform == "android" or device.platform == "windows"   then
				return {3, 4, 5}, {0, 1, 2}
			elseif device.platform == "ios" then
				return {3, 4}, {1, 2}
			end
		elseif date.day == startDay + 2 then
			if device.platform == "android" or device.platform == "windows"    then
				return {6, 7, 8, 9}, {3, 4, 5}
			elseif device.platform == "ios"  then
				return {5, 6}, {3, 4}
			end
		elseif date.day == startDay + 3 then
			if device.platform == "android"  or device.platform == "windows"  then
				return {}, {6, 7, 8, 9}
			elseif device.platform == "ios"   then
				return {7, 8}, {5, 6}
			end
		elseif date.day == startDay + 4 then
			if device.platform == "android" or device.platform == "windows"   then
				return {}, nil
			elseif device.platform == "ios" then
				return {9, 0}, {7, 8}
			end
		elseif date.day == startDay + 5 then
			if device.platform == "android"  or device.platform == "windows"  then
				return {}, nil
			elseif device.platform == "ios"  then
				return {}, {9, 0}
			end
		else
			return {},nil
		end
	end
	return {}, {}
end

local function getIsWaringAndForceTime(...)
	local id = game.service.LocalPlayerService.getInstance():getRoleId()
	local warningIds, forceIds = getWaringAndForceId(id)
	if forceIds == nil then
		return false, true
	else
		local idEnd = id % 10
		return table.indexof(warningIds, idEnd) ~= false, table.indexof(forceIds, idEnd) ~= false
	end
end

function UIMain:ctor()
	self._imgHead			= nil;
	self._imagePointMain	= nil;
	self._textPlayerID		= nil;
	self._textCardValue		= nil;
	self._textPlayerName	= nil;
	self._btnMail			= nil;
	self._btnHelp			= nil;
	self._btnShare			= nil;
	self._btnSetting		= nil;
	self._btnHistory		= nil;
	self._btnJoinRoom		= nil;
	self._btnCreateRoom		= nil;
	self._imgFreeFlag		= nil;
	self._btnFeedback		= nil;
	self._btnYaoqianshu		= nil;
	self._shareBubble	= nil;
	self._btnVerified	= nil;
	self._btnVerified_Ok	= nil;
	self._btnClub			= nil;
	self._btnRegion			= nil;
	self._btnBackpack		= nil;
	
	self._btnMakeMoney	= nil;   -- 赚钱按钮
	self._btnAgents		= nil;   -- 代理商按钮
	
	-- self._imgFreeCard		= nil  	-- 同ip免房卡
	
	
	self._btnShareActivity = nil;	-- 分享活动
	
	self._btnActivity = nil -- 活动按钮
	
	self._imgRedLogo = nil -- 亲友圈红包提示

	self._btnRecommend = nil -- 新手推荐按钮
	self._btnUpdateReward = nil  --更新有奖活动
	
	self._btnGamble = nil --竞彩按钮
	self._imgRedGamble = nil -- 竞彩按钮红点
	
	self._textGold = nil	-- 显示金币
	self._btnBuyGold = nil		--购买金币按钮
	
	self._btnReport = nil -- 举报
	
	self._btnQiXiCharge = nil --七夕充值活动
	self._btnQiXiTwoGay = nil --七夕二人世界
	
	self._tagAct = nil --活动标签
	self._btnGuoQing = nil --国庆活动
	
	self._btnAccountRecovery = nil --账号找回
	self._btnBlessing = nil; 	-- 圣诞祈福
	self._btnChristmasSign = nil 	-- 圣诞签到
	self._btnWelfare = nil -- 每日福利

	self._h5login = h5login.new()
end

function UIMain:init()
	config.H5GameConfig:refresh(self)
	self._h5login:initialize()
	UIMain_LGC:init(self)

	self._imgHead			= seekNodeByName(self, "Image_Main_Head"			, "ccui.ImageView");
	self._imagePointMain	= seekNodeByName(self, "Image_Point_Main"			, "ccui.ImageView");
	self._textPlayerID		= seekNodeByName(self, "Text_Main_PlayerID"			, "ccui.Text");
	self._textPlayerName	= seekNodeByName(self, "Text_Main_PlayerName"		, "ccui.Text");
	self._btnMail			= seekNodeByName(self, "Button_Main_Mail"			, "ccui.Button");
	self._btnMail:setVisible(false)
	self._btnEgg			= seekNodeByName(self, "Button_egg"					, "ccui.Button");
	self._btnHelp			= seekNodeByName(self, "Button_Main_Help"			, "ccui.Button");
	self._btnShare			= seekNodeByName(self, "Button_Main_Share"			, "ccui.Button");
	self._btnSetting		= seekNodeByName(self, "Button_Main_Setting"		, "ccui.Button");
	self._btnHistory		= seekNodeByName(self, "Button_Main_History"		, "ccui.Button");
	self._btnCreateRoom		= seekNodeByName(self, "Button_CreateRoom"	, "ccui.Button");
	-- self._btnCreateRoomBg	= seekNodeByName(self, "Button_Main_CreateRoom"	,	"ccui.Button");
	self._btnJoinRoomBg		= seekNodeByName(self, "Button_JoinRoom"	,	"ccui.Button");
	self._btnNoticeMail		= seekNodeByName(self, "Button_Main_Message"	,	"ccui.Button");
	self._btnPhoneActivity = seekNodeByName(self, "Panel_Phone_Activity",		"ccui.Layout")
	
	self._btnActivity		= seekNodeByName(self, "Button_Main_Activity",		"ccui.Button")
	self._btnUpdateReward	= seekNodeByName(self, "Button_update",		"ccui.Button")	
	self._btnTurnCard		= seekNodeByName(self, "Button_Active_YaoQianShu_0",		"ccui.Button")
	self._btnLuckyDraw	= seekNodeByName(self, "Button_Active_ChouJiang",		"ccui.Button")
	self._btnBackpack		= seekNodeByName(self, "Button_Bag",		"ccui.Button")
	self._btnMore			= seekNodeByName(self, "Button_More",				"ccui.Button")
	self._panelMore		= seekNodeByName(self, "Panel_More",				"ccui.Layout")
	self._panelMask		= seekNodeByName(self, "Panel_Mask",				"ccui.Layout")
	self._btnNianbao 	= seekNodeByName(self, "Panel_nb",		"ccui.Layout")
	
	self._btnLuckyDraw:getChildByName("Image_Point_Main"):setVisible(false)
	self._btnWeekSign		= seekNodeByName(self, "Button_queshen",			"ccui.Button")
	self._btnMonthSign		= seekNodeByName(self, "Button_MonthSign",			"ccui.Button")
	
	self._imgNoticeMailDot = seekNodeByName(self._btnNoticeMail, "Image_red_Setting"	,	"ccui.ImageView")
	self._imgNoticeActivityDot = seekNodeByName(self._btnActivity, "Image_red_Setting"	,	"ccui.ImageView")
	
	self._btnShop			= seekNodeByName(self, "Button_Active_ChouJiang_0"	, "ccui.Button")
	self._imgFreeFlag		= seekNodeByName(self, "Image_xm_CreateRoom_Main"	, "ccui.ImageView")
	self._btnJBC			= seekNodeByName(self, "Button_Active_ChouJiang_0_0", "ccui.Button")
	self._btnFeedback		= seekNodeByName(self, "Button_kf", "ccui.Button")
	self._btnYaoqianshu		= seekNodeByName(self, "Button_Active_YaoQianShu"	, "ccui.Button")
	-- self._shareBubble	= seekNodeByName(self, "Panel_1"					, "ccui.Layout")
	-- self._shareContent	= seekNodeByName(self._shareBubble, "Text_1"	, "ccui.Text")
	self._btnRegion			= seekNodeByName(self, "Button_Active_DuoDiQu",		"ccui.Button")
	
	self._btnClub			= seekNodeByName(self, "Button_Active_JuLeBu"		, "ccui.Button")
	self._imgClubFistCreateTip = seekNodeByName(self._btnClub, "Image_7", "ccui.ImageView")
	-- 默认隐藏
	if self._imgClubFistCreateTip then
		self._imgClubFistCreateTip:setVisible(false)
	end
	self._imgClubRedDot	= seekNodeByName(self._btnClub, "Image_Point_Main_0"			, "ccui.ImageView")

	self._elemNotice = UIElemNotice.extend(
	seekNodeByName(self, "pageview_Notice", "ccui.PageView"),
	seekNodeByName(self, "Panel_gonggao",	"ccui.Layout"),
	seekNodeByName(self, "listview_Indicator", "ccui.ListView")
	)
	-- 代理商
	self._btnMakeMoney	= seekNodeByName(self, "Button_zq", "ccui.Button")
	self._btnAgents		= seekNodeByName(self, "Button_dl", "ccui.Button")
	
	-- 身份认证
	self._btnVerified		= seekNodeByName(self, "Button_smrz0",	"ccui.Button")
	-- self._btnVerified_Ok	= seekNodeByName(self, "Button_smrz0_0", "ccui.Button")
	
	-- self._imgFreeCard		= seekNodeByName(self, "Image_Free_Card"			, "ccui.ImageView")
	
	self._panelRoomCard	= seekNodeByName(self, "Panel_Main_Card"			, "ccui.Layout")
	self._panelBean		= seekNodeByName(self, "Panel_Main_Bean"			, "ccui.Layout")
	self._panelGold	= seekNodeByName(self, "Panel_Main_Gold"			, "ccui.Layout")
	self._btnSpringInvited = seekNodeByName(self, "btnSpringInvited", "ccui.Button")
	self._btnSpringInvitedRedDot = seekNodeByName(self._btnSpringInvited, "Image_3", "ccui.ImageView")
	
	self._btnShareActivity	= seekNodeByName(self, "Button_Active_FenXiang", "ccui.Button")
	self._btnShareActivity:loadTextureNormal("activity/fxlnh/btn_jz_jzlnh.png")

	
	-- 商城
	self._btnMall = seekNodeByName(self, "Button_Active_FenXiang_0", "ccui.Button")
	
	self._imgRedLogo = seekNodeByName(self, "Image_ts", "ccui.ImageView")
	self._imgRedLogo:setVisible(false)
	self._imgClubKoi = seekNodeByName(self, "Image_ClubKoi", "ccui.ImageView")
	self._imgClubKoi:setVisible(false)

	-- 亲友圈新手推荐
	self._btnRecommend = seekNodeByName(self, "Button_recommend", "ccui.Button")
	-- self._btnRecommend:setVisible(false)
	self._btnPhoneBind = seekNodeByName(self, "Button_Main_Phonebind", "ccui.Button")
	
	--竞彩按钮
	self._btnGamble = seekNodeByName(self, "btnGamble", "ccui.Button")
	self._imgRedGamble = seekNodeByName(self._btnGamble, "imgGambleRed", "ccui.Button")
	
	self._btnPullNew = seekNodeByName(self, "Button_pullNew", "ccui.Button")
	--七夕充值活动
	self._btnQiXiCharge = seekNodeByName(self, "btnQiXiCharge", "ccui.Button")
	self._btnQiXiTwoGay = seekNodeByName(self, "btnQiXiTwoGay", "ccui.Button")
	
	-- 好友
	-- self._btnFriend = seekNodeByName(self, "Button_Main_Friend", "ccui.Button")

	
	self._btnGuoQing = seekNodeByName(self, "Panel_guoqing", "ccui.Layout")
	
	self._btnGuoQing.btnStatic = seekNodeByName(self._btnGuoQing, "btnStatic", "ccui.Button")
	self._btnGuoQing.btnAni = seekNodeByName(self._btnGuoQing, "btnAni", "ccui.Button")
	
	self._btnShuang11 = seekNodeByName(self, "Panel_shuang11", "ccui.Layout")
	self._btnShuang11.red = seekNodeByName(self._btnShuang11, "Image_Point_Main", "ccui.ImageView")
	
	self._rightDownPanel = seekNodeByName(self, "Panel_Main_Active", "ccui.Layout")
	self._rightTopPanel = seekNodeByName(self, "Panel_topicon", "ccui.Layout")
	self._rightDownButtons = {}
	self._rightTopButtons = {}
	
	self._btnReport = seekNodeByName(self, "Button_report", "ccui.Button")
    self._btnComeback = seekButton(self, "Button_Comeback", handler(self, self._onBtnComebackClick))
    self._btnCollectCode = seekButton(self, "Button_CollectCode", handler(self, self._onBtnCollectCodeClick))
	
	self._btnAccountRecovery = seekNodeByName(self, "btnAccountRecovery", "ccui.Button")
	
	self._btnLeaderboardActivity	= seekNodeByName(self, "Button_leaderboardActivity",	"ccui.Button") -- 排行榜活动
	self._imgRedDot_LeaderboardActivity = seekNodeByName(self, "Image_activity_red_0", "ccui.ImageView") -- 排行榜活动红点
	-- 圣诞祈福
	self._btnBlessing = seekNodeByName(self, "btnBlessing",	"ccui.Button")
	-- 圣诞签到
	self._btnChristmasSign = seekNodeByName(self, "btnChristmasSign", "ccui.Button")

	self._btnClubRed = seekButton(self, "Button_rw_top_Clubpj", "ccui.Button") -- 红包

    self._btnRedPack = seekNodeByName(self, "Button_Redpack", "ccui.Button")	--拆红包活动
    -- 调查问卷
    self._btnQuestionnare = seekButton(self, "Button_Questionnare", handler(self, self._onBtnQuestionnareClick))

	self._btnWelfare = seekButton(self, "Panel_Phone_Activity_0", handler(self, self._onBtnWelfare))
	self._btnUFOCatcher =  seekButton(self, "Button_UFOCatcher", handler(self, self._onUFOCatcherClicked))


	-- 显示遮罩，请不要再此之上的代码加其他的遮罩层
    --local key = "UIGuide_UIWallet_1"
    --if require("app.game.ui.guides.GuideHelper").isNeedGuide(key, 1) then
    --    ---@type UIGuide_UIWallet_1
    --    local ui = UIManager.getInstance():show(key)
    --    ui:guide(self._imgHead, UtilsFunctions.sizeMul(self._imgHead:getContentSize(), 1.3))
    --end
	
	--右上角按钮
	table.insert(self._rightTopButtons, self._btnYaoqianshu)
	table.insert(self._rightTopButtons, self._btnShareActivity)
	
	table.insert(self._rightTopButtons, self._btnMall)
	table.insert(self._rightTopButtons, self._btnGamble)
	table.insert(self._rightTopButtons, self._btnTurnCard)
	table.insert(self._rightTopButtons, self._btnPullNew)
	table.insert(self._rightTopButtons, self._btnLuckyDraw)
	table.insert(self._rightTopButtons, self._btnWeekSign)
	table.insert(self._rightTopButtons, self._btnEgg)
	table.insert(self._rightTopButtons, self._btnWelfare)
	table.insert(self._rightTopButtons, self._btnMonthSign)
	
	table.insert(self._rightTopButtons, self._btnGuoQing)
	table.insert(self._rightTopButtons, self._btnPhoneActivity)
	table.insert(self._rightTopButtons, self._btnShuang11)
	table.insert(self._rightTopButtons, self._btnComeback)
	table.insert(self._rightTopButtons, self._btnLeaderboardActivity)
	table.insert(self._rightTopButtons, self._btnQiXiCharge)
	table.insert(self._rightTopButtons, self._btnQiXiTwoGay)
	table.insert(self._rightTopButtons, self._layoutBuYu)
	table.insert(self._rightTopButtons, self._btnAccountRecovery)
	table.insert(self._rightTopButtons, self._btnBlessing)
	table.insert(self._rightTopButtons, self._btnChristmasSign)
	table.insert(self._rightTopButtons, self._btnRedPack)
	table.insert(self._rightTopButtons, self._btnSpringInvited)
	table.insert(self._rightTopButtons, self._btnCollectCode)
	table.insert(self._rightTopButtons, self._btnClubRed)
	table.insert(self._rightTopButtons, self._btnNianbao)
	table.insert(self._rightTopButtons, self._btnQuestionnare)
	table.insert(self._rightTopButtons, self._btnUFOCatcher)

	--右下角按钮
	--table.insert(self._rightDownButtons, self._btnJoinRoomBg)
	--table.insert(self._rightDownButtons, self._btnMore)
	--table.insert(self._rightDownButtons, self._btnRecommend)
	--table.insert(self._rightDownButtons, self._btnHistory)
	--table.insert(self._rightDownButtons, self._btnShare)
	--table.insert(self._rightDownButtons, self._btnFeedback)
	--table.insert(self._rightDownButtons, self._btnAgents)
	--table.insert(self._rightDownButtons, self._btnMakeMoney)
	--table.insert(self._rightDownButtons, self._btnActivity)
	--table.insert(self._rightDownButtons, self._btnShop)
	-- table.insert(self._rightDownButtons, self._btnNoticeMail)
	-- table.insert(self._rightDownButtons, self._btnFriend)

	self:_initButtons()
	
	if self._btnPhoneBind then self:_changeButtonVisibleState(self._btnPhoneBind, false) end
	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)
	self:_registerCallBack()
	
	-- 上报自己的设置配置
	game.service.LocalPlayerSettingService:getInstance():_updateDataEye() 


	if cc.UserDefault:getInstance():getBoolForKey("First_to_game", false) == false and game.service.GlobalSetting.getInstance():isFirstInGame() then
        cc.UserDefault:getInstance():setBoolForKey("First_to_game", true)
		if device.platform == "android" then
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_game_android);
        else
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_game_ios);
		end
		
		local params = {
            log_time = kod.util.Time.nowMilliseconds(),
            channel = device.platform,
            deviceId = game.plugin.Runtime.getDeviceId(),
            playerId = game.service.LocalPlayerService.getInstance():getRoleId(),
            event_type = "first_in_game",
            areaid = game.service.LocalPlayerService.getInstance():getArea(),
        }
        kod.util.Http.uploadInfo(params, config.UrlConfig.getUploadFirstInUrl())
    end

	self._panelRight = seekNodeByName(self, "Panel_Main_Btn_right", "ccui.Layout")
	self._panelLeft = seekNodeByName(self, "Panel_Main_Btn_left", "ccui.Layout")

	self:_initMain_LGC()
end

function UIMain:_initMain_LGC()
	--初始化标签功能
	if self._tagAct ~= nil then
		self._tagAct:hide()
		self._tagAct = nil
	end
	UIMain_LGC:initLGCItems()
	self._tagAct = UIMain_LGC:getAagAct()
	self._tagAct:appendTag(self._btnClub, UIMainElemTag.ButtonId.Club)
	self._tagAct:appendTag(self._btnCreateRoom, UIMainElemTag.ButtonId.CreateRoom)
	--标签功能
	self._tagAct:show()
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIMain:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UIMain:showPhoneBind()
	UIManager:getInstance():show("UIPhoneLogin", game.globalConst.phoneMgr.phonebind)
end

function UIMain:_registerCallBack()
	--提审相关（充值、IP信息、亲友圈隐藏）
	if not GameMain.getInstance():isReviewVersion() then
		bindEventCallBack(self._imgHead,			handler(self, self._onImgHeadClick),	ccui.TouchEventType.ended);
		bindEventCallBack(self._btnShare,			handler(self, self._onBtnShareClick),	ccui.TouchEventType.ended);
		bindEventCallBack(self._btnActivity,		handler(self, self._onBtnActivity),	ccui.TouchEventType.ended);
		bindEventCallBack(self._btnFeedback,		handler(self, self._onBtnActive_FeedbackClick),	ccui.TouchEventType.ended);
		bindEventCallBack(self._btnShareActivity,	handler(self, self._onBtnShareActivityClick),	ccui.TouchEventType.ended);
	end
	-- bindEventCallBack(self.btnPhoneBind,    handler(self, self.showPhoneBind),ccui.TouchEventType.ended)
	bindEventCallBack(self._btnMail,		handler(self, self._onBtnMailClick),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnHelp,		handler(self, self._onBtnHelpClick),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnSetting,	handler(self, self._onBtnSettingClick),	ccui.TouchEventType.ended);
	bindEventCallBack(self._btnHistory,	handler(self, self._onBtnHistoryClick),	ccui.TouchEventType.ended);
	bindEventCallBack(self._btnNoticeMail,	handler(self, self._onBtnNoticeMail),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnRecommend,	handler(self, self._onBtnRecommend),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnUpdateReward,	handler(self, self._onUpdateRewardClick),		ccui.TouchEventType.ended);
	bindEventCallBack(self._btnVerified,	handler(self, self._onBtnVerified),		ccui.TouchEventType.ended);
	-- bindEventCallBack(self._btnVerified_Ok,	handler(self, self._onBtnVerified_Ok),		ccui.TouchEventType.ended);
	bindTouchEventWithEffect(self._btnEgg,			handler(self, self._onBtnEgg),			1.05)
	bindEventCallBack(self._btnMonthSign,	handler(self, self._onBtnMonthSign),	ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRedPack,	handler(self, self._onBtnRedPack),		ccui.TouchEventType.ended)

	bindEventCallBack(self._btnJoinRoomBg,	handler(self, self._onBtnJoinRoomClick), ccui.TouchEventType.ended);
	bindTouchEventWithEffect(self._btnCreateRoom, handler(self, self._onBtnCreateRoomClick), 1.05);
	-- bindTouchEventWithEffect(self._btnShop,		handler(self, self._onBtnMallClick),			1.05)
	bindEventCallBack(self._btnShop, handler(self, self._onBtnMallClick), ccui.TouchEventType.ended)
	bindTouchEventWithEffect(self._btnYaoqianshu,	handler(self, self._onYaoqianshuClick),	1.05)
	bindTouchEventWithEffect(self._btnClub,		handler(self, self._onBtnClubClick), 1.05);
	-- bindTouchEventWithEffect(self._btnMakeMoney,	handler(self, self._onBtnRecruit),		1.05);
	bindEventCallBack(self._btnMakeMoney,	handler(self, self._onBtnRecruit),		ccui.TouchEventType.ended);
	bindTouchEventWithEffect(self._btnAgents,		handler(self, self._onBtnAgentsClick),		1.05);
	bindTouchEventWithEffect(self._btnTurnCard,	handler(self, self._onBtnTurnCard),		1.05)
	bindTouchEventWithEffect(self._btnPullNew, handler(self, self._onClickPullNew), 1.05)
	bindTouchEventWithEffect(self._btnWeekSign,	handler(self, self._onBtnWeekSign),		1.05)
    -- bindTouchEventWithEffect(self._btnFriend, handler(self, self._onFriendClick), 1.05)
	bindTouchEventWithEffect(self._btnSpringInvited,    handler(self, self._onClickSpringInvited), 1.05)

	bindEventCallBack(self._btnRegion, handler(self, self._onBtnRegionClick), ccui.TouchEventType.ended);
	bindTouchEventWithEffect(self._btnMall,	handler(self, self._onBtnMallClick),	1.05)
	bindTouchEventWithEffect(self._btnLuckyDraw,	handler(self, self._onBtnLuckyDraw),	0.97);
	bindTouchEventWithEffect(self._panelMask, handler(self, self._onClickMask));
	bindEventCallBack(self._btnMore, handler(self, self._onBtnMore), ccui.TouchEventType.ended)
	bindTouchEventWithEffect(self._btnPhoneActivity,	handler(self, self._onBtnPhoneActivity),	0.97);
	
	bindTouchEventWithEffect(self._btnGamble,	handler(self, self._onBtnGamble),	0.97);
	bindEventCallBack(self._btnBackpack,	handler(self, self._onBtnBackpack),	ccui.TouchEventType.ended);
	
	bindTouchEventWithEffect(self._btnReport,		handler(self, self._onBtnReport),			1.05)
	
	bindTouchEventWithEffect(self._btnQiXiCharge,	handler(self, self._onBtnQiXiCharge), 1.05)
	bindTouchEventWithEffect(self._btnQiXiTwoGay,	handler(self, self._onBtnQiXiTwoGay), 1.05)
	
	bindTouchEventWithEffect(self._btnGuoQing,	handler(self, self._onBtnGuoqing), 1.05)
	bindTouchEventWithEffect(self._btnCollectCode, handler(self, self._onBtnCollectCodeClick), 1.05)
	bindTouchEventWithEffect(self._btnClubRed, handler(self, self._onBtnClubClick), 1.05)
	bindTouchEventWithEffect(self._btnNianbao, handler(self, self._onBtnNianbao), 1.05)
	
	bindTouchEventWithEffect(self._btnShuang11,	handler(self, self._onBtnShuang11), 1.05)
	bindTouchEventWithEffect(self._btnLeaderboardActivity, function()
		UIManager:getInstance():show("UILeaderboardActivityMain")
	end, 1.05)
	
	bindEventCallBack(self._btnAccountRecovery,		handler(self, self._onBtnAccountRecovery),	ccui.TouchEventType.ended)
	bindEventCallBack(self._btnBlessing, handler(self, self._onBtnBlessing),	ccui.TouchEventType.ended)
	bindEventCallBack(self._btnChristmasSign, handler(self, self._onBtnChristmasSign),	ccui.TouchEventType.ended)
end

function UIMain:onShow(...)
	self._bindKeys = {
		CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.CARD, self._panelRoomCard),
		CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.BEAN, self._panelBean),
		CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.GOLD, self._panelGold),
	}
	
	--提审相关（充值、分享、金币场、反馈、 身份认证、 摇钱树、 代理商、 同IP活动、积分商城、活动隐藏）
	if GameMain.getInstance():isReviewVersion() then
		-- self._btnAddCard:setVisible(false)
		self._btnShare:setVisible(false)
		self._btnFeedback:setVisible(false)
		self._btnYaoqianshu:setVisible(false)
		self._btnVerified:setVisible(false)
		self._btnVerified_Ok:setVisible(false)
		self._btnMakeMoney:setVisible(false)
		self._btnAgents:setVisible(false)
		self._btnMall:setVisible(false)
		self._btnActivity:setVisible(false)
		self._btnNoticeMail:setVisible(false)
		self._btnRecommend:setVisible(false)
		self._imgNoticeMailDot:setVisible(false)
		self._btnClub:setVisible(false)
		self._btnShareActivity:setVisible(false)
		self._btnPhoneBind:setVisible(false)
		-- self._panelGold:setVisible(false)
		self._btnReport:setVisible(false)
		-- android提审（应用宝）
		if device.platform == "ios" then
			self._btnShop:setVisible(true)
		else
			-- self._panelRoomCard:setVisible(false)
			self._btnShop:setVisible(false)
		end
		
		-- self._imgFreeCard:setVisible(false)

		-- 隐藏公共版
		self._elemNotice:hide()
	else
		-- --运行版号小于4.0.0.0的版号，默认关闭
		if not game.service.MeiQiaService:getInstance():isSupported() and config.GlobalConfig.getConfig().AREA_ID ~= 10002 then
			self._btnFeedback:setVisible(false)
			
		end
		game.service.GiftService:getInstance():dealWithGiftPack()
		
		
		-- 亲友圈按钮显示逻辑
		self:_updateClubUI()
		
		-- 代理商按钮逻辑
		self:_updateAGTUI(game.service.AgentService.getInstance():getIsAgency())
		
		--设置摇钱树及小红点的显示
		self:setMoneyTreePointBtn()
		
		-- 身份认证
		self:_updateBtnIdentityStatus()
		
		-- 活动状态更新
		self:_updateActivity()

		self:_setRedLeague()
		
		game.service.LoginService:getInstance():addEventListener("EVENT_AGT_STATUS_CHANGED", function(event) self:_updateAGTUI(event.isAgent) end, self)
		game.service.LoginService:getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._updateClubUI), self)
		game.service.LoginService:getInstance():addEventListener("EVENT_VERIFIED_CHANGED", handler(self, self._updateBtnIdentityStatus), self)
		game.service.LoginService:getInstance():addEventListener("EVENT_SWITCH_AREA_CHANGED", handler(self, self._refreshBtnLst), self)
		
		game.service.CertificationService:getInstance():addEventListener("EVENT_VERIFIED_CHANGED", handler(self, self._updateBtnIdentityStatus), self)
		game.service.NoticeMailService:getInstance():addEventListener("EVENT_REDDOT_CHANGED", handler(self, self._onRefreshNoticeMailDot), self)
		--活动列表可能受到稍晚,所以监听一下
		game.service.NoticeMailService:getInstance():addEventListener("EVENT_ACTIVITY_LIST_FIRST_GET", function(...)
			game.service.NoticeMailService:getInstance():showActives()
		end, self)
		
		game.service.club.ClubService.getInstance():addEventListener("EVENT_USER_INFO_INVITATION_CHANGED", handler(self, self._updateClubUI), self)
		game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_DATA_RETRIVED", handler(self, self._updateClubRedLogo), self)
		game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._updateClubUI), self)
		game.service.club.ClubService.getInstance():getClubActivityService():addEventListener("EVENT_CLUB_FIRST_CREATE_AWARD_GET", handler(self, self._onEventClubFirstCreateAward), self)
		game.service.AgentService.getInstance():addEventListener("EVENT_AGT_STATUS_CHANGED", function(event) self:_updateAGTUI(event.isAgent) end, self)
		game.service.AgentService.getInstance():addEventListener("EVENT_AGT_RECRUIT_CHANGED", handler(self, self._updateRecruitInfo), self)
		-- 微信分享有礼内容变更推送
		game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_ACTIVITY_CHANGED", handler(self, self._updateActivity), self)
		-- 活动变更
		game.service.ActivityService.getInstance():addEventListener("EVENT_ACTIVITY_CHANGE", handler(self, self._updateActivity), self)
		game.service.LoginService.getInstance():addEventListener("EVENT_BINDPHONE_CHANGED", function(event)
			self:_changeButtonVisibleState(self._btnPhoneActivity, false)
		end, self)
		-- 俱乐部活动推送
		game.service.club.ClubService.getInstance():getClubActivityService():addEventListener("EVENT_CLUB_ACTIVITY_TIME_INFO", handler(self, self._onClubActivityIconChange), self)
		
		--互通状态改变
		game.service.LocalPlayerService.getInstance():addEventListener("EVENT_INTERFLOW_CHANGE", handler(self, self._updateBtnIdentityStatus), self)
		
		-- 分享获取免费房卡时间监听
		game.service.ActivityService.getInstance():addEventListener("EVENT_WECHAT_SHARECONTENT_CHANGED", handler(self, self._onSharePickSuccess), self);
		
		game.service.MoneyTreeService:getInstance():addEventListener("EVENT_MONEY_TREE_SHOW_RED_CHANGE", handler(self, self.setMoneyTreePointBtn), self);
		game.service.MoneyTreeService:getInstance():addEventListener("EVENT_MONEY_TREE_GIFT_RED_CHANGE", handler(self, self.setMoneyTreePointBtn), self);
		
		game.service.HeadFrameService:getInstance():addEventListener("EVENT_HEAD_CHANGE", handler(self, self._refrashHeadFrame), self)
		
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._refreshTurnCardActivity), self)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):addEventListener("EVENT_AWARD_INFO", handler(self, self._refreshTurnCardActivity), self); --处理活动消息
		-- 监听二丁拐的进度消息
        game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):addEventListener("EVENT_TWO_GAY_ACT_PROGRESS", handler(self, self._refreshErDingGuaiActivity), self)
		
		-- 监听红点树的消息
		game.service.LocalPlayerService:getInstance():addEventListener("EVENT_RED_DOT_CHANGE", handler(self, self._setRedDotActivity), self)
		game.service.bigLeague.BigLeagueService:getInstance():addEventListener("EVENT_CREATE_LEAGUE", handler(self, self._initMain_LGC), self)
		
		--监听圣诞活动相关
		event.EventCenter:addEventListener("EVENT_CHRISTMAS_PACKAGE_INFO", handler(self, self._showChristmasPackAge), self)
		-- 监听断线重连消息
		game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._doWhenReconnect), self)
		
        local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
        service:addEventListener("EVENT_SPRING_INVITED_WORSHIP", handler(self, function ()
            local redDotStateTreeManager = manager.RedDotStateTreeManager.getInstance():changeRedDotData("GodOfWealth",0)
            self._btnSpringInvitedRedDot:setVisible(false)
        end), self)

		game.service.bigLeague.BigLeagueService:getInstance():addEventListener("EVENT_LEAGUE_INFO_SYN", handler(self, self._setRedLeague), self)
		
		--监听可领取奖励改变事件 控制竞彩的红点
		local gambleService = game.service.GambleService:getInstance()
		gambleService:addEventListener("EVENT_GAMBLE_REWARD_COUNT_CHANGE", function()
			self._imgRedGamble:setVisible(gambleService:canDrawReward())
		end, self)
		
		--弹窗公告
		local noticeService = game.service.NoticeService.getInstance()
		if game.service.LoginService.getInstance()._isNeedSelectRegion == false and noticeService:isNoticePop(false) then
			noticeService:_startToShowNotice()
		end
		
		-- 如果在比赛等待状态，显示等待中
		if campaign.CampaignFSM.getInstance():isState("CampaignState_InCampaignWait") then
			UIManager:getInstance():show("UICampaignWait")
		end
		
		-- 如果在比赛打牌状态，同时Roomid为0，则说明在打立赛
		if campaign.CampaignFSM.getInstance():getCurrentState():getIsInBattle() and game.service.RoomService:getInstance():getRoomId() == 0 then
			UIManager:getInstance():show("UICampaignWait")
		end
		
		-- 刷新头像
		game.service.HeadFrameService:getInstance():dispatchEvent({name = "EVENT_HEAD_CHANGE", data = game.service.LocalPlayerService.getInstance():getHeadFrameId()})
		
		-- 设置状态更新
		self:_updateSetting()
		
		self:_updateClubRedLogo()
		
		-- 亲友圈推荐邀请弹窗
		if game.service.club.ClubService.getInstance():getUserData():isPopUps() then
			UIManager:getInstance():show("UIClubRecommend_Invitation")
		end
		
		local userData = game.service.club.ClubService.getInstance():getUserData()
		-- 根据服务器配置的白名单显示不同功能的界面
		self._btnRecommend:setVisible(userData:getIsInWhiteList())
		local activityService = game.service.ActivityService.getInstance()
		
		-- 好友红点刷新
		game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_RED_CHAGE", handler(self, self._chageFriendRed), self)
		self:_chageFriendRed()
		
		game.service.MeiQiaService.getInstance():addEventListener("EVENT_MEIQIA_MSG_STATUS_CHANGED", handler(self, self._refreshFeedbackStatus), self)
		self:_refreshFeedbackStatus()
		--设置更新有礼按钮显示
		local visible = activityService:isActivitieswithin(net.protocol.activityType.UPDATE_REWARD) and not game.plugin.Runtime.isAccountInterflow()
		self._btnUpdateReward:setVisible(visible)
		
	end
	
	local localPlayerService = game.service.LocalPlayerService.getInstance();
	
	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, localPlayerService:getIconUrl());
	self._textPlayerName:setString(kod.util.String.getMaxLenString(localPlayerService:getName(), 12));
	self._textPlayerID:setString("ID:" .. localPlayerService:getRoleId());
	
	-- 显示弹窗公告(保证只弹一次)
	local noticeService = game.service.NoticeService.getInstance()
	
	self._imgFreeFlag:setVisible(#game.service.FreePlayService:getInstance():getActiveData() > 0)

	game.service.LoginService.getInstance():dispatchEvent({name = "EVENT_SELECT_NEED_REGION"});
	
	-- 刷新按钮列表
	self:_refreshBtnLst()
	
	--常驻公告先读取本地配置（本地配置是一张默认图片）
	self._elemNotice:load(UIElemNotice.NOTICE_CONFS.fromConfig(), {
		function()
		end,
	})
	
	--向服务器发起大厅界面公告栏请求
	game.service.NoticeService:getInstance():queryPageNotice()
	
	self._action:gotoFrameAndPlay(0, true)
	
	self:_onRefreshNoticeMailDot()
	
	self._panelMask:setVisible(false)
	self._panelMore:setScale(0)
	
	if self._imgClubFistCreateTip then
		local clubActivityCache = game.service.club.ClubService:getInstance():getClubActivityService():getActivityCache()
		self._imgClubFistCreateTip:setVisible(clubActivityCache.firstCreateClubAwardCardCount > 0)
	end
	
	self:_activityQuerysOnShow()
	
	self:_setRedDotActivity()
	
	self:_onClubActivityIconChange()
	
	local UPDATE_REWARD_IS_OPEN = game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.UPDATE_REWARD)
	
	-- 版本互通(每次回首页都弹)
	if not game.plugin.Runtime.isAccountInterflow() and storageTools.AutoShowStorage.isNeedShow("UIAccountBindForOld", 999) and UPDATE_REWARD_IS_OPEN then
		scheduleOnce(function() self:_onUpdateRewardClick() end, 0.1)
	end

	UIManager:getInstance():showMainUIs()
    local value = false
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEN_JUAN)
    if service and game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.WEN_JUAN) then
        service:checkAutoShow()
        value = not service:isQuestionnaireDone() or false
    end
    self:_changeButtonVisibleState(self._btnQuestionnare, value)

	-- UI改版弹窗(只弹一次)
	--[[
	if localPlayerService:getIsShowUIChange() then 
		UIManager:getInstance():show("UIChangeNotice")
	end
	]] 

	self:_palyAnim()
end

function UIMain:_setRedLeague()
	if UIMain_LGC:getButton("League") then
		local red = ccui.Helper:seekNodeByName(UIMain_LGC:getButton("League"), "Image_Red")
		red:setVisible(game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getHaveApproval())
	end
end

-- 设置排行榜活动红点显示
function UIMain:_setRedDotActivity()
    local redDotStateTreeManager = manager.RedDotStateTreeManager.getInstance()
	self._imgRedDot_LeaderboardActivity:setVisible(redDotStateTreeManager:isVisibleParent(redDotStateTreeManager:getRedDotParent().CLUB_RANK_REWARD))
	self._btnSpringInvitedRedDot:setVisible(redDotStateTreeManager:isVisible(redDotStateTreeManager:getRedDotKey().GOD_OF_WEALTH))

	local value = redDotStateTreeManager:isVisible(redDotStateTreeManager:getRedDotKey().WALLET)

	local redDot = self._imgHead.redDot
	if redDot == nil then
		redDot = ccui.ImageView:create("img/Img_red.png")
		self._imgHead.redDot = redDot
		redDot:setName("RedDot")
		self._imgHead:getParent():addChild(redDot)
		redDot:setPosition(cc.p(75, 65))
		print("REDDOT", redDot:getParent():getName(), redDot:getPositionX(), redDot:getPositionY())
	end
	redDot:setVisible(value)
end

--从配置中检测按钮的显示和隐藏
function UIMain:_checkButtonsVisible(buttons)
	for _, button in pairs(buttons) do
		local name = button:getName()
		local visible = config.checkButtonShowByName(name)
		button:setVisible(visible)
	end
end
--检测按钮是否是控制下的按钮
function UIMain:_checkButtonInControl(button)
	for _, btn in ipairs(self._rightDownButtons) do
		if btn == button then
			return true
		end
	end
	for _, btn in ipairs(self._rightTopButtons) do
		if btn == button then
			return true
		end
	end
	return false
end
--改变单个按钮的显示和隐藏，改变玩了之后要重排
function UIMain:_changeButtonVisibleState(button, visible)
	local ret = false
	local name = button:getName()
	if visible then
        local config_visible = config.checkButtonShowByName(name)
        ret = visible and config_visible
		button:setVisible(ret)
	else
		button:setVisible(ret)
	end
    self:sortAllButtons()
    return ret
end
--初始化按钮的可见性
function UIMain:_initButtons()
	self:_checkButtonsVisible(self._rightDownButtons)
	self:_checkButtonsVisible(self._rightTopButtons)
	self:sortAllButtons()
end
--调整按钮位置
function UIMain:sortAllButtons()
	self:sortPanelButtons(self._rightDownPanel, self._rightDownButtons, 1, 20)
	self:sortPanelButtons(self._rightTopPanel, self._rightTopButtons, 1, 3)
	-- 所有右上角按钮的Y坐标调整
	table.foreach(self._rightTopButtons, function(idx, btn)
		btn:setPositionY(50)
	end)

	table.foreach(self._rightDownButtons, function(idx, btn)
		btn:setPositionY(50)
	end)
end

--dir:0从左开始排，1从右开始排
function UIMain:sortPanelButtons(panel, buttons, dir, interval)
	local posX = 0
	local k = 1
	local btnAp = cc.p(0, 0.5)
	if dir == 1 then
		posX = panel:getContentSize().width
		k = - 1
		btnAp = cc.p(1, 0.5)
	end
	for idx, btn in pairs(buttons) do
		if btn:isVisible() then
			btn:setAnchorPoint(btnAp)
			btn:setPositionX(posX)
			posX = posX +(interval + btn:getContentSize().width) * k
			if btn:getName() == "Button_Chuanqi" then
				posX = posX + 20
			end
		end
	end
end

function UIMain:showGuide(pos)
	if pos == "Club" then
		UIManager:getInstance():show("UIGuide", {target = self._btnClub, swallow = true, callback = handler(self, self._onBtnClubClick)}, "club")
	else
		if UIMain_LGC:getButton("Competition") then
			UIManager:getInstance():show("UIGuide", {target = UIMain_LGC:getButton("Competition"), swallow = true, callback = handler(self, self._onBtnCompetitionFieldClick)})
		end
	end
end

function UIMain:onHide()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		game.service.CertificationService:getInstance():removeEventListenersByTag(self)
		game.service.LoginService:getInstance():removeEventListenersByTag(self)
		game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
		game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
		game.service.AgentService.getInstance():removeEventListenersByTag(self)
		game.service.ActivityService.getInstance():removeEventListenersByTag(self)
		game.service.NoticeMailService.getInstance():removeEventListenersByTag(self)
		game.service.MoneyTreeService.getInstance():removeEventListenersByTag(self)
		game.service.HeadFrameService:getInstance():removeEventListenersByTag(self)
		game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
		game.service.GambleService:getInstance():removeEventListenersByTag(self)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
		game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
		game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
		game.service.MeiQiaService.getInstance():removeEventListenersByTag(self)
		event.EventCenter:removeEventListenersByTag(self)
        game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
        game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED):removeEventListenersByTag(self)
		game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
	end
	for _, key in ipairs(self._bindKeys or {}) do
		CurrencyHelper.getInstance():getBinder():unbind(key)
	end
	self._bindKeys = {}
	--标签功能
	if self._tagAct ~= nil then
		self._tagAct:hide()
	end

	self._h5login:dispose()
end

-- 刷新玩家头像
function UIMain:_refrashHeadFrame(event)
	local id = event.data
	local src = PropReader.getIconById(id)
	-- 添加头像框
	game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, src, 0.6)
end

-- 刷新按钮列表
function UIMain:_refreshBtnLst()
	local localPlayerService = game.service.LocalPlayerService.getInstance();
	-- 此处因为三目运算符因为a and b or c  当b是nil的时候会返回c的值，所以改为(a and {b} or {c})[1]
	self._btnRegion:setVisible((bit.band(localPlayerService:getBtnValue(), buttonConst.SWITCH_REGION_BTN) == 0 and {false} or {true}) [1])
end

--设置摇钱树及小红点的显示
function UIMain:setMoneyTreePointBtn()
	self._imagePointMain:setVisible(game.service.MoneyTreeService:getInstance():getBShowRedPoint())
end

function UIMain:_onYaoqianshuClick()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.moneyTree)
end

-- 身份认证
function UIMain:_updateBtnIdentityStatus()
	if game.service.LocalPlayerService.getInstance() and
	game.service.LocalPlayerService.getInstance():getCertificationService() and
	game.service.LocalPlayerService.getInstance():getCertificationService():getCertificationStatus() then
		self:_changeButtonVisibleState(self._btnVerified, false)
		-- self:_changeButtonVisibleState(self._btnVerified_Ok, true)
	else
		-- self:_changeButtonVisibleState(self._btnVerified_Ok, false)
		self:_changeButtonVisibleState(self._btnVerified, true)
	end
	
	local visible = not game.service.LocalPlayerService.getInstance():getInterflow() and game.plugin.Runtime.isAccountInterflow()
	self:_changeButtonVisibleState(self._btnAccountRecovery, visible)
	
	-- 进行自动互通尝试
	local hasTryAutoHuTong = game.service.LocalPlayerService.getInstance()._playerLocalData.hasAutoCodeHuTong
	if visible and not hasTryAutoHuTong then
		game.plugin.Runtime.getClipboard(function(msg)
			if not msg then
				msg = ""
			end
			-- release_print("account certificate automatic~~~~~~~~~~~~~~", msg)
			if string.len(msg) == 12 and string.match(msg, '^[A-Za-z0-9]+$') then
				game.service.CertificationService:getInstance():CIAccountHuTongByCodeREQ(msg, true)
				game.service.LocalPlayerService.getInstance()._playerLocalData.hasAutoCodeHuTong = true
				game.service.LocalPlayerService.getInstance():saveLocalStorage()
				game.plugin.Runtime.setClipboard("")
			end
		end)
	end	
end

-- 显示个人中心信息
function UIMain:_onImgHeadClick(sender)
	UIManager:getInstance():show("UIPersonalCenter")
    self:onTDEvent("CLICK_HALL_HEAD")
end

function UIMain:_onBtnMailClick(sender)

end

function UIMain:_onBtnHelpClick(sender)
	-- 统计玩法功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_the_way_of_play_game);
	UIManager:getInstance():show("UIHelp")
	
end

function UIMain:_onBtnShareClick(sender)
	-- -- bi统计分享
	game.globalConst.getBIStatistics(game.globalConst.shareType.Main_Share)
	-- 统计分享功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_share);
	local data =
	{
		enter = share.constants.ENTER.HALL,
	}
	share.ShareWTF.getInstance():share(share.constants.ENTER.HALL, {data, data, data})
	-- -- UIManager:getInstance():show("UINewShare")
end

function UIMain:_onBtnSettingClick(sender)
	if config.GlobalConfig.BUGLY_OPEN_LOG then
		Macro.assetFalse(false, "This_is_a_test_bugly_code")
	end
	
	-- 统计设置功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_setting);
	
	UIManager:getInstance():show("UISetting", "main")
end

-- 大厅战绩点击事件回调
function UIMain:_onBtnHistoryClick(sender)
	-- 统计战绩功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_military_exploits);
	
	-- 发送战绩请求
	local historyServer = game.service.LocalPlayerService:getInstance():getHistoryRecordService()
	
	historyServer:queryHistory(0, true)
end

function UIMain:_onBtnJoinRoomClick(sender)
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.joinRoom)
end

function UIMain:_onBtnCreateRoomClick(sender)
	-- room.RoomSettingHelper.initCreateRoomSettings(game.service.RoomCreatorService.getInstance().getLastCreateRoomSettings())
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.createRoom)
end

function UIMain:showFreeFlag()
	self._imgFreeFlag:setVisible(#game.service.FreePlayService:getInstance():getActiveData() > 0)
end

function UIMain:_onBtnActive_FeedbackClick()
	-- 统计反馈功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_feedback);
	game.service.MeiQiaService:getInstance():openMeiQiaWithTip()
end

function UIMain:_changeShareContent(text)
	self._shareContent:setString(text)
	local contentSize = self._shareBubble:getContentSize()
	self._shareContent:setTextAreaSize(cc.size(contentSize.width - 6, 0))
	local _size = self._shareContent:getVirtualRendererSize()
	self._shareContent:setContentSize(cc.size(contentSize.width, _size.height))
end

function UIMain:_onBtnVerified()
	-- 统计实名认证功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_not_certification);
	
	UIManager:getInstance():show("UICertification")
end

function UIMain:_onBtnVerified_Ok()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_certification);
	
	game.ui.UIMessageTipsMgr.getInstance():showTips("已认证")
end

-- Club相关
-- 更新界面状态
function UIMain:_updateClubUI()
	local clubService = game.service.club.ClubService.getInstance()
	
	-- 红点状态更新
	self._imgClubRedDot:setVisible(clubService:hasClubBadges(0))
end

function UIMain:_updateClubRedLogo()
	self:_changeButtonVisibleState(self._btnClubRed, false)
	local clubService = game.service.club.ClubService.getInstance()
	local clubList = clubService:getClubList()
	for _, data in ipairs(clubList.clubs) do
		if data.data ~= nil then
			self._imgRedLogo:setVisible(data.data.hasTask)
			self:_changeButtonVisibleState(self._btnClubRed, data.data.hasTask)
		end
	end
end

function UIMain:_onEventClubFirstCreateAward(event)
	local isShowCreateClubAward = event.protocol.awardCard > 0
	if self._imgClubFistCreateTip then
		self._imgClubFistCreateTip:setVisible(isShowCreateClubAward)
	end
end

-- 点击亲友圈按钮
function UIMain:_onBtnClubClick()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
end

function UIMain:_updateAGTUI(isAgent)
	--self:_changeButtonVisibleState(self._btnMakeMoney, not isAgent)
	--self:_changeButtonVisibleState(self._btnAgents, isAgent)
	 self._btnMakeMoney:setVisible(not isAgent)
	 self._btnAgents:setVisible(isAgent)
end

-- AGT
function UIMain:_onBtnAgentsClick()
	-- 统计AGT功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_be_a_agent);
	
	game.service.AgentService.getInstance():openWebView(config.AGTSTYLE.main)
end

function UIMain:_onBtnRecruit()
	-- 统计点击招募图标的次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.zhaomu_click);
	-- bi统计分享
	game.globalConst.getBIStatistics(game.globalConst.shareType.Agent_Button)
	
	game.service.AgentService.getInstance():sendCGQueryAgtInfoREQ()
end

function UIMain:_updateRecruitInfo(event)
	local path = {}
	-- 下载gmt配置的图片
	local FILE_TYPE = "playericon"
	for k, v in ipairs(event.recruitInfo.sowingMapUrl) do
		local fileExist = manager.RemoteFileManager.getInstance():doesFileExist(FILE_TYPE, v)
		if fileExist == false then
			manager.RemoteFileManager.getInstance():getRemoteFile(FILE_TYPE, v, function(tf, fileType, fileName)
				if Macro.assetFalse(tf) then
					-- 获取成功之后设置图片
					local filePath = manager.RemoteFileManager.getInstance():getFilePath(fileType, fileName)
					table.insert(path, filePath)
					if UIManager:getInstance():getIsShowing("UIRecruit") then
						UIManager:getInstance():destroy("UIRecruit")
					end
					UIManager:getInstance():show("UIRecruit", path, event.recruitInfo.weChat)	
				end
			end)
		else
			local filePath = manager.RemoteFileManager.getInstance():getFilePath(FILE_TYPE, v)
			table.insert(path, filePath)
		end
	end
	
	if #path == #event.recruitInfo.sowingMapUrl then
		if UIManager:getInstance():getIsShowing("UIRecruit") then
			UIManager:getInstance():destroy("UIRecruit")
		end
		UIManager:getInstance():show("UIRecruit", path, event.recruitInfo.weChat)
	end
end

-- 活动状态更新
function UIMain:_updateActivity()
	local activityService = game.service.ActivityService.getInstance()
	-- 分享送房卡活动
	if activityService:isActivitieswithin(net.protocol.activityType.MAINSCENE_SHARE) then
		self:_changeButtonVisibleState(self._btnShareActivity, true)
		-- 每日首次登录提示
		local playerInfo = activityService:loadLocalPlayerInfo()
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.ActivityService.getInstance():getShareCardShow() then
			-- self:_onBtnShareActivityClick()
			playerInfo:getPlayerInfo()._shareCardCount = 1
		end
		-- 一天最多弹三次
		if playerInfo:getPlayerInfo()._shareCardCount < 4 then
			self:_onBtnShareActivityClick()
			playerInfo:getPlayerInfo()._shareCardCount = playerInfo:getPlayerInfo()._shareCardCount + 1
		end
		
		activityService:saveLocalPlayerInfo(playerInfo)
	else
		self:_changeButtonVisibleState(self._btnShareActivity, false)
	end
	-- 摇钱树活动
	local isMoneyTree = activityService:isActivitieswithin(net.protocol.activityType.TURN_TABLE)
	self:_changeButtonVisibleState(self._btnYaoqianshu, isMoneyTree)
	
	-- 拉新活动
	if activityService:isShareQuality() then
		--每日首次登陆自动显示
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.ActivityService.getInstance():getEnterShow() then
			game.service.ActivityService.getInstance():sendCACQueryShareRewardsREQ()
		end
		self:_changeButtonVisibleState(self._btnPullNew, true)
	else
		self:_changeButtonVisibleState(self._btnPullNew, false)
	end
	
	--同ip免房卡提示设置（同IP免房卡活动）
	-- if activityService:isActivitieswithin(net.protocol.activityType.NOCOST_CARD) then
	-- 	self._imgFreeCard:setVisible(true)
	-- else
	-- 	self._imgFreeCard:setVisible(false)
	-- end

	--竞彩活动是否开启
	if activityService:isActivitieswithin(net.protocol.activityType.LOTTERY) then
		-- self._btnGamble:setVisible(true)
		self:_changeButtonVisibleState(self._btnGamble, true)
		self._imgRedGamble:setVisible(game.service.GambleService.getInstance():canDrawReward())
	else
		-- self._btnGamble:setVisible(false)
		self:_changeButtonVisibleState(self._btnGamble, false)
	end
	
	--翻牌活动是否开启
	if activityService:isActivitieswithin(net.protocol.activityType.TURN_CARD) then
		--每日首次登陆自动显示
		if(game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getEnterShow())
		or game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):isNeedRecoverInMain() then
			--UIManager.getInstance():show("UITurnCard")
			-- UIManager.getInstance():show("UIGuoQing")
			 UIManager.getInstance():show("UIGoldenEggs")
		else
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryAcitivityInfo()
		end
		 self:_changeButtonVisibleState(self._btnEgg, true)
		
		--self:_changeButtonVisibleState(self._btnTurnCard, true)
	else
		 self:_changeButtonVisibleState(self._btnEgg, false)
		--self:_changeButtonVisibleState(self._btnTurnCard, false)
	end
	
	--翻牌活动是否开启
	if activityService:isActivitieswithin(net.protocol.activityType.LUCKY_DRAW) then
		self:_changeButtonVisibleState(self._btnLuckyDraw, true)
	else
		self:_changeButtonVisibleState(self._btnLuckyDraw, false)
	end
	
	--七日签到活动
	if activityService:isActivitieswithin(net.protocol.activityType.WEEK_SIGN) then
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getEnterShow() then
			--UIManager.getInstance():show("UIWeekSign")
		end
		self:_changeButtonVisibleState(self._btnWeekSign, true)
	else
		self:_changeButtonVisibleState(self._btnWeekSign, false)
	end
	
	--七夕活动相关
	-- 检查要显示的活动界面
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):checkToShowActPage()
	self:_changeButtonVisibleState(self._btnQiXiCharge, activityService:isActivitieswithin(net.protocol.activityType.QIXI_CHARGE))
	self:_changeButtonVisibleState(self._btnQiXiTwoGay, activityService:isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY))
	
	--双11活动按钮
	self:_changeButtonVisibleState(self._btnShuang11, activityService:isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY))
	--双11活动按钮
	self:_changeButtonVisibleState(self._btnSpringInvited, activityService:isActivitieswithin(net.protocol.activityType.SPRING_INVITED))
    local _v = self:_changeButtonVisibleState(self._btnCollectCode, activityService:isActivitieswithin(net.protocol.activityType.COLLECT_CODE))
    if _v and storageTools.AutoShowStorage.isNeedShow(self._btnCollectCode:getName(), 3) then
        self:_onBtnCollectCodeClick(self._btnCollectCode)
    end
	
	--活动列表显示
	game.service.NoticeMailService.getInstance():showActives()
	
	
	--月签到活动
	if activityService:isActivitieswithin(net.protocol.activityType.MONTH_SIGN) then
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getEnterShow() then
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryAcitivityInfo()
		end
		self:_changeButtonVisibleState(self._btnMonthSign, true)
	else
		self:_changeButtonVisibleState(self._btnMonthSign, false)
	end
	
	--绑定活动是否开启
	if activityService:isActivitieswithin(net.protocol.activityType.BIND_PHONE) and	not game.service.LocalPlayerService:getInstance():getBindPhone() then
		--每日首次登陆自动显示
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and
		not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.BIND_PHONE):getEnterShow() then
			UIManager.getInstance():show("UIBindPhoneActivity")
		end
		print(game.service.LocalPlayerService:getInstance():getBindPhone())
		self:_changeButtonVisibleState(self._btnPhoneActivity, true)
		 
	else
		self:_changeButtonVisibleState(self._btnPhoneActivity, false)
	end	
	self:_changeButtonVisibleState(self._btnComeback, activityService:isActivitieswithin(net.protocol.activityType.COMEBACK))
	--圣诞祈福活动
	self:_changeButtonVisibleState(self._btnBlessing, activityService:isActivitieswithin(net.protocol.activityType.BLESSING))
	-- 圣诞签到活动
	self:_changeButtonVisibleState(self._btnChristmasSign, activityService:isActivitieswithin(net.protocol.activityType.PRAY_SIGN))
	
	if activityService:isActivitieswithin(net.protocol.activityType.RED_PACK) then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):setShowInvite(true)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryAcitivityInfo()
		self:_changeButtonVisibleState(self._btnRedPack, true)
	else
		self:_changeButtonVisibleState(self._btnRedPack, false)
    end
    
    -- 春节拉新活动
	if activityService:isActivitieswithin(net.protocol.activityType.SPRING_INVITED) then
		-- 增加分享有礼按钮，活动开启时替换摇钱树位置
		self:_changeButtonVisibleState(self._btnSpringInvited, true)
	else
		self:_changeButtonVisibleState(self._btnSpringInvited, false)
	end
	
	self:_refreshErDingGuaiActivity()


	if game.service.LocalPlayerService:getInstance():checkShowTuisong() then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.show_tuisong)
		UIManager:getInstance():show("UIOpenTuisong")
	end

	local v = game.service.LocalPlayerService.getInstance():getBtnValue()
	self:_changeButtonVisibleState(self._btnNianbao, bit.band(v, buttonConst.NIAN_BAO) ~= 0)
	 self:_changeButtonVisibleState(self._btnWelfare, bit.band(v, buttonConst.DAILY_BENEFITS) ~= 0)

	self:_changeButtonVisibleState(self._btnUFOCatcher, activityService:isActivitieswithin(net.protocol.activityType.UFO_CATCHER))
	self._imgClubKoi:setVisible(game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.CLUB_KOI))
end

-- 俱乐部活动
function UIMain:_onClubActivityIconChange()
	self:_changeButtonVisibleState(self._btnLeaderboardActivity, game.service.club.ClubService.getInstance():getClubActivityService():isActivitiesWithin(ClubConstant:getClubActivityId().LEADER_BOARD))
	
	if game.service.club.ClubService.getInstance():getClubActivityService():isActivitiesWithin(ClubConstant:getClubActivityId().LEADER_BOARD) then
		--每日首次登陆自动显示
		if game.service.LocalPlayerService:getInstance():isTodayFirstLogin() and not game.service.club.ClubService.getInstance():getClubActivityService():getLeaderboardActivityShow() then
			UIManager:getInstance():show("UILeaderboardActivityMain")
		end
	end
end

-- 是否需要更新
function UIMain:_updateSetting()
	local needUpdate = game.service.LoginService.getInstance():getIsNeedUpdate()
	local hasNew3D = game.service.GlobalSetting.getInstance().isNew3D
	local hasNewFunction = game.service.GlobalSetting.getInstance().settingFeaturesRedCache
	if hasNew3D == nil then
		hasNew3D = true
	end
	self._btnSetting:getChildByName("Image_red_Setting"):setVisible(needUpdate or hasNew3D or hasNewFunction)

	self:_updateMoreRedDot()
end

function UIMain:_updateMoreRedDot()
	local needUpdate = game.service.LoginService.getInstance():getIsNeedUpdate()
	local hasNew3D = game.service.GlobalSetting.getInstance().isNew3D
	local hasNewFunction = game.service.GlobalSetting.getInstance().settingFeaturesRedCache
	local show1 = needUpdate or hasNew3D or hasNewFunction


	local noticeService = game.service.NoticeMailService.getInstance()
	local show2 = noticeService:isNoticeDotShow() or noticeService:isMailDotShow()

	local redDot = self._btnMore:getChildByName("Image_red_Setting")
	redDot:setVisible(show1 or show2)
end

-- 微信分享赠房卡活动
function UIMain:_onBtnShareActivityClick()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.mainSceneShare)
end

-- 比赛场
function UIMain:_onBtnCompetitionFieldClick()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
end

function UIMain:_onBtnMallClick(sender)
	-- 统计礼卷商城功能面板的唤出次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.icon_the_gift_coupon);
	
	-- game.service.MallService:getInstance():query()
	CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
	
end
--点击切换地区按钮
function UIMain:_onBtnRegionClick(sender)
	-- todo 发送CGAreaListREQ，GCAreaListRES显示列表。
	-- 若已报名比赛 则无法切换地区
	if CampaignUtils.forbidenMsgWhenJoinRoom(true) then
		return false
	end
	local request = net.NetworkRequest.new(net.protocol.CGAreaListREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	game.util.RequestHelper.request(request)
end

--点击切换地区按钮
function UIMain:changeRoleId(roleId)
	self._textPlayerID:setString("ID:" .. roleId);
end

function UIMain:_onBtnActivity()
	-- 统计活动点击次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.active_notification_click)
	
	game.service.NoticeMailService:getInstance():CGQueryActivityREQ("lobby")
end

function UIMain:_onBtnNoticeMail()
	UIManager:getInstance():show("UIMessageMain", 0)
end

function UIMain:_onRefreshNoticeMailDot()
	local noticeService = game.service.NoticeMailService.getInstance()
	if noticeService:isNoticeDotShow() or noticeService:isMailDotShow() then
		self._imgNoticeMailDot:setVisible(true)
	else
		self._imgNoticeMailDot:setVisible(false)
	end
	
	if noticeService:isActivityDotShow() then
		self._imgNoticeActivityDot:setVisible(true)
	else
		self._imgNoticeActivityDot:setVisible(false)
	end

	self:_updateMoreRedDot()
end

function UIMain:_onBtnRecommend()
	UIManager:getInstance():show("UIClubMain", false)
end

--成功分享的回调
function UIMain:_onSharePickSuccess(event)
	game.ui.UIMessageBoxMgr.getInstance():show(event.shareContent, {"确定"})
	-- game.ui.UIMessageTipsMgr.getInstance():showTips(event.shareContent)
end


function UIMain:_onUpdateRewardClick(event)
	-- game.ui.UIMessageBoxMgr.getInstance():show("更新版本即送2房卡！！！\n\n新版本内容：\n1.游戏体验优化\n2.下载新版本即可体验《传奇来了》，热血经典等你来战！", {"立即更新"}
	-- , function()
	-- 	local downloadUrl = config.GlobalConfig.getDownloadUrl();
	-- 	cc.Application:getInstance():openURL(config.GlobalConfig.SHARE_HOSTNAME .. downloadUrl)
	-- 	--牌局回放点击量
	-- 	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.CK_Setting_Update)
	-- end, function() end, false, true, cc.TEXT_ALIGNMENT_LEFT, "更新有奖")
	if device.platform == "windows" then
		return
	end
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.update_get_card)
	local isWarn, isForce = getIsWaringAndForceTime()
	UIManager:getInstance():show("UIAccountBindForOld", isWarn, isForce)
end

function UIMain:_onBtnGold()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.gold)
end

function UIMain:_onBtnGamble()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.gamble)
end

function UIMain:_onBtnBackpack()
	game.service.BackpackService:getInstance():queryBackpack()
end

function UIMain:_onBtnTurnCard()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.turnCard)
end

function UIMain:_onBtnReport()
	UIManager:getInstance():show("UIReportMain")
end

function UIMain:_refreshTurnCardActivity()
	local chance = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum()
	--self._btnTurnCard:getChildByName("Image_Point_Main"):setVisible(chance > 0)
	--self._btnTurnCard:getChildByName("Particle_1"):setVisible(chance > 0)


	-- self._btnGuoQing:getChildByName("Image_Point_Main"):setVisible(chance > 0)
	-- self._btnGuoQing.btnStatic:setVisible(chance == 0)
	-- self._btnGuoQing.btnAni:setVisible(chance > 0)

	 self._btnEgg:getChildByName("Image_Point_Main"):setVisible(chance > 0)
	 self._btnEgg:getChildByName("btnAni"):setVisible(chance > 0)
	 self._btnEgg:getChildByName("btnStatic"):setVisible(chance == 0)
end

function UIMain:_onBtnPhoneActivity()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.PhoneActivity_CLICK)
	UIManager:getInstance():show("UIBindPhoneActivity")
end

-- 拉新活动
function UIMain:_onClickPullNew()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.wxShare)
end

function UIMain:_showMoreBtns(visible)
	self._panelMask:setVisible(visible);
	self._panelMask:stopAllActions()
	local x, y = self._btnMore:getPosition()
	if visible then
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1), cc.ScaleTo:create(0.05, 1)))
	else
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.1), cc.ScaleTo:create(0.15, 0)))
	end
end

function UIMain:_onClickMask()
	self:_showMoreBtns(false)
end
function UIMain:_onBtnMore()
	-- game.service.UserEventService:getInstance():_uploadLog()
	self:_showMoreBtns(not self._panelMask:isVisible())
end
function UIMain:_onBtnAccountRecovery(...)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.lobby_account_find)
	UIManager.getInstance():show("UIAccountBindForNew")
end


function UIMain:_onBtnLuckyDraw()
	-- uiSkip.UISkipTool.skipTo(uiSkip.SkipType.luckDraw)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.LuckyDraw_CLICK)
	UIManager:getInstance():show("UILuckyDraw")
end
-- 七日签到活动
function UIMain:_onBtnWeekSign()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.weekSign)
	
end

function UIMain:_onBtnEgg()
	UIManager:getInstance():show("UIGoldenEggs")
end

function UIMain:_onBtnQiXiCharge(...)
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.qixiCharge)
end

function UIMain:_onBtnQiXiTwoGay(...)
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.qixiTwoGay)
end

function UIMain:_onFriendClick()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend)
	UIManager:getInstance():show("UIFriendMain")
end

function UIMain:_chageFriendRed()
	-- self._imgRedFriend:setVisible(game.service.friend.FriendService.getInstance():isApplicant())
end

function UIMain:_onBtnMonthSign()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.monthSign)
end
function UIMain:_onBtnGuoqing()
	UIManager.getInstance():show("UIGuoQing")
end

function UIMain:_onBtnShuang11()
    self:onTDEvent("Button_Special_Shop")
	UIManager.getInstance():show("UIShuang11")
end

function UIMain:_refreshErDingGuaiActivity()
	local progressData = game.service.ActivityService.getInstance().erDingGuaiProgerss
	local hasChance = false
	if progressData then
		for k, v in ipairs(progressData.progress) do
			if v.status == net.protocol.ProgressStatus.completed then
				hasChance = true
				break
			end
		end
	end
	
	self._btnShuang11.red:setVisible(hasChance)
end

function UIMain:_activityQuerysOnShow()
	local activityService = game.service.ActivityService.getInstance()
	if activityService:isActivitieswithin(net.protocol.activityType.QIXI_TWO_GAY) then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldProgressREQ()
	end
	
	if not game.plugin.Runtime.isAccountInterflow() then
		game.service.CertificationService:getInstance():CIAccountHuTongCodeREQ()
	end
	
	local comebackService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
	if comebackService then
		comebackService:checkAutoShow(self.class.__cname)
	end
	
	if activityService:isActivitieswithin(net.protocol.activityType.THROW_REWARD) then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):queryPackageInfo()
    end
    
    if activityService:isActivitieswithin(net.protocol.activityType.SPRING_INVITED) then
		-- 每天弹一次
        if storageTools.AutoShowStorage.isNeedShow("SpringInvited", 1) then
            local springInviteService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
			springInviteService:sendCACGodOfWealthInfoREQ()
		end
	end
end

function UIMain:_onBtnComebackClick(sender)
	-- Q: 如何辨别是不是回归玩家？
	-- A: 在 ACCBackInfoOrdinaryUserRES 中的 task 可以判断是否有签到任务
	local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
	if service then
		service:sendCACBackInfoOrdinaryUserREQ()
	end
end


function UIMain:_refreshFeedbackStatus()
	local hasUnRead = game.service.MeiQiaService.getInstance():getHasUnReadMessages()
	seekNodeByName(self._btnFeedback, "Reddot", "ccui.ImageView"):setVisible(hasUnRead)
end


function UIMain:_onBtnBlessing(...)
	UIManager:getInstance():show("UIBlessing")
end

function UIMain:_showChristmasPackAge()	
	if not UIManager:getInstance():getIsInCache("UIChristmasPackage") then
		UIManager.getInstance():show("UIChristmasPackage")
	end	
end
-- 圣诞签到活动
function UIMain:_onBtnChristmasSign()
	UIManager:getInstance():show("UIChristmasSign")
end

--春节邀新活动
function UIMain:_onClickSpringInvited()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    service:sendCACGodOfWealthInfoREQ()
end

function UIMain:_doWhenReconnect()
	if game.service.ActivityService.getInstance():isActivitieswithin(net.protocol.activityType.THROW_REWARD) then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):queryPackageInfo()
	end
end


function UIMain:_onBtnRedPack()
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.redpack)
end

function UIMain:_onBtnCollectCodeClick()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
    if service then
        service:openActivityMainPage()
    end
end


function UIMain:_onBtnNianbao()

	
	-- local url = "http://test.agtzf.gzgy.gymjnxa.com/annals?areaid=%s&playerid=%s&isInGame=1"
	--正式参数
	local url = "http://agtzf.gzgy.majiang01.com/annals?areaid=%s&playerid=%s&isInGame=1"
	require("app.game.service.h5sdk.yearWebView")
	url = string.format( url,game.service.LocalPlayerService.getInstance():getArea(),game.service.LocalPlayerService.getInstance():getRoleId() )
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.click_nianbao)
	-- cc.Application:getInstance():openURL(url)
	-- game.service.WebViewService.getInstance():openWebView(url)
	yearWebView.getInstance():createWebView(url)

end

-- 调查问卷被点击
function UIMain:_onBtnQuestionnareClick(sender)
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEN_JUAN)
    if service then
        service:openActivityMainPage()
    end
    game.service.TDGameAnalyticsService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Wen_Juan_Main)
end

function UIMain:onTDEvent(eventId)
    if eventId then
        game.service.TDGameAnalyticsService.getInstance():onEvent(eventId)
    end
end

function UIMain:_onBtnWelfare()
	game.service.TDGameAnalyticsService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Welfare)
	self._h5login:showWebView("https://display.eqigou.com/site_login_ijf.htm?app_key=adhua00c55f77ec04c90", 900, function ()
		Logger.debug("_onBtnWelfare")
	end)
end

function UIMain:_onUFOCatcherClicked()
	---@type ActivityServiceBase
	local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.UFO_CATCHER)
	if service then
		service:openActivityMainPage()
	end
end

function UIMain:_palyAnim()
	self._panelLeft:setPositionX(self._panelLeft:getPositionX() - self._panelLeft:getContentSize().width)
	self._panelRight:setPositionX(self._panelRight:getPositionX() + self._panelRight:getContentSize().width)

	--self._panelLeft:runAction(cc.EaseOut:create(cc.MoveBy:create(0.3,cc.p(self._panelLeft:getContentSize().width, 0)), 1.2))
	--self._panelRight:runAction(cc.EaseOut:create(cc.MoveBy:create(0.3,cc.p(-self._panelRight:getContentSize().width, 0)), 1.2))

	local moveL_1 = cc.MoveBy:create(0.2,cc.p(self._panelLeft:getContentSize().width, 0))
	local moveL_2 = cc.MoveBy:create(0.065,cc.p(-5, 0))
	local moveL_3 = moveL_2:reverse()

	local moveR_1 = cc.MoveBy:create(0.2,cc.p(-self._panelRight:getContentSize().width, 0))
	local moveR_2 = cc.MoveBy:create(0.065,cc.p(5, 0))
	local moveR_3 = moveR_2:reverse()

	local actionL = cc.Sequence:create(moveL_1, moveL_2, moveL_3)
	local actionR = cc.Sequence:create(moveR_1, moveR_2, moveR_3)

	self._panelLeft:runAction(actionL)
	self._panelRight:runAction(actionR)
end

function UIMain:getUIRecordLevel()
	return config.UIRecordLevel.MainLayer
end

return UIMain