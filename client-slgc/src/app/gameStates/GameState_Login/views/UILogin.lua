local csbPath = "ui/csb/mengya/UILogin.csb"
local UILogin = class("UILogin", game.UIBase, function() return game.Util:loadCSBNode(csbPath) end)
local LoginLogic = import("logics.LoginLogic")

function UILogin:ctor()
    
end

function UILogin:init()
    self._btnWechatLogin = game.Util:seekNodeByName(self,"btnWechatLogin","ccui.Button")
    self._cbxAgree = game.Util:seekNodeByName(self,"cbxAgree","ccui.CheckBox")
    self._btnLoginMore = game.Util:seekNodeByName(self,"btnLoginMore","ccui.Button")
    self._btnFeekback = game.Util:seekNodeByName(self,"btnFeekback","ccui.Button")
    self._btnFixGame = game.Util:seekNodeByName(self,"btnFixGame","ccui.Button")

    game.Util:bindTouchEvent(self._btnLoginMore,handler(self,self._onBtnLoginMoreClick))
    game.Util:bindTouchEvent(self._btnWechatLogin,handler(self,self._onBtnWechatLoginClick)) 
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

end

function UILogin:_onBtnWechatLoginClick()

end

function UILogin:onHide()
    
end

return UILogin