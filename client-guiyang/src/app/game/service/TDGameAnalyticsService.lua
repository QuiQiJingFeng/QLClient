--[[
TD GameAnalytics模块
--]]
local AccountType = {}
if device.platform == "android" then
	AccountType.AccountAnonymous       = 0    -- 匿名帐户
    AccountType.AccountRegistered      = 1    -- 显性注册帐户
    AccountType.AccountSinaWeibo       = 2    -- 新浪微博
    AccountType.AccountQQ              = 3    -- QQ帐户
    AccountType.AccountTencentWeibo    = 4    -- 腾讯微博
    AccountType.AccountND91            = 5    -- 91帐户
    AccountType.AccountType1           = 6   -- 预留1
    AccountType.AccountType2           = 7   -- 预留2
    AccountType.AccountType3           = 8   -- 预留3
    AccountType.AccountType4           = 9   -- 预留4
    AccountType.AccountType5           = 10   -- 预留5
    AccountType.AccountType6           = 11   -- 预留6
    AccountType.AccountType7           = 12   -- 预留7
    AccountType.AccountType8           = 13   -- 预留8
    AccountType.AccountType9           = 14   -- 预留9
    AccountType.AccountType10          = 15    -- 预留10
elseif device.platform == "ios" then
	AccountType.AccountAnonymous       = 0    -- 匿名帐户
    AccountType.AccountRegistered      = 1    -- 显性注册帐户
    AccountType.AccountSinaWeibo       = 2    -- 新浪微博
    AccountType.AccountQQ              = 3    -- QQ帐户
    AccountType.AccountTencentWeibo    = 4    -- 腾讯微博
    AccountType.AccountND91            = 5    -- 91帐户
    AccountType.AccountType1           = 11   -- 预留1
    AccountType.AccountType2           = 12   -- 预留2
    AccountType.AccountType3           = 13   -- 预留3
    AccountType.AccountType4           = 14   -- 预留4
    AccountType.AccountType5           = 15   -- 预留5
    AccountType.AccountType6           = 16   -- 预留6
    AccountType.AccountType7           = 17   -- 预留7
    AccountType.AccountType8           = 18   -- 预留8
    AccountType.AccountType9           = 19   -- 预留9
    AccountType.AccountType10          = 20    -- 预留10
end

local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local TDGameAnalyticsService = class("TDGameAnalyticsService")
ns.TDGameAnalyticsService = TDGameAnalyticsService

function TDGameAnalyticsService.getInstance()
	return manager.ServiceManager.getInstance():getTDGameAnalyticsService()
end

function TDGameAnalyticsService:ctor()
	self._listenerEnterBackground = nil
	self._listenerEnterForeground = nil
end

-- TD GameAnalytics模块是否生效
function TDGameAnalyticsService:isEnabled()
	if not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled();
	end
end

-- 判断当前版本是否支持TD GameAnalytics
function TDGameAnalyticsService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.9.0")
	return currentVersion:compare(supportVersion) >= 0;

end

-- 初始化
function TDGameAnalyticsService:initialize()
	-- 从4.1.0.0版本开始TD初始化移到了原声代码里面
	if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.1.0.0")) < 0 then
	    self:_init(config.GlobalConfig.GAMEANALYTICS_APPID,game.plugin.Runtime.getChannelId())
	    self:_setAccount("0")
	    self:_setAccountType(AccountType.AccountAnonymous)
	end
	
	self._listenerEnterBackground = listenGlobalEvent("EVENT_APP_DID_ENTER_BACKGROUND", handler(self, self._onEnterBackground))
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))
end

-- 卸载
function TDGameAnalyticsService:dispose()
	Logger.debug("[TDGameAnalyticsService] dispose")
	if self._listenerEnterBackground ~= nil then
		unlistenGlobalEvent(self._listenerEnterBackground)
		self._listenerEnterBackground = nil;
	end
	
	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)
		self._listenerEnterForeground = nil;
	end
end

-- 是否已经初始化
function TDGameAnalyticsService:getSDKInitComplete()
	Logger.debug("[TDGameAnalyticsService] getSDKInitComplete")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "getSDKInitComplete", {},"()Z")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "getSDKInitComplete")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- 内部初始化
