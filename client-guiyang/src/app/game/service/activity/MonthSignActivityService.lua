local super = require("app.game.service.activity.ActivityServiceBase")
local MonthSignActivityService = class("MonthSignActivityService", super)

function MonthSignActivityService:initialize()
    self._enterGameShow = false
    self._curDay = 1        --当前第几天
    self._signDays = 0      --已签到天数
    self._rewardItems = {}  --累计奖励物品信息
    self._dayItems = {}     --30天物品
    self._resignCost = 0    --补签花费
    

    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCMonthSignInfoRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息
    requestManager:registerResponseHandler(net.protocol.ACCMonthSignInRES.OP_CODE, self, self._onReceiveSignInfo); --次数信息
    requestManager:registerResponseHandler(net.protocol.ACCMonthReceiveRewardRES.OP_CODE, self, self._onReceiveRewardInfo); --大奖
end

function MonthSignActivityService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function MonthSignActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function MonthSignActivityService:queryAcitivityInfo()
    net.NetworkRequest.new(net.protocol.CACMonthSignInfoREQ, self:getServerId()):execute()
end

-- 接收活动信息
function MonthSignActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if response:isSuccessful() then
        self:setSignDays(protocol.signCount)
        self:setDayItems(protocol.everyDay)
        self:setRewardItems(protocol.accumulation)
        self:setCurDay(protocol.currentDay)
        self:setResignCost(protocol.signCost)
        --self:dispatchEvent({name = "EVENT_ACTIVITY_INFO"})
        UIManager:getInstance():show("UIMonthSign")
    end
end

-- 申请次数信息
function MonthSignActivityService:querySignInfo(nType)
    net.NetworkRequest.new(net.protocol.CACMonthSignInREQ, self:getServerId()):setBuffer({
        type = nType
    }):execute()
end

-- 接收次数信息
function MonthSignActivityService:_onReceiveSignInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if response:isSuccessful() then
        self:setSignSucceed(protocol.currentDay)
        local event = {name = "EVENT_SIGN_SUCCEED", day = protocol.currentDay}
        self:dispatchEvent(event)
    elseif protocol.result == net.ProtocolCode.ACC_MONTH_SIGN_IN_FAILED then
        game.ui.UIMessageTipsMgr.getInstance():showTips("房卡不足")
    end
end


-- 申请领取大奖(0,1,2,3)
function MonthSignActivityService:queryRewardInfo(index)
    net.NetworkRequest.new(net.protocol.CACMonthReceiveRewardREQ, self:getServerId()):setBuffer({
        index = index
    }):execute()
end

-- 接收领取大奖
function MonthSignActivityService:_onReceiveRewardInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if response:isSuccessful()  then
        -- self:setChanceInfo(protocol.taskList)
        self:setRewardSucceed(protocol.index)
        local event = {name = "EVENT_RECEIVE_REWARD", index = protocol.index + 1, count = protocol.count}
        self:dispatchEvent(event)
    end
end

function MonthSignActivityService:getEnterShow()
    local bShow = self._enterGameShow;
    self._enterGameShow = true
    return bShow
end

--设置30天奖品以及签到状态
function MonthSignActivityService:setDayItems(items)    
    self._dayItems = items
    for i = 1,#items do
        items[i].day = i
    end
end

--设置当前是第几天
function MonthSignActivityService:setCurDay(day)
    self._curDay =day
end
--设置已签到了多少天
function MonthSignActivityService:setSignDays(days)
    self._signDays = days
end
--设置累计签到奖励
function MonthSignActivityService:setRewardItems(items)
    self._rewardItems = items
end

--获取当前天数
function MonthSignActivityService:getCurDay()
    return self._curDay
end
--获取30天物品
function MonthSignActivityService:getDayItems()
    return self._dayItems
end
--获取累计奖励物品
function MonthSignActivityService:getRewardItems()
    return self._rewardItems
end
--获取单个累计物品
function MonthSignActivityService:getRewardItemByIndex(index)
    if index >=1 and index <=4 then
        return self._rewardItems[index]
    end
    return nil
end
--获取已签到天数
function MonthSignActivityService:getSignDays()
    return self._signDays
end
--获取某一天的物品
function MonthSignActivityService:getItemByDay(day)
    if day > #self._dayItems then
        return nil
    end
    return self._dayItems[day]
end
--按周（5天5天）获取物品
function MonthSignActivityService:getItemsByWeek(week)
    local items = {}
    local begin = (week-1)*5
    for i = 1,5 do
        if begin + i > #self._dayItems then
            break
        end
        table.insert(items, self._dayItems[begin+i])
    end
    return items
end
--签到成功
function MonthSignActivityService:setSignSucceed(day)
    self._dayItems[day].status = day == self._curDay and 1 or 2
    self._signDays = self._signDays + 1
end
--大奖领取成功
function MonthSignActivityService:setRewardSucceed(index)
    if index >= 0 and index <= 3 then
        self._rewardItems[index + 1].status = 2
    end
end
--是否可以签到
function MonthSignActivityService:getSignStatus()
    local canSign = self._dayItems[self._curDay].status == 0
    local canReSign = (self._curDay - self._signDays) > 1 or (self._curDay - self._signDays == 1 and not canSign)
    return canSign, canReSign
end
--获取总周数
function MonthSignActivityService:getTotalWeek()
    return math.ceil( #self._dayItems / 5 )
end
--
function MonthSignActivityService:getTodayKey()
    local time = game.service.TimeService:getInstance():getCurrentTime()
    local date = kod.util.Time.dateWithFormat("%Y%m%d",time)
    return date.."_monthsign"
end

function MonthSignActivityService:setResignCost(cost)
    self._resignCost = cost
end

function MonthSignActivityService:getResignCost()
    return self._resignCost
end

return MonthSignActivityService