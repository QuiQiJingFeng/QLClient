local csbPath = "ui/csb/UIMonth.csb"
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIItem = require("app.game.ui.element.UIItem")

local UIDayItem = class("UIDayItem")

local function updateItem(node, info)
	--物品图片
	local imageItem = seekNodeByName(node, "Image_Item", "ccui.ImageView")
	local curDay = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getCurDay()
	-- imageItem:ignoreContentAdaptWithSize(true)
	-- print("_updateItem~~~~~~~~~~~",PropReader.getTypeById(info.itemId))
	-- imageItem:loadTexture(PropReader.getIconByIdAndCount(info.itemId, info.count))
	imageItem:setVisible(false)

	local imageNode = seekNodeByName(node, "Item_Node", "ccui.Layout")
	imageNode:removeAllChildren()

	
	--天数
	local textDay = seekNodeByName(node, "BM_Day", "ccui.TextBMFont")
	textDay:setString("第"..info.day.."天")
	--已签到
	-- dump(info)
	local imageSign = seekNodeByName(node, "Image_Sign", "ccui.ImageView")
	imageSign:setVisible(info.status == 1)
	--已补签
	local imageReSign = seekNodeByName(node, "Image_ReSign", "ccui.ImageView")
	imageReSign:setVisible(info.status == 2)

	local imageToday = seekNodeByName(node, "Image_curDay", "ccui.ImageView")
	imageToday:setVisible(info.day == curDay and info.status == 0 )

	local imageMiss = seekNodeByName(node, "Image_missDay", "ccui.ImageView")
	imageMiss:setVisible(info.day < curDay and info.status == 0)

	local imageAlreadySign = seekNodeByName(node, "Image_6_0", "ccui.ImageView")
	imageAlreadySign:setVisible(info.status ~= 0)

	local item = UIItem.new(info.itemId, info.count, info.time)
	item:setScale(1.2)
	item:setPositionY( -15)
	imageNode:addChild(item)


end

function UIDayItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIDayItem)
    self:_initialize()
    return self
end

function UIDayItem:_initialize()

end

function UIDayItem:setData(items)
	for i = 1, 5 do
		local pNode  = seekNodeByName(self, "Panel_Item"..i, "ccui.Layout")
		-- pNode:setPositionX((i-1) * pNode:getContentSize().width)
		if i > #items then
			pNode:setVisible(false)
		else
			pNode:setTag(i)
			pNode:setVisible(true)
			updateItem(pNode, items[i])
		end
	end
end




local UIMonthSign= class("UIMonthSign",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)



function UIMonthSign:ctor()

end


function UIMonthSign:init()
	--关闭
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	--签到
	self._btnSign = seekNodeByName(self, "Button_Sign", "ccui.Button")
	self._btnAlreadySign = seekNodeByName(self, "Button_AlreadySign", "ccui.Button")
	--补签
	self._btnReSign = seekNodeByName(self, "Button_ReSign", "ccui.Button")
	self._btnAlreadyReSign = seekNodeByName(self, "Button_AlreadyReSign", "ccui.Button")

	self._layoutClose = seekNodeByName(self, "Layout_Close", "ccui.Layout")

	--奖品
	self._listDayItems = UIItemReusedListView.extend(seekNodeByName(self, "ListView_DayItem", "ccui.ListView"), UIDayItem)
	self._listDayItems:setScrollBarEnabled(false)

	--累计奖品
	self._rewardItems = {}
	self._rewardButtons = {}
	self._bmDayLeft = {}
	self._imageAlreadyGet = {}
	self._rewardNodes = {}
	for i = 1,4 do
		self._rewardItems[i] = seekNodeByName(self, "Image_RewardItem"..i, "ccui.ImageView")
		self._rewardItems[i]:setTag(i)
		self._rewardItems[i]:setVisible(false)
		self._rewardItems[i]:setTouchEnabled(true)
		self._rewardNodes[i] = seekNodeByName(self, "Item_Node"..i, "ccui.Layout")
		bindEventCallBack(self._rewardItems[i], handler(self, self._onClickRewardItem), ccui.TouchEventType.ended)
		self._rewardButtons[i] = seekNodeByName(self, "Button_GetReward"..i, "ccui.Button")
		self._bmDayLeft[i] = seekNodeByName(self, "BM_DayLeft"..i, "ccui.TextBMFont")
		self._imageAlreadyGet[i] = seekNodeByName(self, "Image_AlreadyGet"..i, "ccui.ImageView")

		self._rewardButtons[i]:setTag(i)
		bindEventCallBack(self._rewardButtons[i], function() game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryRewardInfo(i-1) end, ccui.TouchEventType.ended)
	end

	self:_registerCallBack()
end

function UIMonthSign:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._layoutClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	-- bindEventCallBack(self._btnHelp, handler(self, self._onClickHelp), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnSign, handler(self, self._onClickSign), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnReSign, handler(self, self._onClickReSign), ccui.TouchEventType.ended)
end

function UIMonthSign:needBlackMask()
    return true
end

function UIMonthSign:closeWhenClickMask()
	return false
end

function UIMonthSign:onShow()
	self._updateTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
		if UIManager:getInstance():getIsShowing("UIMonthSign") then
			self:_update()
		else
			if self._updateTime then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTime)
				self._updateTime = nil
			end
		end
	end, 1, false)

	self._doScorll = false

	--game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryAcitivityInfo()
	--game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):addEventListener("EVENT_SIGN_SUCCEED", handler(self, self._onSignSucceed), self); --处理活动消息
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):addEventListener("EVENT_RECEIVE_REWARD", handler(self, self._getRewardSucceed), self);	--领取累计签到成功

	game.service.LocalPlayerService:getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", handler(self, self._reconnected), self)

	self:_onProcessActivityInfo()
