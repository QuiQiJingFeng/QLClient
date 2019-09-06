local csbPath = "ui/csb/Activity/SpringFestivalInvited/Tips_NoChance.csb"
local super = require("app.game.ui.UIBase")
local UISpringFestivalNoEnoughChance = class("UISpringFestivalNoEnoughChance", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalNoEnoughChance:ctor()
    self._btnClose = nil
end

function UISpringFestivalNoEnoughChance:init()
    self._btnClose = seekNodeByName(self, "Button_1","ccui.Button")
    self._btnInvite = seekNodeByName(self, "Button_3", "ccui.Button")
    self._newBtnConfirm = seekNodeByName(self, "Button_3_0", "ccui.Button")
    self._text = seekNodeByName(self,"Text_1", "ccui.Text")

    self:_registerCallBack()
end

function UISpringFestivalNoEnoughChance:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite,   handler(self, self.onBtnInvited),  ccui.TouchEventType.ended)
    bindEventCallBack(self._newBtnConfirm,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
end

function UISpringFestivalNoEnoughChance:onShow(isNewPlayer)
    self._newBtnConfirm:setVisible(isNewPlayer)
    if isNewPlayer then
        self._btnInvite:setVisible(false)
        self._text:setString("您可以通过继续打牌获得拜财神的机会！")
    end
end

function UISpringFestivalNoEnoughChance:onHide()
    
end

function UISpringFestivalNoEnoughChance:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalNoEnoughChance");
end

function UISpringFestivalNoEnoughChance:onBtnInvited()
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.SPRING_INVITED)
    if service ~= nil then
        service:inviteFriend()
    end
end

function UISpringFestivalNoEnoughChance:needBlackMask()
    return true
end

return UISpringFestivalNoEnoughChance