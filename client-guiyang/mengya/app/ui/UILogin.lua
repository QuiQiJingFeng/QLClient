local csbPath = app.UILoginCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UILogin = class("UILogin", super, function() return app.Util:loadCSBNode(csbPath) end)

function UILogin:ctor()
    
end

function UILogin:init()
    self._btnWechatLogin = Util:seekNodeByName(self,"btnWechatLogin","ccui.Button")
    self._cbxAgree = Util:seekNodeByName(self,"cbxAgree","ccui.CheckBox")
    self._btnLoginMore = Util:seekNodeByName(self,"btnLoginMore","ccui.Button")
    self._btnFeekback = Util:seekNodeByName(self,"btnFeekback","ccui.Button")
    self._btnFixGame = Util:seekNodeByName(self,"btnFixGame","ccui.Button")

    Util:bindTouchEvent(self._btnLoginMore,handler(self,self._onBtnLoginMoreClick))
    Util:bindTouchEvent(self._btnWechatLogin,handler(self,self._onBtnWechatLoginClick))
end

function UILogin:getGradeLayerId()
    return 2
end

function UILogin:isFullScreen()
    return true
end

function UILogin:onShow(...)
    self:playAnimation(csbPath,"login")
end

function UILogin:_onBtnLoginMoreClick()
    UIManager:getInstance():show("UILoginMore")
end

function UILogin:_onBtnWechatLoginClick()
    UIManager:getInstance():show("UIMain")
end

function UILogin:onHide()

end

return UILogin