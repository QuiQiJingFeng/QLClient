local ns = namespace("net");

----------------------------------------------
-- 用于处理发送到Business的请求
----------------------------------------------
local NetworkRequest = class("NetworkRequest", require("app.net.Request"))
ns.NetworkRequest = NetworkRequest

-- @param protoClassCreator
-- @param serverId: number
function NetworkRequest:ctor(protoClassCreator, serverId)
    self.super.ctor(self);

	self._waitForResponse = true;
    self._protocol = protoClassCreator.new(serverId, self:getId());
    self._extraData = nil
end
   
-- 是否需要等待对应的Response返回，当HasResponse为true时有效
function NetworkRequest:getWaitForResponse() 
    return self._waitForResponse
end

function NetworkRequest:setWaitForResponse(value) 
    self._waitForResponse = value
    return self
end
 
-- @return protocol class
function NetworkRequest:getProtocol()
    return self._protocol;
end

-- @return number
function NetworkRequest:getTypeId()
    return self._protocol:getOpCode(); 
end

--[[0
    便捷的设置缓冲内容
]]
function NetworkRequest:setBuffer(tbl)
    if tbl then
        local buffer = self:getProtocol():getProtocolBuf()
        for key, value in pairs(tbl) do
            buffer[key] = value
        end
    end
    return self
end

--[[0
    便捷的获得缓冲内容
]]
function NetworkRequest:getBuffer()
    return self:getProtocol():getProtocolBuf()
end

--[[0
    便捷的发送网络请求
]]
function NetworkRequest:execute()
    game.util.RequestHelper.request(self)
    return self
end

--[[0
    加入一个设置额外数据的接口（仅会存在客户端内存中）
]]
function NetworkRequest:setExtraData(data)
    self._extraData = data
    return self
end

function NetworkRequest:getExtraData(data)
    return self._extraData
end