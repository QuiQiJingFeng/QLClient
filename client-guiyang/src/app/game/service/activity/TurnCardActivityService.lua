local super = require("app.game.service.activity.ActivityServiceBase")
local TurnCardActivityService = class("TurnCardActivityService", super)

function TurnCardActivityService:initialize()
	self._nChances = 0       --抽奖次数
	self._arrItems = {}     --物品
	self._arrShowItems = {} --展示物品
	self._arrChances = {}   --任务
	self._recordList = {}   --获奖列表
	self._strRules = ""     --活动规则
	self._prizeItem = {}    --获奖物品
	self._prizeStr = nil
	self._enterGameShow = false     --每日首次进游戏展示 
	self._winnerInfo = {}   --赢家信息
	self._packageInfo = {
		flopCount = 0,
		taskCount = 20,
		received = false,
		package = {}
	}  -- 礼包信息
	
	self._isNeedRecover = false -- 是否需要回主界面恢复显示

	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.ACCFlopHavePrizeRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息
	requestManager:registerResponseHandler(net.protocol.ACCFlopHavePrizeTaskRES.OP_CODE, self, self._onReceiveChanceInfo); --次数信息
	
	requestManager:registerResponseHandler(net.protocol.ACCFlopGetPrizeRecordRES.OP_CODE, self, self._onReceiveAwardInfo);    --中奖纪录信息
	requestManager:registerResponseHandler(net.protocol.ACCSelectPrizeRES.OP_CODE, self, self._onReceiveCardInfo);    --翻牌信息
	
	requestManager:registerResponseHandler(net.protocol.ACCShareFlopPrizeRES.OP_CODE, self, self._onReceiveShareInfo);    --分享信息
	requestManager:registerResponseHandler(net.protocol.ACCFlopWinnerListRES.OP_CODE, self, self._onReceiveWinnerInfo)
	
	requestManager:registerResponseHandler(net.protocol.ACCFlopGiftPackageInfoRES.OP_CODE, self, self._onACCFlopGiftPackageInfoRES)
	requestManager:registerResponseHandler(net.protocol.ACCFlopReceiveGiftPackageRES.OP_CODE, self, self._onACCFlopReceiveGiftPackageRES)
	requestManager:registerResponseHandler(net.protocol.ACCFlopCardBuyRES.OP_CODE, self, self._onACCFlopCardBuyRES)
	
	
	-- 监听二丁拐奖励列表事件,统一做数据处理
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):addEventListener("EVENT_ER_DING_GUAI_REWARD_RECORD", handler(self, self._onReceiveAwardInfoOfErDingGuai), self)
end

function TurnCardActivityService:dispose()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function TurnCardActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function TurnCardActivityService:queryAcitivityInfo()
    net.NetworkRequest.new(net.protocol.CACFlopHavePrizeREQ, self:getServerId()):execute()
end

-- 接收活动信息
function TurnCardActivityService:_onReceiveAcivityInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- dump(protocol, "_onReceiveAcivityInfo~~")
	self:setChanceNum(protocol.remainFlopCounts)
	-- self:setAllItems(protocol.prizeInfoPROTO)
	self:setRules(protocol.rules)
	self:dispatchEvent({name = "EVENT_ACTIVITY_INFO"})
end

-- 申请次数信息
function TurnCardActivityService:queryChanceInfo()
    net.NetworkRequest.new(net.protocol.CACFlopHavePrizeTaskREQ, self:getServerId()):execute()
end

-- 接收次数信息
function TurnCardActivityService:_onReceiveChanceInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	self:setChanceInfo(protocol.taskList)
	
	self:dispatchEvent({name = "EVENT_TASK_INFO"})
end

--申请我的奖品列表
function TurnCardActivityService:queryAwardInfo()
    net.NetworkRequest.new(net.protocol.CACFlopGetPrizeRecordREQ, self:getServerId()):execute()
end

-- 接收奖品列表信息
function TurnCardActivityService:_onReceiveAwardInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- dump(protocol, "_onReceiveAwardInfo")
	if protocol.recordList then
		self:setRecordItems(protocol.recordList)
	end
	self:dispatchEvent({name = "EVENT_AWARD_LIST_INFO"})
