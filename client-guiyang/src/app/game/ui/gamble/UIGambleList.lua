

local super = require("app.game.ui.UIBase")
local nodeTools = require("app.game.util.NodeTools")
local csbPath = "ui/csb/Gamble/UIGambleList.csb"
local stakeTeamType = net.protocol.stakeTeamType
local UIGambleList = class("UIGambleList", super, function() return cc.CSLoader:createNode(csbPath) end)

local TitleItem = class("TitleItem")
local InfoItem = class("InfoItem")

local stakeUIHeight = 150

function UIGambleList:ctor()
	--缓存list中的信息节点的map方便刷新数据
	self._cacheListNode = {}
	--缓存竞彩比赛的版本号,用于判断是否整体刷新数据
	self._gameInfoVersion = - 1
	--缓存当前点击的checkBox节点,方便还原状态
	self._selectedCheckBox = nil
end

function UIGambleList:init()
	self._listGamble = seekNodeByName(self, "listGamble", "ccui.ListView")
	--子条目标题
	self._panelTitle = seekNodeByName(self, "panelTitle", "ccui.Layout")
	--子条目内容
	self._panelItem = seekNodeByName(self, "panelItem", "ccui.Layout")
	
	--将list的内容提出清理用来方便克隆
	self._panelTitle:removeFromParent(false)
	self:getParent():addChild(self._panelTitle)
	self._panelItem:removeFromParent(false)
	self:getParent():addChild(self._panelItem)
	
	self._panelTitle:setVisible(false)
	self._panelItem:setVisible(false)
	
	self._listGamble:removeAllChildren()
	self._listGamble:setScrollBarEnabled(false)
	self._listInnerContainer = self._listGamble:getInnerContainer()
	
end

function UIGambleList:show()
	self:setVisible(true)
	--初始化数据
	self:_setCacheSelectedCheckBoxFree()
	self._listGamble:jumpToTop()
	--监听事件
	local GambleService = game.service.GambleService.getInstance()
	-- 监听点击押注队伍时的事件
	GambleService:addEventListener("EVENT_SHOW_GAMBLE_STAKE_UI", handler(self, self._onShowStakeUI), self)
	--监听获得各比赛数据的事件
	GambleService:addEventListener("EVENT_GAMBLE_INFO_RECEIVE", handler(self, self._onGetGambleInfo), self)
	--监听赔率变化的事件
	GambleService:addEventListener("EVENT_GAMBLE_GAME_ODD_CHANGE", handler(self, self._onGameOddChange), self)
	--监听押注成功后的事件
	GambleService:addEventListener("EVENT_GAMBLE_GAME_STAKE", handler(self, self._onGameStake), self)
	--监听押注界面关闭的事件
	GambleService:addEventListener("EVENT_STAKE_UI_HIDE", handler(self, self._onStakeUIHide), self)
	
	
	local function sendCGQueryLotteryInfoREQ()
		GambleService:sendCGQueryLotteryInfoREQ(1)
	end
	--启动循环计时器定时刷新数据
	local delay = cc.DelayTime:create(30)
	local sequence = cc.Sequence:create(delay, cc.CallFunc:create(sendCGQueryLotteryInfoREQ))
	local action = cc.RepeatForever:create(sequence)
	self:runAction(action)
	sendCGQueryLotteryInfoREQ()
end

function UIGambleList:hide()
	self:setVisible(false)
	local GambleService = game.service.GambleService.getInstance()
	GambleService:removeEventListenersByTag(self)
	GambleService:sendCGQueryLotteryInfoREQ(2)
	--停止循环计时器
	self:stopAllActions()
	
	self:_setCacheSelectedCheckBoxFree()
	
end

--向list中添加子元素
function UIGambleList:_addOneData(value, type)
	local node = nil
	if type == "info" then
		node = nodeTools.extendItem(self._panelItem:clone(), InfoItem)
	else
		node = nodeTools.extendItem(self._panelTitle:clone(), TitleItem)
	end
	node:setVisible(true)
	node:initialize()
	self._listGamble:pushBackCustomItem(node)
	node:setData(value)
	return node
end

