local ns = namespace("net.protocol")
local ProtobufLib = require("protobuf")

----------------------------
-- 网络链接相关响应的监听器，用于处理各种异步网络操作    
----------------------------
local ProtocolBase = class("ProtocolBase")

-- @param opCode: number
-- @param serverId: number
-- @param callback: number
function ProtocolBase:ctor(opCode, serverId, callback)
    -- // 用于构造Packet的buffer
    -- self.static decodeBuffer: laya.utils.Byte = new laya.utils.Byte()

    -- number : 操作码, 对应网络协议Id
    self._opCode = opCode

    -- number : 协议目标服务器Id 
    self._serverId = serverId

    -- number : 回调值, 对应的返回协议会带有这个值
    self._callback = callback

    -- ProtoBuff协议实例
    self._protocolBuf = {}
end

-- @return number
function ProtocolBase:getOpCode()
    return self._opCode
end

-- @return number
function ProtocolBase:getServerId()
    return self._serverId
end

-- @return number
function ProtocolBase:getCallback()
    return self._callback
end

-- @return xxxx
function ProtocolBase:getProtocolBuf()
    return self._protocolBuf
end

----------------------------------
-- C2S消息体格式
-- serverId : 4 bytes
-- opCode : 4 bytes
-- callback : 4 bytes
-- data : 任意长度 
----------------------------------

-- 将协议转换为字节流
-- @return: ByteBuffer
function ProtocolBase:toBuffer()
    local buffer = ByteBuffer.new(ByteBuffer.ENDIAN_BIG)
    buffer:writeint(self._serverId)
    buffer:writeint(self._opCode)
    buffer:writeint(self._callback)

    -- 序列化pb	
    local pbClassName = net.core.ProtocolManager.getInstance():getProtocolBufClassName(self._opCode)
    if Macro.assetTrue(pbClassName == nil, string.format("Invalid pb code:0x%x", self._opCode)) then
        return
    end

    Logger.debug("Protocol.toBuffer,%d,0x%x,%d", self._serverId, self._opCode, self._callback)
    Logger.dump(self._protocolBuf, "self._protocolBuf =>", 10)
    Macro.assetFalse(ProtobufLib.check(pbClassName), "Missing pbClass," .. pbClassName)
    local message = ProtobufLib.encode(pbClassName, self._protocolBuf)
    buffer:writestring(message)
    return buffer
end

----------------------------------
-- S2C消息体格式
-- opCode : 4 bytes
-- callback : 4 bytes
-- data : 任意长度 
----------------------------------

-- 从字节流生成协议
-- @param data: any
-- @return ProtocolBase
function ProtocolBase.fromBuffer(buffer)
    -- 包长检测 可能为心跳包
    if buffer:available() < 4 + 4 then
        return nil
    end

    -- 获取pb包体头	
    local opCode = buffer:readuint()
    local callback = buffer:readint()

    -- 获得protobuf数据
    local message = buffer:readstring(buffer:available())

    -- 解析pb
    local pbClassName = net.core.ProtocolManager.getInstance():getProtocolBufClassName(opCode)
    if Macro.assetTrue(pbClassName == nil, string.format("Invalid pb code:0x%x", opCode)) then
        return nil
    end

    Macro.assetFalse(ProtobufLib.check(pbClassName), "Missing pbClass," .. pbClassName)
    local pb = ProtobufLib.decode_all(pbClassName, message)
    if Macro.assetTrue(pb == false, string.format("Parse pb failed:%s", pbClassName)) then
        return nil
    end

    -- 构造
    local protocolClass = net.core.ProtocolManager.getInstance():getProtocolClass(opCode)
    if Macro.assetTrue(protocolClass == nil, string.format("Invalid pb code:0x%x", opCode)) then
        return nil
    end

    local protocol = protocolClass.new(opCode, callback)
    protocol._protocolBuf = pb

    Logger.debug("Protocol.fromBuffer,0x%x,%d", opCode, callback)
    -- Logger.dump(protocol._protocolBuf, "protocol._protocolBuf =>", 10)
    return protocol
end

---添加一个便捷的生命网络消息类的入口
---@param CLZ_CODE_PREFIX string 消息pb包名前缀
function ProtocolBase.getBuildMessageFunction(CLZ_CODE_PREFIX)
    ---@param msgName string 消息名， 在pb包名空间下的名称
    ---@param OP_CODE number 消息码
    ---@param SUCCESS_CODE number 用于Response类型的消息表明唯一成功码的， 标记了就可以在 NetWorkResponse 类中使用 isSuccessful，对于Request类可以忽略他
    return function(msgName, OP_CODE, SUCCESS_CODE)
        local msg = class(msgName, ProtocolBase)
        ns[msgName] = msg
        msg.CLZ_CODE = CLZ_CODE_PREFIX .. "." .. msgName
        msg.OP_CODE = OP_CODE
        msg.SUCCESS_CODE = SUCCESS_CODE
        function msg:ctor(serverId, callback)
            self.super.ctor(self, msg.OP_CODE, serverId, callback);
        end
        return msg
    end
end

return ProtocolBase