local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local MatchTicketListViewHandler = class("MatchTicketListViewHandler", super)
local UIItem = require("app.game.ui.element.UIItem")
local items = {
    [201] = {0x0F000007, 1},
    [203] = {0x0F000007, 5},
    [205] = {0x0F000007, 20},
    [206] = {0x0F000007, 50},
    [209] = {0x01000001, 1},
    [210] = {0x01000001, 10},
    [211] = {0x01000002, 1},
    [212] = {0x01000002, 10},
}


function MatchTicketListViewHandler:ctor(...)
    super.ctor(self, ...)
end

-- overwrite
function MatchTicketListViewHandler:onListViewItemSetData(listItem, oneLineData)
    for index, layout in ipairs(listItem.layouts) do
        local data = oneLineData[index]
        if data then
            layout.name:setString(data.goodName)
            -- layout.icon:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(data.goodId))
            layout.icon:setVisible(false)
            local item = UIItem.new(items[data.goodId][1],items[data.goodId][2])
            item:setPosition(layout.icon:getPosition())
            item:setPositionY(item:getPositionY() - 26)
            item:setScale(2.0)
            layout.name:getParent():addChild(item)
            layout.soldout:setVisible(false)
            --layout.connerTag:setVisible(false)
            layout.activityPriceLayout:setVisible(false)
            layout.normalPriceLayout:setVisible(true)
            layout.normalPriceLayout.price:setString(string.format("%s金豆", data.goodPrice))
        end
        layout:setVisible(data ~= nil)
    end
end


-- overwrite
function MatchTicketListViewHandler:onListViewItemSelected(lineNum, oneLineIndex)
    local index = self:getListViewOneLineCount() * (lineNum - 1) + oneLineIndex
    local data = self:getRawDataItemByIndex(index)

    local beanCount = game.service.LocalPlayerService.getInstance():getBeanAmount()

    local message = string.format(config.STRING.UISHOPNEW_STRING_101,
    data.goodPrice .. "金豆",
    data.goodName)

    game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(message, { "确定", "取消" }, function(value)
        game.service.MallService:submitOrder(data.goodId)
    end)
end

return MatchTicketListViewHandler