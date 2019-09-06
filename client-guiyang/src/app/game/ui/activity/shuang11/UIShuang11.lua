local csbPath = "ui/csb/Activity/WomensDay/UIWomensDay.csb"
local super = require("app.game.ui.UIBase")
local UIShuang11 = class("UIShuang11", super, function() return kod.LoadCSBNode(csbPath) end)
local UI_ANIM = require("app.manager.UIAnimManager")

local ListFactory = require("app.game.util.ReusedListViewFactory")


UIShuang11.isInTwoGayUI = false

local giftBag = {
	{skinReach = "art/function/img_lihe3.png", skinUnReach = "art/function/img_lihe2.png", scale = 0.8},
	{skinReach = "art/function/img_lihe3.png", skinUnReach = "art/function/img_lihe2.png", scale = 0.8},
	{skinReach = "art/function/img_lihe3.png", skinUnReach = "art/function/img_lihe2.png", scale = 0.8},
	{skinReach = "art/function/img_lihe3.png", skinUnReach = "art/function/img_lihe2.png", scale = 0.8},
	{skinReach = "art/function/img_lihe.png", skinUnReach = "art/function/img_lihe2.png", scale = 1.1}
}

function UIShuang11:ctor()
	--缓存进度信息
	self._progressData = nil
	--是否需要请求获奖名单(目前关闭界面就认为需要重新请求)
	self._isLoadedwinList = false
end

function UIShuang11:init()
	--各种按钮
	self._btnGoRoom = seekNodeByName(self, "btnGoRoom", "ccui.Button")
	self._btnGoClub = seekNodeByName(self, "btnGoClub", "ccui.Button")
	
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	-- 奖品记录
	self._btnRewardRecord = seekNodeByName(self, "btnRewardRecord", "ccui.Button")
	--进度条
	self._loadingBar = seekNodeByName(self, "LoadingBar", "ccui.LoadingBar")
	
	-- 奖励宝箱进度
	self._listChance = ListFactory.get(seekNodeByName(self, "listChance", "ccui.ListView"), handler(self, self._initlistChance), handler(self, self._setDatalistChance), "listChance")
	-- 进度奖励条
	self._listBoxes = ListFactory.multiListCreate(seekNodeByName(self, "listBoxes", "ccui.ListView"), handler(self, self._initlistBoxes), handler(self, self._setDatalistBoxes), 10, "listBoxes")
	
	self._listChance:deleteAllItems()
	self._listBoxes:deleteAllItems()
	
	self._loadingBar:setPercent(0)
	self:_registerCallBack()	
	
	local prize = {"500元红包", "300元红包", "100元红包", "50元红包", "20元红包", "10元红包", "1-5元随机红包", "游戏内道具"}
	for k, v in ipairs(prize) do
		self._listChance:pushBackItem(v)
	end
	
end

function UIShuang11:_registerCallBack()
	--打开创建房间按钮
	bindEventCallBack(self._btnGoRoom, function(...)
		UIShuang11.isInTwoGayUI = true
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.erdingguai_homepage)
		UIManager:getInstance():show("UICreateRoom")
	end, ccui.TouchEventType.ended)
	--前往俱乐部
	bindEventCallBack(self._btnGoClub, function(...)
		--从俱乐部回来要重新打开界面
		UIShuang11.isInTwoGayUI = true
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.erdingguai_friendCircle)		
		if GameFSM.getInstance():getCurrentState().class.__cname == "GameState_Club" then
			self:hideSelf()
		else
			uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
		end
		
	end, ccui.TouchEventType.ended)
	
	--关闭界面
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnHelp, function(...)
		
		commonUI.ShowUIWithBtnClose.showUI("ui/csb/Activity/WomensDay/UIWomensDay_Explain.csb")
		
	end, ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnRewardRecord, function(...)
		UIManager:getInstance():show("UITurnCardAward", "shuang11")
	end, ccui.TouchEventType.ended)
	
end

-- function UIShuang11:needBlackMask()
-- 	return true
-- end

function UIShuang11:onShow()
	local activityService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA)
	-- 监听进度事件
	activityService:addEventListener("EVENT_TWO_GAY_ACT_PROGRESS", handler(self, self._setProgress), self)
	-- 监听领奖的事件
	activityService:addEventListener("EVENT_RECEIVE_TWO_GAY_REWARD", handler(self, self._receiveReward), self)
	
	self:_setProgress()
    activityService:sendCACMagpieWorldProgressREQ()    
