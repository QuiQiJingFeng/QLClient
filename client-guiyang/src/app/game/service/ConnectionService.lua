--[[
处理登录之后的重连逻辑
-- 监听链接失败事件
-- 监听ConnectionLost事件
-- 监听后台回到前台的事件
--]]
local ns = namespace("game.service")

namespace("net").NetworkStatus = {
    NotReachable = 0,       -- 没有网络
    ReachableViaWiFi = 1,   -- 当前使用Wifi网络
    ReachableViaWWAN = 2    -- 使用的蜂窝网络
}

namespace("net").ConnectionType = {
	Public = 0,				-- 公网服务器
	Intranet = 1 			-- 内网/审核服务器
}

-- 这是对应Connection.luac 中的 lost reason 对应表
namespace("net").ConnectionLostReason = {
    [0] = "UNKNOWN",
    [1] = "HEART_BEAT_TIME_OUT",
    [2] = "REQUEST_TIME_OUT",
    [3] = "HANDSHAKE_TIME_OUT"
}

local ConnectionService = class("ConnectionService")
ns.ConnectionService = ConnectionService

-- 单例支持
-- @return LoginService
function ConnectionService:getInstance()
    return manager.ServiceManager.getInstance():getConnectionService();
end

function ConnectionService:ctor()
	self._canConnect = true;
	self._pendingRequests = {}
	self._delayConnectTask = nil
end

function ConnectionService:initialize()
	self._connection = require("app.net.core.Connection").new()

	-- 注册网络状态事件监听
	self._connection:addEventListener("EVENT_CONNECTION_CREATED", handler(self, self._onConnectionCreated), self);
	self._connection:addEventListener("EVENT_CONNECTION_FAILED", handler(self, self._onConnectionFailed), self);
	self._connection:addEventListener("EVENT_CONNECTION_LOST", handler(self, self._onConnectionLost), self);

	-- 注册前后台切换事件监听
    self._listenerEnterBackground = listenGlobalEvent("EVENT_APP_DID_ENTER_BACKGROUND", handler(self, self._onEnterBackground))
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))

	-- 注册玩家登录流程相关监听
	game.service.LoginService.getInstance():addEventListener("AFTER_USER_DATA_RETRIVED", handler(self, self._onAfterUserDataRetivied), self);
	game.service.LoginService.getInstance():addEventListener("USER_LOGOUT", handler(self, self._onUserLogout), self);
	GameFSM:getInstance():addEventListener("GAME_STATE_CHANGING", handler(self, self._onGameStateChanging), self);
end

function ConnectionService:dispose()
	self._connection:removeEventListenersByTag(self);
	unlistenGlobalEvent(self._listenerEnterBackground)
	unlistenGlobalEvent(self._listenerEnterForeground)
end

-- 获取网络连接
function ConnectionService:getConnection()
	return self._connection
end

function ConnectionService:setConnectionType(connectionType, address)
	self._connection:setConnectionType(connectionType, address)
end

-- 获取网络状态
function ConnectionService:getReachabilityStatus()	
	return loho.getReachabilityStatus()
end

-- 关闭网络连接
function ConnectionService:close()
	self:_clearPendingRequests()
    local state = self._connection:getConnectionState()
	if state == net.ConnectionState.CONNECTING or state == net.ConnectionState.WAITING_HANDSHAKE then
		-- 如果是正在连接状体, 需要EVENT_BUSY_RELEASE
		dispatchGlobalEvent("EVENT_BUSY_RELEASE")
	end
	self._connection:close();
end

-- 发送网络request
function ConnectionService:sendRequest(req)
	if self._connection:getConnectionState() ~= net.ConnectionState.CONNECTED then
		-- 检测当前连接状态, 如果没有连接, 尝试连接, 连接成功之后在处理这条请求
		Logger.debug("delay request %s", req:toString());
		-- Macro.assetFalse(self._connection:getConnectionState() ~= net.ConnectionState.CONNECTING);

		-- 当前没有链接, 缓存这个request, 连接之后在处理
		table.insert(self._pendingRequests, req);

		-- 发起连接
		if self._connection:getConnectionState() == net.ConnectionState.DISCONNECTED and self._canConnect == true then
			-- 当前有可能是切换到前台但是还没有回复为可连接状态的情况
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			self:_connect()
		end
		return;
	end

	self._connection:sendRequest(req)
end

-- 建立网络连接
function ConnectionService:_connect()
	if Macro.assetTrue(self._connection:getConnectionState() ~= net.ConnectionState.DISCONNECTED) then
		return
	end	
	self:_hideRetryUI()
	-- 连接之前先确认网络环境
	if self:getReachabilityStatus() == net.NetworkStatus.NotReachable then
		self:_showRetryUI("没有网络环境, 请确认您的网络\n\n提示：请允许“聚友贵州麻将”使用无线数据")
		dispatchGlobalEvent("EVENT_NOT_IN_SERVICE")
		return
	end
	dispatchGlobalEvent("EVENT_BUSY_RETAIN")
	self._connection:connect()
end

function ConnectionService:_reconnect(reason)
	if Macro.assetTrue(self._connection:getConnectionState() ~= net.ConnectionState.DISCONNECTED) then
		return
	end	
	self:_hideRetryUI()
	-- 连接之前先确认网络环境
	if self:getReachabilityStatus() == net.NetworkStatus.NotReachable then
		self:_showRetryUI("没有网络环境, 请确认您的网络\n\n提示：请允许“聚友贵州麻将”使用无线数据")
		dispatchGlobalEvent("EVENT_NOT_IN_SERVICE")
		return
	end
	dispatchGlobalEvent("EVENT_BUSY_RETAIN")
	self._connection:reconnect(reason)
