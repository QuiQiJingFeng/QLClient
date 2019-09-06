local csbPath = app.UILoginMoreCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UILoginMore = class("UILoginMore", super, function() return app.Util:loadCSBNode(csbPath) end)

--[[
    登录方式
]]

function UILoginMore:ctor()
end

function UILoginMore:init()
    -- 钉钉
    self._btnDingTalk = Util:seekNodeByName(self, "btnDingTalk", "ccui.Button")
    -- 手机登录
    self._btnPhone = Util:seekNodeByName(self, "btnPhone", "ccui.Button")
    --关闭
    self._btnClose = Util:seekNodeByName(self, "btnClose", "ccui.Button")

    Util:bindTouchEvent(self._btnDingTalk, handler(self, self._onDingTalkClick))
    Util:bindTouchEvent(self._btnPhone, handler(self, self._onPhoneClick))
    Util:bindTouchEvent(self._btnClose, handler(self, self._onCloseClick))
end

function UILoginMore:onShow()

end

-- 钉钉登录
function UILoginMore:_onDingTalkClick(sender)
    app.UITipManager:getInstance():show("敬请期待")
end

-- 手机号登录
function UILoginMore:_onPhoneClick()
    UIManager:getInstance():show("UIPhoneLogin")
end

function UILoginMore:_onCloseClick()
    UIManager:getInstance():destroy("UILoginMore")
end

function UILoginMore:onHide()
    
end

function UILoginMore:needBlackMask()
	return true
end

function UILoginMore:closeWhenClickMask()
	return false
end

return UILoginMore