local csbPath = "ui/csb/UIQsqd02.csb"
-- local csbPath = "ui/csb/Activity/Lantern/Lantern.csb"
local UIItem = require("app.game.ui.element.UIItem")
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIWeekSign= class("UIWeekSign",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIWeekSign:ctor()
	self._cards = {}
end


function UIWeekSign:init()
	self._imageDays = {}
	for i = 1,6 do
		self._imageDays[i] = seekNodeByName(self, "Image_day"..i, "ccui.ImageView")
		self._imageDays[i]:setTouchEnabled(true)
		self._imageDays[i]:setTag(i)
		bindEventCallBack(self._imageDays[i], handler(self, self._onClickItem), ccui.TouchEventType.ended)
	end

	self._panelDay7Before = seekNodeByName(self, "Panel_day7", "ccui.Layout")
	self._panelDay7After = seekNodeByName(self, "Panel_day7_0", "ccui.Layout")
	self._btnShare = seekNodeByName(self, "Button_FX", "ccui.Button")
	self._btnBuqian = seekNodeByName(self, "Button_FX_0", "ccui.Button")
	-- local textBtn = self._btnShare:getChildByName("BitmapFontLabel_3")
	-- textBtn:setString("分享领奖")

	self._btnHelp = seekNodeByName(self, "Button_help", "ccui.Button")

	--关闭
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")

	self:_registerCallBack()

	self.animAction = cc.CSLoader:createTimeline(csbPath)
	self.animAction:gotoFrameAndPlay(0,true)
	self:runAction(self.animAction)
end

function UIWeekSign:_registerCallBack()
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnBuqian, handler(self, self._onClickShare), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
end

function UIWeekSign:needBlackMask()
    return true
end

function UIWeekSign:closeWhenClickMask()
	return false
end

function UIWeekSign:onShow()

	self._updateTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		self:_update()
	end, 1, false)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):queryAcitivityInfo(game.service.LocalPlayerService:getInstance():getArea())

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):addEventListener("EVENT_SIGN_SUCCEED", handler(self, self._onProcessSign), self); --处理活动消息

	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._reconnected), self)
end

function UIWeekSign:onHide()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTime)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):removeEventListenersByTag(self)
	game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
end

function UIWeekSign:_onProcessChancesChange()
	self:_updateChances()
end
-- 更新1-6日的奖品
function UIWeekSign:_updateOneItem(idx)
	local i = idx
	local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getItemByDay(i)
	--已补签
	local imageBuqian = self._imageDays[i]:getChildByName("Image_yibuqian")
	imageBuqian:setVisible(item.status == config.WeekSignConfig.statusType.supplement)
	imageBuqian:setLocalZOrder(1000)
	--已签到
	local imageQiandao = self._imageDays[i]:getChildByName("Image_yiqiandao")
	imageQiandao:setVisible(item.status == config.WeekSignConfig.statusType.sign_in)
	imageQiandao:setLocalZOrder(1000)
	--可以补签
	local imageCanBuqian = self._imageDays[i]:getChildByName("Image_dianjibuqian")
	imageCanBuqian:setVisible(item.status == config.WeekSignConfig.statusType.can_supplement)
	--可以签到
	local imageCanQiandao = self._imageDays[i]:getChildByName("Image_dianjiqiandao")
	imageCanQiandao:setVisible(item.status == config.WeekSignConfig.statusType.can_sign_in)
	--今天
	local imageToday = self._imageDays[i]:getChildByName("Image_today")
	imageToday:setVisible(i == game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getCurDay())

	self._imageDays[i]:removeChildByName("myItem")
	local uiItem = UIItem.new(item.rewardId, item.count, 3)
	uiItem:setName("myItem")
	
	self._imageDays[i]:addChild(uiItem)

	-- local info = config.WeekSignConfig.itemConfig[i]
	local imageItem = self._imageDays[i]:getChildByName("Image_jlICON")
	imageItem:setVisible(false)
	uiItem:setPosition(imageItem:getPosition())
	-- imageItem:ignoreContentAdaptWithSize(true)
	-- imageItem:loadTexture(info[2])

	if item.status ~= config.WeekSignConfig.statusType.can_sign_in and item.status ~= config.WeekSignConfig.statusType.can_supplement then
		uiItem:setPositionY(70)
	end
	-- if idx == 3 then
	-- 	imageItem:setScale(1)
	-- end
	-- imageItem:setScale(1)
