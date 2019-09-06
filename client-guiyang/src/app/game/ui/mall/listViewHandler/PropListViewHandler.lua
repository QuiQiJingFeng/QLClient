local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local PropListViewHandler = class("PropListViewHandler", super)
--[[
    消耗类道具商城
]]
function PropListViewHandler:ctor(...)
    super.ctor(self, ...)
end

-- overwrite
function PropListViewHandler:onListViewItemSetData(listItem, oneLineData)
    
    for index, layout in ipairs(listItem.layouts) do
        local data = oneLineData[index]
        local icon = nil
        if data then
            layout.icon:setAnchorPoint(cc.p(0.5,0.5))
            layout.icon:setContentSize(cc.size(150,150))
            layout.icon:loadTexture("ui/art/function/img_none.png")    
            local dd = layout.icon,game.service.MallService:getInstance():getIconRes(data.goodId)        
            PropReader.setIconForNode(layout.icon,game.service.MallService:getInstance():getIconRes(data.goodId))
            layout.name:setString(data.goodName)
            layout.soldout:setVisible(false)
            --layout.connerTag:setVisible(false)

            layout.activityPriceLayout:setVisible(false)
            layout.normalPriceLayout:setVisible(true)
            layout.normalPriceLayout.price:setString("购买")
        end
        layout:setVisible(data ~= nil)
        bindEventCallBack(layout, function()
            self:onListViewItemSelected(layout, data)
        end, ccui.TouchEventType.ended)
    end
end

-- overwrite
function PropListViewHandler:onListViewItemSelected(layout, data)
    local goodInfo = data
    if goodInfo == nil then
        return
    end

    UIManager:getInstance():show("UIPurchaseSelect", goodInfo)
end

return PropListViewHandler