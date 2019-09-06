local csbPath = "ui/csb/Choujiang/UIJSDJ2.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UILuckyDrawToShop= class("UILuckyDrawToShop",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UILuckyDrawToShop:ctor()
end


function UILuckyDrawToShop:init()
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btnClose:addClickEventListener(handler(self, self._onClickClose))

	self._btnToShop = seekNodeByName(self, "Button_Buy", "ccui.Button")
	self._btnToShop:addClickEventListener(handler(self, self._onClickToShop))

	self._btnMode = seekNodeByName(self, "Button_Mode", "ccui.Button")
	self._btnMode:addClickEventListener(handler(self, self._onClickMode))

end


function UILuckyDrawToShop:needBlackMask()
    return true
end

function UILuckyDrawToShop:closeWhenClickMask()
	return false
end

function UILuckyDrawToShop:onShow(parent)
	self._parent = parent
	self._text = seekNodeByName(self, "Text_messagebox", "ccui.Text")
	self._textMoney = seekNodeByName(self, "Text_Money", "ccui.TextBMFont")
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostType() == 0x0F000001 then
		self._text:setString("您的金豆不足，请充值，或切换成房卡参与摇奖。")
		self._textMoney:setString("购买金豆")
	else
		self._text:setString("您的房卡不足，请充值，或切换成金豆参与摇奖。")
		self._textMoney:setString("购买房卡")
	end
end


--关闭
function UILuckyDrawToShop:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawToShop")
end
function UILuckyDrawToShop:_onClickToShop()
	if game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostType() == 0x0F000001 then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.LuckyDraw_ToBeanShop)
		CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.BEAN)
	elseif game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getCostType() == 0x0F000002 then		
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.LuckyDraw_ToCardShop)	
		CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.CARD)
	end
end

function UILuckyDrawToShop:_onClickMode()
	if self._parent and self._parent._onBoxMoney then
		self._parent:_onBoxMoney()
	end
	UIManager:getInstance():hide("UILuckyDrawToShop")
end
return UILuckyDrawToShop
