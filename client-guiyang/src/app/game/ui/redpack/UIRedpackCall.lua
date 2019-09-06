-- local csbPath = "ui/csb/Redpack/UIRedpackCall.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackCall.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackCall= class("UIRedpackCall",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackCall:ctor()
end


function UIRedpackCall:init()

	self._textMyMoney = seekNodeByName(self, "BM_MyMoney", "ccui.TextBMFont")
	self._btnCall = seekNodeByName(self, "Button_Call", "ccui.Button")
end	

function UIRedpackCall:needBlackMask()
    return true
end

function UIRedpackCall:closeWhenClickMask()
	return true
end
function UIRedpackCall:onShow(data)

	local myMoney = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney()
	local moneyToDraw = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getWithdrawConfig()
	self._textMyMoney:setString("".. game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getOpenMoney())

	bindEventCallBack(self._btnCall,			handler(self, self._onClickCall),	ccui.TouchEventType.ended);
end


function UIRedpackCall:_onClickCall()
	UIManager:getInstance():show("UIRedpackShare", handler(self, self._onShareCompleted))
end

function UIRedpackCall:_onShareCompleted()
	UIManager:getInstance():hide("UIRedpackCall")
	UIManager:getInstance():show("UIRedpackFriends")
	UIManager:getInstance():show("UIRedpackShareComplete")
end

function UIRedpackCall:_onCLickTo()
	UIManager:getInstance():hide("UIRedpackCall")
	uiSkip.UISkipTool.skipTo(uiSkip.SkipType.redpack)
end
return UIRedpackCall
