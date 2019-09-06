-- local csbPath = "ui/csb/Redpack/UIRedpackWithDraw.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackWithDraw.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackWithDraw= class("UIRedpackWithDraw",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackWithDraw:ctor()
end


function UIRedpackWithDraw:init()

	self._imgHead = seekNodeByName(self, "Image_face", "ccui.ImageView")
	game.util.PlayerHeadIconUtil.setIcon(self._imgHead, game.service.LocalPlayerService.getInstance():getIconUrl())
	self._textMoney = seekNodeByName(self, "BMFont_Money", "ccui.TextBMFont")




	self._btnDraw1 = seekNodeByName(self, "Button_Draw1", "ccui.Button")
	self._btnDraw2 = seekNodeByName(self, "Button_Draw2", "ccui.Button")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")
	self._btnRule = seekNodeByName(self, "Button_Rule", "ccui.Button")
end	

function UIRedpackWithDraw:needBlackMask()
    return true
end

function UIRedpackWithDraw:closeWhenClickMask()
	return false
end
function UIRedpackWithDraw:onShow()	
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDraw1, handler(self, self._onClickDraw1), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnDraw2, handler(self, self._onClickDraw2), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRule, handler(self, self._onClickRule), ccui.TouchEventType.ended)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):addEventListener("WITH_DRAW_SUCCEED", handler(self, self._onWithDrawSucceed), self); --处理活动消息
	self:_updateLeftImages()
	self:_updateMoney()
end

--提现成功
function UIRedpackWithDraw:_onWithDrawSucceed()
	UIManager:getInstance():show("UIRedpackVerify")
	self:_updateMoney()
	self:_updateLeftImages()
	self:_updateRightImages()
end

function UIRedpackWithDraw:_onClickRule()
	UIManager:getInstance():show("UIRedpackHelp")
end

function UIRedpackWithDraw:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end

function UIRedpackWithDraw:_updateMoney()
	self._textMoney:setString(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney())

	-- UIManager:getInstance():show("UIRedpackVerify")
end

function UIRedpackWithDraw:_updateLeftImages()
	local fHuMoney = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getFriendHuMoney()

end


function UIRedpackWithDraw:_onClickClose()
	UIManager:getInstance():hide("UIRedpackWithDraw")
end


--分享完成
function UIRedpackFriends:_onShareCompleted()
	UIManager:getInstance():show("UIRedpackShareComplete")
end

function UIRedpackWithDraw:_onClickDraw1()
	local fHuMoney = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getFriendHuMoney()
	if fHuMoney ~= 0 then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryWithDraw(1, false)
	else
		game.ui.UIMessageBoxMgr.getInstance():show("好友胡牌才能领取哦\n,快去邀请吧~", {"叫好友胡牌"}, function()
			UIManager:getInstance():show("UIRedpackShare", handler(self, self._onShareCompleted))
		end)
	end
end

function UIRedpackWithDraw:_onClickDraw2()
    local moneyConfig = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getWithdrawConfig()[2]
	local money = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney()
	if money >= moneyConfig then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryWithDraw(game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney(), false)
	else
		UIManager:getInstance():show("UIRedpackWay")
	end
end
return UIRedpackWithDraw