--设置竞彩所有比赛的信息
function UIGambleList:_setAllGamblesInfo(event)
	--记录当前list内容器距离list底端的距离
	local currentHeight = self._listInnerContainer:getContentSize().height + self._listInnerContainer:getPositionY()
	
	--清空列表所有节点 已经各种缓存
	self._listGamble:removeAllChildren()
	self._cacheListNode = {}
	self._selectedCheckBox = nil
	
	
	local lastDate = ""
	
	-- 比赛按时间排序
	table.sort(event.protocol.games, function(l, r)
		return	l.time < r.time
	end)
	
	for k, v in ipairs(event.protocol.games) do
		local date = os.date("%x", v.time / 1000)
		if lastDate ~= date then
			lastDate = date
			self:_addOneData({time = v.time}, "title")
		end
		--比赛信息的条目节点缓存下来方便刷新数据
		self._cacheListNode[v.id] = self:_addOneData(v, "info")
	end
	

	
	--因为listview的InnerContainer 此帧的大小没有即刻改变所以延时处理
	scheduleOnce(function(...)
		local listHeight = self._listGamble:getContentSize().height
		local size = self._listInnerContainer:getContentSize()
		local newHeight = size
		if listHeight - size.height < stakeUIHeight then
			newHeight = size.height + stakeUIHeight
			self._listInnerContainer:setContentSize(cc.size(size.width, newHeight))
		end
		self._listInnerContainer:setPositionY(currentHeight - newHeight)
	end, 0)
	
end

--刷新竞彩所有比赛的信息
function UIGambleList:_refreshGamblesInfo(event)
	for k, v in ipairs(event.protocol.games) do
		if(self._cacheListNode[v.id]) then
			self._cacheListNode[v.id]:setData(v)
		end
	end
end

--收到竞彩协议时的处理
function UIGambleList:_onGetGambleInfo(event)
	if self._gameInfoVersion ~= event.protocol.version then
		self._gameInfoVersion = event.protocol.version
		self:_setAllGamblesInfo(event)
	else
		self:_refreshGamblesInfo(event)
	end
end



-- 点击押注选项时,显示押注界面
function UIGambleList:_onShowStakeUI(event)
	-- 把上一个checkBox取消选中 并指向为当前的checkBox
	self:_setCacheSelectedCheckBoxFree()
	self._selectedCheckBox = event.cbox
	
	local node = self._cacheListNode[event.gameId]
	
	--判断押注的这个节点位置是否会被押注界面盖住,如果会盖住则与押注界面一起向上运动
	local diff = node:getPositionY() + self._listInnerContainer:getPositionY() - stakeUIHeight
	if diff < 0 then
		--随同押注界面一同运动
		self._listInnerContainer:stopAllActions()
		self._listGamble:stopAutoScroll()
		self._listGamble:setTouchEnabled(false)
		local move = cc.MoveBy:create(0.1, cc.p(0, - diff))
		local callback = cc.CallFunc:create(function() self._listGamble:setTouchEnabled(true) end)
		local seq = cc.Sequence:create(move, callback)
		self._listInnerContainer:runAction(seq)
	end
end

function UIGambleList:_onGameOddChange(event)
	local gameData = game.service.GambleService.getInstance().commonConfig.games
	for k, v in ipairs(event.changedIds) do
		local node = self._cacheListNode[v]
		if node then
			node:changeOdd(gameData[v])
		end
	end
end

--押注成功后改变对应信息的押注人数和金额,同时取消选中的复选框
function UIGambleList:_onGameStake(event)
	
	self:_setCacheSelectedCheckBoxFree()
end

--取消选中的复选框,并取消指定
function UIGambleList:_setCacheSelectedCheckBoxFree()
	if self._selectedCheckBox then
		self._selectedCheckBox:setSelected(false)
		self._selectedCheckBox = nil
	end
end

--押注界面关闭时,释放当前的复选框
function UIGambleList:_onStakeUIHide()
	self:_setCacheSelectedCheckBoxFree()
end

--------------------------------------子节点相关----------------------------------------
function TitleItem:initialize()
	self.textDate = seekNodeByName(self, "textDate", "ccui.Text")
end

function TitleItem:setData(value)
	local time = value.time / 1000
	local date = os.date("*t", time)
	local week = {"日", "一", "二", "三", "四", "五", "六"}
	self.textDate:setString(string.format("%d月%d日 星期%s", date.month, date.day, week[date.wday]))
end

