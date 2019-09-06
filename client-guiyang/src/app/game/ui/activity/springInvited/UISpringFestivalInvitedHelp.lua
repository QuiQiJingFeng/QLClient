local csbPath = "ui/csb/Activity/SpringFestivalInvited/hdsm.csb"
local super = require("app.game.ui.UIBase")
local UISpringFestivalInvitedHelp = class("UISpringFestivalInvitedHelp", super, function () return kod.LoadCSBNode(csbPath) end)

function UISpringFestivalInvitedHelp:ctor()
    self._btnClose = nil
end

function UISpringFestivalInvitedHelp:init()
    self._btnClose = seekNodeByName(self, "Button_1","ccui.Button")

    self:_registerCallBack()
end

function UISpringFestivalInvitedHelp:_registerCallBack()
    bindEventCallBack(self._btnClose,   handler(self, self._onBtnClose),  ccui.TouchEventType.ended)
end

function UISpringFestivalInvitedHelp:onShow()
    
end

function UISpringFestivalInvitedHelp:onHide()
    
end

function UISpringFestivalInvitedHelp:_onBtnClose()
    UIManager:getInstance():destroy("UISpringFestivalInvitedHelp");
end

function UISpringFestivalInvitedHelp:needBlackMask()
    return true
end

function UISpringFestivalInvitedHelp:closeWhenClickMask()
	return true
end

return UISpringFestivalInvitedHelp