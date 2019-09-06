local csbPath = "ui/csb/Club/UIClubZhuoJi.csb"
local super = require("app.game.ui.UIBase")

local UIClubZhuoJi = class("UIClubZhuoJi", super, function() return kod.LoadCSBNode(csbPath) end)
local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
-- CCLQueryTreasureInfoREQ  opType的类型
local TreasureOpType = {
	open = 1,
	close = 2
}

--滚动列表间距
local textSpace = 15
local moveSpeed = 60

function UIClubZhuoJi:ctor()
	--当前选择要制作的数量
	self._makeCount = 0
	--可以选则制作器的数量组(固定1个)
	self._makersList = {5}
	--当前亲友圈id
	self._clubId = 0
	-- 缓存当前计时器
	self._timer = nil
	-- 缓存捕捉器上限
	self._catcherLimit = 88
	--缓存总奖励
	self._totalReward = 700
	--缓存幸运群主信息的生成控件(img:  text:)
	self._textListForManager = {}
	--缓存运动控件各位置的参数(size:滑动容器参数,num:可用元素的数值,isStart:是否已经开始运动,needRoll是否需要滚动)
	self._scollConfig = {}
	--动画控制
	self._last = 0
	self._preMove = moveSpeed
	self._touchMoved = 0
	-- 制作一个捕捉器的房卡消耗数目
	self._catcherCost = 1
end

function UIClubZhuoJi:init()
	--获取对应按钮
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._btnReward = seekNodeByName(self, "btnReward", "ccui.Button")
	self._btnHelp = seekNodeByName(self, "btnHelp", "ccui.Button")
	self._btnMake = seekNodeByName(self, "btnMake", "ccui.Button")
	
	--获取选择制作捕捉器的checkBox组
	self._checkBoxMakers = CheckBoxGroup.new({
		seekNodeByName(self, "CheckBox_icon1", "ccui.CheckBox"),
	}, handler(self, self._onMakersClick))
	--------------------------------------------
	--滚动页和活动页的tab组
	self._checkBoxTabs = CheckBoxGroup.new({
		seekNodeByName(self, "CheckBox_hbzj", "ccui.CheckBox"),
		seekNodeByName(self, "CheckBox_xyjl", "ccui.CheckBox"),
	}, handler(self, self._onTabsClick))
	
	self._panelZhuoji = seekNodeByName(self, "Panel_ZhuoJi", "ccui.Layout")
	self._panelLuckyManager = seekNodeByName(self, "Panel_lucky_manager", "ccui.Layout")
	
	-----------------------------------------------
	-------------获取需要改变的文本控件
	--总奖励数目文本
	self._textTotalReward = seekNodeByName(self, "textTotalReward", "ccui.Text")	
	--当前进度
	self._textProcess = seekNodeByName(self, "textProcess", "ccui.Text")
	--我制作的数量
	self._textMyMakers = seekNodeByName(self, "textMyMakers", "ccui.Text")
	--参与的群主数量
	self._textManagerCount = seekNodeByName(self, "textManagerCount", "ccui.Text")
	--第几期
	self._bmTextRound = seekNodeByName(self, "bmTextRound", "ccui.TextBMFont")
	--当前亲友圈的房卡数目
	self._bmtextRoomCard = seekNodeByName(self, "bmtextRoomCrad", "ccui.TextBMFont")
	--幸运群主文本模板
	self._managerInfoMould = seekNodeByName(self, "managerInfo", "ccui.ImageView")
	self._textManagerInfo = seekNodeByName(self, "textManagerInfo", "ccui.Text")
	
	--获取幸运群主的装填容器
	self._panelManager = seekNodeByName(self, "Panel_lucky_manager", "ccui.Layout")
	--奖励红点
	self._imgRewardRed = seekNodeByName(self, "imgRewardRed", "ccui.ImageView")
	--消耗房卡数说明
	self._textCatcherCost = seekNodeByName(self, "Text_word", "ccui.Text")
	
	self._scollConfig.size = self._panelManager:getContentSize()
	--设置群主模板属性
	self._textManagerInfo:ignoreContentAdaptWithSize(true)
	self._textManagerInfo:setTextAreaSize(cc.size(self._scollConfig.size.width - 10, 0))
	
	--捕捉器显示文本列表
	self._bmTextCountList = {}
	
	
	for _, v in ipairs(self._checkBoxMakers:getGroups()) do
		table.insert(self._bmTextCountList, seekNodeByName(v, "bmTextCount", "ccui.TextBMFont"))
	end
	self._catcherCost = MultiArea.getZhuoJiCatcherCost(game.service.LocalPlayerService:getInstance():getArea())
	self._textCatcherCost:setString(string.format(config.STRING.UICLUBZHUOJI_STRING_100, self._catcherCost))
	self:_registerCallBack()
