--[[
转菊花处理
-- 发送全局事件 EVENT_BUSY_RETAIN
-- 发送全局事件 EVENT_BUSY_RELEASE
-- 发送全局事件 EVENT_BUSY_RESET
--]]
local ns = namespace("game.service")

local WaitingService = class("WaitingService")
ns.WaitingService = WaitingService

-- 单例支持
-- @return LoginService
function WaitingService:getInstance()
    return manager.ServiceManager.getInstance():getWaitingService();
end

function WaitingService:ctor()
	self._busyNumber = 0
	self._listenerRetainBusy = nil;
	self._listenerReleaseBusy = nil;
end

function WaitingService:initialize()
	self._listenerRetainBusy = listenGlobalEvent("EVENT_BUSY_RETAIN", handler(self, self.retainBusy))
	self._listenerReleaseBusy = listenGlobalEvent("EVENT_BUSY_RELEASE", handler(self, self.releaseBusy))
end

function WaitingService:dispose()
	if self._listenerRetainBusy ~= nil then
		unlistenGlobalEvent(self._listenerNetBroken)
		self._listenerRetainBusy = nil
	end
	
	if self._listenerReleaseBusy ~= nil then
		unlistenGlobalEvent(self._listenerReleaseBusy)		
		self._listenerReleaseBusy = nil
	end
end

-- 手动标记等待
-- @return void
function WaitingService:retainBusy()
    self._busyNumber = self._busyNumber + 1;	
    self:_onBusyChanged();
end

-- 手动释放等待，需要与RetainBusy配合使用
-- @return void
function WaitingService:releaseBusy()
    self._busyNumber = math.max(self._busyNumber - 1, 0);
	self:_onBusyChanged();
end

function WaitingService:_onBusyChanged()
	if self._busyNumber > 0 then
		if UIManager:getInstance():getIsShowing("UIReconnectTips") == false then
			UIManager:getInstance():show("UIReconnectTips")
		end
	else
		-- TODO：如果不销毁，会出现层级问题，导致界面无法看到
		UIManager:getInstance():destroy("UIReconnectTips")
	end	
end