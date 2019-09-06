-- local csbPath = "ui/csb/Redpack/UIRedpackDetail.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackDetail.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackDetail= class("UIRedpackDetail",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackDetail:ctor()
end


function UIRedpackDetail:init()
	self._imgHead = seekNodeByName(self, "Image_Head", "ccui.ImageView")
	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭
	self._btnShare = seekNodeByName(self, "Button_Share", "ccui.Button")	--分享
end

function UIRedpackDetail:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
end

function UIRedpackDetail:needBlackMask()
    return true
end

function UIRedpackDetail:closeWhenClickMask()
	return false
end
function UIRedpackDetail:onShow()	

	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, game.service.LocalPlayerService.getInstance():getIconUrl())

	local myMoney = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney()
	local moneyToDraw = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getWithdrawConfig()
	self._textMoney:setString("已拆".. myMoney.."元")

	
	self:_registerCallBack()
	-- game.service.WeChatService:getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self._onShareCompleted))
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):addEventListener("EVENT_OPEN_REDPACKAGE", handler(self, self._onOpenSucceed), self)
end

--拆红包返回
function UIRedpackDetail:_onRedPackDetail()
	UIManager:getInstance():show("UIRedpackDetail")
end
--关闭
function UIRedpackDetail:_onClickClose()
	UIManager:getInstance():show("UIRedpackQuit", self)
end

function UIRedpackDetail:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end

function UIRedpackDetail:doHide()
	UIManager:getInstance():hide("UIRedpackDetail")
end
--规则
function UIRedpackDetail:_onClickShare()
	UIManager:getInstance():show("UIRedpackShare", handler(self, self._onShareCompleted))
end

function UIRedpackDetail:_onClickRule()
	UIManager:getInstance():show("UIRedpackHelp")
end
--分享完成
function UIRedpackDetail:_onShareCompleted()
	scheduleOnce(function() 
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryOpenRedPackage(2)
	end, 0.2, self)
end

function UIRedpackDetail:_onOpenSucceed()
	release_print("UIRedpackDetail_onOpenSucceed~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	UIManager:getInstance():hide("UIRedpackDetail")
	UIManager:getInstance():show("UIRedpackFriends")
	UIManager:getInstance():show("UIRedpackCall")
end
return UIRedpackDetail
