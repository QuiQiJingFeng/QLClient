local super = require("app.game.service.activity.ActivityServiceBase")
---@class UFOCatcherActivityService:ActivityServiceBase
local UFOCatcherActivityService = class("UFOCatcherActivityService", super)
function UFOCatcherActivityService:initialize()
    local P = net.protocol
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(P.ACCCatchDollInfoRES.OP_CODE, self, self._onACCCatchDollInfoRES)
    requestManager:registerResponseHandler(P.ACCCatchDollRES.OP_CODE, self, self._onACCCatchDollRES)
    requestManager:registerResponseHandler(P.ACCCatchDollTaskRES.OP_CODE, self, self._onACCCatchDollTaskRES)
    requestManager:registerResponseHandler(P.ACCBuyCatchDollRES.OP_CODE, self, self._onACCBuyCatchDollRES)
    requestManager:registerResponseHandler(P.ACCCatchRecordRES.OP_CODE, self, self._onACCCatchRecordRES)
end

function UFOCatcherActivityService:dispose()
    net.RequestManager:getInstance():unregisterResponseHandler(self)
end

function UFOCatcherActivityService:getActivityServerType()
    return net.protocol.activityServerType.UFO_CATCHER
end

function UFOCatcherActivityService:getActivityType()
    return net.protocol.activityType.UFO_CATCHER
end

function UFOCatcherActivityService:openActivityMainPage()
    game.service.TDGameAnalyticsService.getInstance():onEvent("UFOCatcher_OpenActivityMainPage")
    net.NetworkRequest.new(net.protocol.CACCatchDollInfoREQ, self:getServerId()):execute()
end

---@param buffer table
function UFOCatcherActivityService:sendCACCatchDollREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACCatchDollREQ, self:getServerId()):setBuffer(buffer):execute()
end

---@param buffer table
function UFOCatcherActivityService:sendCACCatchDollTaskREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACCatchDollTaskREQ, self:getServerId()):setBuffer(buffer):execute()
end

---@param buffer table
function UFOCatcherActivityService:sendCACBuyCatchDollREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACBuyCatchDollREQ, self:getServerId()):setBuffer(buffer):execute()
end

---@param buffer table
function UFOCatcherActivityService:sendCACCatchRecordREQ(buffer)
    net.NetworkRequest.new(net.protocol.CACCatchRecordREQ, self:getServerId()):setBuffer(buffer):execute()
end

---@private
---@param response NetworkResponse
function UFOCatcherActivityService:_onACCCatchDollInfoRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIUFOCatcherMain", response:getBuffer())
    end
end

---@private
---@param response NetworkResponse
function UFOCatcherActivityService:_onACCCatchDollRES(response)
    --if response:checkIsSuccessful() then
    --    self:dispatchEvent({ name = "ACCCatchDollRES", buffer = response:getBuffer() })
    --end
    self:dispatchEvent({ name = "ACCCatchDollRES", response = response })
end

---@private
---@param response NetworkResponse
function UFOCatcherActivityService:_onACCCatchDollTaskRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIUFOCatcherChanceList", response:getBuffer())
    end
end

---@private
---@param response NetworkResponse
function UFOCatcherActivityService:_onACCBuyCatchDollRES(response)
    self:dispatchEvent({ name = "ACCBuyCatchDollRES", response = response })
end

---@private
---@param response NetworkResponse
function UFOCatcherActivityService:_onACCCatchRecordRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIUFOCatcherRecord", response:getBuffer())
    end
end

function UFOCatcherActivityService:getEntranceNodeCSBPath()
    return "csb/Activity/UFOCatcher/EntranceNode.csb"
end

return UFOCatcherActivityService