end
-- 接收二丁拐奖品列表信息
function TurnCardActivityService:_onReceiveAwardInfoOfErDingGuai(event)

	-- dump(protocol, "_onReceiveAwardInfo")
	if event.protocol.record then
		self:setRecordItems(event.protocol.record)
	end
	self:dispatchEvent({name = "EVENT_AWARD_LIST_INFO"})
end


-- 翻牌
function TurnCardActivityService:queryCardInfo()
    net.NetworkRequest.new(net.protocol.CACSelectPrizeREQ, self:getServerId()):execute()
end

-- 接收奖品信息
function TurnCardActivityService:_onReceiveCardInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- if protocol.result == net.ProtocolCode.GC_SELECT_PRIZE_SUCCESS then
	-- dump(protocol, "_onReceiveCardInfo~~")
	self:setChanceNum(protocol.remainFlopCounts)
	self:dispatchEvent({name = "EVENT_CHANCE_CHANGE"})
	local event = {name = "EVENT_AWARD_INFO"}
	if response:isSuccessful() then
		event.item = protocol.prizeInfoPROTO	
		-- self._prizeItem = protocol.prizeInfoPROTO  
		self:setPrizeItem(protocol.prizeInfoPROTO)
		self:_turnCardToPackage()
	end
	self:dispatchEvent(event)
end
--请求中奖者信息
function TurnCardActivityService:queryWinnerInfo()
    net.NetworkRequest.new(net.protocol.CACFlopWinnerListREQ, self:getServerId()):execute()
end
--接收中奖者信息
function TurnCardActivityService:_onReceiveWinnerInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- dump(protocol, "_onReceiveWinnerInfo~~")
	if response:isSuccessful() then
		self._winnerInfo = protocol.content
		self:dispatchEvent({name = "EVENT_WINNER_INFO"})
	end
end


-- 分享
function TurnCardActivityService:queryShareInfo()
    net.NetworkRequest.new(net.protocol.CACShareFlopPrizeREQ, self:getServerId()):execute()
