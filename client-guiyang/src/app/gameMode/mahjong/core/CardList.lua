local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local CardList = class("CardList")

-- @param cardState: CardDefines.CardState
function CardList:ctor()
    self.discardedCardList = {};	-- 打出的牌
    self.cardGroups = {};			-- 吃/碰/杠牌
    self.handCards = {};			-- 手牌
    self.lastDrewCard = nil;		-- 当前摸到的牌。也在handCards里
    self.huaCards = {};				-- 花牌
    self.huCards = {};				-- 胡牌
    self.guiCards = {};				-- 鬼牌（鸡牌）
    self.lackCardType = - 1; 		-- 定缺
    self.mapais = {maCount = 0, win = {}, lose = {}, all = {}};				-- 马牌
    self.maCards = {};				--/*买马/罚马牌 复牌只会有第一个动画需要的牌*/
    self.cornerCardValues = {}		-- 所有角标牌的牌值 用于服务器直接发值的时候引用
    self.tingTipsLastDiscard = 0    -- 上次打出的牌，听牌提示使用的，因为被碰的时候会把discardCardList中最后一张pop掉，所以在这里保存改派牌值
end

function CardList:dispose()
    self:releaseAllCards();
end

function CardList:addDiscardedCard(card, isTing)
    table.insert(self.discardedCardList, card)
    if not isTing then
        self.tingTipsLastDiscard = card:getCardValue()
    end
end

-- 上次打出的能牌/听牌提示使用
function CardList:getLastTingDiscard()
    return self.tingTipsLastDiscard
end

function CardList:addHuCards(card)
    table.insert(self.huCards, card)
end
function CardList:addHuaCard(card)
    table.insert(self.huaCards, card)
end

function CardList:addGuiCards(card)
    table.insert(self.guiCards, card)
end
--/** 该牌值是否为指定的鬼牌类型 */
function CardList:isCornerCard(cardValue, cornerType)
    if self.cornerCardValues[cornerType] then
        return table.indexof(self.cornerCardValues[cornerType], cardValue)
    end
    return false
end

--/** 获得当前手牌 角标类型 */
function CardList:getCardCornerTypes(cardValue)
    local cornerTypes = {}
    for type, _ in pairs(self.cornerCardValues) do
        if self:isCornerCard(cardValue, type) then
            table.insert(cornerTypes, type)
        end
    end
    
    return cornerTypes
end

--设置鬼牌类型
function CardList:setCornerCardValues(type, cardValues)
    self.cornerCardValues[type] = cardValues
end

--当鬼牌明确后将牌局中的牌设置角标
function CardList:reSetCornerType(chairType)
    for i = 1, #self.handCards do
        local card = self.handCards[i]
        local cornerTypes = self:getCardCornerTypes(card:getCardValue())
        if #cornerTypes > 0 then
            card:setCornerMasks(cornerTypes, chairType)
        end
    end
end

-- @return card, 删掉的卡
function CardList:removeDiscardedCardTail(cardNumber)
    -- 删掉最后一张
    for i = #self.discardedCardList, 1, - 1 do
        local card = self.discardedCardList[i];
        if card._cardValue == cardNumber then
            table.remove(self.discardedCardList, i)
            return card;
        end
    end
    
    return nil
end