end

function UIClubZhuoJi:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnReward, handler(self, self._onReward), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnHelp, handler(self, self._onHelp), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnMake, handler(self, self._onMake), ccui.TouchEventType.ended);
	
	self._panelManager:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			self._preMove = 0
			self._beginTouchPos = sender:getTouchBeganPosition()
		elseif eventType == ccui.TouchEventType.moved then
			local pt = sender:getTouchMovePosition()
			self._touchMoved = pt.y - self._beginTouchPos.y + self._touchMoved
			self._beginTouchPos = pt
		elseif eventType == ccui.TouchEventType.ended then
			self._preMove = moveSpeed
			self._touchMoved = 0
		elseif eventType == ccui.TouchEventType.canceled then
			self._preMove = moveSpeed
			self._touchMoved = 0
		end
	end)
end

function UIClubZhuoJi:onShow(clubId)
	self._clubId = clubId
	
	local clubActivity = game.service.club.ClubService.getInstance():getClubActivityService()
	--监听寻宝捉鸡配置数据,刷新界面显示
	clubActivity:addEventListener("EVENT_TREASURE_INFO_GET", handler(self, self._onTreasureInfoReceive), self)
	--监听活动进度变化
	clubActivity:addEventListener("EVENT_TREASURE_PROCESS_INFO_GET", handler(self, self._onTreasureProcessInfo), self)
	--监听制作捕捉器
	clubActivity:addEventListener("EVENT_CLCPurchaseCatcherRES", handler(self, self._onCLCPurchaseCatcherRES), self)
	--监听奖励版本刷新红点信息
	clubActivity:addEventListener("EVENT_CLUB_ACTIVITY_TREASURE_VERSION_CHANGED", handler(self, self._setRewardShow), self)
	
	--监听房卡变化
	game.service.club.ClubService.getInstance():getClubManagerService():addEventListener("EVENT_USER_INFO_CARD_COUNT_CHANGED", handler(self, self._onCardCountChangedEvent), self)
	
	self._checkBoxMakers:setSelectedIndex(self._checkBoxMakers:getSelectedIndex())
	self._checkBoxTabs:setSelectedIndex(1)
	
	clubActivity:sendCCLQueryTreasureInfoREQ(TreasureOpType.open)
	self:_onCardCountChangedEvent()
	
	self:_setRewardShow()
	
	
end

--点击对应选项时改变要制作捕捉器的数量
function UIClubZhuoJi:_onMakersClick(group, index)
	self._makeCount = self._makersList[index]
end

--切换标签页的回调1:活动界面,2幸运群主
function UIClubZhuoJi:_onTabsClick(group, index)
	local visible = index == 1
	self._panelZhuoji:setVisible(visible)
	self._panelLuckyManager:setVisible(not visible)
	if(not visible) then
		if(not self._scollConfig.isStart) then
			self._scollConfig.isStart = true
			self:scheduleUpdateWithPriorityLua(function(dt)
				self:_update(dt)
			end, 0)
		elseif self._scollConfig.needRoll then
			self:_initTextPosition(self._scollConfig.num, self._scollConfig.needRoll)
			self._scollConfig.isGetBound = false
		end
	end
end

function UIClubZhuoJi:needBlackMask()
	return true
end

function UIClubZhuoJi:_onClose()
	UIManager.getInstance():hide("UIClubZhuoJi")
end

-- 奖励按钮回调
function UIClubZhuoJi:_onReward()
	UIManager.getInstance():show("UIClubZhuoJiReward")
