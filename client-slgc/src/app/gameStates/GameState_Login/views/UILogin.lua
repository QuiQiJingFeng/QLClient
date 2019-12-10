local csbPath = "ui/csb/mengya/UILogin.csb"
local UILogin = class("UILogin", game.UIBase, function() return game.Util:loadCSBNode(csbPath) end)
local LoginLogic = import("logics.LoginLogic")
local Util = game.Util
local UITipManager = game.UITipManager
local UIManager = game.UIManager
local GameFSM = game.GameFSM
function UILogin:ctor()
    game.EventCenter:on("EVENT_CONNECTION_VERIFYPASS",handler(self,self._onConnectionVerifyPass))
    game.EventCenter:on("login",handler(self,self._onLogin))
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
    UIManager:getInstance():show("UIUserProtocol")
end

function UILogin:_onBtnFixGame()
    UITipManager:getInstance():show("修复游戏")
end

function UILogin:_onBtnFeedBack()
    UITipManager:getInstance():show("在线客服")
end

function UILogin:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UILogin:isFullScreen()
    return true
end

function UILogin:onShow(...)
    self:playAnimation(csbPath,"login")
end

function UILogin:_onBtnLoginMoreClick()
    UIManager:getInstance():show("views.UILoginMore")
end

function UILogin:_onBtnWechatLoginClick()
    if not self._cbxAgree:isSelected() then
        return UITipManager:getInstance():show("请查阅用户协议")
    end
    -- GameFSM:getInstance():enterState("GameState_Lobby")

    
    game.NetWork:connect("127.0.0.1:8888")
end

function UILogin:_onConnectionVerifyPass()
    print("connect success")
    game.NetWork:send("login",{user_id = 10001,token="226729048d7752f63dc2afc0ada1be116c513382"},true)
end

function UILogin:_onLogin(responseMessage)
    dump(responseMessage,"FYD=====")
end

function UILogin:onHide()
    
end

return UILogin