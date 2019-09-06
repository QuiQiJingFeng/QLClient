local ns = namespace("game.service")

local Version = require "app.kod.util.Version"

-- 事件
-- EVENT_AUTH_RESP
-- {
--	errCode:int
--	errStr:string
-- 	code:string
-- 	state:string
-- }
-- EVENT_SEND_RESP
-- {
--	errCode:int
--	errStr:string
-- }

local WeChatService = class("WeChatService")
ns.WeChatService = WeChatService

WeChatService.WXScene = {
	WXSceneSession  = 0,	-- 聊天界面
	WXSceneTimeline = 1,    -- 朋友圈
	WXSceneFavorite = 2,	-- 收藏
}

WeChatService.WXErrorCode = {
    WXSuccess           = 0,    -- 成功
    WXErrCodeCommon     = -1,   -- 普通错误类型
    WXErrCodeUserCancel = -2,   -- 用户点击取消并返回
    WXErrCodeSentFail   = -3,   -- 发送失败
    WXErrCodeAuthDeny   = -4,   -- 授权失败
    WXErrCodeUnsupport  = -5,   -- 微信不支持
}

-- 单例支持
-- @return LoginService
function WeChatService:getInstance()
    return manager.ServiceManager.getInstance():getWeChatService();
end

function WeChatService:ctor()
	cc.bind(self, "event");
end

function WeChatService:initialize()
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local thumbImageSize, thumbImageDataSize = 120, 4 -- old parameter
    if currentVersion:compare(Version.new("4.1.3.0")) >= 0 or device.platform == "ios" then
        thumbImageSize, thumbImageDataSize = 640, 32 -- new parameter
    end
	self:_init(1024, 80, thumbImageSize, thumbImageDataSize,
		handler(self, self._onGetMessageFromWXReq),
		handler(self, self._onShowMessageFromWXReq),
		handler(self, self._onLaunchFromWXReq),
		handler(self, self._onSendAuthResp),
		handler(self, self._onSendMessageToWXResp));
		
	-- test
	-- Logger.debug("isWXAppInstalled,%s", tostring(self:isWXAppInstalled()));
	-- Logger.debug("isWXAppSupportApi,%s", tostring(self:isWXAppSupportApi()));
	-- Logger.debug("getWXAppInstallUrl,%s", self:getWXAppInstallUrl());
	-- Logger.debug("getApiVersion,%s", self:getApiVersion());
    -- 初始化WeChat_init

    game.service.WeChatService.getInstance():registerApp(config.GlobalConfig.getConfig().WECHAT_APPID)
end

function WeChatService:dispose()
	cc.unbind(self, "event");
end

function WeChatService:isEnabled()
	return game.plugin.Runtime.isEnabled();
end

function WeChatService:checkApp()
	if self:isEnabled() == false then return true; end
	
	if self:isWXAppInstalled() == false then
		return false;
	end
	
	if self:isWXAppSupportApi() == false then
		return false;
	end
	
	return true;
end

function WeChatService:_init(maxImageSize, maxImageDataSize, maxThumbImageSize, maxThumbImageDataSize, getMessageFromWXReqCallback, showMessageFromWXReqCallback, launchFromWXReqCallback, sendAuthRespCallback, sendMessageToWXRespCallback)
	-- Logger.debug("initialize")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local param = { 
			maxImageSize, 
			maxImageDataSize, 
			maxThumbImageSize, 
			maxThumbImageDataSize, 
			getMessageFromWXReqCallback,
			showMessageFromWXReqCallback,
			launchFromWXReqCallback,
			sendAuthRespCallback, 
			sendMessageToWXRespCallback
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "initialize", param, "(IIIIIIIII)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Logger.debug("initialize"..tostring(ret))
		return ret;
	elseif device.platform == "ios" then
		local param = { 
			maxImageSize = maxImageSize, 
			maxImageDataSize = maxImageDataSize, 
			maxThumbImageSize = maxThumbImageSize, 
			maxThumbImageDataSize = maxThumbImageDataSize, 
			getMessageFromWXReqCallback = getMessageFromWXReqCallback,
			showMessageFromWXReqCallback = showMessageFromWXReqCallback,
			launchFromWXReqCallback = launchFromWXReqCallback,
			sendAuthRespCallback = sendAuthRespCallback, 
			sendMessageToWXRespCallback = sendMessageToWXRespCallback,
		}
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "initialize", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Logger.debug("initialize"..tostring(ret))
		return ret;
	end

	Macro.assetFalse(false);	
end

-- return bool
function WeChatService:registerApp(appId)
	-- Logger.debug("registerApp")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "registerApp", {appId},"(Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "registerApp", { appId = appId })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- return bool
function WeChatService:isWXAppInstalled()
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "isWXAppInstalled", {},"()I");
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "isWXAppInstalled")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- return bool
function WeChatService:isWXAppSupportApi()
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "isWXAppSupportApi", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "isWXAppSupportApi")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- return string
function WeChatService:getWXAppInstallUrl()
	if self:isEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "getWXAppInstallUrl")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- return string
function WeChatService:getApiVersion()
	if self:isEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "getApiVersion")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- return string
