-- local csbPath = "ui/csb/Redpack/UIRedpackDrawSucceed.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackDrawSucceed.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackDrawSucceed= class("UIRedpackDrawSucceed",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackDrawSucceed:ctor()
end


function UIRedpackDrawSucceed:init()

	self._imgHead = seekNodeByName(self, "Image_face", "ccui.ImageView")
	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, game.service.LocalPlayerService.getInstance():getIconUrl())
	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")




	self._btnConfirm = seekNodeByName(self, "Button_Confirm", "ccui.Button")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")

end	

function UIRedpackDrawSucceed:needBlackMask()
    return true
end

function UIRedpackDrawSucceed:closeWhenClickMask()
	return false
end
function UIRedpackDrawSucceed:onShow()	
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickClose), ccui.TouchEventType.ended)

	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):addEventListener("WITH_DRAW_SUCCEED", handler(self, self._onWithDrawSucceed), self); --处理活动消息
end

--提现成功
function UIRedpackDrawSucceed:_onWithDrawSucceed()
	UIManager:getInstance():show("UIRedpackVerify")
end


function UIRedpackDrawSucceed:_updateMoney()
	self._textMoney:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getWithDrawMoney())
end

function UIRedpackDrawSucceed:_updateLeftImages()
	local fHuMoney = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getFriendHuMoney()

end


function UIRedpackDrawSucceed:_onClickClose()
	UIManager:getInstance():hide("UIRedpackDrawSucceed")
end


return UIRedpackDrawSucceed
