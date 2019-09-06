-- local csbPath = "ui/csb/Redpack/UIRedpackShareComplete.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackShareComplete.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackShareComplete= class("UIRedpackShareComplete",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

local strWords = {
	"art/activity/Redpack/z_1_chb.png",
	"art/activity/Redpack/z_2_chb.png",
	"art/activity/Redpack/z_4_chb.png"
}

function UIRedpackShareComplete:ctor()
end


function UIRedpackShareComplete:init()
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")
	self._btnShare = seekNodeByName(self, "Button_Share", "ccui.Button")
	self._imgWords = seekNodeByName(self, "Image_Word", "ccui.ImageView")
end	

function UIRedpackShareComplete:needBlackMask()
    return true
end

function UIRedpackShareComplete:closeWhenClickMask()
	return false
end
function UIRedpackShareComplete:_refreshWords()
	local idx = math.ceil( 3 * math.random() )
	self._imgWords:loadTexture(strWords[idx])
end
function UIRedpackShareComplete:onShow()	
	self:_refreshWords()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
end

function UIRedpackShareComplete:_onClickClose()
	UIManager:getInstance():hide("UIRedpackShareComplete")
	
end

function UIRedpackShareComplete:_onClickShare()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):doShare(function() self:_refreshWords() end)
end

return UIRedpackShareComplete
