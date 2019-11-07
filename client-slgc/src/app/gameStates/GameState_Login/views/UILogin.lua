local csbPath = "ui/csb/mengya/UILogin.csb"
local UILogin = class("UILogin", game.UIBase, function() return game.Util:loadCSBNode(csbPath) end)
local LoginLogic = import("logics.LoginLogic")
local Util = game.Util

function UILogin:ctor()
    
end

function UILogin:init()
    self._btnWechatLogin = Util:seekNodeByName(self,"btnWechatLogin","ccui.Button")
    self._cbxAgree = Util:seekNodeByName(self,"cbxAgree","ccui.CheckBox")
    self._btnLoginMore = Util:seekNodeByName(self,"btnLoginMore","ccui.Button")
    self._btnFeedback = Util:seekNodeByName(self,"btnFeedback","ccui.Button")
    self._btnFixGame = Util:seekNodeByName(self,"btnFixGame","ccui.Button")
    self._panelAgree = Util:seekNodeByName(self,"panelAgree","ccui.Layout")

    Util:bindTouchEvent(self._btnLoginMore,handler(self,self._onBtnLoginMoreClick))
    Util:bindTouchEvent(self._btnWechatLogin,handler(self,self._onBtnWechatLoginClick)) 
    Util:bindTouchEvent(self._btnFeedback,handler(self,self._onBtnFeedBack))
    Util:bindTouchEvent(self._btnFixGame,handler(self,self._onBtnFixGame))
    Util:bindTouchEvent(self._panelAgree,handler(self,self._onPanelAgreeClick))
end

function UILogin:_onPanelAgreeClick()
    game.UITipManager:getInstance():show("用户协议")
end

function UILogin:_onBtnFixGame()
    game.UITipManager:getInstance():show("修复游戏")
end

function UILogin:_onBtnFeedBack()
    game.UITipManager:getInstance():show("在线客服")
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
    game.UIManager:getInstance():show("views.UILoginMore")
end

function UILogin:_onBtnWechatLoginClick()
    if not self._cbxAgree:isSelected() then
        game.UITipManager:getInstance():show("请查阅用户协议")
    end
end

function UILogin:onHide()
    
end

return UILogin