local csbPath = "ui/csb/Activity/QiXi/UIQiXiTwoGay.csb"
local super = require("app.game.ui.UIBase")
local UIQiXiTwoGay = class("UIQiXiTwoGay", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local UIRollPanel = require("app.game.util.UIRollPanel")
local ShopCostConfig = require("app.config.ShopCostConfig")
local UI_ANIM = require("app.manager.UIAnimManager")

UIQiXiTwoGay.isInTwoGayUI = false

local rewardPanelBgType = {
	[net.protocol.ProgressStatus.uncomplete] = "art/activity/Icon_qp.png",
	[net.protocol.ProgressStatus.completed] = "art/activity/Icon_qp3.png",
	[net.protocol.ProgressStatus.received] = "art/activity/Icon_qp.png",
}

-- function UIQiXiTwoGay:getGradeLayerId()
--     return config.UIConstants.UI_LAYER_ID.Top;
-- end
function UIQiXiTwoGay:ctor()
	--缓存进度信息
	self._progressData = nil
	--是否需要请求获奖名单(目前关闭界面就认为需要重新请求)
	self._isLoadedwinList = false
end

function UIQiXiTwoGay:init()
	--各种按钮
	self._btnGoRoom = seekNodeByName(self, "btnGoRoom", "ccui.Button")
	self._btnGoClub = seekNodeByName(self, "btnGoClub", "ccui.Button")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	
	
	--滚动页和活动页的tab组
	self._checkBoxTabs = CheckBoxGroup.new({
		seekNodeByName(self, "cboxReward", "ccui.CheckBox"),
		seekNodeByName(self, "cboxNameLsit", "ccui.CheckBox"),
	}, handler(self, self._onTabsClick))
	
	-- 幸运名单列表
	self._panelWinList = UIRollPanel.extendItem(seekNodeByName(self, "panelWinList", "ccui.Layout"))
	-- 奖励预览列表
	self._listRewardInfo = seekNodeByName(self, "listRewardInfo", "ccui.ListView")
	-- 进度奖励条
	self._rewardList = {}
	for i = 1, 5 do
		local panel = seekNodeByName(self, "panelReward" .. i, "ccui.Layout")
		table.insert(self._rewardList,
		{
			panel = panel,
			--未完成时显示的进度总体
			panelProgress = seekNodeByName(panel, "panelProgress", "ccui.Layout"),
			--进度条
			loadingBar = seekNodeByName(panel, "loadingBar", "ccui.LoadingBar"),
			--奖励名称
			textReward = seekNodeByName(panel, "textReward", "ccui.Text"),
			--进度(条文字版)
			textProgress = seekNodeByName(panel, "textProgress", "ccui.TextBMFont"),
			--动画节点
			animNode = seekNodeByName(panel, "animNode", "cc.Node"),
			--已领取的标志
			imgReceive = seekNodeByName(panel, "imgReceive", "ccui.ImageView"),
		})
	end
	
	
	self:_registerCallBack()	
end

function UIQiXiTwoGay:_registerCallBack()
	--打开创建房间按钮
	bindEventCallBack(self._btnGoRoom, function(...)
		UIQiXiTwoGay.isInTwoGayUI = true
		UIManager:getInstance():show("UICreateRoom")
	end, ccui.TouchEventType.ended)
	--前往俱乐部
	bindEventCallBack(self._btnGoClub, function(...)
		--从俱乐部回来要重新打开界面
		UIQiXiTwoGay.isInTwoGayUI = true
		uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
	end, ccui.TouchEventType.ended)
	
	--关闭界面
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnHelp, function(...)
		UIManager.getInstance():show("UIQiXiHelp")
		
	end, ccui.TouchEventType.ended)
	
	--领奖事件
	for k, v in ipairs(self._rewardList) do
		bindEventCallBack(v.panel, function()
			self:_drawReward(k)
		end, ccui.TouchEventType.ended)
	end
end

function UIQiXiTwoGay:needBlackMask()
	return true
end

