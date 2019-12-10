local luasocket = require "socket"
local crypt = require "crypt"
local bit = require "bit"
local ConnectorIntranet = class("ConnectorIntranet")
local NETSTATE = {
	--未连接状态
	UN_CONNECTED = 0,
	CONNECTING = 1,
	CONNECTED = 2,
}
local CONNECTING_TIMEOUT = 5
local DISCONNECT_REASON = {
    UNKOWN = 0,   --未知原因
    CONNECT_TIME_OUT = 1,   --连接超时
}
-- 数据包头长度
local HEADER_SIZE = 2

function ConnectorIntranet:ctor(address)
    local iter = string.gmatch("(%d+):(%d+)")
    self._host = iter()
    self._port = iter()  
    self:updateState(NETSTATE.UN_CONNECTED)
end

function ConnectorIntranet:isIPV6(host)
    -- 使用socket.dns判断服务器地址是否为IPv6地址
    for k,v in pairs(luasocket.dns.getaddrinfo(host) or {}) do
        if v.family == "inet6" then
            return true  
        end
    end

    return false
end

function ConnectorIntranet:connect()
    Logger.debug("ConnectorIntranet:connect")
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
function ConnectorIntranet:disconnect(reason)
    if self._socket then
        self._socket:close()
        self._socket = nil
    end
end

function ConnectorIntranet:updateState(state)
    if self._netState == state then
        return
    end
    self._netState = state
    if NETSTATE.CONNECTING == state then
        self._connectTime = luasocket.gettime()
        self:openSchedule()
    elseif NETSTATE.UN_CONNECTED == state then
        self:closeSchedule()
    end
end

function ConnectorIntranet:equalState(state)
    return self._netState == state
end

function ConnectorIntranet:openSchedule()
    local scheduler = cc.Director:getInstance():getScheduler()
    self._scheduleId = scheduler:scheduleScriptFunc(function(dt)
        self:onUpdate(dt)
    end, 0, false)
end

function ConnectorIntranet:closeSchedule()
    if self._scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduleId)
        self._scheduleId = nil
    end
end

function ConnectorIntranet:onUpdate()
    --检测连接超时
    if self:equalState(NETSTATE.CONNECTING) and luasocket.gettime() - self._connectTime > CONNECTING_TIMEOUT then
        self:updateState(NETSTATE.UN_CONNECTED)
        self:disconnect(DISCONNECT_REASON.CONNECT_TIME_OUT)
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
                self:updateState(NETSTATE.UN_CONNECTED)
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
                --proto decode
            end
        end
    end
end

function ConnectorIntranet:unpackData()
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



return ConnectorIntranet