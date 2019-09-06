
local csbPath = "ui/csb/BigLeague/UIBigLeagueGamePlayStatistics.csb"
local super = require("app.game.ui.UIBase")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local UIBigLeagueGamePlayStatistics = class("UIBigLeagueGamePlayStatistics", super, function() return kod.LoadCSBNode(csbPath) end)
function UIBigLeagueGamePlayStatistics:ctor()
	
end

function UIBigLeagueGamePlayStatistics:init()
	self._reusedListManager = ListFactory.get(
	seekNodeByName(self, "ListView_PlayStatistics", "ccui.ListView"),
	handler(self, self._onListViewInit),
	handler(self, self._onListViewSetData)
	)
	
	-- 不显示滚动条, 无法在编辑器设置
	self._reusedListManager:setScrollBarEnabled(false)
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox") -- 今日数据
	self._btnYesterDay = seekNodeByName(self, "CheckBox_Yesterday", "ccui.CheckBox") -- 昨日数据
	self._btnBeforeYesterday = seekNodeByName(self, "CheckBox_BeforeYesterday", "ccui.CheckBox") -- 前日数据
	--日期选择box
	local tbChkBox = {self._btnToday, self._btnYesterDay, self._btnBeforeYesterday}
	local isSelected = true
	local pFunc = function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			isSelected = sender:isSelected()
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if sender:getName() == "CheckBox_Today" then
				self:_onClickToday()
			elseif sender:getName() == "CheckBox_Yesterday" then
				self:_onClickYesterDay()
			elseif sender:getName() == "CheckBox_BeforeYesterday" then
				self:_onClickBeforeYesterday()
			end
			
			for _, btn in ipairs(tbChkBox) do
				btn:setSelected(sender == btn)
			end
		elseif eventType == ccui.TouchEventType.canceled then
			sender:setSelected(isSelected)
		end
	end
	
	self._btnToday:addTouchEventListener(pFunc)
	self._btnYesterDay:addTouchEventListener(pFunc)
	self._btnBeforeYesterday:addTouchEventListener(pFunc)
	
	
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end


function UIBigLeagueGamePlayStatistics:_onListViewInit(listItem)
	
	listItem._textIndex = seekNodeByName(listItem, "Text_Index", "ccui.TextBMFont") --排序
	listItem._textGameName = seekNodeByName(listItem, "Text_GameName", "ccui.Text") --玩法名称
	listItem._textGameCount = seekNodeByName(listItem, "Text_PlayCount", "ccui.Text") -- 玩法场次
	listItem._textLotteryGameCount = seekNodeByName(listItem, "Text_DrawCount", "ccui.Text") -- 抽奖场次
	listItem._textLotteryCost = seekNodeByName(listItem, "Text_DrawCost", "ccui.Text") -- 抽奖消耗
	listItem._btnRuleEdit = seekNodeByName(listItem, "Button_RuleEdit", "ccui.Button") --玩法编辑按钮
	
end

function UIBigLeagueGamePlayStatistics:_onListViewSetData(listItem, val)
	listItem._textIndex:setString(val.index)
	listItem._textGameName:setString(val.name)
	listItem._textGameCount:setString(val.gameCount)
	listItem._textLotteryGameCount:setString(val.lotteryGameCount)
    listItem._textLotteryCost:setString(val.lotteryCost)
    
	--点击编辑
	bindEventCallBack(listItem._btnRuleEdit, function()
		--该玩法删除了
		if val.delete then
			game.ui.UIMessageTipsMgr.getInstance():showTips("该玩法已被删除")
			return
        end
        local tabBsy = {}
        tabBsy.isGameplayStatistics = val.isGameplayStatistics
        tabBsy.date = val.date
		UIManager:getInstance():show("UIBigLeagueGameRuleEdit", val.gameplay,tabBsy)
	end, ccui.TouchEventType.ended)
end

function UIBigLeagueGamePlayStatistics:onShow()
    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
	--默认选中今天
	self._btnToday:setSelected(true)
	self._btnBeforeYesterday:setSelected(false)
	self._btnYesterDay:setSelected(false)
	--发送今天的协议
	self:_onClickToday()
	self._bigLeagueService:addEventListener("EVENT_PLAY_STATISTIC", handler(self, self._updateListView), self)
end


--点击今日
function UIBigLeagueGamePlayStatistics:_onClickToday()
	self:_sendQueryRequest(0)	
end

--点击昨日
function UIBigLeagueGamePlayStatistics:_onClickYesterDay()
	self:_sendQueryRequest(1)	
end

--点击前日
function UIBigLeagueGamePlayStatistics:_onClickBeforeYesterday()
	self:_sendQueryRequest(2)	
end

--发送请求
function UIBigLeagueGamePlayStatistics:_sendQueryRequest(preDate)
	self._bigLeagueService:sendCCLQueryGameplayStatisticsREQ(self._bigLeagueService:getLeagueData():getLeagueId(),
	game.service.TimeService:getInstance():getStartTime(preDate) * 1000)
	
end

function UIBigLeagueGamePlayStatistics:_updateListView()
	--获取玩法数据
    local gameplayData = self._bigLeagueService:getLeagueData():getGamePlayStatistic()
	--按照成员场次排序
	table.sort(gameplayData, function(a, b)
		return a.gameCount > b.gameCount
	end)
	-- 清空数据
	self._reusedListManager:deleteAllItems()
	for i, data in ipairs(gameplayData) do
        data.index = i
        data.isGameplayStatistics = true
		self._reusedListManager:pushBackItem(data)
	end
	
end

function UIBigLeagueGamePlayStatistics:_onClickClose()
	self:hideSelf()
end

function UIBigLeagueGamePlayStatistics:onHide()
	self._bigLeagueService:removeEventListenersByTag(self)
end

return UIBigLeagueGamePlayStatistics 