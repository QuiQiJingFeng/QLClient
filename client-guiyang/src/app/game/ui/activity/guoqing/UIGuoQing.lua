local csbPath = "ui/csb/Activity/GuoQing/UIGuoQingMain.csb"
local super = require("app.game.ui.UIBase")
local UIGuoQing = class("UIGuoQing", super, function() return kod.LoadCSBNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UI_ANIM = require("app.manager.UIAnimManager")
local ScrollText = require("app.game.util.ScrollText")


function UIGuoQing:ctor()
	
end

function UIGuoQing:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	--烟花列表
	self._listFireWorks = ListFactory.multiListCreate(seekNodeByName(self, "ListView_Fireworks", "ccui.ListView"),
	handler(self, self._onListViewInit),
	handler(self, self._onListViewSetData), 4)
	
	self._btnRewardPreview = seekNodeByName(self, "btnRewardPreview", "ccui.Button")
	self._btnDraw = seekNodeByName(self, "btnDraw", "ccui.Button")
	
	self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	self._btnMyReward = seekNodeByName(self, "btnMyReward", "ccui.Button")
	self._btnChance = seekNodeByName(self, "btnChance", "ccui.Button")
	
	self._textFireCount = seekNodeByName(self, "textFireCount", "ccui.Text")
	self._textProcess = seekNodeByName(self, "textProcess", "ccui.Text")
	-- 播放动画的挡板
	self._imgMask = seekNodeByName(self, "imgMask", "ccui.ImageView")
	-- 放火箭的节点(因为火箭在挡板前面)
	self._panelRocket = seekNodeByName(self, "panelRocket", "ccui.Layout")
	
	self._tempFireItem = nil -- 临时缓存点击的烟花节点
	
	self._panelItems = {
		seekNodeByName(self, "panel1", "ccui.Layout"),
		seekNodeByName(self, "panel2", "ccui.Layout")
	}
	
	
	PropReader.setIconForNode(self._panelItems[1], 51380233, 0.5)
	PropReader.setIconForNode(self._panelItems[2], "art/function/icon_fk2.png", 0.9)
	
	self:_registerCallBack()
	self:_initRocketList()
end

function UIGuoQing:onShow()
	local turnCardService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD)
	turnCardService:addEventListener("EVENT_ACTIVITY_INFO", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	turnCardService:addEventListener("EVENT_PACKAGE_CHANGE", handler(self, self._onPackageInfo), self) 			--处理礼包消息
	turnCardService:addEventListener("EVENT_PACKAGE_RECEIVE", handler(self, self._onPackageReceived), self) 			--处理礼包消息
	turnCardService:addEventListener("EVENT_AWARD_INFO", handler(self, self._onProcessAwardInfo), self) 	--处理抽奖奖品消息
	turnCardService:addEventListener("EVENT_CHANCE_CHANGE", handler(self, self._onProcessActivityInfo), self); --处理活动消息
	
	
	turnCardService:queryAcitivityInfo()
	turnCardService:CACFlopGiftPackageInfoREQ()
	--进入先设置一下数据防止每次都等数据回调
	self:_onPackageInfo()
	self:_onProcessActivityInfo()
end

function UIGuoQing:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):removeEventListenersByTag(self)
end

function UIGuoQing:needBlackMask()
	return true
end


function UIGuoQing:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	--奖励预览
	bindEventCallBack(self._btnRewardPreview, function(...)
		local ui = commonUI.ShowUIWithBtnClose.showUI("ui/csb/Activity/GuoQing/UIGuoQing_Preview.csb")
	end, ccui.TouchEventType.ended)
	--领取礼包
	bindEventCallBack(self._btnDraw, function(...)
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):CACFlopReceiveGiftPackageREQ()
	end, ccui.TouchEventType.ended)
	--国庆帮助
	bindEventCallBack(self._btnHelp, function()
		local ui = commonUI.ShowUIWithBtnClose.showUI("ui/csb/Activity/GuoQing/UIGuoQing_Help.csb")
		ScrollText.new(seekNodeByName(ui, "text", "ccui.Text"), 22, true)
		
	end, ccui.TouchEventType.ended)
	--打开中奖纪录
	bindEventCallBack(self._btnMyReward, function()
		UIManager:getInstance():show("UITurnCardAward")
	end, ccui.TouchEventType.ended)
	--获取领奖次数
	bindEventCallBack(self._btnChance, function(...)
		UIManager.getInstance():show("UITurnCardChance")
	end, ccui.TouchEventType.ended)