end
function UIWeekSign:_updateLastDay()
	-- self._panelLastDay = seekNodeByName(self, "Panel_day7", "ccui.Layout")
	local curPanel = nil
	local scale = 1.2
	local dayInfo, dayInfo2 = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getItemByDay(7)
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getCurDay() < 7 or dayInfo.status >= config.WeekSignConfig.statusType.sign_in then
		self._panelDay7Before:setVisible(true)
		self._panelDay7After:setVisible(false)
		curPanel = self._panelDay7Before
		-- scale = 0.8
		local imageAlready = self._panelDay7Before:getChildByName("Image_2")
		imageAlready:setLocalZOrder(10000)
		imageAlready:setVisible(dayInfo.status >= config.WeekSignConfig.statusType.sign_in)
		
	else		
		self._panelDay7Before:setVisible(false)
		self._panelDay7After:setVisible(true)
		curPanel = self._panelDay7After
		self._panelDay7After:setTag(7)
		self._panelDay7After:addClickEventListener(handler(self, self._onClickItem))

		scale = 1.6
		local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getItemByDay(7)
		--可以补签
		local imageCanBuqian = self._panelDay7After:getChildByName("Button_FX_0")
		imageCanBuqian:setVisible(item.status == config.WeekSignConfig.statusType.can_supplement)
		--可以签到
		local imageCanQiandao = self._panelDay7After:getChildByName("Button_FX")
		imageCanQiandao:setVisible(item.status == config.WeekSignConfig.statusType.can_sign_in)
	end

	local pPanel1 = curPanel:getChildByName("Panel_JL1");
	local image1 = pPanel1:getChildByName("Image_jlICON1")
	image1:setVisible(false)
	curPanel:removeChildByName("csbHeadNode")
	local pItem1 = UIItem.new(dayInfo.rewardId, dayInfo.count , 0)
	pItem1:setName("csbHeadNode")
	pItem1:setScale(scale)
	pItem1:setPosition(image1:getPosition())
	pPanel1:addChild(pItem1)

	local pPanel2 = curPanel:getChildByName("Panel_JL2")
	local image2 = pPanel2:getChildByName("Image_jlICON1")
	image2:setVisible(false)
	curPanel:removeChildByName("csbHeadNode")
	local pItem2 = UIItem.new(dayInfo2.rewardId, dayInfo2.count , 0)
	pItem2:setName("csbHeadNode")
	pItem2:setPosition(image2:getPosition())
	pItem2:setScale(scale)
	pPanel2:addChild(pItem2)
end

function UIWeekSign:_onProcessActivityInfo()
	-- local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getAllItems()
	for i = 1,6 do
		self:_updateOneItem(i)
	end
	self:_updateLastDay()
end

function UIWeekSign:_onProcessSign(event)
	local day = event.day
	if day <= 6 then
		self:_updateOneItem(day)
	else
		-- game.ui.UIMessageBoxMgr.getInstance():show("恭喜您获得", {"确定"})
		UIManager:getInstance():show("UIWeekSignItem")
		self:_updateLastDay()
	end
end

function UIWeekSign:_onClickItem(sender)
	-- 如果第七天需要分享领奖，则用注释掉的这部分
	local idx = sender:getTag()
	if idx == 7 then
		self:_onClickShare()
	else
		self:_signNormalDay(idx)
	end	
	-- local idx = sender:getTag()
	-- self:_signNormalDay(idx)
end
--最后一天分享签到
function UIWeekSign:_onClickShare()
	if not game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):canShare() then
		-- game.ui.UIMessageTipsMgr.getInstance():showTips("签到或补签满六天，即可分享领取第七天奖励")
		game.ui.UIMessageBoxMgr.getInstance():show("签到或补签满六天，即可分享领取第七天奖励", {"确定"})
		return
	end
	-- 如果第七天需要分享领奖，则用注释掉的这部分
	-- local data =
	-- {
	-- 	enter = share.constants.ENTER.WEEK_SIGN,
	-- }
	-- share.ShareWTF:getInstance():share(share.constants.ENTER.WEEK_SIGN, {data, data, data}, handler(self,self._onShareCompleted))

	self:_signNormalDay(7)
end
--平时签到
function UIWeekSign:_signNormalDay(idx)
	local dayInfo = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getItemByDay(idx)
	if dayInfo == nil then
		Macro.assertFalse(false,"_sign Normal Day error:".. idx)
		return
	end
	if dayInfo.status == config.WeekSignConfig.statusType.can_sign_in then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):querySignInfo(idx, config.WeekSignConfig.operateType.sign)
	elseif dayInfo.status == config.WeekSignConfig.statusType.can_supplement then
		if game.service.LocalPlayerService:getInstance():getCardCount() < 2 then 
			game.ui.UIMessageBoxMgr.getInstance():show("房卡不足，是否前往商城购买",
			 {"取消","购买"},
			function ()
				return
			end,
			function()
				CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
			end,
			true)
			return
		end

		game.ui.UIMessageBoxMgr.getInstance():show("是否使用2房卡进行补签", 
			{"取消","确定"},
			function ()
				return
			end,
			function()
				game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):querySignInfo(idx, config.WeekSignConfig.operateType.supplement)
			end,
        true)
	end
end
function UIWeekSign:_onShareCompleted()
	-- print("_onShareCompleted~~~~~~~~~~~~~~~~~~~~~~~~~")
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):querySignInfo(7, config.WeekSignConfig.operateType.sign)
end

--关闭
function UIWeekSign:_onClickClose()
	UIManager:getInstance():hide("UIWeekSign")
end

--帮助按钮
function UIWeekSign:_onClickHelp(sender)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Rull_CLICK)
	local str = string.gsub(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRules(), "\\n", "\n")
	UIManager:getInstance():show('UIWeekSignHelp', str)
end

function UIWeekSign:_update()
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local date = kod.util.Time.time2Date(time)
	if date.hour ==0 and date.min == 0 and date.sec == 0 then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):queryAcitivityInfo(game.service.LocalPlayerService:getInstance():getArea())
	end
end

function UIWeekSign:_reconnected()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):queryAcitivityInfo(game.service.LocalPlayerService:getInstance():getArea())
end

return UIWeekSign
