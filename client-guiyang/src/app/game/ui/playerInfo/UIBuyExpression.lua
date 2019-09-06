local csbPath = "ui/csb/UIBuyExpression.csb"
local super = require("app.game.ui.UIBase")
local ShopCostConfig = require("app.config.ShopCostConfig")
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local UIBuyExpression = class("UIBuyExpression", super, function () return kod.LoadCSBNode(csbPath) end)

--[[
	该购买目前只支持金豆
]]

function UIBuyExpression:ctor()
	self._count = 0
end

function UIBuyExpression:init()
	self._imgIcon = seekNodeByName(self, "Image_icon", "ccui.ImageView")
	self._textContent = seekNodeByName(self, "Text_Content", "ccui.Text")
	self._textCount = seekNodeByName(self, "Text_count", "ccui.Text")
	self._textPrice = seekNodeByName(self, "Text_price", "ccui.Text")

	self._btnBuy = seekNodeByName(self, "Button_buy", "ccui.Button")
	self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
	self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button")

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnQuit, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnBuy, handler(self, self._onClickBuy), ccui.TouchEventType.ended)
end

function UIBuyExpression:_onClickClose()
	UIManager:getInstance():destroy("UIBuyExpression")
end

function UIBuyExpression:onShow(id)
	local expressionInfo = game.service.ChatService.getInstance():getExpressionInfo(id)
	
	self._imgIcon:loadTexture(PropReader.getIconById(expressionInfo.costId))
	self._textContent:setString(string.format("立刻购买%s,表情任性发!", PropReader.getNameById(expressionInfo.costId)))

	-- 相差多少金豆
	self._count = ShopCostConfig.calcCurrencyItNeeds("", expressionInfo.count - game.service.LocalPlayerService.getInstance():getBeanAmount())
	self._textCount:setString(string.format("数量:%s%s", self._count.count, PropReader.getNameById(expressionInfo.costId)))
	self._textPrice:setString(string.format("价格:%s元", self._count.cost))
end

function UIBuyExpression:_onClickBuy()
	game.service.PaymentService.getInstance():queryPayType(CurrencyHelper.CURRENCY_TYPE.BEAN, self._count.count)
end

function UIBuyExpression:needBlackMask()
	return false
end

function UIBuyExpression:closeWhenClickMask()
	return false
end

function UIBuyExpression:onHide()
end

return UIBuyExpression