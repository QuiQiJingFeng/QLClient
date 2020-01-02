local csbPath = "ui/csb/mengya/UILogin.csb"
local UILogin = class("UILogin", game.UIBase, function() return game.Util:loadCSBNode(csbPath) end)
local LoginLogic = import("logics.LoginLogic")
local Util = game.Util
local UITipManager = game.UITipManager
local UIManager = game.UIManager
local GameFSM = game.GameFSM
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
    -- self:playAnimation(csbPath,"login")
    local url = "https://lsjgame.oss-cn-hongkong.aliyuncs.com/%E5%B7%A5%E5%85%B7/%E7%99%BE%E5%BA%A6%E7%BD%91%E7%9B%98%E9%AB%98%E9%80%9F%E4%B8%8B%E8%BD%BD%E5%B7%A5%E5%85%B7_v2.0.5(1).zip"
    local savePath = "/Users/jingfeng/Desktop/QLClient/client-slgc/tools.zip"
    game.Downloader:downloadSingleFile(url,savePath,function(process) 
        print("FYD--->>process:",process)
        if process > 30 then
            return true
        end
    end)
    
end

function UILogin:_onBtnLoginMoreClick()
    UIManager:getInstance():show("views.UILoginMore")
end

function UILogin:_onBtnWechatLoginClick()
    if not self._cbxAgree:isSelected() then
        return UITipManager:getInstance():show("请查阅用户协议")
    end
    GameFSM:getInstance():enterState("GameState_Lobby")
end

function UILogin:onHide()
    
end

return UILogin