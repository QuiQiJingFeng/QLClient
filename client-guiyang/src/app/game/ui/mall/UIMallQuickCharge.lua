local csbPath = 'ui/csb/Mall/UIMallQuickCharge.csb'
local super = require("app.game.ui.UIBase")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ShopCostConfig = require("app.config.ShopCostConfig")
local M = class("UIMallQuickCharge", super, function() return kod.LoadCSBNode(csbPath) end)

function M:init()
    self._bmTextTitle = seekNodeByName(self, "BMFont_Title", "ccui.TextBMFont")
    self._textSlogan = seekNodeByName(self, "Text_Slogan", "ccui.Text")
    self._imgIconCenter = seekNodeByName(self, "Image_Icon_Center", "ccui.ImageView")
    self._bmTextCenter = seekNodeByName(self, "BMFont_Name", "ccui.TextBMFont")
    self._goodsIcon = seekNodeByName(self, "Icon", "ccui.ImageView")

    self._btnClose = UtilsFunctions.seekButton(self, "Button_Close", handler(self, self._onButtonCloseClick))
    self._btnAbandon = UtilsFunctions.seekButton(self, "Button_Abandon", handler(self, self._onButtonAbandonClick))
    self._btnBuy = UtilsFunctions.seekButton(self, "Button_Buy", handler(self, self._onButtonBuyClick))

    self._imgBuyIcon = seekNodeByName(self._btnBuy, "Icon", "ccui.ImageView")
    self._bmTextPrice = seekNodeByName(self._btnBuy, "BMFont_Price", "ccui.TextBMFont")
end

function M:onShow( ... )
    local args = { ... }
    local price = args[1]
    local goodId = args[2]

    local result = ShopCostConfig.calcCurrencyItNeeds("bean",price - game.service.LocalPlayerService.getInstance():getBeanAmount())
    -- self._cache = tbl
    self:_setTextsContent({currencyType = CurrencyHelper.CURRENCY_TYPE.BEAN,count = result.count, price = result.cost, goodId = goodId})
    -- self:_loadTexture(tbl)
    self._cache = {currencyType = CurrencyHelper.CURRENCY_TYPE.BEAN,count = result.count, price = result.cost, goodId = goodId}
end

function M:onHide()
end

function M:destroy()
end

function M:_setTextsContent(tbl)
    local currencyType = tbl.currencyType
    local count = tbl.count
    local price = tbl.price
    local goodId = tbl.goodId
    local zhName = CurrencyHelper.getInstance():getCurrencyZhName(currencyType)
    self._bmTextTitle:setString(string.format("%s不足", zhName))
    self._textSlogan:setString(string.format("推荐您购买%s数量，只要（%s元/%s%s）", count, price, count, zhName))
    self._bmTextCenter:setString(string.format("%sX%s", zhName, count))
    self._bmTextPrice:setString(price .. "元")
    self._goodsIcon:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(goodId))
end

function M:_loadTexture(tbl)
end

function M:_onButtonCloseClick(sender)
    self:hideSelf()
end

function M:_onButtonAbandonClick(sender)
    self:hideSelf()
end

function M:_onButtonBuyClick(sender)
    if self._cache == nil then
        return
    end

    local currencyType = self._cache.currencyType
    local chargeCount = self._cache.count

    game.service.PaymentService.getInstance():queryPayType(currencyType, chargeCount, {
        type =  net.protocol.PayType.QUICK_PAY,
        goodId = self._cache.goodId,
        activityId = 1
    })
end

function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

function M:needBlackMask()
	return true
end

return M