end
--帮助按钮回调
function UIClubZhuoJi:_onHelp()
	UIManager.getInstance():show("UIClubZhuoJiHelp", self._totalReward, self._catcherLimit)
end

--点击制作按钮通知服务器制作前数量的捕捉器
function UIClubZhuoJi:_onMake()
	local clubActivity = game.service.club.ClubService.getInstance():getClubActivityService()
	
	clubActivity:sendCCLPurchaseCatcherREQ(self._clubId, self._makeCount)
	
	--为了防止误点击,使按钮处于0.3S不可点击状态
	self._btnMake:setEnabled(false)
	self._timer = scheduleOnce(function() self._btnMake:setEnabled(true) end, 0.3)
end


function UIClubZhuoJi:onHide()
	local clubActivity = game.service.club.ClubService.getInstance():getClubActivityService()
	clubActivity:removeEventListenersByTag(self)
	game.service.club.ClubService.getInstance():getClubManagerService():removeEventListenersByTag(self)
	game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
	unscheduleOnce(self._timer)
	self._btnMake:setEnabled(true)
	
	clubActivity:sendCCLQueryTreasureInfoREQ(TreasureOpType.close)
	self:unscheduleUpdate()
	self._scollConfig.isStart = false
end

-- 接收到捉鸡寻宝协议数据的回调
function UIClubZhuoJi:_onTreasureInfoReceive(event)
	local protocol = event.protocol
	self._makersList = protocol.purchaseCount
	self._makeCount = self._makersList[self._checkBoxMakers:getSelectedIndex()]
	self._catcherLimit = protocol.catcher
	self._totalReward = protocol.reward
	--刷新ui显示
	self._textTotalReward:setString(config.STRING.UICLUBZHUOJI_STRING_101)
	self._bmTextRound:setString(string.format("第%d期活动", protocol.period))
	self._textProcess:setString(string.format("%d/%d", protocol.currentCatcher, protocol.catcher))
	self._textMyMakers:setString(protocol.myCatcher .. "个")
	self._textManagerCount:setString(string.format("%d个群主已参与", protocol.partakeNumber))
	
	for k, v in ipairs(self._bmTextCountList) do
		v:setString("X" .. self._makersList[k])
	end
	
	self:_setLuckyManager(protocol.luckyManager)
	
end

--本页面进度推送来的时候回调
function UIClubZhuoJi:_onTreasureProcessInfo(event)
	local protocol = event.protocol
	
	--刷新ui显示
	self._bmTextRound:setString(string.format("第%d期活动", protocol.period))
	self._textProcess:setString(string.format("%d/%d", protocol.currentCatcher, self._catcherLimit))
	self._textManagerCount:setString(string.format("%d个群主已参与", protocol.partakeNumber))
	self._textMyMakers:setString(protocol.myCatcher .. "个")
end
--制作捕捉器成功后的回调
function UIClubZhuoJi:_onCLCPurchaseCatcherRES(event)
	
	if event.leftCount > 0 then
		local showMsg = string.format(config.STRING.UICLUBZHUOJI_STRING_102, event.usedCount * self._catcherCost, event.usedCount, event.leftCount * self._catcherCost)
		game.ui.UIMessageBoxMgr.getInstance():show(showMsg, {"确认"})
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("制作成功")
	end
end

-- 实时刷新房卡
function UIClubZhuoJi:_onCardCountChangedEvent()
	-- 设置亲友圈房卡数量
	local clubService = game.service.club.ClubService.getInstance()
	local club = clubService:getClub(self._clubId)
	local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
	if club:isManager(localRoleId) then
		local userData = game.service.club.ClubService.getInstance():getUserData();
		self._bmtextRoomCard:setString(userData.info and userData.info.clubCardCount or "0")
	elseif club:isAdministrator(localRoleId) then
		self._bmtextRoomCard:setString(club.info.clubCardCount)
	end
end