function TDGameAnalyticsService:_init(appId, channelId)
	Logger.debug("[TDGameAnalyticsService] _init,%s,%s", tostring(appId), tostring(channelId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "initialize", {tostring(appId), tostring(channelId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "initialize", {appId = tostring(appId), channelId = tostring(channelId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- login 
function TDGameAnalyticsService:login(accountId)
	Logger.debug("[TDGameAnalyticsService] login,%s", tostring(accountId))
	if self:isEnabled() == false then return false end
	
	self:_setAccount(accountId)
	self:_setAccountType(AccountType.AccountRegistered)
	
end

-- logout
function TDGameAnalyticsService:logout()
	Logger.debug("[TDGameAnalyticsService] logout")
	
	self:_setAccount("")
end

-- 设置用户信息
function TDGameAnalyticsService:setUserInfo(accountName, gender)
	Logger.debug("[TDGameAnalyticsService] setUserInfo,%s,%s", tostring(accountName), tostring(gender))
	if self:isEnabled() == false then return false end
	
	self:_setAccountName(accountName)
	self:_setGender(gender)
end

-- setAccount
function TDGameAnalyticsService:_setAccount(accountId)
	Logger.debug("[TDGameAnalyticsService] setAccount,%s", tostring(accountId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setAccount", {tostring(accountId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setAccount", {accountId = tostring(accountId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_setAccountType(accountType)
	Logger.debug("[TDGameAnalyticsService] setAccountType,%s", tostring(accountType))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setAccountType", 
            {tonumber(accountType)}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setAccountType", {accountType = tonumber(accountType)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:setLevel(level)
	Logger.debug("[TDGameAnalyticsService] setLevel,%s", tostring(level))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setLevel", 
            {tonumber(level)}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setLevel", {level = tonumber(level)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_setGender(gender)
	Logger.debug("[TDGameAnalyticsService] _setGender,%s", tostring(gender))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setGender",
            {tonumber(gender)}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setGender", {gender = tonumber(gender)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_setAccountName(accountName)
	Logger.debug("[TDGameAnalyticsService] _setAccountName,%s", tostring(accountName))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setAccountName", {tostring(accountName)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setAccountName", {accountName = tostring(accountName)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:setAge(age)
	Logger.debug("[TDGameAnalyticsService] setAge,%s", tostring(age))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setAge",
            {tonumber(age)}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setAge", {age = tonumber(age)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:setGameServer(gameServer)
	Logger.debug("[TDGameAnalyticsService] setGameServer,%s", tostring(gameServer))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "setGameServer", {tostring(gameServer)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "setGameServer", {gameServer = tostring(gameServer)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onChargeRequst(orderId,iapId,currencyAmount,currencyType,virtualCurrencyAmount,paymentType)
	Logger.debug("[TDGameAnalyticsService] onChargeRequst,%s,%s,%s,%s,%s,%s", 
	tostring(orderId), tostring(iapId), tostring(currencyAmount), tostring(currencyType), 
	tostring(virtualCurrencyAmount), tostring(paymentType))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onChargeRequst", 
		{tostring(orderId),tostring(iapId),tonumber(currencyAmount),tostring(currencyType),tonumber(virtualCurrencyAmount),tostring(paymentType)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onChargeRequst", 
		{orderId = tostring(orderId),iapId = tostring(iapId),currencyAmount = tonumber(currencyAmount),currencyType = tostring(currencyType),
		virtualCurrencyAmount = tonumber(virtualCurrencyAmount),paymentType = tostring(paymentType)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onChargeSuccess(orderId)
	Logger.debug("[TDGameAnalyticsService] onChargeSuccess,%s", tostring(orderId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onChargeSuccess", {tostring(orderId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onChargeSuccess", {orderId = tostring(orderId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onReward(virtualCurrencyAmount, reason)
	Logger.debug("[TDGameAnalyticsService] onReward,%s,%s", tostring(virtualCurrencyAmount), tostring(reason))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onReward", {tonumber(virtualCurrencyAmount),tostring(reason)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onReward", {virtualCurrencyAmount = tonumber(virtualCurrencyAmount), reason = tostring(reason)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onPurchase(item, number, price)
	Logger.debug("[TDGameAnalyticsService] onPurchase,%s,%s,%s", tostring(item), tostring(number), tostring(price))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onPurchase",
            {tostring(item), tonumber(number), tonumber(price)}, "(Ljava/lang/String;IF)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onPurchase", {item = tostring(item),number = tonumber(number),price = tonumber(price)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onUse(item, number)
	Logger.debug("[TDGameAnalyticsService] onUse,%s,%s", tostring(item), tostring(number))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onUse",
            {tostring(item),tonumber(number)}, "(Ljava/lang/String;I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onUse", {item = tostring(item),number = tonumber(number)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onBegin(missionId)
	Logger.debug("[TDGameAnalyticsService] onBegin,%s", tostring(missionId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onBegin", {tostring(missionId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onBegin", {missionId = tostring(missionId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onCompleted(missionId)
	Logger.debug("[TDGameAnalyticsService] onCompleted,%s", tostring(missionId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onCompleted", {tostring(missionId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onCompleted", {missionId = tostring(missionId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onFailed(missionId, cause)
	Logger.debug("[TDGameAnalyticsService] onFailed,%s,%s", tostring(missionId), tostring(cause))
	if self:isEnabled() == false then return false; end
	
	local _cause = cause or ""
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onFailed", {tostring(missionId), tostring(_cause)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onFailed", {missionId = tostring(missionId), cause = tostring(_cause)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:onEvent(eventId, eventData)
	local _jsonStr = ""
	if nil ~= eventData then 
		_jsonStr = json.encode(eventData) 
	end

	Logger.debug("[TDGameAnalyticsService] onEvent,%s,%s", tostring(eventId), tostring(_jsonStr))
	if self:isEnabled() == false then return false; end

	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onEvent", {tostring(eventId), tostring(_jsonStr)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("GameAnalyticsLuaWrapper", "onEvent", {eventId = tostring(eventId), eventData = tostring(_jsonStr)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_onPause()
	Logger.debug("[TDGameAnalyticsService] _onPause")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onPause")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_onResume()
	Logger.debug("[TDGameAnalyticsService] _onResume")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/talkingdata/GameAnalyticsLuaWrapper", "onResume")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false);
end

function TDGameAnalyticsService:_onEnterBackground()
	if self:getSDKInitComplete() then
		self:_onPause();
	end
end

function TDGameAnalyticsService:_onEnterForeground()
	if self:getSDKInitComplete() then
		self:_onResume();
	end
end