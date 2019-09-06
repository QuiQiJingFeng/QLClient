local h5sdk = class("h5sdk")

cc.exports.yearWebView = h5sdk -- 到处到_G下

-- 单例支持
h5sdk._instance = nil

function h5sdk.getInstance()
    if nil == h5sdk._instance then
        h5sdk._instance = h5sdk:new()
        h5sdk._instance:initialize()
    end
    return h5sdk._instance;
end

local netservice = import(".netservice")
local WEBVIEW_NORMAL = 0
local WEBVIEW_PORTRAIT_FULLSCREEN = 1
local WEBVIEW_PORTRAIT_TITLEBAR = 2
--print = release_print

function h5sdk:ctor()
    self._net = netservice.new()
    self._paymentWebView = nil
    self._gameWebView = nil
    self._listenerEnterBackground = nil
    self._timeoutIOSPaymentTask = nil
end

function h5sdk:initialize()
    self._net:initialize()
    if self:_isIOSNewPaymentLogic() then
        self._listenerEnterBackground = listenGlobalEvent("EVENT_APP_DID_ENTER_BACKGROUND", handler(self, self._onEnterBackground))
    end
end

function h5sdk:dispose()
	if self._listenerEnterBackground then
		unlistenGlobalEvent(self._listenerEnterBackground)
		self._listenerEnterBackground = nil
	end

    if self._timeoutIOSPaymentTask then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeoutIOSPaymentTask)
        self._timeoutIOSPaymentTask = nil
    end

    self._net:dispose()
    self:_destroyH5Game()
end

function h5sdk:isEnabled()
    return device.platform ~= "windows"
end

-- runtime 是否支持新牌接口
function h5sdk:isSupport()
    return ccexp.WebView.setAlertDialogText ~= nil
end

-- 解决iOS12+WKWebView无法拉起微信支付的新逻辑
function h5sdk:_isIOSNewPaymentLogic()
    return device.platform == "ios" and ccexp.WebView.setAlertDialogText ~= nil
end


function h5sdk:_destroyH5Game()
    print("_destroyH5Game")
    if self._gameWebView then
        self._gameWebView:removeFromParent()
        self._gameWebView = nil
    end

    if self._paymentWebView then
        self._paymentWebView:removeFromParent()
        self._paymentWebView = nil
    end

    self._initialized = false
end

function h5sdk:_createWebView(tp)
    if self:isSupport() then
        return ccexp.WebView:create(tp)
    else
        return ccexp.WebView:create()
    end
end

-- h5的回调
function h5sdk:_onJavascriptCustomEvent(sender, paramStr)
    local realStr = string.urldecode(paramStr)
    local newStr = string.sub(realStr, string.len("loho://?") + 1)
    local params = json.decode(newStr)
    local jscmd = params["cmd"]
    local args = params["args"]
    if jscmd == "closeWebView" then
        self:_destroyH5Game()
        manager.AudioManager.getInstance():resumeMusic()
        self._net:gameExited()
    elseif jscmd == "shareNianbao" then
        local strUrl = config.UrlConfig.getYearReportUrl()
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.share_nianbao)
        kod.getShortUrl.doGet(strUrl, function(shortUrl, bSuccess)
            local data = {{url = shortUrl,shareInfo = "原来，我的聚友年度战绩是这样的...", shareContent = "点击查看，我的聚友年度报告！"}}
            share.ShareWTF:getInstance():share(share.constants.ENTER.NIAN_BAO, data, function()  end)
        end)
    end
end

-- 加载游戏用的webview
function h5sdk:createWebView(url)
    if not self:isEnabled() then return end

    -- 如果已经开启了的话，先暂定清空，重新创建
    if self._gameWebView then
        self._gameWebView:removeFromParent()
        self._gameWebView = nil
    end

    local webView = self:_createWebView(WEBVIEW_PORTRAIT_TITLEBAR)



    -- webView:setVisible(false)
    -- game.ui.UIMessageBoxMgr.getInstance():show("1111111111111111111111", {"确定"})
    webView:setScalesPageToFit(true)

    webView:setOnShouldStartLoading(function(sender, url)
        local scheme = string.match(url, "^([%w][%w%+%-%.]*)%:")
        if scheme == "http" or scheme == "https" then
            return true
        end
        if scheme == "loho" then
            -- 如果runtime 不支持，那么将由此处发起调用
            if not self:isSupport() then
                self:_onJavascriptCustomEvent(sender, url)
            end
        end
        return false
    end)

    -- 如果runtime 支持新的调用方式
    if self:isSupport() then
        webView:setJavascriptInterfaceScheme("loho")
        webView:setOnJSCallback(handler(self, self._onJavascriptCustomEvent))
    end
   
    webView:setOnDidFinishLoading(function(sender, url)
        print("网页加载完成 " .. url)
        if not self._initialized then
            self._initialized = true            
            webView:setVisible(true)            
            manager.AudioManager.getInstance():pauseMusic()
        end
    end)
    webView:setOnDidFailLoading(function(sender, url)
        print("网页加载失败 " .. url)
    end)
    -- game.ui.UIMessageBoxMgr.getInstance():show(url, {"确定"})
    webView:loadURL(url)
    -- 更新alert 提示内容
    if ccexp.WebView.setAlertDialogText then
        webView:setAlertDialogText("提示","","")
    end
    cc.Director:getInstance():getRunningScene():addChild(webView)
    return webView
end