end

function UIGuoQing:_close(sender)
	UIManager.getInstance():hide("UIGuoQing")
end

function UIGuoQing:_initRocketList(...)
	self._listFireWorks:setAllData({1, 2, 3, 4, 5, 6, 7, 8})
end

function UIGuoQing:_onListViewInit(listItem)
	listItem.node = seekNodeByName(listItem, "panel", "ccui.Layout")
	listItem.btnFire = seekNodeByName(listItem, "btnFire", "ccui.Button")
	
	local path = "ui/csb/Activity/GuoQing/Rocket.csb"
	listItem.rocket = kod.LoadCSBNode(path)
	listItem.rocket:setAnchorPoint(cc.p(0.5, 0.5))
	listItem.node:addChild(listItem.rocket)
	listItem.rocket:setPosition(cc.p(0, 0))
	listItem.action = cc.CSLoader:createTimeline(path)
	listItem.rocket:runAction(listItem.action)
end

function UIGuoQing:_onListViewSetData(listItem, data)
	local rocketMain = seekNodeByName(listItem.rocket, "ImgMain", "ccui.ImageView")
	rocketMain:loadTexture(string.format("art/function/icon_lp%d.png", data - 1))
	
	bindEventCallBack(listItem.btnFire, function()
		self._tempFireItem = listItem
		self:_onBtnFire()
	end, ccui.TouchEventType.ended)
end

function UIGuoQing:_onBtnFire()
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum() <= 0 then
		game.ui.UIMessageTipsMgr.getInstance():showTips("点燃机会不足，请完成任务")
		return
	end
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):queryCardInfo()
end
-----------------------------------------------------事件回调分割线-------------------------------------------------------------------
-- 抽奖次数回调
function UIGuoQing:_onProcessActivityInfo(event)
	local chanceNum = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getChanceNum()
	self._textFireCount:setString(chanceNum)
	self._listFireWorks:foreach(function(v)
		v.btnFire:setEnabled(chanceNum > 0)
	end)
end
--抽奖回调
function UIGuoQing:_onProcessAwardInfo(event)
	self._panelRocket:setTouchEnabled(true)
	-- 判空一下
	if not self._tempFireItem then
		return
	end
	local listItem = self._tempFireItem
	local posAll = listItem:convertToWorldSpace(cc.p(listItem.node:getPosition()))
	local pos = self._panelRocket:convertToNodeSpace(posAll)
	listItem.rocket:removeFromParent(false)
	self._panelRocket:addChild(listItem.rocket)
	listItem.rocket:setPosition(pos)
	
	self._tempFireItem.action:gotoFrameAndPlay(0, false)
	local actBgMask = cc.Sequence:create(cc.DelayTime:create(2.5), cc.FadeIn:create(1.1))
	local playAniExplodeF = function(...)
		UI_ANIM.UIAnimManager:getInstance():onShow({
			_path = "ui/csb/Activity/GuoQing/Guoqing.csb",
			_parent = UIManager.getInstance():getTopMostLayer()
		})
	end
	local allFinishedF = function()
		self._tempFireItem.action:gotoFrameAndPause(0)
		self._imgMask:setOpacity(0)
		self._panelRocket:setTouchEnabled(false)
		
		listItem.rocket:removeFromParent(false)
		listItem.node:addChild(listItem.rocket)
		listItem.rocket:setPosition(cc.p(0, 0))
		UIManager.getInstance():show("UITurnCardItem")
	end
	self._imgMask:runAction(cc.Sequence:create(actBgMask, cc.CallFunc:create(playAniExplodeF), cc.DelayTime:create(1.3), cc.CallFunc:create(allFinishedF)))
end
-- 礼包信息回调
function UIGuoQing:_onPackageInfo(event)
	local packageInfo = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPackageInfo()
	local btnVisible = false
	
	btnVisible = packageInfo.flopCount >= packageInfo.taskCount and not packageInfo.received
	local text = packageInfo.flopCount < packageInfo.taskCount and packageInfo.flopCount .. "/" .. packageInfo.taskCount or "已领取"
	self._textProcess:setString(text)
	
	
	self._textProcess:setVisible(not btnVisible)
	self._btnDraw:setVisible(btnVisible)
	
end

-- 礼包信息回调
function UIGuoQing:_onPackageReceived(event)
	UIManager.getInstance():show("app.game.ui.activity.guoqing.UIGuoQingPackage")
end


return UIGuoQing 