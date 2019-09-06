------------------------------------
-- 网络链接封装:SocketTCP
------------------------------------
local LuaSocket = require("socket")

local SocketTCP = class("SocketTCP")

local SOCKET_STATUS_CLOSED = "closed"
local SOCKET_STATUS_TIMEOUT = "timeout"
local SOCKET_STATUS_NOT_CONNECTED = "Socket is not connected"
local SOCKET_STATUS_ALREADY_CONNECTED = "already connected"
local SOCKET_STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"

-- Socket连接检测周期
local SOCKET_CHECK_CONNECT_INTERVAL = 0.1
-- Socket收包检测周期
local SOCKET_RECEIVE_PACKET_INTERVAL = 0.01

function SocketTCP:ctor()
    self._socket = nil;                             -- lua socket实例
    self._connectingCheckTask = nil;                -- 连接检测任务    
    self._hasConnected = false;                     -- 标记是否连接陈宫
    self._receivePacketTask = nil;                  -- 收包检测任务
end

function SocketTCP:dispose()
    self:close();

    self._onConnectionCreatedCallback = nil;
    self._onConnectionFailedCallback = nil;
    self._onConnectionLostCallback = nil;
    self._onPacketReceivedCallback = nil;
end

function SocketTCP:setConnectionCreatedCallback(callback)
	self._onConnectionCreatedCallback = callback
end

function SocketTCP:setConnectionFailedCallback(callback)
	self._onConnectionFailedCallback = callback
end

function SocketTCP:setConnectionLostCallback(callback)
self._onConnectionLostCallback = callback
end

function SocketTCP:setPacketReceivedCallback(callback)
	self._onPacketReceivedCallback = callback
end

-- 通过Url建立链接
-- @param ipv4: boolean 
-- @param ipAddress: string 网络链接的IP地址, 不接受域名
-- @param port: number
function SocketTCP:connect(ipv4, ipAddress, port, timeOutTime)	
    -- 断开之前的链接
    self:close();

	-- for dataeye log
	self._connectStartTime = LuaSocket.gettime()
    game.service.TDGameAnalyticsService.getInstance():onBegin("Net_connect2Server")

    -- 创建socket链接
	local err
    if ipv4 then
        self._socket, err = LuaSocket.tcp()		
    else
        self._socket, err = LuaSocket.tcp6()
    end
	if self._socket == nil then
		Logger.error("create socket error: " .. err)
		return false
	end

	-- disables the Nagle's algorithm
	self._socket:setoption("tcp-nodelay", true)	

    -- 底层的timeout可能不起作用
    self._socket:settimeout(0)

    -- 开始链接
    local succ, status = self._socket:connect(ipAddress, port)

    -- 有可能瞬时连接好了
    if succ == 1 or status == SOCKET_STATUS_ALREADY_CONNECTED then
        self:_onConnectionCreated()
        return true;
    end

    -- 开启链接检测
    self:_startConnectingCheckTask(ipAddress, port, timeOutTime);
	return true;
end

-- 关闭网络链接
function SocketTCP:close()
    -- 清除链接状态
    self._hasConnected = false;

    -- 关闭socket
    if self._socket ~= nil then        
        self._socket:close();
        self._socket = nil;
    end

    -- 取消链接计时器
    self:_endConnectingCheckTask();
    -- 终止收包
    self:_endReceivePacketTask();
end

-- 发送消息
function SocketTCP:send(message)
    if self._socket == nil or self.isConnected == false then
        return false;
    end
    
	local sentCount, errorMsg, errorSent = self._socket:send(tostring(message));
	if sentCount == nil then
		Logger.warn("[SocketTCP] send failed,%s,%d", errorMsg, errorSent)
		return false;
	end
    return true;
end

