-- local csbPath = "ui/csb/Redpack/UIRedpackOtherAward.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackOtherAward.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackOtherAward= class("UIRedpackOtherAward",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackOtherAward:ctor()
end


function UIRedpackOtherAward:init()

	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")
	self._imgHead = seekNodeByName(self, "Image_Head", "ccui.ImageView")
end	

function UIRedpackOtherAward:needBlackMask()
    return true
end

function UIRedpackOtherAward:closeWhenClickMask()
	return true
end
function UIRedpackOtherAward:onShow()
	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, game.service.LocalPlayerService.getInstance():getIconUrl())

	local invitees = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getInviteInfo()
	local num = #invitees > 3 and #invitees-3 or 0
	self._textMoney:setString("已领取"..num.."/10")

	bindEventCallBack(self._btnClose,			handler(self, self._onClickClose),	ccui.TouchEventType.ended);
end


function UIRedpackOtherAward:_onClickClose()
	UIManager:getInstance():hide("UIRedpackOtherAward")
end


return UIRedpackOtherAward
