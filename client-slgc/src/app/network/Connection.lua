local luasocket = require "socket"
local crypt = require "crypt"
local bit = require "bit"
local protobuf = cocos.pb()
local Connection = class("Connection")
local NETSTATE = {
	--未连接状态
	UN_CONNECTED = 0,
	CONNECTING = 1,
    CONNECTED = 2,
    VERIFYPASS = 3, --校验通过
}

--连接超时时间
local CONNECTING_TIMEOUT_TIME = 0.2
--协议超时时间
local PROTOCOL_TIMEOUT_TIME = 5

local DISCONNECT_REASON = {
    UNKOWN = 0,   --未知原因
    CONNECT_TIME_OUT = 1,   --连接超时
    PROTO_TIMEOUT = 2,          --协议超时
    HEART_BEAT_TIME_OUT = 3,    --心跳超时
}
Connection.DISCONNECT_REASON = DISCONNECT_REASON
-- 数据包头长度
local HEADER_SIZE = 2

function Connection:ctor()
    local pbPath = cc.FileUtils:getInstance():fullPathForFilename("pb/protocol.pb")
    assert(protobuf.loadfile(pbPath))
    self._sessionId = 0
    self._sendMap = {}
end

function Connection:isIPV6(host)
    -- 使用socket.dns判断服务器地址是否为IPv6地址
    for k,v in pairs(luasocket.dns.getaddrinfo(host) or {}) do
        if v.family == "inet6" then
            return true  
        end
    end

    return false
end
--47.52.99.120:8888
function Connection:connect(adress)
    Logger.debug("Connection:connect")
    local iter = string.gmatch(adress,"(.+):(.+)")
    local host,port = iter()
    self._host = host
    self._port = tonumber(port)
    if self:isIPV6(self._host) then
    	self._socket = luasocket.tcp6()
    else
    	self._socket = luasocket.tcp()
    end
    self._receiveData = ""
    -- 由于是阻塞socket，所以将超时时间设为0防止阻塞
    -- 也因此不再根据connect的返回值判断是否连接成功
    self._socket:settimeout(0)
    self._socket:connect(self._host,self._port)
    self:updateState(NETSTATE.CONNECTING)
end

--主动断开连接
function Connection:disconnect(reason)
    if self._socket then
        self._socket:close()
        self._socket = nil
        self:updateState(NETSTATE.UN_CONNECTED,reason)
        game.EventCenter:dispatch("EVENT_CONNECTION_LOST")
    end
end

function Connection:updateState(state,reason)
    if self._netState == state then
        return
    end
    self._netState = state
    print("netState = ",state," reason = ",reason)
    if NETSTATE.CONNECTING == state then
        self._connectTime = luasocket.gettime()
        self:openSchedule()
    elseif NETSTATE.UN_CONNECTED == state then
        self:closeSchedule()
        game.EventCenter:dispatch("EVENT_CONNECTION_LOST")
    end

    if NETSTATE.VERIFYPASS == state then
        game.EventCenter:dispatch("EVENT_CONNECTION_VERIFYPASS")
    end
end

function Connection:equalState(state)
    return self._netState == state
end

function Connection:openSchedule()
    local scheduler = cc.Director:getInstance():getScheduler()
    self._scheduleId = scheduler:scheduleScriptFunc(function(dt)
        self:onUpdate(dt)
    end, 0, false)
end

function Connection:closeSchedule()
    if self._scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleId)
        self._scheduleId = nil
    end
end

function Connection:_checkTimeout()
    for _, content in pairs(self._sendMap) do
        if luasocket.gettime() > content.timeOutPoint then
            local requestName,requestMessage
            for k,v in pairs(content) do
                if k ~= "session_id" then
                    requestName = k
                    requestMessage = v
                end
            end

            local tip = string.format("[Request timeout], request name is %s", requestName)
            Logger.error(tip)
            game.UITipManager:getInstance():show(tip)
            return true
        end
    end

    return false
end