-- 链接成功的内部回调函数
function SocketTCP:_onConnectionCreated()
	-- 关闭连接超时检测
	self:_endConnectingCheckTask();
	
    -- 标记已链接
    self._hasConnected = true;

    -- 回调
    if self._onConnectionCreatedCallback ~= nil then
        self._onConnectionCreatedCallback();
    end

    -- 开始收包
    self:_startReceivePacketTask()

	-- 统计
	game.service.DataEyeService.getInstance():onEvent("Net_socketSucceed", LuaSocket.gettime() - self._connectStartTime)
	self._connectStartTime = 0
    game.service.TDGameAnalyticsService.getInstance():onCompleted("Net_connect2Server")
end

-- 链接失败的内部回调函数
function SocketTCP:_onConnectingFailed()
    -- 关闭链接重置状态
    self:close();    

    -- 回调
    if self._onConnectionFailedCallback ~= nil then
        self._onConnectionFailedCallback();
    end
end

-- 连接断开的内部回调函数
function SocketTCP:_onConnectionLost()
    self:close();

    -- 回调
    if self._onConnectionLostCallback ~= nil then
        self._onConnectionLostCallback();
    end    
end

function SocketTCP:_onReceivePacket(packet)
     -- 回调
    if self._onPacketReceivedCallback ~= nil then
        self._onPacketReceivedCallback(packet);
    end
end

-- 开启Connecting状态检测轮询函数
function SocketTCP:_startConnectingCheckTask(ipAddress, port, timeOutTime)
    self:_endConnectingCheckTask();

     -- 进行connecting检测
    self._connectingStartTime = LuaSocket.gettime()

    local connectingCheckFunc = function ()
        -- 检测当前链接状态
        local connectingResult, connectingStatus = self._socket:connect(ipAddress, port)
        if connectingResult == 1 or connectingStatus == SOCKET_STATUS_ALREADY_CONNECTED then
            self:_onConnectionCreated()
            return;
        end

        -- TODO : 现在只用超时检测链接状态, 应该还有根本不能链接的情况

        -- 检测链接超时
        if LuaSocket.gettime() - self._connectingStartTime >= timeOutTime then
            self:_onConnectingFailed()
            return;
        end
    end

    -- 开启轮询检测, 0.1秒检测一次
    self._connectingCheckTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(connectingCheckFunc, SOCKET_CHECK_CONNECT_INTERVAL, false)
end

-- 终止Connecting状态检测
function SocketTCP:_endConnectingCheckTask()
    -- 取消链接计时器
    if self._connectingCheckTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._connectingCheckTask);
        self._connectingCheckTask = nil;
    end
end

-- 开启收包检测轮询
function SocketTCP:_startReceivePacketTask()
    -- 开启网络收报检测
    local receiveFunc = function()
        while true do
			if self._hasConnected == false then
				-- 处理消息过程中, 断开链接
				return
			end
			
            -- if use "*l" pattern, some buffer will be discarded, why?
            local body, status, partial = self._socket:receive("*a")  -- read the package body
            if status == SOCKET_STATUS_CLOSED or status == SOCKET_STATUS_NOT_CONNECTED then
                -- 收包出问题了, 断开网络
                Logger.warn("[SocketTCP], receive failed,%s", status)
                game.service.DataEyeService.getInstance():onEvent("Net_receiveFailed_" .. status)
                self:_onConnectionLost();
                return
            end

            -- 获取包体,__partial也是包体
            local data = nil
            if(body and #body > 0) then 
                data = body 
            elseif(partial and #partial > 0) then
                data = partial
            end

            -- 没有数据, 等待下一次
            if data == nil then
                return
            end

            -- 接收数据			
            self:_onReceivePacket(data);
            
            -- 再次尝试接收, 直到本次检测没有数据为止
        end
    end

    -- 开启收包检测
    self._receivePacketTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(receiveFunc, SOCKET_RECEIVE_PACKET_INTERVAL, false)
end

-- 开启收包检测
function SocketTCP:_endReceivePacketTask()
    -- 取消链接计时器
	if self._receivePacketTask ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._receivePacketTask);
		self._receivePacketTask = nil;
	end
end

-- cc.exports.onCreated = function()
-- 	print("send", test:send("asd"));
-- end

-- cc.exports.test = SocketTCP.new(onCreated);
-- print(test:connect(true, "182.254.214.182", 3800, 5))

return SocketTCP;