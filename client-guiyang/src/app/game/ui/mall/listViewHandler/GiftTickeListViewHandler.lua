local MallUserDataSender = require("app.game.ui.mall.MallUserDataSender")
local super = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local GiftTicketListViewHandler = class("GiftTicketListViewHandler", super)
local UIItem = require("app.game.ui.element.UIItem")
local items = {
    [101] = {0x0F000002, 3},
    [102] = {0x0F000002, 10},
    [103] = {0x0F000008, 10},
    [104] = {0x0F000008, 100},
    [105] = {0x0F000007, 1},
    [107] = {0x0F000007, 10},
    [109] = {0x0F000003, 10000},
    [110] = {0x0F000003, 80000},
}


function GiftTicketListViewHandler:ctor(...)
    super.ctor(self, ...)
end

-- overwrite
function GiftTicketListViewHandler:onListViewItemSetData(listItem, oneLineData)
    
    for index, layout in ipairs(listItem.layouts) do
        local data = oneLineData[index]
        if data then
            -- layout.icon:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(data.goodId))
            layout.icon:setVisible(false)
            local item = UIItem.new(items[data.goodId][1],items[data.goodId][2])
            item:setPosition(layout.icon:getPosition())
            item:setPositionY(item:getPositionY() - 26)
            item:setScale(2.0)
            layout.name:getParent():addChild(item)
            layout.name:setString(data.goodName)
            layout.soldout:setVisible(false)
            --layout.connerTag:setVisible(false)

            layout.activityPriceLayout:setVisible(false)
            layout.normalPriceLayout:setVisible(true)
            layout.normalPriceLayout.price:setString(string.format("%s礼券", data.goodPrice))
        end
        layout:setVisible(data ~= nil)
        bindEventCallBack(layout, function()
            self:onListViewItemSelected(layout, data)
        end, ccui.TouchEventType.ended)
    end
end

-- overwrite
function GiftTicketListViewHandler:onListViewItemSelected(layout, data)
    local goodInfo = data
    if goodInfo == nil then
        return
    end

    if self:_checkBuyCondition(goodInfo) then
        self:_showBuyUI(goodInfo)
    end
end

function GiftTicketListViewHandler:_checkBuyCondition(goodInfo)
    if goodInfo.currentInventory == 0 then
        game.ui.UIMessageBoxMgr.getInstance():show("库存不足，兑换失败!", { "确定" })
        return false
    end

    if goodInfo.exchangeTimes ~= -1 and goodInfo.alreadyExchanged == goodInfo.exchangeTimes then
        game.ui.UIMessageBoxMgr.getInstance():show("今日领取已达上限，兑换失败!", { "确定" })
        return false
    end

    local ticketCount = game.service.LocalPlayerService.getInstance():getGiftTicketCount()
    if ticketCount < goodInfo.goodPrice then

        if config.UIGIFT_TICKET_STRING_100 ~= "" then
            game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UIGIFT_TICKET_STRING_100, { config.STRING.UIGIFT_TICKET_STRING_101, config.STRING.UIGIFT_TICKET_STRING_102 }, function()
                GameFSM.getInstance():enterState("GameState_Gold")
            end,
            function()
                game.service.CampaignService.getInstance():sendCCAFocusOnCampaignListREQ(game.globalConst.CampaignConst.START_WATCH_CAMPAIGN_LIST)
                UIManager:getInstance():destroy("UISuperMall")
            end,
            false,false,1,"提示",true
        )
        end
        return false
    end

    return true
end

function GiftTicketListViewHandler:_showBuyUI(goodInfo)
    MallUserDataSender.send(MallUserDataSender.ACTION_ENUM.WANTED, goodInfo.goodId)
    if goodInfo.isNeedAddress then
        UIManager:getInstance():show("UIMallReward_Address", goodInfo)
    else
        UIManager:getInstance():show("UIMallReward_Phone", goodInfo)
    end
end

function GiftTicketListViewHandler:_getGoodInfoByIndex(index)
    return self:getRawData()[index]
end


return GiftTicketListViewHandler