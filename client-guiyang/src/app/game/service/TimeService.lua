local ns = namespace("game.service")
local TimeService = class("TimeService")
ns.TimeService = TimeService

local instance = nil
function TimeService:ctor()
    self._timeDiff = 0
    self._callback = {}
end

function TimeService:getInstance()
    if instance == nil then
        instance = TimeService.new()
        instance:initialize()
    end
    return instance
end

function TimeService:initialize()
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.GCTimeSynchronizationRES.OP_CODE, self, self._onTimeSynchronizationRES);
end

function TimeService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
    self._callback = {}
end

-- 更新本地时间戳保证与服务器同步
function TimeService:_setTimeDiff(timeStamp)
    self._timeDiff = timeStamp/1000 - kod.util.Time.now();
end

-- 获取当前时间(单位秒)
function TimeService:getCurrentTime()
    return kod.util.Time.now() + self._timeDiff
end

-- 获取当前时间(单位毫秒)
function TimeService:getCurrentTimeInMSeconds()
    return self:getCurrentTime() * 1000
end

-- 添加关注
function TimeService:register(callback)
    if callback == nil then
        return
    end

    for idx = 1, #self._callback do
        if self._callback[idx] == callback then
            return
        end
    end

    table.insert(self._callback, callback)
end

-- 跟服务器同步一次时间(进行要求时间准确度很高的操作时调用)
function TimeService:updateTimeFromServer(callback)
    local request = net.NetworkRequest.new(net.protocol.CGTimeSynchronizationREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:setWaitForResponse(false);
    game.util.RequestHelper.request(request)

    self:register(callback)
end

function TimeService:_onTimeSynchronizationRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_TIME_SYNCHRONIZATION_SUCCESS then
        self:_setTimeDiff(protocol.timeStamp)
    else
        UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end

    table.foreach(self._callback, function(key, val)
        val()
    end)
end

-- 获取传入的时间是当前时间的几天前
function TimeService:getDaysAgo(beforeTime)
    -- local beforeDay = os.date("%d", beforeTiem / 1000)
    -- local currentDay = os.date("%d", self:getCurrentTime())
    -- local day = tonumber(currentDay) - tonumber(beforeDay)
    -- return day > 0 and day or 0
    local day = math.floor((self:getCurrentTime() - beforeTime/1000)/(24 * 3600))
    return day > 0 and day or 0
end

-- 获取当天开始(00:00:00)时间戳(单位：秒)
function TimeService:getStartTime(dayBefore)
    local time = self:getCurrentTime()
    local days = dayBefore or 0
    time = time - days * 24 * 3600
    local now_date = os.date("*t", time)
    return os.time{year = now_date.year, month = now_date.month, day = now_date.day, hour = 0, min = 0, sec = 0}
end

-- 获取当天结束(23:59:59)时间戳(单位：秒)
function TimeService:getEndTime()
    local time = self:getCurrentTime()
    local now_date = os.date("*t", time)
    return os.time{year = now_date.year, month = now_date.month, day = now_date.day, hour = 23, min = 59, sec = 59}
end

-- 获取某一天开始(00:00:00)时间戳(单位：秒)
function TimeService:getOneDayStartTime(time)
    local now_date = os.date("*t", time)
    return os.time{year = now_date.year, month = now_date.month, day = now_date.day, hour = 0, min = 0, sec = 0}
end