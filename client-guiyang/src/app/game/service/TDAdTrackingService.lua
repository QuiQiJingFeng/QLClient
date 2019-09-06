--[[
TD AdTracking模块
--]]
local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local TDAdTrackingService = class("TDAdTrackingService")
ns.TDAdTrackingService = TDAdTrackingService

function TDAdTrackingService.getInstance()
	return manager.ServiceManager.getInstance():getTDAdTrackingService()
end

function TDAdTrackingService:ctor()
	
end

-- TD AdTracking模块是否生效
function TDAdTrackingService:isEnabled()
	if not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled();
	end
end

-- 判断当前版本是否支持TD AdTracking
function TDAdTrackingService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.2.0")
	return currentVersion:compare(supportVersion) >= 0;
end

-- 初始化
function TDAdTrackingService:initialize()
	self:_init(config.GlobalConfig.getConfig().ADTRACKING_APPID, game.plugin.Runtime.getChannelId())
end

-- 卸载
function TDAdTrackingService:dispose()
	Logger.debug("[TDAdTrackingService] dispose")
end

-- 内部初始化
function TDAdTrackingService:_init(appId, channelId)
	Logger.debug("[TDAdTrackingService] _init,%s,%s", tostring(appId), tostring(channelId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/AdTrackingLuaWrapper", "initialize", {appId, channelId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("AdTrackingLuaWrapper", "initialize", {appId = appId, channelId = channelId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- login
function TDAdTrackingService:onLogin(userId)
	Logger.debug("[TDAdTrackingService] onLogin,%s", tostring(userId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/AdTrackingLuaWrapper", "onLogin", {userId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("AdTrackingLuaWrapper", "onLogin", {userId = userId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

