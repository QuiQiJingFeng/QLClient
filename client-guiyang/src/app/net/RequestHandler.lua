local timeout_tip_flag = device.platform == 'windows'
local ns = namespace("net")

local RequestHandler = class("RequestHandler")
ns.RequestHandler = RequestHandler

----------------------------
-- 客户端协议处理层
-- RequestManager用于Request和Response的处理
-- 1. 匹配对应的request和response
-- 2. 检查response超时
-- 3. 网络等待通知
----------------------------
function RequestHandler:ctor(timeoutCallback)
    self._waitingRequests = {}      -- 等待响应的Request队列
    self._responseTimeoutTime = 5;  -- 响应超时时间
    self._updateTask = nil;
    self._timeoutCallback = timeoutCallback;


    -- 开始更新
    self:_startCheckTimeout();
end

-- 销毁实例
function RequestHandler:dispose()
    self:reset();

    -- 终止更新
    self:_endCheckTimeout();
end

-- 忽略当前所有缓存的Requesty以及Response
function RequestHandler:reset()
    for _, req in pairs(self._waitingRequests) do
        if req:getHasResponse() and req:getWaitForResponse() then
            dispatchGlobalEvent("EVENT_BUSY_RELEASE")
        end
    end
    self._waitingRequests = {};
end

function RequestHandler:onRequest(req)
    if req:getHasResponse() then
        -- 设置超时时间
        req:setTimeoutTime(kod.util.Time.now() + self._responseTimeoutTime);

        -- 添加进等待队列
        Macro.assetFalse(self._waitingRequests[req:getId()] == nil)
        self._waitingRequests[req:getId()] = req;

        -- 如果需要等待回复, 增加等待计数
        if req:getWaitForResponse() then
            dispatchGlobalEvent("EVENT_BUSY_RETAIN")
        end
    end
end

-- 收到Response
-- @param response: Response
-- @return boolean
function RequestHandler:onResponse(response)
    -- Logger.debug("Response %s", response:toString());

    -- 找到对应的request
    local callback = response:getRequestId()
    local peerRequest = self._waitingRequests[callback]
    if peerRequest then
        -- 如果在本地能够查找到对应的请求
        response:setRequest(peerRequest)
        if peerRequest:getHasResponse() and peerRequest:getWaitForResponse() then
            dispatchGlobalEvent("EVENT_BUSY_RELEASE")
        end
    elseif callback == 0 then
        -- 这个一个 SYN 消息， callback 是默认值， 不用管他
    elseif callback ~= 0 then
        --[[
            意味着收到了一个在本地找不到请求的响应，有以下情况会走到这里：
            1、在没有发送REQ的时候，收到了一个RES
            2、连续收到了两个相同callback值的response，后一个response会出现这个问题（这个是服务器问题）
            3、发送给服务器的callback本来就出现了问题（这可能是callback在传递累加的时候出现了问题）
            4、客户端已经清空了所有的请求后，收到了某个被清空的请求的回复（这个一般出现在服务器大延迟，客户端尝试清空缓存重新连接导致）
        ]]
        local msg = string.format('maybe received sample callback response twice ! response opCode is 0x%x, callback is %s', response:getTypeId(), callback)
        Macro.assertFalse(false, msg)
        return
    end

    -- 执行Response
    local handlers = net.RequestManager.getInstance():getResponseHandler(response:getTypeId());
    if handlers ~= nil then
        for _, handler in ipairs(handlers) do
            handler.func(handler.responder, response);
        end
    end

    -- Mark request responded flag.
    if peerRequest ~= nil then
        self._waitingRequests[peerRequest:getId()] = nil;
    end

    return true;
end

function RequestHandler:_startCheckTimeout()
    self:_endCheckTimeout();

    self._updateTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()

        -- 检测协议超时
        if self:_checkTimeout() then
            -- 等待响应response超时, 网络出了问题，直接断线重新登录
            if self._timeoutCallback ~= nil then
                self._timeoutCallback()
            end
            return ;
        end
    end, 0, false)
end

function RequestHandler:_endCheckTimeout()
    if self._updateTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTask);
        self._updateTask = nil;
    end
end

-- @param boolean
function RequestHandler:_checkTimeout()
    for _, req in pairs(self._waitingRequests) do
        if req:getTimeoutTime() ~= nil and kod.util.Time.now() > req:getTimeoutTime() then
            local tip = string.format("[Request timeout], request opcode is 0x%x", req:getTypeId())
            Logger.error(tip)
            if timeout_tip_flag then
                game.ui.UIMessageBoxMgr.getInstance():show(tip, {"ok"})
            end
            return true;
        end
    end

    return false;
end

return RequestHandler;