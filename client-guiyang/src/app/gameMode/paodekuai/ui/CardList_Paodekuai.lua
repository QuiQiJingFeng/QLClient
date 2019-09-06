--[[    使用层处理触摸时，layout(或者任何其他控件)会率先触发触摸事件并且吞噬掉，导致层的触摸逻辑不触发
    处理方式：将layout的触摸禁用
]]
local Card = require("app.gameMode.paodekuai.core.Card")
local CardDefines = require("app.gameMode.paodekuai.core.CardDefines_Paodekuai")
local CardFactory = require "app.gameMode.paodekuai.core.CardFactory_Paodekuai"
local TipsHelper = require("app.gameMode.paodekuai.utils.TipsHelper")
local SCALE = 1.5
local WIDTH = 96 * SCALE
local HEIGHT = 128 * SCALE
local MARGIN = WIDTH * 0.25 * SCALE


local CardList_Paodekuai = class("CardList_Paodekuai")

function CardList_Paodekuai:ctor(root)
    self._root = root
    self._uiCards = {}
    self._values = {}
    self._selectedIndex = {}
    self._isTouchEnable = false
    self:_init()

    self._lastTouchIndex = -1
    self:resetTipsCounter()
end

function CardList_Paodekuai:_init()
    self._container = self._root
    self._size = self._container:getContentSize()
    self._position = cc.p(self._root:getPosition())
end

