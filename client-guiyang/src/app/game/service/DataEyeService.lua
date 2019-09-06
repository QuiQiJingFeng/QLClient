--[[
DataEye埋点服务

-- 需求
-- 初始化
-- 登录/登出
-- 玩家信息: 性别/
-- 关卡: 牌局房间
-- 自定义事件: 
-- 错误收集:
	* Group信息下载错误
	* 微信认证错误
	* 服务器异常错误
	* 房间解散异常
	* 多牌少牌错误收集

-- Event : {name = "EVENT_DATA_SERVICE_LOGINED"} 监听事件用于上报状态事件
--]]
local Version = require "app.kod.util.Version"

local DCAgent,DCAccount,DCItem,DCAgent,DCEvent
if Version.new("4.0.9.0"):compare(Version.new(game.plugin.Runtime.getBuildVersion())) >= 0 then
    DCAgent = require("app.kod.plugin.dataEye.DCAgent")
    DCAccount = require("app.kod.plugin.dataEye.DCAccount")
    DCItem = require("app.kod.plugin.dataEye.DCItem")
    DCAgent = require("app.kod.plugin.dataEye.DCAgent")
    DCEvent = require("app.kod.plugin.dataEye.DCEvent")
end

local ns = namespace("game.service")

local StatusData = class("StatusData")
function StatusData:ctor()
	self.lastReportDate = 0
	-- { key, event }
	self.events = {}
end

local DataEyeService = class("DataEyeService")
ns.DataEyeService = DataEyeService

function DataEyeService.getInstance()
	return manager.ServiceManager.getInstance():getDataEyeService();
end

function DataEyeService:ctor()
	cc.bind(self, "event");

	self._accountId = nil;
	self._statusData = nil
end

function DataEyeService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	-- 4.0.9版本废弃DataEye, 转换问TalkingData
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.9.0")
	return currentVersion:compare(supportVersion) < 0;
end

function DataEyeService:initialize()
	if not self:isEnabled() then return end
	if device.platform == "android" then return end
	-- TODO : 需要设置版本吗
	DCAgent.setDebugMode(config.GlobalConfig.DATAEYE_DEBUG)
	DCAgent.setReportMode(config.GlobalConfig.DATAEYE_REPORTMODE)
	DCAgent.onStart(config.GlobalConfig.DATAEYE_APP_ID, game.plugin.Runtime.getChannelId())
end

function DataEyeService:dispose()
	cc.unbind(self, "event");
end

function DataEyeService:_loadLocalStorage()
	self._statusData = manager.LocalStorage.getUserData(self._accountId, "StatusData", StatusData);

	-- TODO : 删除废弃的状态

	-- 上报状态数据
	self:_reportStatusEvent();
end

-- 保存本地数据
function DataEyeService:_saveLocalSetting()
	manager.LocalStorage.setUserData(self._accountId, "StatusData", self._statusData);
end

function DataEyeService:isEnabled()
	if not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled();
	end
end

-- 登录/登出
function DataEyeService:login(accountId)
	if not self:isEnabled() then
		game.service.TDGameAnalyticsService.getInstance():login(accountId);
	else
		DCAccount.login(tostring(accountId))
	end	

	self._accountId = accountId;

	self:_loadLocalStorage();
	self:dispatchEvent({name = "EVENT_DATA_SERVICE_LOGINED"})
end

function DataEyeService:logout()
	if not self:isEnabled() then
		game.service.TDGameAnalyticsService.getInstance():logout()
	else
		DCAccount.logout()
    end

	self._accountId = nil
	self._statusData = nil
end

-- 设置用户信息
function DataEyeService:setUserInfo(accountName, gender)
	if not self:isEnabled() then
		game.service.TDGameAnalyticsService.getInstance():setUserInfo(accountName, gender)
	else
		DCAccount.setGender(tostring(gender))
	end
end

-- 自定义事件
function DataEyeService:onEvent(eventId, duration)
	if not self:isEnabled() then
		if duration == nil then
			-- talking game不再统计duration事件
		    game.service.TDGameAnalyticsService.getInstance():onEvent(eventId)
	    end
		return 
	end
	
	-- 确保lable有值
	duration = duration or 0;

	if self._accountId ~= nil then
		DCEvent.onEventDuration(eventId, "", duration);
	else
		-- 构造Map调用
		DCEvent.onEventBeforeLogin(eventId, {}, duration)
	end
end

-- 用于统计状态类型事件
function DataEyeService:onStatusEvent(key, event)
	if self._accountId == nil then
		return
	end
	local oldEvent = self._statusData.events[key]
	self._statusData.events[key] = event
	self:_saveLocalSetting();

	-- 第一次设置, 上报数据
	if oldEvent == nil then
		self:onEvent(event)
	end
end

function DataEyeService:_reportStatusEvent()
	if not self:isEnabled() then return end
	if self._accountId == nil then
		return
	end

	-- 一天上报一次
	local nowDay = math.floor(kod.util.Time.now() / 60 / 60 / 24);
	if self._statusData.lastReportDate ~= 0 and self._statusData.lastReportDate == nowDay then
		return 
	end

	-- 记录上报时间
	self._statusData.lastReportDate = nowDay
	self:_saveLocalSetting();

	for _,event in pairs(self._statusData.events) do
		self:onEvent(event)
	end
end

-- 错误收集
function DataEyeService:amapError(errorCode, errorStr)
	if not self:isEnabled() then return end

	local msg = tostring((errorCode or ""))..","..tostring((errorStr or ""))
	if "" == msg then msg = "invalid errorStr!" end
	DCAgent.reportError("amapError", msg)
end

function DataEyeService:needReportCardListError(roomId, roundIndex)
	return self._roomId ~= roomId or self._roundIndex ~= roundIndex;
end

function DataEyeService:reportCardListError(roomId, roundIndex, cardsStr)
	if self:needReportCardListError(roomId, roundIndex) == false then return end

	self._roomId = roomId;
	self._roundIndex = roundIndex;
	self:reportError("cardListError", string.format("%d,%d:%s", roomId, roundIndex, cardsStr));
end

function DataEyeService:reportError(errorName, errorDesc)
	if not self:isEnabled() then
		if self:isSupported() == false then
			-- 4.0.9版本开始支持buglyReportEvent
			Logger.reportError(errorName, errorDesc)
		end
		return
	end
	DCAgent.reportError(errorName, tostring(errorDesc))
end