end

function UIShuang11:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
	
end

function UIShuang11:_close()
	UIShuang11.isInTwoGayUI = false
	UIManager.getInstance():hide("UIShuang11")
end

-- 抽奖列表相关
function UIShuang11:_initlistBoxes(listItem)
	listItem.textDrawStatus = listItem:getChildByName("textDrawStatus")
	listItem.imgUnReach = listItem:getChildByName("imgUnReach")
	listItem.imgReach = listItem:getChildByName("imgReach")
	listItem.btnDraw = listItem:getChildByName("btnDraw")
	listItem.ImgReceived = listItem:getChildByName("ImgReceived")
	
end
function UIShuang11:_setDatalistBoxes(listItem, value)
	local flagReach = value.curRoundCount >= value.data.progress
	local flagReceived = value.data.status == net.protocol.ProgressStatus.received
	
	listItem.textDrawStatus:setString((value.curRoundCount > value.data.progress and value.data.progress or value.curRoundCount) .. "/" .. value.data.progress .. "局")
	
	listItem.imgUnReach:setVisible(not flagReach)
	listItem.imgReach:setVisible(flagReach)

	-- listItem.imgUnReach:setVisible(false)
	-- listItem.imgReach:setVisible(true)
	
	listItem.textDrawStatus:setVisible(not flagReceived)
	listItem.ImgReceived:setVisible(flagReceived)
	listItem.btnDraw:setVisible(not flagReceived and flagReach)
	
	local imgData = giftBag[value.index]
	listItem.imgUnReach:loadTexture(imgData.skinUnReach)
	listItem.imgReach:loadTexture(imgData.skinReach)
	
	listItem.imgUnReach:setScale(imgData.scale)
	listItem.imgReach:setScale(imgData.scale)
	
	
	bindEventCallBack(listItem.btnDraw, function()
		if flagReach then
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldReceiveRewardREQ(value.data.progress)
		else
			game.ui.UIMessageBoxMgr.getInstance():show("完成相应局数后，可点击抽取奖励", {"确定"})
		end
    end, ccui.TouchEventType.ended)
    
    bindEventCallBack(listItem.imgReach, function()
		if flagReach and not flagReceived then
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldReceiveRewardREQ(value.data.progress)
		end
	end, ccui.TouchEventType.ended)
end

-- 抽奖机会列表相关
function UIShuang11:_initlistChance(listItem)
	listItem.text = listItem:getChildByName("text")
	
end
function UIShuang11:_setDatalistChance(listItem, value)
	-- local text = ""
	-- if value.curRoundCount >= value.data.progress then
	-- 	text = "已达成"
	-- else
	-- 	text = string.format("完成二丁拐%d/%d局", value.curRoundCount, value.data.progress)
	-- end
	listItem.text:setString(value)
end


--设置奖励信息
function UIShuang11:_setProgress()
	-- self._listChance:deleteAllItems()
	local progressData = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA).erDingGuaiProgerss
	
	if progressData then
		self._loadingBar:setPercent(progressData.curRoundCount / progressData.maxRoundCount * 100)
		local giftBagData = {}
		for k, v in ipairs(progressData.progress) do
			local data = clone(progressData)
			data.data = v
			data.index = k
			table.insert(giftBagData, data)
			-- self._listChance:pushBackItem(data)
		end
		self._listBoxes:setAllData(giftBagData)
	else
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldProgressREQ()
	end
end
-- 抽奖的回调
function UIShuang11:_receiveReward(event)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldProgressREQ()
	
	UI_ANIM.UIAnimManager:getInstance():onShow({
		_path = "ui/csb/Activity/WomensDay/Effect_WomensDay.csb",
		_parent = UIManager.getInstance():getTopMostLayer()
	})
	
	local action = cc.Sequence:create(cc.DelayTime:create(1.6), cc.CallFunc:create(function(...)
		UIManager.getInstance():show("UITurnCardItem", self, event.protocol.itemId, event.protocol.count, event.protocol.time )
	end))
	
	self:runAction(action)
end

function UIShuang11:_receiveRecord(...)
	UIManager:getInstance():show("UITurnCardAward")
end

return UIShuang11 