end

-- 网络连接创建成功回调
function ConnectionService:_onConnectionCreated()
	self:_hideRetryUI() -- 关闭重连弹窗
	dispatchGlobalEvent("EVENT_BUSY_RELEASE")

	-- 连接成功
	if GameFSM:getInstance():getCurrentState():isGamingState() then
		-- 如果是登录状态, 重新发起登录, 登录成功之后尝试执行等待的消息
		game.service.LoginService.getInstance():startRelogin()
	elseif #self._pendingRequests ~= 0 then
		-- 否则, 尝试执行等待的消息
		self:_processPendingRequests()
	elseif iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Login") then
		-- _onConnectionCreated的时候如果没有等待消息, 就意味着这是断线重连产生的情况
		-- TODO : 代码结构不好造成的, 在LoginState断线没法发起重连, 先写死成这样, 日后需要改为GameState与Scene分开
		game.service.LoginService.getInstance():startRelogin()
	elseif iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Update") then
		-- _onConnectionCreated的时候如果没有等待消息, 就意味着这是断线重连产生的情况
		game.service.UpdateService.getInstance():restart()		
	end
end

-- 服务器连接失败回调
function ConnectionService:_onConnectionFailed()
	dispatchGlobalEvent("EVENT_BUSY_RELEASE")
	dispatchGlobalEvent("EVENT_NOT_IN_SERVICE")
	self:_showRetryUI("网络不稳定, 是否要重试")
end

-- 服务器连接断开的回调
function ConnectionService:_onConnectionLost(event)
	self:_clearPendingRequests()
	self:_reconnect(event.data)	
end

function ConnectionService:_onEnterBackground()
	Logger.debug("_onEnterBackground")
	dispatchGlobalEvent("EVENT_NOT_IN_SERVICE")
	-- 标记为不能发起连接状态
	self._canConnect = false;
	-- 主动断开链接
	self:close();
end

function ConnectionService:_onEnterForeground()
	Logger.debug("_onEnterForeground")
	-- 延迟0.1秒重新登录
	
	-- 防止在这段时间用户点击
	dispatchGlobalEvent("EVENT_BUSY_RETAIN")
	if self._delayConnectTask ~= nil then
		-- RETAIN 与 RELEASE一定要配对
		dispatchGlobalEvent("EVENT_BUSY_RELEASE")
		unscheduleOnce(self._delayConnectTask)
		self._delayConnectTask = nil
	end

	self._delayConnectTask = scheduleOnce(function()
		self._delayConnectTask = nil;
		dispatchGlobalEvent("EVENT_BUSY_RELEASE")
		
		-- 恢复可发起连接状态
		self._canConnect = true;

		if GameFSM:getInstance():getCurrentState():isGamingState() then
			-- 如果是登录状态, 重新链接
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			self:_connect()
		elseif iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Login") 
			and game.service.LocalPlayerService.getInstance() ~= nil then
			-- 登录界面在LoginInterface之后没有进入大厅之前, 切换出去在回来, 需要重新发起链接
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			self:_connect()
		elseif iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Update") 
			and not game.service.UpdateService.getInstance():isStartWorking() then
			-- 热更新界面还没开始下载, 则重新发起连接
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			self:_connect()
		elseif #self._pendingRequests ~= 0 then
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			self:_connect()
		end
	end, 0.5)
end

-- 用户登出回调
function ConnectionService:_onUserLogout()
	self:close();
end

-- 重连刷洗数据之后, 尝试再次发起等待的协议
function ConnectionService:_onAfterUserDataRetivied()
	self:_processPendingRequests();
end

-- 当场景切换的时候, 认为_pendingRequests的上下文产生变化, 不在继续发送_pendingRequests
function ConnectionService:_onGameStateChanging()
	self:_clearPendingRequests();
end

function ConnectionService:_hideRetryUI()
	UIManager:getInstance():destroy("UIConnectionMessageBox")
end

-- 显示重新连接UI
function ConnectionService:_showRetryUI(text)
	-- 这里处理的不好
	if GameFSM:getInstance():getCurrentState():isGamingState() then		
		UIManager:getInstance():show("UIConnectionMessageBox", text, {"确定","取消"},
		function()
			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
			-- 确定, 重连
			scheduleOnce(handler(self, self._connect), 0)
			return true
		end,
		function()
			-- 取消, 返回登录			
			game.service.LoginService.getInstance():forceLogout()
			return true
		end)
	else		
		-- 其他状态如果连不上继续重连
		UIManager:getInstance():show("UIConnectionMessageBox", text, {"确定"}, function()
			-- 确定, 重连
    		if iskindof(GameFSM:getInstance():getCurrentState(), "GameState_Update") and not game.service.UpdateService.getInstance():isStartWorking() then
    			Logger.info("[Bugly Info Logs] call connect at ConnectionService.lua line " .. debug.getinfo(1).currentline)
    			scheduleOnce(handler(self, self._connect), 0)
            end
		end)
	end
end

-- 处理等待的请求
function ConnectionService:_processPendingRequests()
	local cachedRequests = self._pendingRequests
	self:_clearPendingRequests();
	for _,req in ipairs(cachedRequests) do
		self._connection:sendRequest(req)
	end
end

function ConnectionService:_clearPendingRequests()
	self._pendingRequests = {}
end
