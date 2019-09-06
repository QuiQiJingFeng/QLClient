local CardFactory = require("app.gameMode.zhengshangyou.core.CardFactory_ZhengShangYou")
local CardDefines = require("app.gameMode.zhengshangyou.core.CardDefines_ZhengShangYou")
local ListViewFactory = require("app.game.util.ReusedListViewFactory")
local Card = require("app.gameMode.zhengshangyou.core.Card")
local SCALE = 0.8
local MARGIN = Card.MARGIN * SCALE * 0.8
local WIDTH = Card.WIDTH * SCALE
local HEIGHT = Card.HEIGHT * SCALE

local csbPath = "ui/csb/Paodekuai/UICardsInfo_Paodekuai.csb"
local UICardsInfo_ZhengShangYou = class("UICardsInfo_ZhengShangYou", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)

function UICardsInfo_ZhengShangYou:ctor()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._remainLayout = seekNodeByName(self, "Panel_Remain_Card", "ccui.Layout")
    self._remainLayout:retain()
    self._remainLayout:setVisible(false)
    self._uiCards = {}
    self._raw_listView = seekNodeByName(self, "ListView", "ccui.ListView")
    self._listView = ListViewFactory.get(self._raw_listView,
    handler(self, self._onListViewInit),
    handler(self, self._onListViewSetData),
    "UICardInfo_ZhengShangYou_ListView")
end

function UICardsInfo_ZhengShangYou:init()
    bindEventCallBack(self._btnClose, handler(self, self.dispose), ccui.TouchEventType.ended)
end

function UICardsInfo_ZhengShangYou:onShow(playersData, playersInfo, remainCards)
    for idx, playerInfo in ipairs(playersInfo) do
        local data = { info = playerInfo, cards = playersData[idx] }
        self._listView:pushBackItem(data)
    end

    -- 剩余的牌
    local startPosX = 20
    for idx, value in ipairs(remainCards) do
        local card = CardFactory:get(value, SCALE)
        table.insert(self._uiCards, card)
        self._remainLayout:addChild(card)
        card:setPosition(startPosX + MARGIN, HEIGHT * 0.5 - 5)
        startPosX = startPosX + MARGIN
    end

    -- 这里破坏了ReusedListView的结构，但应该不会影响代码的执行
    self._remainLayout:removeFromParent()
    self._raw_listView:pushBackCustomItem(self._remainLayout)
    local size = self._remainLayout:getContentSize()
    self._remainLayout:setContentSize(cc.size(size.width, HEIGHT))
end

function UICardsInfo_ZhengShangYou:_onListViewInit(listItem)
    local nodes = bindNodeToTarget(listItem)
    listItem.imgHead = seekNodeByName(listItem, "Image_Face", "ccui.ImageView")
    listItem.panelCardStart = seekNodeByName(listItem, "Panel_Hand_Card_Start", "ccui.Layout")
    listItem.textName = seekNodeByName(listItem, "Text_Name", "ccui.Text")
    listItem.panelCardStart:setVisible(false)
end

function UICardsInfo_ZhengShangYou:_onListViewSetData(listItem, data)
    local playerInfo = data.info
    local playerData = data.cards
    game.util.PlayerHeadIconUtil.setIcon(listItem.imgHead, playerInfo.iconUrl)
    listItem.textName:setString(kod.util.String.getMaxLenString(playerInfo.roleName, 8))

    -- 处理牌的数据
    local startPosX = listItem.panelCardStart:getPositionX()
    local y = listItem.panelCardStart:getPositionY()

    -- 对手牌排序
    local sorted_hand = playerData.handCards
    sorted_hand = CardDefines.sort(sorted_hand)

    -- 对打出的牌排序
    local outs, buffer = {}, {}
    for _, value in ipairs(playerData.outCards) do
        if value == -1 or value == 255 then
            buffer = CardDefines.sort(buffer)
            table.insert(buffer, 255)
            table.insertto(outs, buffer)
            buffer = {}
        else
            table.insert(buffer, value)
        end
    end
    local set = { outs, sorted_hand }
    -- local set = {
    --     {1,-1,2,-1,3,-1,4,-1,5,-1,6,-1,7,-1,8,-1,9,-1,10,-1,11,-1,12,-1,13,-1,14,-1,15,-1,16,-1,17}
    -- }
    for key, values in ipairs(set) do
        for idx, value in ipairs(values) do
            if value == -1 or value == 255 then
                startPosX = startPosX + MARGIN
            else
                local card = CardFactory:get(value)
                card:setScale(SCALE)
                listItem:addChild(card)
                card:setPosition(startPosX + MARGIN, y)
                startPosX = startPosX + MARGIN
            end
        end
        startPosX = startPosX + WIDTH
    end
end

function UICardsInfo_ZhengShangYou:onHide()
    self._listView:deleteAllItems()
    self._raw_listView:removeAllChildren()
end

function UICardsInfo_ZhengShangYou:dispose()
    self._remainLayout:release()
    UIManager:getInstance():destroy(self.class.__cname)
end

function UICardsInfo_ZhengShangYou:isFullScreen() return true end

return UICardsInfo_ZhengShangYou