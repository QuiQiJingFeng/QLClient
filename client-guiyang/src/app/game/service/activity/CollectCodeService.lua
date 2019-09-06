local super = require("app.game.service.activity.ActivityServiceBase")
local CollectCodeService = class("CollectCodeService", super)
CollectCodeService.ActivityState = {
    none = 'none', -- 初始状态
    being = 'being', -- 集码阶段
    countdown = 'countdown', -- 倒计时阶段
    opencode = 'opencode', -- 开奖阶段
    final = 'final' -- 最终展示阶段
}

function CollectCodeService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeInfoRES.OP_CODE, self, self._onACCCollectCodeInfoRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeShareRES.OP_CODE, self, self._onACCCollectCodeShareRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeLotteryRES.OP_CODE, self, self._onACCCollectCodeLotteryRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeReceiveTaskRewardRES.OP_CODE, self, self._onACCCollectCodeReceiveTaskRewardRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeLuckyRecordRES.OP_CODE, self, self._onACCCollectCodeLuckyRecordRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeQueryCodeRES.OP_CODE, self, self._onACCCollectCodeQueryCodeRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeQueryHistoryCodeRES.OP_CODE, self, self._onACCCollectCodeQueryHistoryCodeRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeHistoryLuckyRecordRES.OP_CODE, self, self._onACCCollectCodeHistoryLuckyRecordRES)
    requestManager:registerResponseHandler(net.protocol.ACCCollectCodeReceiveLotteryRewardRES.OP_CODE, self, self._onACCCollectCodeReceiveLotteryRewardRES)

    self:resetCache()
end

function CollectCodeService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function CollectCodeService:getActivityType()
    return net.protocol.activityType.COLLECT_CODE
end

-- overwrite
function CollectCodeService:openActivityMainPage()
    self:destroyAllActivityUIWithout()
    self:sendCACCollectCodeInfoREQ()
end


function CollectCodeService:getActivityServerType()
    return net.protocol.activityServerType.COLLECT_CODE
end

function CollectCodeService:resetCache()
    -- ACCCollectCodeInfoRES 的缓存
    self._collectCodeInfo = nil
    -- ACCCollectCodeQueryCodeRES 的缓存
    self._myCodeInfo = nil
    -- ACCCollectCodeQueryHistoryCodeRES 的缓存
    self._myHistoryCodeInfo = nil
    -- 可摇奖次数
    self._lotteryTimes = 0
    -- 已拥有的本期的码的个数
    self._codeCount = 0

    -- 显示倒计时任务的计划id
    self:unscheduleToShowCountDownUI()
    self._showCountDownUIScheduleId = nil

    -- 活动状态
    self._activityState = CollectCodeService.ActivityState.none
end

-- 请求集码活动信息
function CollectCodeService:sendCACCollectCodeInfoREQ()
    self:resetCache()

    net.NetworkRequest.new(net.protocol.CACCollectCodeInfoREQ, self:getServerId()):execute()
end