function InfoItem:initialize()
	self:setAnchorPoint(0, 0)
	-- 队伍名称
	self.textNameHome = seekNodeByName(self, "textNameHome", "ccui.Text")
	self.textNameAway = seekNodeByName(self, "textNameAway", "ccui.Text")
	--队伍图标
	self.imgHome = seekNodeByName(self, "imgHome", "ccui.ImageView")
	self.imgAway = seekNodeByName(self, "imgAway", "ccui.ImageView")
	--赔率部分
	self.textHomeOdds = seekNodeByName(self, "textHomeOdds", "ccui.TextBMFont")
	self.textTiedOdds = seekNodeByName(self, "textTiedOdds", "ccui.TextBMFont")
	self.textAwayOdds = seekNodeByName(self, "textAwayOdds", "ccui.TextBMFont")
	--参与部分
	self.textNumForPartIn = seekNodeByName(self, "textNumForPartIn", "ccui.Text")
	self.textGoldForGamble = seekNodeByName(self, "textGoldForGamble", "ccui.Text")
	--比赛部分
	self.textMatchName = seekNodeByName(self, "textMatchName", "ccui.Text")
	self.textMatchState = seekNodeByName(self, "textMatchState", "ccui.Text")
	--点击部分
	self.checkStakeHome = seekNodeByName(self, "CheckBox_StakeHome", "ccui.CheckBox")
	self.checkStakeTied = seekNodeByName(self, "CheckBox_StakeTied", "ccui.CheckBox")
	self.checkStakeAway = seekNodeByName(self, "CheckBox_StakeAway", "ccui.CheckBox")
end




local function onStake(cbox, gameId, selectedTeam)
	local gold = game.service.LocalPlayerService:getInstance():getGoldAmount()
	if(gold < 200) then
		game.ui.UIMessageTipsMgr.getInstance():showTips("金币低于最低押注额度,无法进行活动")
		return false
	else
		local GambleService = game.service.GambleService.getInstance()
		GambleService:dispatchEvent({name = "EVENT_SHOW_GAMBLE_STAKE_UI", cbox = cbox, gameId = gameId, selectedTeam = selectedTeam})
		return true
	end
end
--点击押注时回调
local function onTounchCheckStakeBox(cbox, gameId, selectedTeam)
	
	return function(sender, eventType)
		local isSelected = false
		if eventType == ccui.TouchEventType.began then
			isSelected = cbox:isSelected()
		elseif eventType == ccui.TouchEventType.moved then
		elseif eventType == ccui.TouchEventType.ended then
			if isSelected then
				cbox:setSelected(isSelected)	
			else
				cbox:setSelected(onStake(cbox, gameId, selectedTeam))
			end
		elseif eventType == ccui.TouchEventType.canceled then
			cbox:setSelected(isSelected)
		end
	end
end

--显示比赛时间的逻辑
local function changeTimeToShow(gameTime)
	local currentTime = game.service.TimeService:getInstance():getCurrentTime()
	local diff = gameTime - currentTime
	if diff < 0 then
		return "已开赛"
	elseif diff < 60 * 5 then
		return "即将开赛"
	elseif diff < 60 * 60 then
		return math.floor(diff / 60) .. "分钟后"
	elseif diff < 3600 * 5 then
		return math.floor(diff / 3600) .. "小时后"
	else
		local date = os.date("*t", gameTime)
		return string.format("%02d:%02d", date.hour, date.min)
	end
end

function InfoItem:setData(value)
	
	self.textNameHome:setString(value.homeTeam)
	game.util.PlayerHeadIconUtil.setIcon(self.imgHome, value.homeIcon, "WORLD_CUP")
	
	self.textNameAway:setString(value.visitingTeam)
	game.util.PlayerHeadIconUtil.setIcon(self.imgAway, value.visitingIcon, "WORLD_CUP")
	
	self.textHomeOdds:setString(value.homeOdds)
	self.textTiedOdds:setString(value.dogFall)
	self.textAwayOdds:setString(value.visitingOdds)
	
	self.textMatchName:setString(value.name)
	
	self.textNumForPartIn:setString(kod.util.String.formatMoney(value.peopleOfBet, 2))
	self.textGoldForGamble:setString(kod.util.String.formatMoney(value.moneyOfBet, 2))
	
	
	self.textMatchState:setString(changeTimeToShow(value.time / 1000))
	
	self.checkStakeHome:addTouchEventListener(onTounchCheckStakeBox(self.checkStakeHome, value.id, stakeTeamType.home))
	self.checkStakeTied:addTouchEventListener(onTounchCheckStakeBox(self.checkStakeTied, value.id, stakeTeamType.tied))
	self.checkStakeAway:addTouchEventListener(onTounchCheckStakeBox(self.checkStakeAway, value.id, stakeTeamType.away))
	
	
end

function InfoItem:changeOdd(value)
	self.textHomeOdds:setString(value.homeOdds)
	self.textTiedOdds:setString(value.dogFall)
	self.textAwayOdds:setString(value.visitingOdds)
end

function InfoItem:changeBetMoneyAPeople(value)
	self.textNumForPartIn:setString(kod.util.String.formatMoney(value.peopleOfBet, 2))
	self.textGoldForGamble:setString(kod.util.String.formatMoney(value.moneyOfBet, 2))
end


return UIGambleList 