function UIQiXiTwoGay:onShow()
	local activityService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA)
	-- 监听进度事件
	activityService:addEventListener("EVENT_TWO_GAY_ACT_PROGRESS", handler(self, self._setProgress), self)
	-- 监听获奖名单事件
	activityService:addEventListener("EVENT_TWO_GAY_WIN_LIST", handler(self, self._setWinList), self)
	-- 监听领奖的事件
	activityService:addEventListener("EVENT_RECEIVE_TWO_GAY_REWARD", handler(self, self._receiveReward), self)
	
	activityService:sendCACMagpieWorldProgressREQ()
	--默认显示奖励图
	self._checkBoxTabs:setSelectedIndex(1)
end

function UIQiXiTwoGay:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
	self._panelWinList:clear()
	
end
--点击标签切换
function UIQiXiTwoGay:_onTabsClick(group, index)
	local visible = index == 1
	self._listRewardInfo:setVisible(visible)
	self._panelWinList:setVisible(not visible)
	if index == 1 then
		
	else
		if self._isLoadedwinList then
			self._panelWinList:initTextPosition()
		else
			game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):sendCACMagpieWorldWinnerListREQ()
		end
	end
end
--设置奖励信息
function UIQiXiTwoGay:_setProgress(event)
	self._progressData = event.protocol
	
	for k, v in ipairs(event.protocol.progress) do
		local control = self._rewardList[k]
		-- 设置气泡背景
		control.panel:setBackGroundImage(rewardPanelBgType[v.status])
		-- 各状态下的控件显隐控制
		control.panelProgress:setVisible(v.status == net.protocol.ProgressStatus.uncomplete)
		control.animNode:setVisible(v.status == net.protocol.ProgressStatus.completed)
		control.imgReceive:setVisible(v.status == net.protocol.ProgressStatus.received)
		control.textReward:setString(v.reward)
		control.textReward:setVisible(false)
		control.panel:setTouchEnabled(v.status == net.protocol.ProgressStatus.completed or v.status == net.protocol.ProgressStatus.uncomplete)
		
		if v.status == net.protocol.ProgressStatus.uncomplete then
			-- 未完成时设置进度显示
			control.panelProgress:setVisible(true)
			local progress = event.protocol.curRoundCount / v.progress * 100
			control.loadingBar:setPercent(progress > 100 and 100 or progress)
			control.textProgress:setString(event.protocol.curRoundCount .. "/" .. v.progress)
		elseif v.status == net.protocol.ProgressStatus.completed then
			--可领取时显示动画
			if not control.animNode.hasNode then
				control.animNode.hasNode = true
				PropReader.setIconForNode(control.animNode, "ui/csb/Activity/QiXi/Node.csb", 0.9)
			end
		else
			--已领取状态
		end
		
	end
end
--设置幸运名单
function UIQiXiTwoGay:_setWinList(event)
	local winList = {}
	local count = #event.protocol.content
	for k, v in ipairs(event.protocol.content) do
		winList[count - k + 1] = v
	end
	self._panelWinList:setTextList(winList)
	self._panelWinList:startRoll(50)
end

function UIQiXiTwoGay:_close()
	UIQiXiTwoGay.isInTwoGayUI = false
	UIManager.getInstance():hide("UIQiXiTwoGay")
end

function UIQiXiTwoGay:_drawReward(index)
	--如果没有数据则什么都不处理
	if not self._progressData or not self._progressData.progress[index] then
		return
	end
	if self._progressData.curRoundCount >= self._progressData.progress[index].progress then
		local activityService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA)
		activityService:sendCACMagpieWorldReceiveRewardREQ(self._progressData.progress[index].progress)
	else
		game.ui.UIMessageBoxMgr.getInstance():show("完成相应局数后，可点击抽取奖励", {"确定"})
	end
end

function UIQiXiTwoGay:_receiveReward(event)
	local activityService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA)
	activityService:sendCACMagpieWorldProgressREQ()
	local imageSource = event.protocol.itemId == 0 and event.protocol.image or event.protocol.itemId
	UIManager.getInstance():show("UIQiXiRewardGet", imageSource, event.protocol.gooods, event.protocol.count)
end

return UIQiXiTwoGay 