-- 应答集码活动信息
function CollectCodeService:_onACCCollectCodeInfoRES(response)
    if response:checkIsSuccessful() then
        self._collectCodeInfo = response:getBuffer()
        self._lotteryTimes = self._collectCodeInfo.lotteryTimes
        self._codeCount = self._collectCodeInfo.codeCount

        -- print("开始倒计时间： " .. kod.util.Time.dateWithFormat(nil, self._collectCodeInfo.countDownTime * 0.001))
        -- print("开奖时间： " .. kod.util.Time.dateWithFormat(nil, self._collectCodeInfo.lotteryTime * 0.001))
        self:unscheduleToShowCountDownUI()

        if self:isFinalPeriod(response:getBuffer().period) then
            -- 最后一期直接去请求我的红包信息
            self._activityState = self.ActivityState.final
            self:sendCACCollectCodeQueryHistoryCodeREQ()
        else
            -- 非最后一期才处理
            -- 这里如果是待开奖阶段，要直接去显示倒计时。 若还没到倒计时时间，则显示主界面，并且开启定时任务去显示倒计时界面
            local nowMS = game.service.TimeService.getInstance():getCurrentTimeInMSeconds() -- 现在时刻
            local startCountTimeDiff = nowMS - self._collectCodeInfo.countDownTime -- 开始倒计时时刻差
            local lotteryTimeDiff = nowMS - self._collectCodeInfo.lotteryTime -- 开奖时刻差
            if lotteryTimeDiff >= 0 then
                -- 如果已经过了开奖时间
                self._activityState = self.ActivityState.opencode
                if self._myCodeInfo == nil then
                    self:sendCACCollectCodeQueryCodeREQ({ showCodeResultFlag = true })
                else
                    UIManager:getInstance():show("UICollectCodeResult")
                end
            elseif startCountTimeDiff >= 0 then
                -- 如果正处于倒计时时间
                self._activityState = self.ActivityState.countdown
                UIManager:getInstance():show("UICollectCodeCountDown")
            else
                self._activityState = self.ActivityState.being
                -- 如果处于集码时间
                UIManager:getInstance():show("UICollectCodeMain", self._collectCodeInfo)
                self:scheduleToShowCountDownUI(self._collectCodeInfo.countDownTime - nowMS)
            end
        end

    end
end

-- 开启倒计时
function CollectCodeService:scheduleToShowCountDownUI(delayTimeMS)
    self:unscheduleToShowCountDownUI()

    local ui = UIManager:getInstance():getUI("UICollectCodeMain")
    if ui and self._showCountDownUIScheduleId == nil then
        self._showCountDownUIScheduleId = scheduleOnce(function()
            self._showCountDownUIScheduleId = nil
            if UIManager:getInstance():getIsShowing("UICollectCodeMain") then
                self._activityState = self.ActivityState.countdown
                UIManager:getInstance():show("UICollectCodeCountDown")
            end
        end, delayTimeMS * 0.001, ui)
    end
end


-- 结束倒计时
function CollectCodeService:unscheduleToShowCountDownUI()
    local ui = UIManager:getInstance():getUI("UICollectCodeMain")
    if self._showCountDownUIScheduleId ~= nil and ui ~= nil then
        unscheduleOnce(self._showCountDownUIScheduleId, ui)
    end
    self._showCountDownUIScheduleId = nil
end

-- 请求分享
function CollectCodeService:sendCACCollectCodeShareREQ()
    net.NetworkRequest.new(net.protocol.CACCollectCodeShareREQ, self:getServerId()):execute()
end

-- 应答分享
function CollectCodeService:_onACCCollectCodeShareRES(response)
    if response:checkIsSuccessful() then
    end
end

-- 请求抽取幸运码
function CollectCodeService:sendCACCollectCodeLotteryREQ()
    net.NetworkRequest.new(net.protocol.CACCollectCodeLotteryREQ, self:getServerId()):execute()
end

-- 应答抽取幸运码
function CollectCodeService:_onACCCollectCodeLotteryRES(response)
    if response:checkIsSuccessful() then
        if self._lotteryTimes then
            self._lotteryTimes = self._lotteryTimes - 1
        end
        if self._codeCount then
            self._codeCount = self._codeCount + 1
        end
    end
    self:dispatchEvent({ name = "EVENT_COLLECT_CODE_GET_CODE_RES", data = response })
end

-- 领取奖励请求
function CollectCodeService:sendCACCollectCodeReceiveTaskRewardREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACCollectCodeReceiveTaskRewardREQ, self:getServerId()):setBuffer(buffer):execute()
end

-- 领取奖励请求
function CollectCodeService:_onACCCollectCodeReceiveTaskRewardRES(response)
    if response:checkIsSuccessful() then
        local buffer = response:getBuffer()
        local rewardString = PropReader.getNameById(buffer.reward.itemId) .. " x" .. buffer.reward.count
        -- todo 领取奖励
    end
end

-- 请求当前期我的查询幸运码
function CollectCodeService:sendCACCollectCodeQueryCodeREQ(extraData)
    net.NetworkRequest.new(net.protocol.CACCollectCodeQueryCodeREQ, self:getServerId()):setExtraData(extraData):execute()
