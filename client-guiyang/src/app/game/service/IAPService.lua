--[[
IAP模块(内购)
--]]
local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local IAPService = class("IAPService")
ns.IAPService = IAPService

function IAPService.getInstance()
	return manager.ServiceManager.getInstance():getIAPService()
end

function IAPService:ctor()
	cc.bind(self, "event");
end

-- 模块是否生效
function IAPService:isEnabled()
	if not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled();
	end
end

-- 判断当前版本是否支持
function IAPService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.1.6.0")
	return currentVersion:compare(supportVersion) >= 0;
end

-- 初始化
function IAPService:initialize()
	if not self:isInitialized() then
		self:setCallback(handler(self, self._onResultAppCallback))
	end
end

-- 卸载
function IAPService:dispose()
	Logger.debug("[IAPService] dispose")
	cc.unbind(self, "event");
end

-- 设置回调
function IAPService:setCallback(onResultAppCallback)
	Logger.debug("[IAPService] setCallback,%s", tostring(onResultAppCallback))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAPService", "setCallback", {onResultAppCallback = onResultAppCallback})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 是否初始化成功
function IAPService:isInitialized()
	Logger.debug("[IAPService] isInitialized")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAPService", "isInitialized")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 查询是否有未完成的订单
function IAPService:queryOrder()
	Logger.debug("[IAPService] queryOrder")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAPService", "queryOrder")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 传餐（productID，orderID）
function IAPService:setPayParams(productId, orderId, roleId)
	-- Logger.debug("[IAPService] setPayParams,%s", tostring(params))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAPService", "setPayParams", {productId = productId, orderId = orderId, roleId = tostring(roleId)})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Macro.assetTrue(true, "IAPService Log setPayParams")
		return true
	end
end

-- 完成后通知客户端(true:验证成功，false：验证失败)
function IAPService:notifyResult(verifyResult)
	Logger.debug("[IAPService] notifyResult")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("IAPService", "notifyResult", {verifyResult = verifyResult})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

--返回客户端，订单orderid，苹果交易号transcationId，收据receiptString
function IAPService:_onResultAppCallback(jsonStr)
	Logger.debug("[IAPService] _onResultAppCallback", jsonStr)
	local params = json.decode(jsonStr)
	Logger.dump(params, "IAPService:_onResultAppCallback", 2)
	self:dispatchEvent({name = "EVENT_ONRESULTAPPCALLBACK", orderid = params.orderid, transcationId = params.transcationId, receiptString = params.receiptString, roleId = tonumber(params.roleId)})
	Macro.assetTrue(true, "IAPService Log onResultAppCallback")
end