function CardList:getLastDiscardCard()
    return self.discardedCardList[#self.discardedCardList]
end

function CardList:addHandCard(card)
    table.insert(self.handCards, card)
end

-- 打出（移除）一张牌。
function CardList:removeHandCard(card)
    for i = 1, #self.handCards do
        if self.handCards[i] == card then
            table.remove(self.handCards, i)
            return;
        end
    end
end

function CardList:removeHandCardAndReleaseByObject(cardObject)
    if Macro.assertFalse(cardObject, "card object is a nil value") then
        self:removeHandCard(cardObject)
        CardFactory:getInstance():releaseCard(cardObject)
    end
end

-- 如果有多个相同牌值，从左往右移除
function CardList:removeHandCardAndReleaseByValue(cardValue)
    for index, card in ipairs(self.handCards) do
        if card._cardValue == cardValue then
            CardFactory:getInstance():releaseCard(card)
            table.remove(self.handCards, index)
            return
        end
    end
end

function CardList:releaseAll(cards)
    while #cards > 0 do
        CardFactory:getInstance():releaseCard(cards[#cards])
        table.remove(cards, #cards)
    end
end

function CardList:releaseGuiCards(cards)
    while #cards > 0 do
        local node = cards[#cards]:getChildByName("corner_chicken")
        cards[#cards]:removeChild(node)
        CardFactory:getInstance():releaseCard(cards[#cards])
        table.remove(cards, #cards)
    end
end

function CardList:releaseAllCards()
    self:releaseAll(self.discardedCardList)
    self:releaseAll(self.handCards)
    self:releaseAll(self.huCards)
    self:releaseAll(self.huaCards)
    self:releaseGuiCards(self.guiCards)
    self:releaseAll(self.maCards)
    self.mapais = {maCount = 0, win = {}, lose = {}, all = {}};
    self.cornerCardValues = {}
    while #self.cardGroups > 0 do
        self:releaseAll(self.cardGroups[1].cards)
        table.remove(self.cardGroups, 1)
    end
    self.lackCardType = - 1
--[[	while (this.discardedCardList.length > 0)
        CardFactory:getInstance():releaseCard(this.discardedCardList.pop());

    while (this.handCards.length > 0) {
        CardFactory:getInstance():releaseCard(this.handCards.pop());
    }

    while (this.cardGroups.length > 0) {
        let group = this.cardGroups.pop();
        while (group.cards.length > 0) {
            CardFactory:getInstance():releaseCard(group.cards.pop());
        }
    }

    while (this.huCards.length > 0) {
        CardFactory:getInstance():releaseCard(this.huCards.pop());
    }

    while (this.huaCards.length > 0) {
        CardFactory:getInstance():releaseCard(this.huaCards.pop());
    }

    this.lackCardType = 0;
--]]
end

-- 获取一张指定牌面值的牌。
-- @param cardNumber: number
-- @param handCardOnly: boolean,是否仅考虑可以打出的牌
-- @return Card
function CardList:getCard(cardNumber, handCardOnly)
    Macro.assetFalse(handCardOnly == true)
    local matched = nil;
    for i = 1, #self.handCards do
        if self.handCards[i]._cardValue == cardNumber then
            return self.handCards[i]
        end
    end
    
    return nil
end

function CardList:getHandCardValuesClone()
    local rawValues = {}
    for index, card in ipairs(self.handCards) do
        table.insert(rawValues, card._cardValue)
    end
    return rawValues
end

function CardList:getHandCardValuesWithoutThose(cardValues)
    if Macro.assertFalse(self:checkValuesInHandCard(cardValues), 'some values does in hand card!') then
        local handCardValues = self:getHandCardValuesClone()
        for _, value in ipairs(cardValues) do
            local index = table.indexof(handCardValues, value)
            if index then
                table.remove(handCardValues, index)
            end
        end
        return handCardValues
    end
end

function CardList:checkValuesInHandCard(cardValues)
    local handCardValues = self:getHandCardValuesClone()
    if #cardValues > #handCardValues then
        return false
    end
    cardValues = {unpack(cardValues, 1, #cardValues)} -- pointer ref
    for index, value in ipairs(cardValues) do
        local handIndex = table.indexof(handCardValues, value)
        if handIndex then
            cardValues[index] = nil
        end
    end
    return #cardValues == 0
end




--[[-- 排序函数, 静态
local function _sortFunc(l,r)
    if l.cardNumber ~= r.cardNumber then
        -- 牌值不相等, 按牌值排序
        return l.cardNumber - r.cardNumber;
    else
        -- TODO : 牌值相等, 按照实例Id排序
        return 0;
    end
end--]]
function CardList:sort()
    
    table.sort(self.handCards, function(l, r)
        
        local lGui = self:isCornerCard(l:getCardValue(), CardDefines.CornerType.GuiPai) and 1 or 0;
        local rGui = self:isCornerCard(r:getCardValue(), CardDefines.CornerType.GuiPai) and 1 or 0;
        
        if lGui ~= rGui then
            return rGui < lGui
        end
        
        local weightA = nil
        local weightB = nil
        if l:getCardValue() ~= r:getCardValue() then
            -- 牌值不相等, 按牌值排序
            weightA = l:getCardValue()
            weightB = r:getCardValue()
        else
            -- TODO : 牌值相等, 按照实例Id排序
            weightA = l:getId()
            weightB = r:getId()
        end
        
        if self.lackCardType ~= - 1 then
            weightA = weightA +(CardDefines.getCardType(l:getCardValue()) == self.lackCardType and 100 or 0)
            weightB = weightB +(CardDefines.getCardType(r:getCardValue()) == self.lackCardType and 100 or 0)
        end
        
        return weightA < weightB
    end)
end

-- 3d麻将 胡牌时用(给牌值进行排序方便创建手牌)
function CardList:sortValue(value)
    table.sort(value, function(l, r)
        
        local lGui = self:isCornerCard(l, CardDefines.CornerType.GuiPai) and 1 or 0;
        local rGui = self:isCornerCard(r, CardDefines.CornerType.GuiPai) and 1 or 0;
        
        if lGui ~= rGui then
            return rGui < lGui
        end
        
        local weightA = nil
        local weightB = nil
        weightA = l
        weightB = r
        
        if self.lackCardType ~= - 1 then
            weightA = weightA +(CardDefines.getCardType(l) == self.lackCardType and 100 or 0)
            weightB = weightB +(CardDefines.getCardType(r) == self.lackCardType and 100 or 0)
        end
        
        return weightA < weightB
    end)
end

-- 将当前的卡牌信息输出为字符串
function CardList:toStrings()
    local cardsStr = "cardList==>"
    -- handcard to strings
    cardsStr = cardsStr .. "handCards:["
    for iddx = 1, #self.handCards do
        cardsStr = cardsStr .. self.handCards[iddx]._cardValue .. ","
    end
    for iddx = 1, #self.cardGroups do
        local group = self.cardGroups[iddx];
        cardsStr = cardsStr .. "["
        for idddx = 1, #group.cards do
            cardsStr = cardsStr .. group.cards[idddx]._cardValue .. ","
        end
        cardsStr = cardsStr .. "]"
    end
    cardsStr = cardsStr .. "]"
    
    -- discard to strings
    cardsStr = cardsStr .. " discardCards:["
    for iddx = 1, #self.discardedCardList do
        cardsStr = cardsStr .. self.discardedCardList[iddx]._cardValue .. ","
    end
    cardsStr = cardsStr .. "]"
    return cardsStr
end

--答应手牌信息
function CardList:outputCardsInfo(str)
    local cardsInfo = str and str or "cardsInfo:"
    for iddx = 1, #self.handCards do
        if self.handCards[iddx]._cardValue == 255 then
            return 
        end
        cardsInfo = cardsInfo .. self.handCards[iddx]._cardValue .. ","
        cardsInfo = cardsInfo .. (self.handCards[iddx]:isVisible() and "t" or "f") .. ","        
    end
    Logger.debug(cardsInfo)
end

return CardList 