end

-- 应答当前期我的查询幸运码
function CollectCodeService:_onACCCollectCodeQueryCodeRES(response)
    if response:checkIsSuccessful() then
        local buffer = response:getBuffer()
        self._myCodeInfo = buffer
        self._codeCount = #buffer.codes

        local extraData = response:getRequest():getExtraData()
        if extraData and extraData.showCodeResultFlag == true then
            -- 如果是倒计时时没有幸运码数据的请求的话
            UIManager:getInstance():show("UICollectCodeResult")
        else
            --[[0
                状态有：
                    1、已开奖后查询我的幸运码
                    2、未开奖查询我的幸运码
            ]]
            if self._activityState == CollectCodeService.ActivityState.opencode then
                UIManager:getInstance():show("UICollectCodeMyCode_History", "current", buffer)
            elseif self._activityState == CollectCodeService.ActivityState.being then
                if #buffer.codes > 0 then
                    UIManager:getInstance():show("UICollectCodeMyCode_Being", buffer.codes)
                else
                    UIManager:getInstance():show("UICollectCodeMyCode_NoCode", buffer)
                end
            elseif self._activityState == CollectCodeService.ActivityState.countdown then
                UIManager:getInstance():show("UICollectCodeMyCode_Being", buffer.codes)
            end
        end
    end
end

-- 查询本期中奖名单
function CollectCodeService:sendCACCollectCodeLuckyRecordREQ()
    net.NetworkRequest.new(net.protocol.CACCollectCodeLuckyRecordREQ, self:getServerId()):execute()
end

-- 应答本期中奖名单
function CollectCodeService:_onACCCollectCodeLuckyRecordRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UICollectCodeRecordListDetail", response:getBuffer().record.playerInfo)
    end
end

-- 请求查询我的历史幸运码
function CollectCodeService:sendCACCollectCodeQueryHistoryCodeREQ(extraData)
    if self._myHistoryCodeInfo then
        if #self._myHistoryCodeInfo.record == 0 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("您暂未获得红包")
        else
            UIManager:getInstance():show("UICollectCodeMyCode_History", "history", self._myHistoryCodeInfo)
        end
    else
        net.NetworkRequest.new(net.protocol.CACCollectCodeQueryHistoryCodeREQ, self:getServerId()):setBuffer({
        }):setExtraData(extraData):execute()
    end
end

-- 应答查询我的历史幸运码
function CollectCodeService:_onACCCollectCodeQueryHistoryCodeRES(response)
    if response:checkIsSuccessful() then
        self._myHistoryCodeInfo = response:getBuffer()
        local extraData = response:getRequest():getExtraData()
        if extraData and extraData.justQuery then
            self:dispatchEvent({ name = "EVENT_COLLECT_CODE_HISTORY_CODE_RES" })
            return
        end
        -- 这里的本期幸运码通过此 service 额外去拿
        if #self._myHistoryCodeInfo.record == 0 then
            if self:isFinalPeriod(self._collectCodeInfo.period) then
                game.ui.UIMessageTipsMgr.getInstance():showTips("活动已结束，敬请期待下次活动")
            else
                game.ui.UIMessageTipsMgr.getInstance():showTips("您暂未获得红包")
            end
        else
            UIManager:getInstance():show("UICollectCodeMyCode_History", "history", self._myHistoryCodeInfo)
        end
    end
end

-- 请求历史开奖纪录 往期瓜分
function CollectCodeService:sendCACCollectCodeHistoryLuckyRecordREQ()
    net.NetworkRequest.new(net.protocol.CACCollectCodeHistoryLuckyRecordREQ, self:getServerId()):setBuffer({

    }):execute()
end

-- 回复历史开奖纪录 往期瓜分
function CollectCodeService:_onACCCollectCodeHistoryLuckyRecordRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UICollectCodeRecordList", response:getBuffer())
    end
end

-- 请求领取摇奖码奖励
function CollectCodeService:sendCACCollectCodeReceiveLotteryRewardREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACCollectCodeReceiveLotteryRewardREQ, self:getServerId()):setBuffer(buffer):execute()
end

