local KEY_MING_GANG, KEY_AN_GANG = 'mingGang', 'anGang'
local CARD_GROUP_COUNT = 5
local GROUP_SURFACE_MAX_COUNT = 4
local Constants = require("app.gameMode.mahjong.core.Constants")
local PlayType = Constants.PlayType
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local ListFactory = require("app.game.util.ReusedListViewFactory")
local csbPath = 'ui/csb/Gold/UIGoldShareRoundResult.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIGoldShareRoundResult", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    super.ctor(self)
    self:playAnimation(csbPath, nil, true)
end

function M:init()
    self._btnBack = seekNodeByName(self, "Button_Back", "ccui.Button")
    local layoutBottom = seekNodeByName(self, "Layout_Bottom", "ccui.Layout")
    self._btnContinue = seekNodeByName(layoutBottom, "Button_Continue", "ccui.Button")
    self._btnShare = seekNodeByName(layoutBottom, "Button_Share", "ccui.Button")
    self._btnShareDaily = seekNodeByName(layoutBottom, "Button_Share_Daily_First", "ccui.Button")
    self._imgShareDailyTip = seekNodeByName(layoutBottom, "Image_Share_Daily_Tips", "ccui.ImageView")

    self._textTotalPoint = seekNodeByName(self, "BMFont_Total_Point", "ccui.TextBMFont")
    self._textHuType = seekNodeByName(self, "BMFont_Hu_Type", "ccui.TextBMFont")

    self._layoutMahjongCards = seekNodeByName(self, "Layout_Mahjong_Cards", "ccui.Layout")
    self._mahjongCardGroups = self:_initMahjongGroups(self._layoutMahjongCards)

    self._listView = ListFactory.get(seekNodeByName(self, "ListView_Score", "ccui.ListView"),
    handler(self, self._onListViewInit),
    handler(self, self._onListViewSetData))

    self:_registeCallback()
end