function WeChatService:openWXApp()
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "openWXApp", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "openWXApp")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	end

	Macro.assetFalse(false);
end

-- return void
function WeChatService:_registerSendAuthRespCallback(callback)
	-- Logger.debug("_registerSendAuthRespCallback")
	if self:isEnabled() == false then return; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "registerSendAuthRespCallback", {callback})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "registerSendAuthRespCallback", { callback = callback })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return;
	end

	Macro.assetFalse(false);
end

function WeChatService:_registerSendMessageToWXRespCallback(callback)
	-- Logger.debug("_registerSendAuthRespCallback")
	if self:isEnabled() == false then return; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "registerSendMessageToWXRespCallback", {callback})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "registerSendMessageToWXRespCallback", { callback = callback })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return;
	end

	Macro.assetFalse(false);
end

-- @param scope: string
-- return bool
function WeChatService:sendAuthReq(scope, state)
	-- Logger.debug("sendAuthReq")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "sendAuthReq", { scope, state}, "(Ljava/lang/String;Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "sendAuthReq", { scope = scope, state = state})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- 微信请求App提供内容，需要app提供内容后使用sendRsp返回
function WeChatService:_onGetMessageFromWXReq(jsonstr)
	-- Logger.debug("_onGetMessageFromWXReq,%s", jsonstr)
end

-- 显示微信传过来的内容
function WeChatService:_onShowMessageFromWXReq(jsonstr)
	-- Logger.debug("_onShowMessageFromWXReq,%s", jsonstr)
end

-- 送微信启动App
function WeChatService:_onLaunchFromWXReq(jsonstr)
	-- Logger.debug("_onLaunchFromWXReq,%s", jsonstr)
end

-- App向微信发起SendMessageToWXReq的回复
function WeChatService:_onSendAuthResp(jsonstr)
	Logger.debug("_onSendAuthResp,%s", jsonstr)

	local params = json.decode(jsonstr)
	self:dispatchEvent({ 
		name = "EVENT_AUTH_RESP",
		errCode = params["errCode"],
		errStr = params["errStr"],
		code = params["code"],
		state = params["state"],
	});
end

function WeChatService:_onSendMessageToWXResp(jsonstr)
	Logger.debug("_onSendMessageToWXResp,%s", jsonstr)

	local params = json.decode(jsonstr)
	self:dispatchEvent({ 
		name = "EVENT_SEND_RESP",
		errCode = params["errCode"],
		errStr = params["errStr"],
	});	
end

-- @param text: string
-- @param scene: int
-- return bool
function WeChatService:sendText(text, scene)
	-- Logger.debug("sendText")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "sendText", {text, scene}, "(Ljava/lang/String;I)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "sendText", { text = text, scene = scene})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- @param imagePath: string
-- @param tagName: string
-- @param messageExt: int
-- @param messageAction: string
-- @param thumbImagePath: string
-- @param scene: scene
-- return bool
function WeChatService:sendImageData(imagePath, tagName, messageExt, messageAction, thumbImagePath, scene)
	-- Logger.debug("sendImageData")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local param = { 
			imagePath, 
			tagName, 
			messageExt, 
			messageAction, 
			thumbImagePath, 
			scene
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "sendImageData", param , "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local param = { 
			imagePath = imagePath, 
			tagName = tagName, 
			messageExt = messageExt, 
			messageAction = messageAction, 
			thumbImagePath = thumbImagePath, 
			scene = scene, 
		}
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "sendImageData", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- @param urlString: string
-- @param tagName: string
-- @param title: int
-- @param description: string
-- @param thumbImagePath: string
-- @param scene: scene
-- return bool
function WeChatService:sendLinkURL(urlString, tagName, title, description, thumbImagePath, scene)
	-- Logger.debug("sendLinkURL===========" .. urlString)
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local param = { 
			urlString, 
			tagName, 
			title, 
			description, 
			thumbImagePath, 
			scene
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "sendLinkURL", param, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local param = { 
			urlString = urlString, 
			tagName = tagName, 
			title = title, 
			description = description, 
			thumbImagePath = thumbImagePath, 
			scene = scene, 
		}
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "sendLinkURL", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end

-- 发送APP消息给微信
function WeChatService:sendAppContentData(extFilePath, extInfo, extUrl, title, description, thumbImagePath, messageExt, messageAction, scene)
	-- Logger.debug("sendLinkURL")
	if self:isEnabled() == false then return false end
	
	if device.platform == "android" then
		local param = { 
			extFilePath, 
			extUrl, 
			title,
			description, 
			thumbImagePath, 
			messageExt, 
			messageAction, 
			scene
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/wechat/WXLuaWrapper", "sendAppContentData", param, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	elseif device.platform == "ios" then
		local param = { 
			extFilePath = extFilePath, 
			extUrl = extUrl, 
			title = title,
			description = description, 
			thumbImagePath = thumbImagePath, 
			messageExt = messageExt, 
			messageAction = messageAction, 
			scene = scene, 
		}
		local ok, ret = luaoc.callStaticMethod("WXLuaWrapper", "sendAppContentData", param)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret ~= 0;
	end

	Macro.assetFalse(false);
end