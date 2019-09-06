local h5sdk = class("h5sdk")

cc.exports.h5sdk = h5sdk -- 到处到_G下

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
    self._loading = false
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

-- 登陆
function h5sdk:login(key)
    if self._loading then
        return
    end
    self._net:setAccessTokenCallback(function(isSuccess, url)
        -- 登陆成功
        if isSuccess then
            -- 如果新版接口，那么不创建横屏的
            self._gameWebView = self:_createGameWebView(url, not self:isSupport())
            self._net:gameStarted(url)
        end
    end)
    -- appkey,现在写死在这里了，如果有配置需求，自行添加配置处理
    self._net:sendCGQueryH5AccessTokenREQ(key)
   
end

-- h5的回调
function h5sdk:_onJavascriptCustomEvent(sender, paramStr)
    local realStr = string.urldecode(paramStr)
    local newStr = string.sub(realStr, string.len("loho://?") + 1)
    local params = json.decode(newStr)
    local jscmd = params["cmd"]
    local args = params["args"]
    if jscmd == "pay" then
        -- 测试，发送请求相关消息
        self._net:setPaymentCallback(function(isSuccess, url)
            if not isSuccess or url == "" then
                self._gameWebView:evaluateJS("alert(\"支付失败("..tostring(isSuccess)..","..tostring(url)..")\");")
                return
            end
            if self:_isIOSNewPaymentLogic() then
                self:_doPaymentIOSNew(url)
            else
                self:_doPayment(url)
            end
            self._gameWebView:evaluateJS(string.format("%s(%s,%s)", params["dispatcher"], params["callbackId"], "{status: 2}"))
        end)
        local prepayId = args["prepayId"]
        print("========> newStr", newStr)
        print("========> prepayId", prepayId)
        if prepayId == "" then
            self._gameWebView:evaluateJS("alert(\"支付失败(prepayId)\");")
            return
        end
        self._net:sendCGQueryH5PayUrlREQ(prepayId)
    elseif jscmd == "closeWebView" then
        self:_destroyH5Game()
        manager.AudioManager.getInstance():resumeMusic()
        self._net:gameExited()
    elseif jscmd == "reportData" then
        self._net:sendBILog(args)
    end
end

-- 加载游戏用的webview
function h5sdk:_createGameWebView(url, isLandscape)
    if not self:isEnabled() then return end

    self._loading = true

    -- 如果已经开启了的话，先暂定清空，重新创建
    if self._gameWebView then
        self._gameWebView:removeFromParent()
        self._gameWebView = nil
    end

    local webView
    if isLandscape then
        webView = self:_createWebView(WEBVIEW_NORMAL)
        webView:setContentSize(cc.size(display.width, display.height))
        webView:setPosition(display.cx, display.cy)
    else
        webView = self:_createWebView(WEBVIEW_PORTRAIT_FULLSCREEN)
    end
    if device.platform == "android" then
        webView:setVisible(false)
    end
    print("dispatchGlobalEvent~~~~~EVENT_BUSY_RETAIN")
    game.ui.UIMessageTipsMgr.getInstance():showTips("加载中，请稍候...", 5)
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
        self._loading = false
        print("网页加载完成 " .. url)
        if not self._initialized then
            self._initialized = true 
            if device.platform == "android" then           
                webView:setVisible(true)           
            end 
            manager.AudioManager.getInstance():pauseMusic()
        end
    end)
    webView:setOnDidFailLoading(function(sender, url)
        self._loading = false
        print("网页加载失败 " .. url)
    end)

    webView:loadURL(url)
    -- 更新alert 提示内容
    if ccexp.WebView.setAlertDialogText then
        webView:setAlertDialogText("提示","","")
    end
    cc.Director:getInstance():getRunningScene():addChild(webView)
    return webView
end


-- 支付webview，现在只用来拉取微信支付的网页
function h5sdk:_doPayment(url)
    if not self._paymentWebView then
        local webView = self:_createWebView(WEBVIEW_NORMAL)
        webView:setContentSize(cc.size(0, 0))
        webView:setOnDidFinishLoading(function(sender, url)
            print("PaymentWebView:done: " .. url)
        end)
    	webView:setOnDidFailLoading(function(sender, url)
	    	print("PaymentWebView:failed: " .. url)
    	end)
        webView:setVisible(false)
        cc.Director:getInstance():getRunningScene():addChild(webView)
        self._paymentWebView = webView
    end
    print("_paymentWebView:loadURL: ".. url)
    self._paymentWebView:loadURL(url)
end


local TIME_MAX_IOS_PAYMENT_WAITING = 10

function h5sdk:_onEnterBackground()
    self:_doneWaitingIOSPayment()
end

function h5sdk:_showIOSPaymentWebView()
    if self._timeoutIOSPaymentTask then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeoutIOSPaymentTask)
        self._timeoutIOSPaymentTask = nil
    end
    self._paymentWebView:setVisible(true)
    self._gameWebView:setVisible(false)
end

function h5sdk:_doneWaitingIOSPayment()
    if self._waitingIOSPayment then    
        self._waitingIOSPayment = false
        if self._timeoutIOSPaymentTask then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timeoutIOSPaymentTask)
            self._timeoutIOSPaymentTask = nil
        end
        self._gameWebView:setVisible(true)
        self._paymentWebView:setVisible(false) 
    end           
end

function h5sdk:_doPaymentIOSNew(url)
    if not self._paymentWebView then
        local webView = self:_createWebView(WEBVIEW_NORMAL)
        webView:setContentSize(cc.size(display.width, display.height))
        webView:setPosition(display.cx, display.cy)
        webView:setOnDidFinishLoading(function(sender, url)
            print("PaymentWebView:done: " .. url)        
        end)
        webView:setOnDidFailLoading(function(sender, url)
            print("PaymentWebView:failed: " .. url)
        end)
        webView:setVisible(false)
        cc.Director:getInstance():getRunningScene():addChild(webView)
        self._paymentWebView = webView
    end
    
    self:_showIOSPaymentWebView()
    
    self._timeoutIOSPaymentTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:_doneWaitingIOSPayment()
    end, TIME_MAX_IOS_PAYMENT_WAITING, false)

    print("_paymentWebView:loadURL: ".. url)
    self._paymentWebView:loadURL(url)
    self._waitingIOSPayment = true
end