function Connection:onUpdate()
    --检测连接超时
    if self:equalState(NETSTATE.CONNECTING) and luasocket.gettime() - self._connectTime > CONNECTING_TIMEOUT_TIME then
        self:disconnect(DISCONNECT_REASON.CONNECT_TIME_OUT)
        return
    end
    
    if self:_checkTimeout() then
        self:disconnect(DISCONNECT_REASON.PROTO_TIMEOUT)
       return
    end

    local arr = {self._socket}
    local recvt, sendt, status = luasocket.select(arr, self:equalState(NETSTATE.CONNECTING) and arr or nil, 0)
    if self:equalState(NETSTATE.CONNECTING) then
        if sendt and #sendt >= 1 and sendt[1] == self._socket then
            self:updateState(NETSTATE.CONNECTED)
        end
    else
        if recvt and #recvt >= 1 and recvt[1] == self._socket then
            local pattern, status, partial = self._socket:receive("*a")
            if status == 'closed' then
                -- socket已经断开
                self:disconnect(DISCONNECT_REASON.UNKOWN)
                return
            end
            -- 拼接数据
            if pattern then
                self._receiveData = self._receiveData .. pattern
            elseif partial then
                self._receiveData = self._receiveData .. partial
            end
            local data = self:unpackData()
            if data then
                local content, err = protobuf.decode("S2C", data)
                if err then
                    return Logger.error("encode Protobuf Error: %s", err)
                end
                local sessionId = nil
                local responseName,responseMessage
                for k,v in pairs(content) do
                    if k == "session_id" then
                        sessionId = v
                    else
                        responseName = k
                        responseMessage = v
                    end
                end
                if responseName == "handshake" then
                    self:processHandShake(responseMessage)
                    game.EventCenter:dispatch("EVENT_CONNECTION_HANDLED")
                elseif responseName == "heartbeat" then 
                    game.EventCenter:dispatch("EVENT_CONNECTION_HEART")
                elseif self._sendMap[sessionId] then
                    game.EventCenter:dispatch(responseName,responseMessage,sessionId)
                    self._sendMap[sessionId] = nil
                else
                    --推送
                    game.EventCenter:dispatch(responseName,responseMessage)
                end
            end
        end
    end
end

function Connection:processHandShake(responseMessage)
    self._challenge = crypt.base64decode(responseMessage["v1"])
    self._clientkey = crypt.randomkey()
    self._serverkey = crypt.base64decode(responseMessage["v2"])
    local secret = crypt.dhsecret(self._serverkey, self._clientkey)
    local reqMessage = {}
    reqMessage["v1"] = crypt.base64encode(crypt.dhexchange(self._clientkey))
    reqMessage["v2"] = crypt.base64encode(crypt.hmac64(self._challenge, secret))
    --发送回应包
    self:send("handshake",reqMessage,true)
    self._secret = secret
    self:updateState(NETSTATE.VERIFYPASS)
end

function Connection:unpackData()
    -- 按照大段编码规则分割数据
    local receive_size = #self._receiveData
    if receive_size >= HEADER_SIZE then
        local data_size = self._receiveData:byte(1) * 256 + self._receiveData:byte(2)
        local data_end_pos = data_size + HEADER_SIZE
        if receive_size >= data_end_pos then
            -- 获取完整的一个包数据，进行解析
            local data = crypt.base64decode(self._receiveData:sub(HEADER_SIZE + 1, data_end_pos))
            -- 剩余数据等待下一次解析
            self._receiveData = self._receiveData:sub(data_end_pos + 1)
            if self._secret then
                data = crypt.desdecode(self._secret, data)
            end
            return data
        end
    end
end

function Connection:send(key,dataContent,ignoreSession)
    if  not (self:equalState(NETSTATE.CONNECTED) or self:equalState(NETSTATE.VERIFYPASS)) then
        print("netState ==:::::",self._netState)
        assert(false)
        return Logger.warn("network state not connected")
    end
    local sessionId
    if not ignoreSession then
        self._sessionId = self._sessionId + 1 
        sessionId = self._sessionId
    else
        sessionId = nil
    end

    local content = {[key] = dataContent, session_id = sessionId}
    local success, data, err = pcall(protobuf.encode, "C2S", content)
    if not success or err then
        Logger.error("encode protobuf error:%s", err)
    elseif data then
        if self._secret then
            success, data = pcall(crypt.desencode, self._secret, data) 
            if not success then
                Logger.error("desencode error")
                return false
            end
        end

        data = crypt.base64encode(data)
        local size = #data
        data = string.char(bit.band(bit.rshift(size, 8), 0xff)) .. string.char(bit.band(size, 0xff)) .. data
        local _, err = self._socket:send(data)
        if err then
            return self:disconnect(DISCONNECT_REASON.UNKOWN)
        end
        if sessionId then
            print("sessionId =",sessionId, " luasocket.gettime() = ",luasocket.gettime())
            self._sendMap[sessionId] = { content = content, timeOutPoint = luasocket.gettime() + PROTOCOL_TIMEOUT_TIME}
        end
    end
end

return Connection