function M:_registeCallback()
    bindEventCallBack(self._btnBack, handler(self, self._onBtnBackClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnContinue, handler(self, self._onBtnContinueClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onBtnShareClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShareDaily, handler(self, self._onBtnShareDailyClick), ccui.TouchEventType.ended)
end

function M:_initMahjongGroups(container)
    local mahjongCardGroups = {}
    for groupIndex = 1, CARD_GROUP_COUNT, 1 do
        local group = {}
        local imgGroup = seekNodeByName(container, "ImageView_Group_" .. groupIndex, "ccui.ImageView")
        for surfaceIndex = 1, GROUP_SURFACE_MAX_COUNT, 1 do
            -- 可能找不到，不过不影响后续的赋值逻辑
            group['surface' .. surfaceIndex] = seekNodeByName(imgGroup, "ImageView_Surface_" .. surfaceIndex, "ccui.ImageView")
        end
        -- 加入gang的资源，如果有杠的话只需要做显隐处理即可，真正的牌面都加入到了surface中
        -- 可能找不到，不过不影响后续的赋值逻辑
        local imgMingGang = seekNodeByName(imgGroup, "ImageView_Ming_Gang", "ccui.ImageView")
        local imgAnGang = seekNodeByName(imgGroup, "ImageView_An_Gang", "ccui.ImageView")
        group[KEY_MING_GANG] = imgMingGang
        group[KEY_AN_GANG] = imgAnGang

        table.insert(mahjongCardGroups, group)
    end
    return mahjongCardGroups
end

function M:_getMahjongCardGroupDatas(handCards, operateCards)
    local operateDataArr = {} -- {key, value}
    local clonedHandCards = { unpack(handCards, 1, #handCards) }
    table.sort(clonedHandCards, function(a, b) return a < b end)

    local interestedOperatePlayType = {
        PlayType.OPERATE_AN_GANG,
        PlayType.OPERATE_GANG_A_CARD,
        PlayType.OPERATE_BU_GANG_A_CARD,
        PlayType.OPERATE_PENG_A_CARD,
        PlayType.OPERATE_CHI_A_CARD,
    }

    local collectOperates = {}
    for _, item in ipairs(operateCards) do
        if table.indexof(interestedOperatePlayType, item.playType) then
            table.insert(collectOperates, item)
        elseif item.playType == PlayType.OPERATE_HU then
            -- 胡牌的当做手牌看待，放入到手牌的最后一张
            table.insert(clonedHandCards, item.cards[1])
        end
    end
    --[[-
        cardGroupDatas 为长度为5的数组，对应5个group，如果没有吃碰杠，或者吃碰杠的个数少于4组，那么就用从手牌中移出去顶替
        顶替的方式是：3张一组去顶替
        index 1-4的group的长度应该是[3,4]，第4个表示杠的牌，如果为暗杠则第4个牌值为255
    ]]
    local cardGroupDatas = {}
    for i = 1, 4 do
        local cards = {}
        local operateCard = collectOperates[i]
        if operateCard then
            cards = operateCard.cards
            if operateCard.playType == PlayType.OPERATE_AN_GANG then
                cards[4] = 255
            end
        else
            cards = {
                table.remove(clonedHandCards, 1),
                table.remove(clonedHandCards, 1),
                table.remove(clonedHandCards, 1),
            }
        end
        table.insert(cardGroupDatas, cards)
    end
    table.insert(cardGroupDatas, clonedHandCards)
    return cardGroupDatas
end

-- cardGroupDatas 多组牌的数据
function M:_loadGroupSurfaces(cardGroupDatas)
    for groupIndex, cards in ipairs(cardGroupDatas) do
        local mahjongGroup = self._mahjongCardGroups[groupIndex]
        -- 牌面赋值
        for cardIndex, value in ipairs(cards) do
            if value ~= 255 then
                local skinPath = CardFactory:getInstance():getSurfaceSkin(value)
                if Macro.assertFalse(skinPath, 'get skin path failed, value = ' .. tostring(value)) then
                    local imgSurface = mahjongGroup["surface" .. cardIndex]
                    imgSurface:loadTexture(skinPath, ccui.TextureResType.plistType)
                end
            end
        end
        -- 杠的显示，只有index[1,4]的group有杠牌
        if groupIndex <= 4 then
            local mingGangVisiable = #cards == 4 and cards[4] ~= 255
            local anGangVisibale = #cards == 4 and cards[4] == 255
            mahjongGroup[KEY_MING_GANG]:setVisible(mingGangVisiable)
            mahjongGroup[KEY_AN_GANG]:setVisible(anGangVisibale)
        end
    end
end

function M:_convertBytes2Numbers(arugment)
    local fn = function(bytes)
        local ret = {}
        for i = 1, #bytes do
            local cardValue = string.byte(bytes, i)
            table.insert(ret, cardValue)
        end
        return ret
    end
    if arugment.handCards then
        arugment.handCards = fn(arugment.handCards)
    end

    if arugment.operateCards then
        for _, item in ipairs(arugment.operateCards) do
            item.cards = fn(item.cards)
        end
    end
end


function M:onShow()
    local shareData = game.service.GoldService.getInstance():getShareData()
    self:_convertBytes2Numbers(shareData)
    self._textHuType:setString(Constants.SpecialEvents.getName(shareData.huType))
    UtilsFunctions.setScore(self._textTotalPoint, shareData.totalPoint)

    self._listView:deleteAllItems()
    for _, item in ipairs(shareData.events) do
        self._listView:pushBackItem(item)
    end
    local cardGroupDatas = self:_getMahjongCardGroupDatas(shareData.handCards, shareData.operateCards)
    self:_loadGroupSurfaces(cardGroupDatas)
    -- 把计算好的值缓存下，下一个UI直接使用
    shareData.cardGroupDatas = cardGroupDatas
    game.service.GoldService.getInstance():setShareData(shareData)

    -- 是否是有奖分享
    local hasRemainShareTimes = false
    local goldService = game.service.GoldService:getInstance()
    if goldService then
        hasRemainShareTimes = goldService:getRemainShareLargeHuTimes() > 0
    end
    self._btnShareDaily:setVisible(hasRemainShareTimes)
    self._btnShare:setVisible(not hasRemainShareTimes)
end

function M:_onListViewInit(listItem)
    listItem.textType = seekNodeByName(listItem, "Text_Type", "ccui.Text")
    listItem.textScore = seekNodeByName(listItem, "Text_Score", "ccui.Text")
end

function M:_onListViewSetData(listItem, data)
    listItem.textType:setString(data.labelType)
    UtilsFunctions.setScore(listItem.textScore, data.labelScore)
end

function M:_onBtnBackClick(sender)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Gold_Click_Share_Large_Hu_Back)
    self:destroySelf()
end

function M:_onBtnContinueClick(sender)
    game.service.GoldService.getInstance():getQuickChargeHelper():onContinueMatch()
end

function M:_onBtnShareClick(sender)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Gold_Click_Share_Large_Hu_Normal)
    self:_startShare()
end

function M:_startShare()
    GameFSM:getInstance():enterState("GameState_Gold") -- 先切到金币场状态，可能因为 MahjongState 的原因导致切换状态UI被删除了。
    UIManager:getInstance():show("UIGoldShareRoundResult_ShareNode")
end

function M:_onBtnShareDailyClick(sender)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Gold_Click_Share_Large_Hu_Reward)
    self:_sendShareREQ()
    self:_startShare()
end

function M:_sendShareREQ()
    local goldService = game.service.GoldService:getInstance()
    if goldService then
        local times = goldService:getRemainShareLargeHuTimes()
        if times > 0 then
            goldService:delaySendShareRequest()
        end
    end
end


return M