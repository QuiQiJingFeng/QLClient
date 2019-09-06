local csbPath = "ui/csb/Redpack/UIRedpackNewPlayer.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackNewPlayer= class("UIRedpackNewPlayer",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackNewPlayer:ctor()
end


function UIRedpackNewPlayer:init()
	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")
	self._btnTo = seekNodeByName(self, "Button_To", "ccui.Button")
end	

function UIRedpackNewPlayer:needBlackMask()
    return true
end

function UIRedpackNewPlayer:closeWhenClickMask()
	return false
end
function UIRedpackNewPlayer:onShow()
	self._textMoney:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getNewPlayerMoney())
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnTo, handler(self, self._onCLickTo), ccui.TouchEventType.ended)
end

function UIRedpackNewPlayer:_onClickClose()
	UIManager:getInstance():hide("UIRedpackNewPlayer")
end

function UIRedpackNewPlayer:_onCLickTo()
	UIManager:getInstance():hide("UIRedpackNewPlayer")
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
end
return UIRedpackNewPlayer
