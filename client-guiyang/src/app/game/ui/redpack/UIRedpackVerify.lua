local csbPath = "ui/csb/Redpack/UIRedpackVerify.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackVerify= class("UIRedpackVerify",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackVerify:ctor()
end


function UIRedpackVerify:init()
	self._btnConfirm = seekNodeByName(self, "Button_Confirm", "ccui.Button")
	
end	

function UIRedpackVerify:needBlackMask()
    return true
end

function UIRedpackVerify:closeWhenClickMask()
	return false
end
function UIRedpackVerify:onShow()	
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickConfirm))
end

function UIRedpackVerify:_onClickConfirm()
	UIManager:getInstance():hide("UIRedpackVerify")
end

return UIRedpackVerify
