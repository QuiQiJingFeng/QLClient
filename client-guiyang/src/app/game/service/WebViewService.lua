--[[
WebView模块
--]]
local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local WebViewService = class("WebViewService")
ns.WebViewService = WebViewService

function WebViewService.getInstance()
	return manager.ServiceManager.getInstance():getWebViewService()
end

function WebViewService:ctor()	
end

-- 模块是否生效
function WebViewService:isEnabled()
	if not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled()
	end
end

-- 判断当前版本是否支持
function WebViewService:isSupported()
	if not game.plugin.Runtime.isEnabled() then
		-- 支持模拟器测试
		return true
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.1.2.0")
	return currentVersion:compare(supportVersion) >= 0
end

function WebViewService:isNewWebViewSDK()
    return ccexp.WebView.setAlertDialogText ~= nil
end

-- 初始化
function WebViewService:initialize()
	if device.platform == 'windows' then
		return
	end
    if self:isNewWebViewSDK() then
        return
    end
    if not self:isSupported() then
        return
    end
    -- 旧webview初始化
	if not self:isInitialized() then
	    self:setCallback(handler(self, self._onViewInitFinishedCallback))
	    self:setOverrideUrlList({"alipays:","alipay:","weixin:"})
	    --self:setOverrideUrlList()
	    self:_init()
	end
end

-- 卸载
function WebViewService:dispose()
	Logger.debug("[WebViewService] dispose")
end

-- 内部初始化
function WebViewService:_init()
	Logger.debug("[WebViewService] _init")
	if not self:isEnabled() then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "initialize")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false)
end

-- 设置回调
function WebViewService:setCallback(onViewInitFinishedCallback)
	Logger.debug("[WebViewService] setCallback,%s", tostring(onViewInitFinishedCallback))
	if not self:isEnabled() then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "setCallback", 
            {onViewInitFinishedCallback})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false)
end

-- 是否初始化成功
function WebViewService:isInitialized()
	Logger.debug("[WebViewService] isInitialized")
	if not self:isEnabled() then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "isInitialized", {},"()Z")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false)
end

-- 设置webview的黑名单
function WebViewService:setOverrideUrlList(overrideUrlListTab)
	Logger.debug("[WebViewService] setOverrideUrlList")
	if not self:isEnabled() then return false end
	if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.1.3.0")) < 0 then return false end

	if device.platform == "android" then

	    local overrideUrlList = ""
	    if overrideUrlListTab ~= nil then
		    overrideUrlList = json.encode(overrideUrlListTab)
	    end

		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "setOverrideUrlList", {overrideUrlList})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return true
	end
	
	Macro.assetFalse(false)
end

-- 获取webview的黑名单
function WebViewService:getOverrideUrlList()
	Logger.debug("[WebViewService] getOverrideUrlList")
	if not self:isEnabled() then return false end
	if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.1.3.0")) < 0 then return false end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "getOverrideUrlList", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return ""
	end
	
	Macro.assetFalse(false)
end

-- 打开WebView
function WebViewService:openWebView(url)
	Logger.debug("[WebViewService] openWebView,%s", tostring(url))
	if not self:isEnabled() then 
		cc.Application:getInstance():openURL(url)
		return false
	end
	
	if game.plugin.Runtime.getPlatform() == "ios" then
        self:_openWebView(url)
    elseif game.plugin.Runtime.getPlatform() == "android" and 
        Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.1.3.0")) >= 0 then
        self:_openWebView(url)
    else
        cc.Application:getInstance():openURL(url)
    end
end

-- 内部打开WebView
function WebViewService:_openWebView(url)
	Logger.debug("[WebViewService] _openWebView,%s", tostring(url))
	
    if self:isNewWebViewSDK() then
        self:_openAGTWebViewNew(url)
        return true
    end

	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/webview/WebViewLuaWrapper", "openWebView",
            {url},"(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("WebViewLuaWrapper", "openWebView", {url = url})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false)
end

function WebViewService:_onViewInitFinishedCallback(result)
	if device.platform == "android" then
		--game.ui.UIMessageTipsMgr.getInstance():showTips("初始化完成，初始化结果：" .. tostring(result))
		Logger.debug("[WebViewService] _onViewInitFinishedCallback,%s", tostring(result))
	end
end


local WEBVIEW_PORTRAIT_TITLEBAR = 2
function WebViewService:_openAGTWebViewNew(url)
    local webView = ccexp.WebView:create(WEBVIEW_PORTRAIT_TITLEBAR)
    webView:setVisible(false)
    webView:setScalesPageToFit(true)
    webView:setOnDidFinishLoading(function(sender, url)
		Logger.debug("[WebViewService] didFinishLoading, %s", url)
    end)
    webView:setOnDidFailLoading(function(sender, url)
		Logger.debug("[WebViewService] didFailLoading, %s", url)
    end)
    webView:loadURL(url)
    cc.Director:getInstance():getRunningScene():addChild(webView)
    webView:setVisible(true)
end