-- 应答领取摇奖码奖励
function CollectCodeService:_onACCCollectCodeReceiveLotteryRewardRES(response)
    if response:checkIsSuccessful() then
        -- 如果已经关闭了，则不提示信息框了，只弹一个tip
        local isTip = false
        local key = "TipMessage_UICollectCodeMessageBox"
        local service = game.service.ActivityService.getInstance()
        local data = service.activeCache
        if data then
            if data[key] == nil or data[key] == false then
                UIManager:getInstance():show("UICollectCodeMessageBox")
                isTip = true
            end
        end

        if not isTip then
            game.ui.UIMessageTipsMgr.getInstance():showTips("红包已领取")
        end
    end
end


---
--- 一些工具方法  ** 若当前正在两期之间的休息期内， 返回上一期的 **
---
function CollectCodeService:getCollectCodeInfo()
    return self._collectCodeInfo
end

function CollectCodeService:getMyCodeInfo()
    return self._myCodeInfo
end

function CollectCodeService:getLotteryTimes()
    return self._lotteryTimes
end

function CollectCodeService:getCodeCount()
    return self._codeCount
end

function CollectCodeService:getMyHistoryCodeInfo()
    return self._myHistoryCodeInfo
end

function CollectCodeService:getCurrentOpenCodeTime(isFormat)
    if isFormat then
        return kod.util.Time.dateWithFormat(nil, self._collectCodeInfo.lotteryTime * 0.001)
    else
        return self._collectCodeInfo.lotteryTime
    end
end

function CollectCodeService:collectCodeShare(callback)
    local data = {
        enter = share.constants.ENTER.COLLECT_CODE
    }
    share.ShareWTF.getInstance():share(data.enter, { data, data, data }, function()
        if callback then
            callback()
        end
    end)
end

function CollectCodeService:convertToCodeArray(codes)
    local ret = {}
    for i = 1, string.utf8len(codes) do
        local ch = string.utf8sub(codes, i, 1)
        table.insert(ret, ch)
    end
    return ret
end

-- 当集码倒计时结束后
function CollectCodeService:onCountDownOver()
    self._activityState = self.ActivityState.opencode
    -- 开奖后需要重新请求下数据
    self:sendCACCollectCodeQueryCodeREQ({ showCodeResultFlag = true })
end

function CollectCodeService:getActivityState()
    return self._activityState
end

function CollectCodeService:destroyAllActivityUIWithout(...)
    local withoutList = { ... }
    local uiList = {
        "UICollectCodeMain",
        "UICollectCodeCountDown",
        "UICollectCodeResult",
        "UICollectCodeMyCode_History",
        "UICollectCodeMyCode_Being",
        "UICollectCodeMyCode_NoCode",
        "UICollectCodeRecordListDetail",
        "UICollectCodeRecordList",
        "UICollectCodeGetCodeResult",
        "UICollectCodeGetCodeTips",
        "UICollectCodeHelp",
        "UICollectCodeGuide",
        "UICollectCodeMessageBox",
    }
    for _, name in ipairs(uiList) do
        if table.indexof(withoutList or {}, name) == false then
            UIManager:getInstance():destroy(name)
        end
    end
end

--[[0
    是否为最后一期
活动结束之后 添加一个展示阶段：
方案：
    如果活动预计是开3期，每期持续1天，想在第3期后预留1天给玩家显示红包去领取。
实施:
    活动实际开4期，客户端代码中知道最后一期的期数，在最后一期时，只显示我的红包界面，不让玩家参与抽奖

@return true：是最后一期，并且处理了  false：不是最后一期，交给外部处理
]]

-- 从0开始
local FinalPeriodConfig = {
    [10002] = 5 - 1, -- 贵阳
    [20001] = 8 - 1, -- 潮汕
    [30001] = 5 - 1, -- 内蒙
}

function CollectCodeService:isFinalPeriod(period)
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local finalPeriod = FinalPeriodConfig[areaId] or 0xFFFF
    return period >= finalPeriod
end

return CollectCodeService