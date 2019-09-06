local CurrencyHelper = require("app.game.util.CurrencyHelper")
local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local GoldListViewHandler = class("GoldListViewHandler", super)

local iconPath = {
    [301] = "art/mall/goodIcon/icon_gold1_mall.png",
    [302] = "art/mall/goodIcon/icon_gold2_mall.png",
    [303] = "art/mall/goodIcon/icon_gold3_mall.png",
    [304] = "art/mall/goodIcon/icon_gold4_mall.png",
    [305] = "art/mall/goodIcon/icon_gold5_mall.png",
    [306] = "art/mall/goodIcon/icon_gold6_mall.png",
    [307] = "art/mall/goodIcon/icon_gold7_mall.png",
    [308] = "art/mall/goodIcon/icon_gold8_mall.png",
}

function GoldListViewHandler:ctor(...)
    super.ctor(self, ...)
    self.currencyHelper = CurrencyHelper.getInstance()
end

-- overwrite
function GoldListViewHandler:onListViewItemSetData(listItem, oneLineData)
    for index, layout in ipairs(listItem.layouts) do
        local data = oneLineData[index]
        layout:setVisible(data ~= nil)
        if data then
            layout.icon:loadTexture(iconPath[data.goodId])
            layout.icon:ignoreContentAdaptWithSize(true)
            --self:_setItemTagTexture(layout.connerTag, index)
            layout.name:setString(data.goodName)
            layout.soldout:setVisible(false)
            layout.activityPriceLayout:setVisible(false)
            layout.normalPriceLayout:setVisible(true)
            layout.normalPriceLayout.price:setString(string.format("%s" .. PropReader.getNameById(data.payType), data.goodPrice))
        end
    end
end

-- overwrite
function GoldListViewHandler:onListViewItemSelected(lineNum, oneLineIndex)
    local index = self:getListViewOneLineCount() * (lineNum - 1) + oneLineIndex
    local data = self:getRawDataItemByIndex(index)

    local payTypeName = PropReader.getNameById(data.payType)
    -- 客户端不判断了
    -- local count = self.currencyHelper:getCurrencyCount(self.currencyHelper:getCurrencyTypeByPropId(data.payType))
    -- if count < data.goodPrice then
    --     game.ui.UIMessageBoxMgr.getInstance():show(payTypeName .. "不足，兑换失败!", { "确定" })
    --     return
    -- end

    local message = string.format(config.STRING.UISHOPNEW_STRING_101,
    data.goodPrice .. payTypeName,
    data.goodName)

    game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(message, { "确定", "取消" }, function(value)
        game.service.MallService.getInstance():submitOrder(data.goodId)
    end)
end

function GoldListViewHandler:_setItemTagTexture(iconTag, oneLineIndex)
    local isLineLastItem = oneLineIndex % self:getListViewOneLineCount() == 0
    if isLineLastItem then
        local lineNum = self:getCurrentSetDataLineNumber()
        if lineNum == 1 then
            iconTag:loadTexture("art/gold/icon_rx.png")
        elseif lineNum == 2 then
            iconTag:loadTexture("art/gold/icon_th.png")
        else
            iconTag:setVisible(false)
        end
    end
    iconTag:setVisible(isLineLastItem)
end


return GoldListViewHandler