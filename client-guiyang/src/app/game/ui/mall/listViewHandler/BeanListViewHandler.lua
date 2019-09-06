local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ShopCostConfig = require("app.config.ShopCostConfig")
local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local BeanListHandler = class("BeanListHandler", super)

function BeanListHandler:ctor(...)
    super.ctor(self, ...)

    self.isPushData = false
    self.data = {
        {
            name = "10金豆",
            price = "1元",
            iconPath = "art/mall/goodIcon/icon_bean1_mall.png",
            chargeCount = 10,
        },
        {
            name = "60金豆",
            price = "6元",
            iconPath = "art/mall/goodIcon/icon_bean2_mall.png",
            chargeCount = 60,
        },
        {
            name = "120金豆",
            price = "12元",
            iconPath = "art/mall/goodIcon/icon_bean3_mall.png",
            chargeCount = 120,
        },
        {
            name = "300金豆",
            price = "30元",
            iconPath = "art/mall/goodIcon/icon_bean4_mall.png",
            chargeCount = 300,
        },
        {
            name = "600金豆",
            price = "60元",
            iconPath = "art/mall/goodIcon/icon_bean5_mall.png",
            chargeCount = 600,
        },
        {
            name = "1280金豆",
            price = "128元",
            iconPath = "art/mall/goodIcon/icon_bean6_mall.png",
            chargeCount = 1280,
        },
        {
            name = "3280金豆",
            price = "328元",
            iconPath = "art/mall/goodIcon/icon_bean7_mall.png",
            chargeCount = 3280,
        },
        {
            name = "6480金豆",
            price = "648元",
            iconPath = "art/mall/goodIcon/icon_bean8_mall.png",
            chargeCount = 6480,
        },
    }
end

-- overwrite
function BeanListHandler:onListViewPushDataEnd()
    super.onListViewPushDataEnd(self)
    self.isPushData = true
end

-- overwrite
function BeanListHandler:onListViewItemSetData(listItem, oneLineData)
    -- assert(false)
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
function BeanListHandler:onListViewItemSelected(lineNum, oneLineIndex)
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

    local index = self:getListViewOneLineCount() * (lineNum - 1) + oneLineIndex
    local data = self:getRawDataItemByIndex(index)
    if Macro.assertFalse(data.chargeCount, 'sell item must have charge count in config') then
        game.service.PaymentService.getInstance():queryPayType(CurrencyHelper.CURRENCY_TYPE.BEAN, data.chargeCount)
    end
end

-- overwrite
function BeanListHandler:setListViewData(rawData)
    if self.isPushData then
        return
    end
    -- 房卡的数据是固定的，不需要从外部获取
    super.setListViewData(self, self.data)
end

return BeanListHandler