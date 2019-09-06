local csbPath = "ui/csb/Activity/Christmas/UIChristmasSign.csb"
local super = require("app.game.ui.UIBase")
local UIChristmasSign = class("UIChristmasSign", super, function() return kod.LoadCSBNode(csbPath) end)

local UIItem = require("app.game.ui.element.UIItem")
local ListFactory = require("app.game.util.ReusedListViewFactory")

function UIChristmasSign:ctor()
	
end

function UIChristmasSign:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._listReward = ListFactory.multiListCreate(seekNodeByName(self, "listReward", "ccui.ListView"),
	handler(self, self._onListViewInit),
	handler(self, self._onListViewSetData), 4)
	
	
	self:_registerCallBack()
end
-- 签到每个重复单元初始化
function UIChristmasSign:_onListViewInit(listItem)
	listItem.panelItem = seekNodeByName(listItem, "panelItem", "ccui.Layout")
	listItem.btnDraw = seekNodeByName(listItem, "btnDraw", "ccui.Button")
	listItem.imgFlag = seekNodeByName(listItem, "imgFlag", "ccui.ImageView")
	listItem.imgDrawBg = seekNodeByName(listItem, "imgDrawBg", "ccui.ImageView")
	
	listItem.textName = seekNodeByName(listItem, "textName", "ccui.TextBMFont")
end
-- 签到每个重复单元赋值
function UIChristmasSign:_onListViewSetData(listItem, index)
	local signData = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getSignData()
	local reward = signData.reward[index]
	UIItem.extend(listItem.panelItem, listItem.textName, reward.itemId, reward.count, reward.time)
	
	listItem.imgFlag:setVisible(index <= signData.signCount)

	local canDraw = signData.canSign and signData.signCount + 1 == index
	listItem.btnDraw:setVisible(canDraw)
	listItem.imgDrawBg:setVisible(canDraw)
	local posY = canDraw and 85.00 or 70
	listItem.panelItem:setPositionY(posY)
	-- 签到
	bindEventCallBack(listItem.btnDraw, function(...)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACPraySignREQ()
	end, ccui.TouchEventType.ended)
	
end

function UIChristmasSign:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	
	
end

function UIChristmasSign:onShow()
	-- 获取签到信息刷新显示
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_SING_INFO_RECEIVE", handler(self, self._refreshShowUI), self)
	-- 签到后刷新显示 并 提示奖励
	event.EventCenter:addEventListener("EVENT_CHRISTMAS_SING_RECEIVE_SUCCESS", function(event)
		self:_refreshShowUI()
		local itemData = event.itemData
		
		UIManager.getInstance():show("UITurnCardItem", self, itemData.itemId, itemData.count, itemData.time)
	end, self)

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACPraySignInfoREQ()
	self:_refreshShowUI()
end

function UIChristmasSign:onHide()
	event.EventCenter:removeEventListenersByTag(self)
	
end

function UIChristmasSign:needBlackMask()
	return true
end

function UIChristmasSign:_close(sender)
	UIManager.getInstance():hide("UIChristmasSign")
end

function UIChristmasSign:_refreshShowUI(...)
	local signData = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getSignData()
	-- 本地没有信息则请求
	if not signData then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACPraySignInfoREQ()
		self._listReward:setVisible(false)
	else
		self._listReward:setVisible(true)
		-- 初始化单元数据
		self._listReward:setAllData({1, 2, 3, 4, 5, 6, 7, 8})
	end
end


return UIChristmasSign 