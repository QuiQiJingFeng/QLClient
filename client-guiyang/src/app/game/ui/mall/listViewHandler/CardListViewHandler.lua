local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ShopCostConfig = require("app.config.ShopCostConfig")
local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local CardListViewHandler = class("CardListViewHandler", super)

function CardListViewHandler:ctor(...)
    super.ctor(self, ...)

    self.isPushData = false
    self.data = {
        {
            name = string.format(config.STRING.UISUPER_MALL_STRING_100, 1),
            price = string.format(config.STRING.UISUPER_MALL_STRING_101, 3),
            iconPath = "art/mall/goodIcon/icon_fk1_mall.png",
            chargeCount = 1,
        },
        {
            name = string.format(config.STRING.UISUPER_MALL_STRING_100, 3),
            price = string.format(config.STRING.UISUPER_MALL_STRING_101, 8),
            iconPath = "art/mall/goodIcon/icon_fk2_mall.png",
            chargeCount = 3,
        },
        {
            name = string.format(config.STRING.UISUPER_MALL_STRING_100, 36),
            price = string.format(config.STRING.UISUPER_MALL_STRING_101, 88),
            iconPath = "art/mall/goodIcon/icon_fk3_mall.png",
            chargeCount = 36,
        },
        {
            name = string.format(config.STRING.UISUPER_MALL_STRING_100, 88),
            price = string.format(config.STRING.UISUPER_MALL_STRING_101, 188),
            iconPath = "art/mall/goodIcon/icon_fk4_mall.png",
            chargeCount = 88,
        },
    }

    -- 下面的代码只有潮汕会用到，以后会提成配置
    -- if device.platform == 'android' then
    --     self.data = {}
    --     self.listView.emptyText:setString(string.format("%s、游戏相关问题请加客服微信", CurrencyHelper.getInstance():getCurrencyZhName(CurrencyHelper.CURRENCY_TYPE.CARD)))
    -- else
    --     self.listView.emptyText:setString("")
    -- end
end

-- overwrite
function CardListViewHandler:onListViewPushDataEnd()
    super.onListViewPushDataEnd(self)
    self.isPushData = true
end

-- overwrite
function CardListViewHandler:onListViewItemSetData(listItem, oneLineData)
    for index, layout in ipairs(listItem.layouts) do
        local itemData = oneLineData[index]
        layout:setVisible(itemData ~= nil)
        if itemData then
            --layout.connerTag:setVisible(false)
            layout.icon:loadTexture(itemData.iconPath)
            layout.icon:ignoreContentAdaptWithSize(true)
            layout.name:setString(itemData.name)
            layout.soldout:setVisible(false)
            layout.activityPriceLayout:setVisible(false)
            layout.normalPriceLayout.price:setString(itemData.price)
        end
    end
end

-- overwrite
function CardListViewHandler:setListViewData(rawData)
    if self.isPushData then
        return
    end
    -- 房卡的数据是固定的，不需要从外部获取
    super.setListViewData(self, self.data)
end


-- overwrite
function CardListViewHandler:onListViewItemSelected(lineNum, oneLineIndex)
    local index = self:getListViewOneLineCount() * (lineNum - 1) + oneLineIndex
    local info = self.data[index]
    if info == nil then
        return
    end

    -- local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
    -- local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
    -- if Macro.assertTrue(SHOP_TYPE_COST == nil) then
    --     return
    -- end

    -- -- 4.1.6版本以下不支持新版内购
    -- if not game.service.IAPService.getInstance():isSupported() and device.platform ~= "android" then
    --     game.ui.UIMessageTipsMgr.getInstance():showTips("请更新为最新版本")
    --     return
    -- end

    -- local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
    -- local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
    -- if Macro.assertTrue(SHOP_TYPE_COST == nil) then
    --     return
    -- end

    local data = self:getRawDataItemByIndex(index)
    if Macro.assertFalse(data.chargeCount, 'sell item must have charge count in config') then
        -- game.service.PaymentService.getInstance():quickPay(CurrencyHelper.CURRENCY_TYPE.CARD, data.chargeCount)
        game.service.PaymentService.getInstance():queryPayType(CurrencyHelper.CURRENCY_TYPE.CARD, data.chargeCount)
    end
end

return CardListViewHandler