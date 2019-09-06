--[[
房间限免活动
--]]
local ns          = namespace("game.service")
local TimeService = require("app.game.service.TimeService")
local room        = require("app.game.ui.RoomSettingHelper")
local activity    = {}

activity.FreePlayData = {
    activityId = -1,
    startTime  = -1,
    endTime    = -1,
    roomType   = -1,
    name       = "",
}

activity.FreePlayData.new = function (activityId, startTime, endTime, roomType, name)
    local data                = {}
    data.activityId           = activityId
    data.startTime            = startTime
    data.endTime              = endTime
    data.roomType             = roomType
    data.name                 = name
    return data
end

-- 这里要注意，服务器转过来的时候，是毫秒为单位的，客户端是秒为单位
activity.FreePlayData.clone = function (target)
    local data                  = {}
    data.activityId             = target.activityId
    data.startTime              = target.startTime/1000
    data.endTime                = target.endTime/1000
    data.roomType               = target.roomType
    data.name                   = target.name
    return data
end

local FreePlayService    = class("FreePlayService")
activity.FreePlayService = FreePlayService
ns.FreePlayService       = FreePlayService

local instance = nil
function FreePlayService:ctor()
    self:clear()
end

function FreePlayService:clear()
    self.startTimer  = -1
    self.endTimer    = -1
    self.waitingData = {}
    self.activeData  = {}
end

function FreePlayService:getInstance()
    if game.service.LocalPlayerService:getInstance() ~= nil then
        return game.service.LocalPlayerService:getInstance():getFreePlayService()
    end
    return nil
end

function FreePlayService:getActiveData()
    return self.activeData
end

function FreePlayService:initialize()
    self.endTimer        = kod.util.Time.now();
    self.startTimer      = kod.util.Time.now();
    -- 监听网络操作
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.GCLimitedCostlessActivityRES.OP_CODE, self, self._onLimitedCostlessActivityRES);
    requestManager:registerResponseHandler(net.protocol.GCNewLimitedCostlessActivitySYN.OP_CODE, self, self._onNewLimitedCostlessActivitySYN);
end

function FreePlayService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
end

function FreePlayService:clear()
    self.startTimer  = -1
    self.endTimer    = -1
    self.waitingData = {}
    self.activeData  = {}
    if self._endTimerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._endTimerScheduler)
        self._endTimerScheduler = nil
    end
    if self._startTimerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._startTimerScheduler)
        self._startTimerScheduler = nil
    end
end

function FreePlayService:_onLimitedCostlessActivityRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_LIMITED_COSTLESS_ACTIVITY_SUCCESS then
        self:setData(protocol.activityList)
    else
        UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

-- 收到服务器新的活动推送开始请求活动内容
function FreePlayService:_onNewLimitedCostlessActivitySYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self:setData(protocol.activityList)
end

function FreePlayService:_requestLimitedCostlessActivity()
    local request = net.NetworkRequest.new(net.protocol.CGLimitedCostlessActivityREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    -- request:getProtocol():setData(gameCountType, gameCount, gameRules, freeActivityId)
    game.util.RequestHelper.request(request)
end

-- 向服务器请求活动信息
function FreePlayService:queryActivity(updateTime)
    if updateTime then
        game.service.TimeService:getInstance():updateTimeFromServer(handler(self, self._requestLimitedCostlessActivity))
    else
        self:_requestLimitedCostlessActivity()
    end
end

function FreePlayService:setData(activityList)
    self:clear()
    table.foreach(activityList, function (key, data)
        if data.endTime <= game.service.TimeService:getInstance():getCurrentTime() then
            -- 忽略已过期的的活动
            return
        end
        if Macro.assetTrue(room.RoomSettingHelper.convert2OptionType(data.roomType) == nil, "限免活动房间类型错误 :"..data.roomType) then
            -- 忽略房间类型错误的活动
            return
        end

        local freeData = activity.FreePlayData.clone(data)
        if freeData.startTime < game.service.TimeService:getInstance():getCurrentTime() then
            -- 活动已经开始
            table.insert(self.activeData, freeData)
        else
            -- 等待活动开始
            table.insert(self.waitingData, freeData)
        end
    end )

    table.sort(self.activeData, function (a, b)
        return a.startTime < b.startTime
    end )
    table.sort(self.waitingData, function (a, b)
        return a.startTime < b.startTime
    end )

    -- 根据情况启动计时器
    if #self.waitingData > 0 then
        local delayTime           = self.waitingData[1].startTime-game.service.TimeService:getInstance():getCurrentTime()
        self._startTimerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._startNextWaitData), delayTime, false)
    end

    if #self.activeData > 0 then
        local delayTime         = self.activeData[1].endTime-game.service.TimeService:getInstance():getCurrentTime()
        self._endTimerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._endNextActData), delayTime, false)
    end

    self:refreshMainFreeFlag();
    self:refreshSubFreeFlag();
end

function FreePlayService:_startNextWaitData()
    if self._startTimerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._startTimerScheduler)
        self._startTimerScheduler = nil
    end
    while #self.waitingData > 0 do
        local delayTime = self.waitingData[1].startTime-game.service.TimeService:getInstance():getCurrentTime()
        -- 当前活动开启了
        if delayTime <= 0 then
            table.insert(self.activeData, self.waitingData[1])
            table.remove(self.waitingData, 1)
        else
            self._startTimerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._startNextWaitData), delayTime, false)
            break
        end
    end
    self:refreshMainFreeFlag();
    self:refreshSubFreeFlag();
    table.sort(self.activeData, function (a, b)
        return a.startTime < b.startTime
    end )

    -- 清空上次的定时器
    if self._endTimerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._endTimerScheduler)
        self._endTimerScheduler = nil
    end

    if #self.activeData > 0 then
        local delayTime         = self.activeData[1].endTime-game.service.TimeService:getInstance():getCurrentTime()
        self._endTimerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._endNextActData), delayTime, false)
    end
end

function FreePlayService:_endNextActData()
    if self._endTimerScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._endTimerScheduler)
        self._endTimerScheduler = nil
    end
    while #self.activeData > 0 do
        local delayTime = self.activeData[1].endTime-game.service.TimeService:getInstance():getCurrentTime()
        if delayTime <= 0 then
            -- 当前活动结束
            table.remove(self.activeData, 1)
        else
            -- 开启下次活动
            self._endTimerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._endNextActData), delayTime, false)
            break
        end
    end

    self:refreshMainFreeFlag();
    self:refreshSubFreeFlag();
end

-- 刷新相关界面
function FreePlayService:refreshMainFreeFlag()
    local main = UIManager:getInstance():getUI("UIMain")
    if main ~= nil then
        main:showFreeFlag()
    end
end

-- 刷新相关界面
function FreePlayService:refreshSubFreeFlag()
    local createRoom = UIManager:getInstance():getUI("UICreateRoom")
    if createRoom ~= nil then
        createRoom:refreshRoomSettingForFree()
    end
end

-- 返回限免活动id
function FreePlayService:getActivityId(freeRoomType)
    local activityId = -1
    for i = 1, #self.activeData do
        if self.activeData[i].roomType == freeRoomType then
            activityId = self.activeData[i].activityId
            break
        end
    end
    return activityId
end