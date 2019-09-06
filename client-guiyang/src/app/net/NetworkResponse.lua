local ns = namespace("net")

----------------------------------------------
-- 用于处理发送到收到的相应消息
----------------------------------------------
---@class NetworkResponse:Response
local NetworkResponse = class("NetworkResponse", require("app.net.Response"))
ns.NetworkResponse = NetworkResponse

--@param protocol: 协议实例
function NetworkResponse:ctor(protocol)
    self.super.ctor(self);

    self._protocol = protocol;
end

---@return number
function NetworkResponse:getTypeId()
	return self._protocol:getOpCode();
end

---@return number
function NetworkResponse:getRequestId()
	return self._protocol:getCallback(); 
end

---@return protocol
function NetworkResponse:getProtocol()
	return self._protocol;
end

--[[0
    便捷的获得缓冲区内容
]]
function NetworkResponse:getBuffer()
    return self:getProtocol():getProtocolBuf()
end

-- 便捷的获得错误码
function NetworkResponse:getResultCode()
    return self:getBuffer().result or -1
end

--[[0
    便捷的去判断是否为一个成功的请求
    不是指网络传输成功，而是指请求是否合法
]]
---@return boolean
function NetworkResponse:isSuccessful()
    local protocol = self:getProtocol()
    local buffer = self:getBuffer()

    if buffer.result == nil or protocol.SUCCESS_CODE == nil then
        return false
    end

    return buffer.result == protocol.SUCCESS_CODE
end

---@return string
function NetworkResponse:getResultString()
    local code = self:getBuffer().result
    if code and code ~= "" then
        return net.ProtocolCode.code2Str(self:getBuffer().result)
    else
        return ""
    end
end

function NetworkResponse:tipResultString()
    game.ui.UIMessageTipsMgr.getInstance():showTips(self:getResultString())
end

---@return boolean
function NetworkResponse:checkIsSuccessful()
    if self:isSuccessful() then
        return true
    else
        self:tipResultString()
        return false
    end
end

return NetworkResponse