function CardList_Paodekuai:setTouchEnable(value)
    if value and self._isTouchEnable == false then
        self._listener = cc.EventListenerTouchOneByOne:create()
        self._listener:registerScriptHandler(handler(self, self._onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
        self._listener:registerScriptHandler(handler(self, self._onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
        self._listener:registerScriptHandler(handler(self, self._onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
        local dispatcher = self._container:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(self._listener, self._container)
    elseif value == false and self._isTouchEnable == true then
        local dispatcher = self._container:getEventDispatcher()
        dispatcher:removeEventListener(self._listener)
    end
    self._isTouchEnable = value
end

function CardList_Paodekuai:setEnable(value)
    self._root:setVisible(value or false)
end


function CardList_Paodekuai:onTips()
    -- selfCards, lastCards, lastCardType
    local info = gameMode.mahjong.Context:getInstance():getGameService():getLastDiscardInfo()
    self:popDownAll()
    if info.value == nil or #(info.value) == 0 then
        return
    end
    local values = TipsHelper:get(self._values, info.value, self._retryCounter) or {}


    if #values == 1 then
        -- 如果是单张，必须出单张最大的
        local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(info.roleId)
        local remainNum = processor:getUIPlayer():getCardRemainNum()
        local optValues = game.service.RoomService:getInstance():getRoomRules()
        if table.indexof(optValues, "GAME_PLAY_BAO_DAN_BI_DING") and remainNum == 1 then
            local sortedCards = CardDefines.sort(self._values)
            local tipResult = CardDefines.Map[sortedCards[1]].sortValue
            values = { tipResult }
            self._retryCounter.count = 0
            Logger.debug("====MUST SELECTE MOST BIG VALUE CARD ==")
        end
    end

    Logger.debug("=====TIPS RESULT ======")
    Logger.debug("=====TIPS COUNTER = " .. self._retryCounter.count)
    dump(values)


    for i, tipValue in ipairs(values or {}) do
        for j, card in ipairs(self._uiCards) do -- 使用ui来， values的可能 index不对应
            if tipValue == card:getSortValue() and not card:isSelected() then
                Logger.debug("===SELECTE CARD === " .. card:getName())
                card:select()
                break
            end
        end
    end
end

function CardList_Paodekuai:resetTipsCounter()
    self._retryCounter = {
        count = 0,
        retrySplit2Counter = 0,
        retrySplit3Counter = 0,
        retrySplit4Counter = 0,
    } --保持地址引用
end

function CardList_Paodekuai:getValues()
    return self._values
end

function CardList_Paodekuai:popDownAll()
    for idx, uiCard in ipairs(self._uiCards) do
        uiCard:unselect()
    end
end

function CardList_Paodekuai:popReverse(index)
    local card = self._uiCards[index]
    if index <= 0 or index > #self._uiCards then
        return
    end
    if card:isSelected() then
        card:unselect()
    else
        card:select()
    end
end

function CardList_Paodekuai:popUp(index)
    -- local index = table.keyof(self._values, value)
    local card = self._uiCards[index]
    if Macro.assertFalse(card.getValue() == value) then
        card:select()
    end
end

function CardList_Paodekuai:popDown(index)
    -- local index = table.keyof(self._values, value)
    local card = self._uiCards[index]
    if Macro.assertFalse(card.getValue() == value) then
        card:unselect()
    end
end

function CardList_Paodekuai:setValues(values)
    self:_deleteAllCard()
    self:_createAllCard(values)
    self:_resizeContainerSize()
    self:_addAllCardToRoot()
    -- TODO start to create a card insert to
end

function CardList_Paodekuai:_addAllCardToRoot()
    local startX = (WIDTH) * 0.5
    local y = self._size.height * 0.5
    for idx, uiCard in ipairs(self._uiCards) do
        self._container:addChild(uiCard)
        local posX = startX + MARGIN * (idx - 1)
        uiCard:setPosition(posX, y)
        -- Logger.debug("x = " .. posX)
    end
end

function CardList_Paodekuai:_createAllCard(values)
    for idx, value in ipairs(values) do
        local uiCard = CardFactory:get(value, SCALE)
        uiCard:setIndex(idx)
        table.insert(self._uiCards, uiCard)
    end
    self._values = values
end

function CardList_Paodekuai:_deleteAllCard()
    self._values = {}
    self._selectedIndex = {}
    for idx, uiCard in ipairs(self._uiCards) do
        uiCard:dispose()
        uiCard:removeFromParent()
    end
    self._uiCards = {}
end

function CardList_Paodekuai:_deleteCards(cards)
    -- 判断是否含有，没含有就报错
    for idx, value in ipairs(cards) do
        local _index = table.indexof(self._values, value)
        if _index then
            table.remove(self._values, _index)
        end
    end
    self:setValues(self._values)
end

function CardList_Paodekuai:_resizeContainerSize()
    local count = #self._uiCards
    local height = HEIGHT
    -- local width = #self._uiCards * (MARGIN + WIDTH) - MARGIN
    local width = (count - 1) * MARGIN + WIDTH
    -- Logger.debug(string.format("count = %s, height = %s, width = %s",count, height, width))
    self._size = cc.size(width, height)
    self._container:setContentSize(self._size)
end

--[[ 
        ====== 监听触摸部分 =======
]]
function CardList_Paodekuai:_onTouchBegan(touch, event)
    local isIn = self:_isTapInView(touch:getLocation())
    if isIn then
        self._lastTouchIndex = self:_getCurrentTouchIndex(touch:getLocation())
        self:popReverse(self._lastTouchIndex)
    else
        self:popDownAll()
    end
    return isIn
end

function CardList_Paodekuai:_onTouchMoved(touch, event)
    -- Logger.debug("_onTouchMoved")
    local index = self:_getCurrentTouchIndex(touch:getLocation())
    if self._lastTouchIndex ~= index then
        self:popReverse(index)
        self._lastTouchIndex = index
    end
end

function CardList_Paodekuai:_onTouchEnded(touch, event)
    local index = self:_getCurrentTouchIndex((touch:getLocation()))
    if self._lastTouchIndex ~= index then
        self._lastTouchIndex = index
        self:popReverse(index)
    end
end

function CardList_Paodekuai:_convert2Self(p)
    local selfP = self._container:convertToNodeSpace(p)
    return selfP
end

function CardList_Paodekuai:_onTouchCanceled()
    Logger.debug("_onTouchCanceled")
end

function CardList_Paodekuai:_isTapInView(location)
    local scene_location = self._container:getParent():convertToNodeSpace(location)
    if cc.rectContainsPoint(self._container:getBoundingBox(), scene_location) then
        return true
    else
        return false
    end
end

function CardList_Paodekuai:_getCurrentTouchIndex(location)
    local p = self:_convert2Self(location)
    local count = #self._uiCards
    local touchX = p.x
    for i = 0, count do
        local _x = i * MARGIN
        if touchX < _x then
            -- Logger.debug("Touch INDEX = " .. i)
            return i
        end
    end
    return count
end

function CardList_Paodekuai:getSelectedCardValues()
    local ret = {}
    for idx, card in ipairs(self._uiCards) do
        if card:isSelected() then
            table.insert(ret, card:getValue())
        end
    end
    return ret
end

function CardList_Paodekuai:debugSortedValues()
    local t = clone(self._values)
    table.sort(t, function(v1, v2) return v1 > v2 end)
    Logger.debug("==== cards = " .. table.concat(t))
    return t
end

-- 目前是删除了所有手牌 后续优化下
function CardList_Paodekuai:onDiscard(cards)
    -- 1、恢复所有牌的位置
    -- 2、直接从手牌中删除服务器发来的牌
    -- 3、重新排列位置
    -- Logger.debug("==== before Discard cards = ")
    -- self:debugSortedValues()
    -- Logger.debug("==== onDiscard")
    -- Logger.debug("cards = " .. table.concat(cards, ","))
    self:_deleteCards(cards)
    -- Logger.debug("Now cards = ")
    -- self:debugSortedValues()
end

function CardList_Paodekuai:prepareForNextRound()
    self:_deleteAllCard()
    self:setEnable(false)
end

function CardList_Paodekuai:toStrings()
    local ret = table.concat(self._values or {}, ",")
    return ret
end

function CardList_Paodekuai:dispose()
    self:setTouchEnable(false)
    self:_deleteAllCard()
end

return CardList_Paodekuai