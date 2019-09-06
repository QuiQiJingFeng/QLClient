local ns = namespace("game.service")

local Version = require "app.kod.util.Version"
local DingTalkService = class("DingTalkService")
ns.DingTalkService = DingTalkService


local _dingTalkSupportVersion = Version.new("4.5.0.0")
local specialErrorVersion = Version.new("4.9.0.0")
-- 单例支持
-- @return LoginService
function DingTalkService:getInstance()
	return manager.ServiceManager.getInstance():getDingTalkService()
end

function DingTalkService:ctor()
	cc.bind(self, "event")
	print("DingTalkService:ctor")
end

function DingTalkService:initialize()
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(_dingTalkSupportVersion) < 0 then
		return false
	end
	local thumbImageSize, thumbImageDataSize = 640, 32 -- new parameter
	self:_init(1024, 80, thumbImageSize, thumbImageDataSize,
	handler(self, self._sendMessageReqCallBack),
	handler(self, self._sendMessageToDingTalkRespCallBack))		
	game.service.DingTalkService.getInstance():registerApp(config.GlobalConfig.getConfig().DINGTALK_APPID)
	return true
end

function DingTalkService:dispose()
	cc.unbind(self, "event")
end

function DingTalkService:isEnabled()
	return game.plugin.Runtime.isEnabled()
end

function DingTalkService:isSupported()
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if device.platform == "ios" then
		return currentVersion:compare(_dingTalkSupportVersion) >= 0
	else
		return currentVersion:compare(_dingTalkSupportVersion) >= 0 and currentVersion:compare(specialErrorVersion) ~= 0
	end
end


function DingTalkService:checkApp()
	if self:isEnabled() == false then return true end	
	if not self:isDTAppInstalled() then return false end	
	if not self:isDTAppSupportApi() then return false end	
	return true
end

function DingTalkService:_init(maxImageSize, maxImageDataSize, maxThumbImageSize, maxThumbImageDataSize, sendMessageReqCallBack, sendMessageToDingTalkRespCallBack)
	-- Logger.debug("initialize")
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local param = {
			maxImageSize,
			maxImageDataSize,
			maxThumbImageSize,
			maxThumbImageDataSize,
			sendMessageReqCallBack,
			sendMessageToDingTalkRespCallBack
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "initialize", param, "(IIIIII)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Logger.debug("initialize" .. tostring(ret))
		return ret
	elseif device.platform == "ios" then
		local param = {
			maxImageSize = maxImageSize,
			maxImageDataSize = maxImageDataSize,
			maxThumbImageSize = maxThumbImageSize,
			maxThumbImageDataSize = maxThumbImageDataSize,
			sendMessageReqCallBack = sendMessageReqCallBack,
			sendMessageToDingTalkRespCallBack = sendMessageToDingTalkRespCallBack,
		}
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "initialize", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Logger.debug("initialize" .. tostring(ret))
		return ret
	end
	
	Macro.assetFalse(false)	
end

-- return bool
function DingTalkService:registerApp(appId)
	Logger.debug("DingTalkService:registerApp " .. appId)
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "registerApp", {appId}, "(Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "registerApp", {appId = appId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- return bool
function DingTalkService:isDTAppInstalled()
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "isDingTalkInstalled", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "isDingTalkInstalled")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- return bool
function DingTalkService:isDTAppSupportApi()
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "isDingTalkSupportOpenAPI", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "isDingTalkSupportOpenAPI")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- return string
function DingTalkService:getDTAppInstallUrl()
	if self:isEnabled() == false then return "" end
	
	if device.platform == "android" then
		return ""
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "appStoreURLOfDingTalk")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret
	end
	
	Macro.assetFalse(false)
end

-- return string
function DingTalkService:getApiVersion()
	if self:isEnabled() == false then return "" end
	
	if device.platform == "android" then
		return ""
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "openAPIVersion")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret
	end
	
	Macro.assetFalse(false)
end

-- return string
function DingTalkService:openDTApp()
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "openDingTalk", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "openDingTalk")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false)
end


-- @param text: string
-- return bool
function DingTalkService:sendText(text)
	-- Logger.debug("sendText")
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "sendText", {text}, "(Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "sendText", {text = text})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- @param imagePath: string
-- return bool
function DingTalkService:sendImageData(imagePath)
	-- Logger.debug("sendImageData")
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local param = {
			imagePath
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "sendImageData", param, "(Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local param = {
			imagePath = imagePath
		}
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "sendImageData", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- @param urlString: string 			-- url
-- @param title: string					
-- @param description: string
-- @param thumbImagePath: string
-- return bool
function DingTalkService:sendLinkURL(urlString, title, description, thumbImagePath)
	-- Logger.debug("sendLinkURL===========" .. urlString)
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local param = {
			urlString,
			title,
			description,
			thumbImagePath
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/ddshare/DTShareLuaWrapper", "sendLinkURL", param, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	elseif device.platform == "ios" then
		local param = {
			urlString = urlString,
			title = title,
			description = description,
			thumbImagePath = thumbImagePath
		}
		local ok, ret = luaoc.callStaticMethod("DTShareLuaWrapper", "sendLinkURL", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0
	end
	
	Macro.assetFalse(false)
end

-- 钉钉请求内容返回
function DingTalkService:_sendMessageReqCallBack(jsonstr)
	Logger.debug("_sendMessageReqCallBack,%s", jsonstr)
end

-- 显示钉钉传过来的内容
function DingTalkService:_sendMessageToDingTalkRespCallBack(jsonstr)
	Logger.debug("_sendMessageToDingTalkRespCallBack,%s", jsonstr)
	local params = json.decode(jsonstr)
	self:dispatchEvent({
		name = "EVENT_DT_SEND_RESP",
		errCode = params["errCode"],
		errStr = params["errStr"]
	});
end








