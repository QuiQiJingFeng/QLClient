-- local csbPath = "ui/csb/Redpack/UIRedpackWay.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackWay.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackWay= class("UIRedpackWay",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackWay:ctor()
end


function UIRedpackWay:init()

	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")


	self._btnInvite1 = seekNodeByName(self, "Button_Invite", "ccui.Button")
	self._btnInvite2 = seekNodeByName(self, "Button_Invite2", "ccui.Button")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")
end	

function UIRedpackWay:needBlackMask()
    return true
end

function UIRedpackWay:closeWhenClickMask()
	return false
end
function UIRedpackWay:onShow()	
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnInvite1, handler(self, self._onClickInvite), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnInvite2, handler(self, self._onClickInvite), ccui.TouchEventType.ended)

	self:_updateMoney()
end

function UIRedpackWay:_updateMoney()
	self._textMoney:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney())
end

function UIRedpackWay:_onClickClose()
	UIManager:getInstance():hide("UIRedpackWay")
end

function UIRedpackWay:_onClickInvite()
	UIManager:getInstance():show("UIRedpackShare", handler(self, self._shareComplete))
end

function UIRedpackWay:_shareComplete()
	UIManager:getInstance():show("UIRedpackShareComplete")
end
return UIRedpackWay