end

function UIMonthSign:onHide()
	if self._updateTime then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTime)
		self._updateTime = nil
	end

	self:_scrollToDay(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getCurDay())
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):removeEventListenersByTag(self)
	game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
end

--关闭
function UIMonthSign:_onClickClose()
	-- UIManager:getInstance():destroy("UIMonthSign")
	UIManager:getInstance():hide("UIMonthSign")
end

--处理活动消息
function UIMonthSign:_onProcessActivityInfo()
	self:_updateAllItems()
	self:_updateButtons()
	self:_updateRewardItems()
	self:_updateRewardItemsState()
	if not self._doScorll then
		self._doScorll = true
		self:_scrollToDay(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getCurDay())
	end

	self:playAnimation_Scale()
end
--
function UIMonthSign:_scrollToDay(day)
	self._doScorll = true
	local week = math.ceil( day / 5 ) - 1
	local totalWeek = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getTotalWeek()
	local percent = week / (totalWeek - 3) * 100
	percent = percent <= 100 and percent or 100
	self._listDayItems:jumpToPercentVertical( percent)
end
--刷新所有物品
function UIMonthSign:_updateAllItems()
	self._listDayItems:deleteAllItems()
	for i = 1,7 do
		local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getItemsByWeek(i)
		if #items > 0 then
			self._listDayItems:pushBackItem(items)
		end
	end
end
--刷新签到和补签按钮状态
function UIMonthSign:_updateButtons()
	local canSign , canResign = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getSignStatus()
	self._btnSign:setVisible(canSign)
	self._btnAlreadySign:setVisible(not canSign)
	self._btnReSign:setVisible(canResign)
	self._btnAlreadyReSign:setVisible(not canResign)
end
--刷新累积物品
function UIMonthSign:_updateRewardItems()
	local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getRewardItems()
	for i = 1,4 do
		-- 加载图片
		-- self._rewardItems[i]:ignoreContentAdaptWithSize(true)
		-- self._rewardItems[i]:loadTexture(images[i])
		self._rewardItems[i]:setVisible(false)
		self._rewardNodes[i]:removeAllChildren()
		local item = UIItem.new(items[i].itemId, items[i].count, items[i].time, true)
		item:changeFontColor(cc.c3b(255, 228, 196))
		item:setScale(1.2)
		item:setPositionY(-8)

		if  i == 4 then 		--特殊处理下这次的红包，很烦躁
			item:hideFont()
			item:setScale(1.5)
			item:setPositionY(0)
		end
		self._rewardNodes[i]:addChild(item)
	end
end
--刷新已领取物品状态
function UIMonthSign:_updateRewardItemsState()
	local items = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getRewardItems()
	local signDays = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getSignDays()
	for i = 1,4 do
		-- 加载图片
		-- self._rewardItems[i]:ignoreContentAdaptWithSize(true)
		-- self._rewardItems[i]:loadTexture(PropReader.getIconByIdAndCount(items[i].itemId, items[i].count))
		

		self._rewardButtons[i]:setVisible(items[i].status ~= 2 and signDays >= items[i].signCount)
		self._imageAlreadyGet[i]:setVisible(items[i].status == 2)
		self._bmDayLeft[i]:setVisible(signDays < items[i].signCount)
		self._bmDayLeft[i]:getChildByName("Day"):setString((items[i].signCount - signDays).."天")
	end
end

--帮助按钮
function UIMonthSign:_onClickHelp(sender)
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.TurnCard_Rull_CLICK)
	local str = string.gsub(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getRules(), "\\n", "\n")
	UIManager:getInstance():show('UIMonthSignHelp', str)
end


--当过日时
function UIMonthSign:_update()
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local date = kod.util.Time.time2Date(time)
	if date.hour ==0 and date.min == 0 and date.sec == 0 then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryAcitivityInfo()
	end	
end

--

function UIMonthSign:_reconnected()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):queryAcitivityInfo()
end

--签到
function UIMonthSign:_onClickSign(sender)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):querySignInfo(1)
end

--补签
function UIMonthSign:_onClickReSign(sender)
	if game.service.LocalPlayerService:getInstance():getCardCount() < game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getResignCost() then
		game.ui.UIMessageBoxMgr.getInstance():show("您的房卡不足，请购买后重试", {"购买","取消"}
		, function()
			CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
		end, function() end, false, true)
	else
		local key =  game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getTodayKey()
		if cc.UserDefault:getInstance():getBoolForKey(key, true) then
			UIManager:getInstance():show("UIMonthSignTips")
		else
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):querySignInfo(2)
		end
	end

end

--签到或补签成功
function UIMonthSign:_onSignSucceed(event)
	local day = event.day
	local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getItemByDay(day)

	--tips提示
	local name = PropReader.getNameById(item.itemId)
	if PropReader.getNameById(item.itemId) == "HeadFrame" then
		game.ui.UIMessageTipsMgr.getInstance():showTips("恭喜您获得"..name)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("恭喜您获得"..name.."X"..item.count)
	end

	--更新按钮状态和下面的累计奖励
	self:_updateButtons()
	self:_updateRewardItemsState()

	--更新物品状态
	local n = math.ceil((day/5))
	local info = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getItemsByWeek(n)
	self._listDayItems:updateItem(n,info)
	
	self:_scrollToDay(day)
end

--领取累计奖励成功
function UIMonthSign:_getRewardSucceed(event)
	local index = event.index
	
	UIManager:getInstance():show("UIMonthSignItem", index, event.count)

	self:_updateRewardItemsState()
end

function UIMonthSign:_onClickRewardItem(sender)
	local index = sender:getTag()
	local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getRewardItemByIndex(index)
	UIManager:getInstance():show("UIElemItem", item.itemId, item.count)
end

return UIMonthSign
