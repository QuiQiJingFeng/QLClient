local h5login = class("h5login")

local WEBVIEW_NORMAL = 0
local WEBVIEW_PORTRAIT_FULLSCREEN = 1
local WEBVIEW_PORTRAIT_TITLEBAR = 2
print = release_print

function h5login:ctor()
    self._paymentWebView = nil
    self._loginWebView = nil
    self._isDingTalk = false
end

function h5login:initialize()
end

function h5login:dispose()
    self:_destroyH5Game()
end

function h5login:isEnabled()
    return device.platform ~= "windows"
end

-- runtime 是否支持新牌接口
function h5login:isSupport()
    return ccexp.WebView and ccexp.WebView.setAlertDialogText ~= nil
end

function h5login:_destroyH5Game()
    print("_destroyH5Game")
    -- 关闭界面
    UIManager:getInstance():destroy("UIH5Login")
    if self._loginWebView then
        self._loginWebView:removeFromParent()
        self._loginWebView = nil
    end

    self._initialized = false
    self._callback = nil
end

function h5login:_createWebView(tp)
    if self:isSupport() then
        return ccexp.WebView:create(tp)
    else
        return ccexp.WebView:create()
    end
end

-- 登陆
--[[
    @param callback 成功后的返回
]]
function h5login:login(callback)
    self._width = nil
    self._isDingTalk = true
    self._callback = callback
    -- 登陆成功
    local ding = config.UrlConfig.getDingTalkParameter(game.service.LocalPlayerService.getInstance():getArea())
    local url = "https://oapi.dingtalk.com/connect/oauth2/sns_authorize?appid="..ding.appid.."&response_type=code&scope=snsapi_login&state=state+&redirect_uri=".. ding.redirect_uri
    -- 横屏登陆
    self._loginWebView = self:_createLoginWebView(url, true)
end

function h5login:showWebView(url, width, callback)
    self._width = width
    self._isDingTalk = false
    self._callback = callback
    self._loginWebView = self:_createLoginWebView(url, true)
end

function h5login:_handlerOnShouldStartLoading(sender, url)
    local scheme = string.match(url, "^([%w][%w%+%-%.]*)%:")
    if scheme == "http" or scheme == "https" then
        return true
    end
    if scheme == "loho" then
        local realStr = string.urldecode(url)
        local newStr = string.sub(realStr, string.len("loho://?") + 1)
        local params = json.decode(newStr)
        -- {"code":"42f50e18086e3ded80e3d8ce7ec55795","state":"state"}
        if self._callback then
            self._callback(params, newStr)
        end
        self:_destroyH5Game()
    end
    return false
end

-- 加载游戏用的webview
function h5login:_createLoginWebView(url, isLandscape)
    if not self:isEnabled() then return end

    -- 如果已经开启了的话，先暂定清空，重新创建
    if self._loginWebView then
        self._loginWebView:removeFromParent()
        self._loginWebView = nil
    end

    local webView
    if isLandscape then
        webView = self:_createWebView(WEBVIEW_NORMAL)
        local width_real = self._width and self._width or 860/1136*display.width
        webView:setContentSize(cc.size(width_real, display.height))
        -- webView:setContentSize(900,640)
        webView:setPosition(display.cx, display.cy)
    else
        webView = self:_createWebView(WEBVIEW_PORTRAIT_FULLSCREEN)
    end

    webView:setVisible(false)
    webView:setScalesPageToFit(false)

    webView:setOnShouldStartLoading(handler(self, self._handlerOnShouldStartLoading))
    -- webView:setJavascriptInterfaceScheme("loho")
    webView:setOnDidFinishLoading(function(sender, url)
        print("网页加载完成 " .. url)
        if not self._initialized then
            self._initialized = true
            webView:setVisible(true)
            -- 注册界面回调
            UIManager:getInstance():show("UIH5Login", function()
                if self._isDingTalk and game.service.LoginService.getInstance():getLoginDingTalkService() then
                    game.service.LoginService.getInstance():getLoginDingTalkService():dispatchEvent({ name = "EVENT_DING_TALK_BUTTON_STATUS_CHAGE" })
                end
                self:_destroyH5Game()
            end)
        end
    end)
    webView:setOnDidFailLoading(function(sender, url)
        print("网页加载失败 " .. url)
    end)

    webView:loadURL(url)
    cc.Director:getInstance():getRunningScene():addChild(webView)
    return webView
end

return h5login