--随机排序
local function RandSort(array)
	------------本来是乱序,现在改为倒序
	-- math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	-- local len = #array
	-- for i = 1, len do
	-- 	local rand = math.random(i, len)
	-- 	local temp = array[rand]
	-- 	array[rand] = array[i]
	-- 	array[i] = temp
	-- end
	local len = #array
	for i = 1, math.floor(len / 2) do
		local rand = len - i + 1
		local temp = array[rand]
		array[rand] = array[i]
		array[i] = temp
	end
	
end

-- 设置幸运群主滚动列表
function UIClubZhuoJi:_setLuckyManager(luckyManagers)
	-- RandSort(luckyManagers)
	
	local totalHeight = 0
	for k, v in ipairs(luckyManagers) do
		if not self._textListForManager[k] then
			self:_createManagerText()
		end
		self._textListForManager[k].text:setString(v)
		local size = self._textListForManager[k].text:getVirtualRendererSize()
		self._textListForManager[k].text:setContentSize(size)
		local imgWidth =(self._textListForManager[k].img:getContentSize()).width
		local imgHeight = size.height + 9
		self._textListForManager[k].img:setContentSize(cc.size(imgWidth, imgHeight))
		self._textListForManager[k].text:setPositionY(imgHeight / 2)
		totalHeight = totalHeight + imgHeight
	end
	
	totalHeight = textSpace *(#luckyManagers - 1) + totalHeight
	
	self:_initTextPosition(#luckyManagers, self._scollConfig.size.height < totalHeight)
end

--创建新的幸运群主条目
function UIClubZhuoJi:_createManagerText()
	local node = self._managerInfoMould:clone()
	self._panelManager:addChild(node)
	table.insert(self._textListForManager, {img = node, text = seekNodeByName(node, "textManagerInfo", "ccui.Text")})	
end

--设置自滚动控件的位置
function UIClubZhuoJi:_initTextPosition(num, needRoll)
	self._scollConfig.num = num
	self._scollConfig.needRoll = needRoll
	local positionY = self._panelManager:getContentSize().height
	if needRoll then
		positionY = positionY / 2
	end
	
	for k, v in ipairs(self._textListForManager) do
		local node = self._textListForManager[k].img
		if k > num then
			node:setPositionY(10000)
		else
			positionY = positionY - node:getContentSize().height - textSpace
			node:setPosition(0, positionY)
		end
	end
	if(num ~= 0) then
		self._scollConfig.lowerBound = self._panelManager:getContentSize().height / 2 + self._textListForManager[num].img:getPositionY()
	end
end

--控制滚动条的帧动画
function UIClubZhuoJi:_update(dt)
	
	local y = 0
	-- touch 位移
	if self._touchMoved ~= 0 then
		for i = 1, self._scollConfig.num do
			local node = self._textListForManager[i].img
			y = node:getPositionY()
			
			y = y + self._touchMoved
			node:setPositionY(y)
		end
		
	end
	
	-- 自动向上移动和位置循环
	if self._scollConfig.needRoll then
		for i = 1, self._scollConfig.num do
			local node = self._textListForManager[i].img
			y = node:getPositionY()
			
			y = y + self._preMove * dt
			if y > self._scollConfig.size.height and self._touchMoved >= 0 then
				self._scollConfig.isGetBound = true
				--找到前一个元素
				local prevNodeIndex = i - 1 > 0 and i - 1 or self._scollConfig.num
				
				local prevNode = self._textListForManager[prevNodeIndex].img
				y = prevNode:getPositionY() - textSpace - node:getContentSize().height
			elseif self._touchMoved <= 0 and self._scollConfig.isGetBound then
				if	y < self._scollConfig.lowerBound then
					--找到后一个元素
					local nextNodeIndex = i + 1 <= self._scollConfig.num and i + 1 or 1
					local nextNode = self._textListForManager[nextNodeIndex].img
					y = nextNode:getPositionY() + textSpace + nextNode:getContentSize().height
				end
			end
			
			node:setPositionY(y)
		end
	end
	
	self._touchMoved = 0
	
end

--设置红点显示
function UIClubZhuoJi:_setRewardShow()
	local cache = game.service.club.ClubService.getInstance():getClubActivityService():getActivityCache()
	
	self._imgRewardRed:setVisible(not cache:getTreasureIsRead())
end

return UIClubZhuoJi