end
-- 接收分享
function TurnCardActivityService:_onReceiveShareInfo(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:isSuccessful() then
		self._nChances = self._nChances + 1
		self:_changeChanceState(4, true)
		self:dispatchEvent({name = "EVENT_CHANCE_CHANGE"})
	end
end


-- 礼包信息
function TurnCardActivityService:CACFlopGiftPackageInfoREQ()
    net.NetworkRequest.new(net.protocol.CACFlopGiftPackageInfoREQ, self:getServerId()):execute()
end
-- 礼包信息回复
function TurnCardActivityService:_onACCFlopGiftPackageInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._packageInfo = protocol
		self:dispatchEvent({name = "EVENT_PACKAGE_CHANGE"})
	end
end


-- 礼包领取
function TurnCardActivityService:CACFlopReceiveGiftPackageREQ()
    net.NetworkRequest.new(net.protocol.CACFlopReceiveGiftPackageREQ, self:getServerId()):execute()
end
-- 礼包领取回复
function TurnCardActivityService:_onACCFlopReceiveGiftPackageRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		self._packageInfo.received = true
		self:dispatchEvent({name = "EVENT_PACKAGE_CHANGE"})
		self:dispatchEvent({name = "EVENT_PACKAGE_RECEIVE"})
	end
end
--翻拍引起的礼包变化
function TurnCardActivityService:_turnCardToPackage(...)
	if self._packageInfo then
		self._packageInfo.flopCount = self._packageInfo.flopCount + 1
		self:dispatchEvent({name = "EVENT_PACKAGE_CHANGE"})
	end
end

-- 房卡兑换抽奖机会
function TurnCardActivityService:CACFlopCardBuyREQ()
    net.NetworkRequest.new(net.protocol.CACFlopCardBuyREQ, self:getServerId()):execute()
end
-- 房卡兑换抽奖机会回复
function TurnCardActivityService:_onACCFlopCardBuyRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if response:checkIsSuccessful() then
		local task = self:getChanceData(9)
		local count = 1
		if task then
			count = task.chanceCount
		end
		self._nChances = self._nChances + count
		self:queryChanceInfo()
		self:dispatchEvent({name = "EVENT_CHANCE_CHANGE"})
	end
end

function TurnCardActivityService:_changeChanceState(id, state)
	for i = 1, #self._arrChances do
		if self._arrChances[i].taskType == id then
			self._arrChances[i].isFinish = state
			break
		end
	end
end

function TurnCardActivityService:setChanceNum(val)
	self._nChances = val
end
function TurnCardActivityService:getChanceNum()
	return self._nChances
end

function TurnCardActivityService:setRecordItems(record)
	self._recordList = record
	for i = 1, #self._recordList do
		self._recordList[i].itemId = self._recordList[i].itemId
	end
	table.sort(self._recordList, function(a, b)
		return a.winTime > b.winTime		
	end)
end
function TurnCardActivityService:getRecordItems()
	return self._recordList
end
function TurnCardActivityService:setChanceInfo(chances)
	-- local index = {8, 5, 7, 3, 1, 2, 4, 6}   --翻牌的顺序
	local index = {5, 6, 8, 1, 2, 7, 4, 3, 9}        --砸蛋的顺序
	self._arrChances = chances
	table.sort(self._arrChances, function(a, b)
		if not a.isFinish and not b.isFinish then
			return index[a.taskType] < index[b.taskType]
		else	
			return(not a.isFinish and b.isFinish)
		end end)
end
function TurnCardActivityService:getChanceInfo()
	return self._arrChances
end

function TurnCardActivityService:getChanceData(type)
	for k, v in ipairs(self._arrChances) do
		if v.taskType == type then
			return v
		end
	end
	return nil
end

function TurnCardActivityService:setAllItems(items)
	self._arrItems = items
	for _, item in pairs(items) do
		local n = math.floor(item.imageId / 1000)
		if self._arrShowItems[n] == nil or self._arrShowItems[n].imageId > item.imageId then
			self._arrShowItems[n] = item
		end
	end
end
function TurnCardActivityService:getAllShowItems()
	return self._arrShowItems
end
--获取物品
function TurnCardActivityService:getItemByImageId(imageId)
	for _, item in pairs(self._arrItems) do
		if item.imageId == imageId then
			return item
		end
	end
end
--获取父物品
function TurnCardActivityService:getParentItemByImageid(imageId)
	for _, item in pairs(self._arrShowItems) do
		if math.floor(item.imageId / 1000) == math.floor(imageId / 1000) then
			return item
		end
	end
	return nil
end

function TurnCardActivityService:setPrizeItem(item)
	self._prizeItem = item
	if self._prizeItem.prizeName ~= "谢谢参与" then
		self._prizeStr = "恭喜 " .. game.service.LocalPlayerService:getInstance():getName() .. " 翻牌获得 " .. self._prizeItem.prizeName
	end
end
function TurnCardActivityService:getPrizeItem()
	return self._prizeItem
end

function TurnCardActivityService:getPrizeStr()
	local str = self._prizeStr
	self._prizeStr = nil
	return nil
end

function TurnCardActivityService:getPhysicalItemInfo(goodUID)
	for i = 1, #self._recordList do
		if self._recordList[i].goodUID == goodUID then
			return self._recordList[i]
		end
	end
	return nil
end

function TurnCardActivityService:hasPhysicalItemToGet()
	for i = 1, #self._recordList do
		if PropReader.getTypeById(self._recordList[i].itemId) == "RealItem" and self._recordList[i].status == 0 then
			return true
		end
	end
	return false
end

function TurnCardActivityService:setRules(rules)
	self._strRules = rules
end
function TurnCardActivityService:getRules()
	return self._strRules
end

function TurnCardActivityService:getEnterShow()
	local bShow = self._enterGameShow;
	self._enterGameShow = true
	return bShow
end

--主界面是否需要恢复显示
function TurnCardActivityService:isNeedRecoverInMain(...)
	local bShow = self._isNeedRecover;
	self._isNeedRecover = false
	return bShow
end
--设置是否需要回复显示
function TurnCardActivityService:setNeedRecover(flag)
	self._isNeedRecover = flag
end

function TurnCardActivityService:getWinnerInfo()
	return self._winnerInfo
end

function TurnCardActivityService:getPackageInfo(...)
	return self._packageInfo
end

return TurnCardActivityService 