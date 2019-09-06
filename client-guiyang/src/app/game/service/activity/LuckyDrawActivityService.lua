local super = require("app.game.service.activity.ActivityServiceBase")
local LuckyDrawActivityService = class("LuckyDrawActivityService", super)

function LuckyDrawActivityService:initialize()
    self._costType = -1;
    self._costOnce = 0;
    self._costTen = 0;
    self._cost = {};        --消耗类型
    self._defaultLight = 0  --默认亮灯ID
    self._freeTimes = 0     --
    self._arrItems = {}     --物品
    self._recordList = {}   --获奖列表
    self._strRules = ""     --活动规则
    self._prizeItems = {}    --获奖物品
    self._prizeStr = nil
    self._enterGameShow = false     --每日首次进游戏展示 


    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCQueryLuckyDrawRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息    
    requestManager:registerResponseHandler(net.protocol.ACCQueryDrawRES.OP_CODE, self, self._onReceiveDrawInfo);    --翻牌信息
    requestManager:registerResponseHandler(net.protocol.ACCQueryDrawRecordRES.OP_CODE, self, self._onReceiveAwardInfo);    --中奖纪录信息
end

function LuckyDrawActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function LuckyDrawActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function LuckyDrawActivityService:queryAcitivityInfo()
    net.NetworkRequest.new(net.protocol.CACQueryLuckyDrawREQ, self:getServerId()):execute()
end

-- 接收活动信息
function LuckyDrawActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol, "_onReceiveAcivityInfo~~~")
    if response:isSuccessful() then
        self:setAllItems(protocol.reward)
        self:setCost(protocol.cost)
        self:setDefaultLight(protocol.defaultLightId)
        self:setFreeTimes(protocol.freeDrawTimes)
        self:dispatchEvent({name = "EVENT_ACTIVITY_INFO"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("活动未开启！")   
    end
end

--申请我的奖品列表
function LuckyDrawActivityService:queryAwardInfo()
    net.NetworkRequest.new(net.protocol.CACQueryDrawRecordREQ, self:getServerId()):execute()
end

-- 接收奖品列表信息
function LuckyDrawActivityService:_onReceiveAwardInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol,"_onReceiveAwardInfo~~~~~~~~")
    if protocol.record then
        self:setRecordItems(protocol.record)
    end
    self:dispatchEvent({name = "EVENT_AWARD_LIST_INFO"})
end

-- 抽奖
function LuckyDrawActivityService:queryDrawInfo(times)
    local isFree = self._freeTimes >= times
    net.NetworkRequest.new(net.protocol.CACQueryDrawREQ, self:getServerId()):setBuffer({
        operate = times,
        isFree = isFree,
        costId = self._costType,
    }):execute()
end

-- 接收奖品信息
function LuckyDrawActivityService:_onReceiveDrawInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- dump(protocol, "_onReceiveDrawInfo~~")
   
    if response:isSuccessful() then
        local event = {name = "EVENT_AWARD_INFO"}
        self:setPrizeItems(protocol.reward)
        self:setFreeTimes(protocol.freeDrawTimes)
        self:dispatchEvent(event)
    elseif protocol.result == net.ProtocolCode.ACC_QUERY_DRAW_FAILED_NO_MONEY then
        local event = {name = "EVENT_NO_MONEY"}
        self:dispatchEvent(event)
    end
   
end

function LuckyDrawActivityService:setRecordItems(record)
    self._recordList = record
end
function LuckyDrawActivityService:getRecordItems()
    return self._recordList
end
--设置免费次数
function LuckyDrawActivityService:setFreeTimes(freeTimes)
    if self._freeTimes > 0 and freeTimes == 0 then
        local event = {name = "EVENT_FIRST_DRAW"}
        self:dispatchEvent(event)
    end
    self._freeTimes = freeTimes
end
function LuckyDrawActivityService:getFreeTimes()
    return self._freeTimes
end
--设置抽奖物品
function LuckyDrawActivityService:setAllItems(items)
    self._arrItems = items
end
function LuckyDrawActivityService:getAllItems()
    return self._arrItems
end
--设置抽奖消耗类型
function LuckyDrawActivityService:setCost(cost)
    self._cost = cost
    if self._costType == -1 then
        self:changeCostType(1)
    end
end

function LuckyDrawActivityService:changeCostType(idx)
    if idx > 0 and idx <= #self._cost then
        self._costType = self._cost[idx].itemId
        self._costOnce = self._cost[idx].one
        self._costTen = self._cost[idx].ten
    end
end
function LuckyDrawActivityService:getCostInfo()
    -- return self._costType
    return self._cost
end
function LuckyDrawActivityService:getCostType()
    return self._costType
end
function LuckyDrawActivityService:getCostIcon()
    return config.LuckyDrawConfig.moneyConfig[self._costType][2]
end
function LuckyDrawActivityService:getCostString()
    local strOne = self._costOnce..config.LuckyDrawConfig.moneyConfig[self._costType][1]
    local strTen = self._costTen..config.LuckyDrawConfig.moneyConfig[self._costType][1]
    return strOne,strTen
end
function LuckyDrawActivityService:getCostIdx()
    for i = 1,#self._cost do
        if self._cost[i].itemId == self._costType then
            return i
        end
    end
    return 1
end
--设置默认亮灯Id
function LuckyDrawActivityService:setDefaultLight(defaultId)
    self._defaultLight = defaultId
end
function LuckyDrawActivityService:getDefaultLight()
    return self._defaultLight
end
--中奖
function LuckyDrawActivityService:setPrizeItems(item)
    self._prizeItems = item
end
function LuckyDrawActivityService:getPrizeItems()
    return self._prizeItems
end
function LuckyDrawActivityService:getPrizeIdx()
    local idx = {}
    for _,item in pairs(self._prizeItems) do
        table.insert(idx, item.id)
    end
    return idx
end

function LuckyDrawActivityService:getPrizeStr()
    local str = self._prizeStr
    self._prizeStr = nil
    return nil
end
--设置记录
function LuckyDrawActivityService:setRecordItems(record)
    -- 为了用翻牌的界面，现将字段与翻牌数据统一
    for _,item in pairs(record) do
        item.winTime = item.time
        item.prizeName = item.reward
        item.goodUID = item.goodUUID
    end
    self._recordList = record
end
function LuckyDrawActivityService:getRecordItems()
    return self._recordList
end

function LuckyDrawActivityService:getPhysicalItemInfo(goodUID)
    for i = 1,#self._recordList do
        if self._recordList[i].goodUID == goodUID then
            return self._recordList[i]
        end
    end
    return nil
end

function LuckyDrawActivityService:hasPhysicalItemToGet()
    for i = 1,#self._recordList do
        if PropReader.getTypeById(self._recordList[i].itemId) == "RealItem" and self._recordList[i].status == 0 then
            return true
        end
    end
    return false
end

function LuckyDrawActivityService:setRules(rules)
    self._strRules = rules
end
function LuckyDrawActivityService:getRules()
    return self._strRules
end

function LuckyDrawActivityService:getEnterShow()
    local bShow = self._enterGameShow;
    self._enterGameShow = true
    return bShow
end
return LuckyDrawActivityService