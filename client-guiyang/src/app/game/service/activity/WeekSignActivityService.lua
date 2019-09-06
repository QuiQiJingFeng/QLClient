local super = require("app.game.service.activity.ActivityServiceBase")
local WeekSignActivityService = class("WeekSignActivityService", super)

function WeekSignActivityService:initialize()
    self._enterGameShow = false
    self._curDay = 1        --当前第几天
    self._arrItems = {}     --物品

    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.ACCQueryWeekRES.OP_CODE, self, self._onReceiveAcivityInfo);  --活动信息
    requestManager:registerResponseHandler(net.protocol.ACCQuerySignInRES.OP_CODE, self, self._onReceiveSignInfo); --次数信息
end

function WeekSignActivityService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function WeekSignActivityService:getServerId()
    return game.service.LocalPlayerService:getInstance():getActivityManagerServerId()
end

-- 申请活动信息
function WeekSignActivityService:queryAcitivityInfo(area)
    net.NetworkRequest.new(net.protocol.CACQueryWeekREQ, self:getServerId()):setBuffer({
        area = area,
    }):execute()
end

-- 接收活动信息
function WeekSignActivityService:_onReceiveAcivityInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    dump(protocol, "_onReceiveAcivityInfo")
    if response:isSuccessful() then
        self:setCurDay(protocol.day)
        self:setAllItems(protocol.rewards)
        self:dispatchEvent({name = "EVENT_ACTIVITY_INFO"})
    end
end

-- 申请次数信息
function WeekSignActivityService:querySignInfo(day, operate)
    net.NetworkRequest.new(net.protocol.CACQuerySignInREQ, self:getServerId()):setBuffer({
        day = day,
        operate = operate,
    }):execute()
end

-- 接收次数信息
function WeekSignActivityService:_onReceiveSignInfo(response)
    local protocol = response:getProtocol():getProtocolBuf()
    dump(protocol, "_onReceiveSignInfo")
    if response:isSuccessful() then
        -- self:setChanceInfo(protocol.taskList)
        self:setSignSucceed(protocol.day)
        local event = {name = "EVENT_SIGN_SUCCEED", day = protocol.day}
        self:dispatchEvent(event)
    elseif protocol.result == net.ProtocolCode.ACC_QUERY_SING_IN_FAILED_NO_MONEY then
        --todo: money not enough
        game.ui.UIMessageTipsMgr.getInstance():showTips("房卡不足")
    end
    
    -- self:dispatchEvent({name = "EVENT_TASK_INFO"})
end


function WeekSignActivityService:getEnterShow()
    local bShow = self._enterGameShow;
    self._enterGameShow = true
    return bShow
end

function WeekSignActivityService:setCurDay(day)
    self._curDay = day
end
function WeekSignActivityService:getCurDay()
    return self._curDay
end
function WeekSignActivityService:setAllItems(items)
    self._arrItems = items
end
function WeekSignActivityService:getAllItems()
    return self._arrItems
end
function WeekSignActivityService:getItemByDay(day)
    if day == 7 then
        return self._arrItems[7], self._arrItems[8]
    end
    for _,item in pairs(self._arrItems) do
        if item.day == day then
            return item
        end
    end
    Macro.assertFalse(false,"no such day info"..day)
    return nil
end
--是否可以分享，完成了前6天的签到才可以分享
function WeekSignActivityService:canShare()
    for _,item in pairs(self._arrItems) do
        if item.day <= 6 and item.status <= config.WeekSignConfig.statusType.can_supplement then
            return false
        end
    end
    return true
end

function WeekSignActivityService:setSignSucceed(day)
    for _,item in pairs(self._arrItems) do
        if item.day == day then
            if day == self._curDay then
                item.status = config.WeekSignConfig.statusType.sign_in               
            else
                item.status = config.WeekSignConfig.statusType.supplement
            end
        end
    end
    if day ~= 7 then
        local pItem = self:getItemByDay(day)
        local obj = {{id = pItem.rewardId, count = pItem.count}}
        game.ui.UIMessageTipsMgr.getInstance():showTips("恭喜您获得了"..PropReader.generatePropTxtAutoWrap(obj))    
    end

    local item = self:getItemByDay(day)
    if PropReader.getTypeById(item.rewardId) == "HeadFrame" and game.service.LocalPlayerService.getInstance():getHeadFrameId() == 0x03000001 then
        local item = self:getItemByDay(7)
        game.service.HeadFrameService.getInstance():querySwitchHeadFrame(item.rewardId)
    end
end

return WeekSignActivityService