--[[
    网络模拟器
    支持消息的收费
    协议的encode，decode
]]
local Simulator = function (connection)
    local _curbuffer = nil  -- 当前解析出的buffer
    local _curproto = nil   -- 当前解析出的protocol
    -- 假的socket，只需要实现send就可以了，把send的buffer记录下来
    local fake_socket = {
        send = function ( buffer )
            _curbuffer = buffer
        end
    }
    -- 假的协议包handler，把handle的包记录下来
    local fake_protocolPacketHandler = {
        handlePacket = function ( protocol )
            _curproto = protocol
        end
    }

    -- 请求
    local _request = function ( req )
        local real_socket = connection._socket -- 记录真的socket，一会要回复回去，否则客户端就无法发消息了
        connection._socket = fake_socket -- 设置成假的socket，否则消息会被发出去
        connection:sendRequest(req) -- 这里 除了有个假的socket，导致消息发不出去，其他逻辑走的和真实情况一样
        connection._socket = real_socket -- 消息发完了，该记录的记录了，恢复真socket
        local buffer = _curbuffer
        _curbuffer = nil -- 清除记录
        return buffer, req:getId() -- 返回“发出”的buffer，以及id(后端的callback，用于查询req)
    end

    -- response一个buffer
    local _responsebuffer = function ( buffer )
        -- 因为requestHandler里记录了request的id，所以对不上的消息会被丢弃，用这个方法前，需要手动先调request
        connection.onReceiveProtocol(buffer) -- 剩下的交给connect，就能反馈到具体的responseHandler里了
    end

    -- response一个protocol
    local _responseprotocol = function ( protocol )
        -- 因为会有协议加密，如果前后的加密解密算法相同，可以使用_responsebuffer
        -- 但是如果不同，就只能直接去抛protocol了
        connection._protocolPacketHandler(protocol)
    end

    -- encode protocol->buffer
    local _encode = function ( protocol )
        local real_socket = connection._socket -- 记录真的socket，一会要回复回去，否则客户端就无法发消息了
        connection._socket = fake_socket -- 设置成假的socket，否则消息会被发出去
        connection:sendProtocol(protocol) -- 这里 除了有个假的socket，导致消息发不出去，其他逻辑走的和真实情况一样
        connection._socket = real_socket -- 消息发完了，该记录的记录了，恢复真socket
        local buffer = _curbuffer
        _curbuffer = nil -- 清除记录
        return buffer -- 返回生成的buffer
    end

    -- decode buffer->protocol
    local _decode = function ( buffer )
        local real_protocolPacketHandler = connection._protocolPacketHandler -- 记录真的_protocolPacketHandler
        connection._protocolPacketHandler = fake_protocolPacketHandler -- 设置假的_protocolPacketHandler，防止消息被onResponse
        connection:onReceiveProtocol(buffer) -- 解析buffer，生成protocol
        connection._protocolPacketHandler = real_protocolPacketHandler -- 恢复
        local protocol = _curproto
        _curproto = nil -- 清除记录
        return protocol -- 返回生成的protocol
    end

    return {
        ["request"] = function ( req, sendtoserver )
            if sendtoserver then
                game.service.ConnectionService.getInstance():sendRequest(req);
            else
                local buffer, callbackid
                buffer, callbackid = _request(req)
                return callbackid
            end
        end,
        ["response"] = function ( rsp )
            local buffer = _encode(rsp:getProtocol())
            _responsebuffer(buffer)
        end,
        ['encode'] = function ( protocol )
            return _encode(protocol)
        end,
        ['decode'] = function ( buffer )
            return _decode(buffer)
        end
    }
end

_G.tnetsimulator = Simulator