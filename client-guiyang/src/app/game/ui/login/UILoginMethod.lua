local csbPath = "ui/csb/UILoginMethod.csb"
local super = require("app.game.ui.UIBase")
local UILoginMethod = class("UILoginMethod", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    登录方式
]]

function UILoginMethod:ctor()
end

function UILoginMethod:init()
    self._btnDingTalk = seekNodeByName(self, "Button_dingTalk", "ccui.Button") -- 钉钉
    self._btnPhone = seekNodeByName(self, "Button_phone", "ccui.Button") -- 手机登录
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")

    bindEventCallBack(self._btnDingTalk, handler(self, self._onDingTalkClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPhone, handler(self, self._onPhoneClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onCloseClick), ccui.TouchEventType.ended)
end

function UILoginMethod:onShow()
    self._btnDingTalk:setEnabled(true)
    game.service.LoginService.getInstance():getLoginDingTalkService():addEventListener("EVENT_DING_TALK_BUTTON_STATUS_CHAGE", function()
		self._btnDingTalk:setEnabled(true)
	end, self)
end

-- 钉钉登录
function UILoginMethod:_onDingTalkClick(sender)
    game.ui.UIMessageTipsMgr.getInstance():showTips("敬请期待")
	do return end   
    
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Login_DingTalk)
    sender:setEnabled(false)
    game.service.LoginService:getInstance():getLoginDingTalkService():loginDingTalk()
end

-- 手机号登录
function UILoginMethod:_onPhoneClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Login_Phone)
    UIManager:getInstance():show("UIPhoneLogin", game.globalConst.phoneMgr.phonelogin)
end

function UILoginMethod:_onCloseClick()
    UIManager:getInstance():destroy("UILoginMethod")
end

function UILoginMethod:onHide()
    game.service.LoginService.getInstance():getLoginDingTalkService():removeEventListenersByTag(self)
end

function UILoginMethod:needBlackMask()
	return true
end

function UILoginMethod:closeWhenClickMask()
	return false
end

return UILoginMethod