local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

local UIElemCardTips = {}

local y2by = CC_DESIGN_RESOLUTION.screen.toButtom
-----------------------------------------------------------------------------------------------------
-- UI组件，用来以现有的结构获取大小，方便扩展
local Component_Hu = class("Component_Hu", function() return cc.CSLoader:createNode("ui/csb/ui_component/CardTing.csb") end)

function Component_Hu:ctor()
    self._content = seekNodeByName(self, "content", "ccui.Layout")
    self._cardNode = seekNodeByName(self, "cardAnchor", "cc.Node")
    self._cardNumber = seekNodeByName(self, "txt2", "ccui.TextBMFont")
    self._card = nil

    self._cardsInfo = nil

    -- game.service.LocalPlayerService.getInstance():addEventListener("GAME_UPDATE_TING_CARDS_NUM", handler(self, self.updateCardNums), self)
end

function Component_Hu:getSize()
    return self._content:getContentSize()
end

function Component_Hu:updateCardNums()
    if self._card == nil then 
        return 
    end
    local card = self._card:getCardValue()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    local num = gameService:getRemainCardValue(card)
    if self._cardsInfo ~= nil then
        self:update(self._cardsInfo,num)
    end
end

function Component_Hu:update(cardInfo, cardNumber)
    self:clean()
    if cardNumber < 0 then
        cardNumber = 0
    end
    self._cardsInfo = cardInfo
    if cardInfo.score == nil then
        self._cardNumber:setString(tostring(cardNumber) .. "张")      
        if cardNumber == 0 then
            self._card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.CardTip_Dark, cardInfo.card, nil, 1.08)
        else
            self._card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.Shoupai, cardInfo.card, nil, 1.08, cardNumber)
        end
    elseif cardNumber == 0 then
        self._cardNumber:setString(tostring(cardInfo.score) .. "分")        
        self._card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.CardTip_Dark, cardInfo.card, nil, 1.08)
    else
        self._cardNumber:setString(tostring(cardInfo.score) .. "分")        
        self._card = CardFactory:getInstance():createCard2(CardDefines.Chair.Down, CardDefines.CardState.Shoupai, cardInfo.card, CardDefines.CornerType.RemaingCards, 1.08, cardNumber)
    end
    -- if cardNumber == 0 then
    --     if self._card ~= nil then
    --         kod.ShaderHelper.shaderButtonCard(self._card._realBtn)
    --         kod.ShaderHelper.shaderImageCard(self._card._face)
    --     end
    -- end
    self._cardNode:addChild(self._card)
    -- 需要重置一下坐标，不然就找不到了。。。。
    self._card:setPosition(cc.p(0,0))
    self:setVisible(true)
    self._cardNumber:setVisible(true)
    self._content:setSwallowTouches(false)
end

-- 清除加载的卡牌
function Component_Hu:clean()
    if self._card then
        CardFactory:getInstance():releaseCard(self._card)
        self._card = nil
    end
    self._cardsInfo = nil
    self:setVisible(false)
    self._cardNumber:setVisible(false)
end

function Component_Hu:dispose()
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
end

-----------------------------------------------------------------------------------------------------
local UIElemCardTips_HU = class("UIElemCardTips_HU", function() return cc.Node:create() end)

local WIDTH_FIXED = 30
local HEIGHT_FIXED = 12
local PIC_X_FIXED = 6
local PIC_Y_FIXED = 12
local LEFT_TEXT_FIXED = 75
local CARD_WIDTH_FIXED = 26
local CARD_HEIGHT_FIXED = 5

function UIElemCardTips_HU:ctor(parent)
    self._parent = parent
    self._cards = {}
    self._anchorCard = nil
    self.cardsNumText = nil
    self.hangingNode = parent:getParent():getChildByName("tingTipsNode")
    self._componentPools = {}
    -- 添加箭头
    self._arrow = ccui.ImageView:create("gaming/jt.png")
    self:addChild(self._arrow)
    self._arrow:setLocalZOrder(-1)
    self._arrow:setAnchorPoint(cc.p(0.5,0))
    self._arrowOffset = self._arrow:getContentSize()
    -- 添加背景图
    self._bg = ccui.ImageView:create("gaming/dw_ts.png")
    self:addChild(self._bg)
    self._bg:setScale9Enabled(true)
    self._bg:setCapInsets(cc.rect(100, 9, 15, 50))
    self._bg:setAnchorPoint(cc.p(0,0))
    self._bg:setPosition(cc.p(-WIDTH_FIXED-PIC_X_FIXED,-HEIGHT_FIXED-PIC_Y_FIXED))

    -- 左侧所听牌总的张数剩余3
    self.cardsNumText = ccui.TextBMFont:create()
    self.cardsNumText:setFntFile("art/font/font_Arena.fnt")
    -- self.cardsNumText:setColor(cc.c3b(165, 63, 0))
    self.cardsNumText:setAnchorPoint(cc.p(0.5,0.5))
    self.cardsNumText:setString("0")
    self.cardsNumText:setScale(0.9)
    self.cardsNumText:setPosition(53,100)

    local text = ccui.TextBMFont:create()
    text:setFntFile("art/font/font_jsq.fnt")
    text:setAnchorPoint(cc.p(0.5,0.5))
    text:setString("张")
    text:setScale(0.9)
    text:setPosition(53,42)
    text:setColor(cc.c3b(255, 230, 105))

    self._bg:addChild(self.cardsNumText)
    self._bg:addChild(text)

    -- 添加滑动组件
    self._scrollView = ccui.ScrollView:create()
    self._scrollView:setDirection(ccui.ScrollViewDir.horizontal)
    self._scrollView:setScrollBarEnabled(false)
    self._scrollView:setAnchorPoint(cc.p(0,0))
    self._scrollView:setPosition(cc.p(36 + LEFT_TEXT_FIXED, 20))
    self._bg:addChild(self._scrollView)

    self:retain()

    -- 初始化10个组件
    for i=1,10 do
        self._componentPools[i] = Component_Hu.new()
        self._scrollView:addChild(self._componentPools[i])
        self._componentPools[i]:clean()
    end

    -- 如果没有添加
    if not self:getParent() then
        parent:addChild(self)
    end
end

function UIElemCardTips_HU:getComponent(index)
    if self._componentPools[index] == nil then
        self._componentPools[index] = Component_Hu.new()
        self._scrollView:addChild(self._componentPools[index])
        self._componentPools[index]:clean()
    end
    return self._componentPools[index]
end

-- param isLongest: 是否需要使用 "多"的箭头表示其为胡最多牌
function UIElemCardTips_HU:bind(cards, anchorCard, isLongest)
    self._cards = cards
    table.sort(self._cards,function (a,b)
        return a.card < b.card
    end)
    self._anchorCard = anchorCard
    self._isLongest = isLongest

    self:_update()        
end

function UIElemCardTips_HU:unbind()
    for i,v in ipairs(self._componentPools) do
        -- 清除挂载的牌，并隐藏
        v:clean()
    end
    self._cards = {}
    self._anchorCard = nil
end

-- 是否为特殊的牌张，若是，其听牌提示张数要减1
function UIElemCardTips_HU:_isSpecailCard(cardValue)
    -- 判定是否为有效牌值
    local isValid = CardDefines.isValidCardNumber(cardValue)
    if not isValid then 
        return false 
    end 

    -- 
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if gameService == nil then 
        return false 
    end 
    local processor = gameService:getPlayerProcessorByPlayerId(roleId)
    if processor == nil then 
        return false 
    end 

    -- 获取牌张列表
    local cardList = processor._cardList
    if not cardList then 
        return false 
    end  

    -- 获取手牌的角标类型
    local isSpecail = false 
    local gameType = Constants.SpecialEvents.gameType
    local cornerTypes = cardList:getCardCornerTypes(cardValue)
    local isExist = table.indexof(cornerTypes, CardDefines.CornerType.GuiPai) ~= false 
    -- 是否为贵阳癞子鸡牌
    if gameType == "GAME_TYPE_R_GUIYANG" and isExist then 
        isSpecail = true 
    end 
    return isSpecail
end

function UIElemCardTips_HU:_update()
    local totalCardsNum = 0
    local rw = 0
    local width = 0
    local height = 0
    local maxBgWidth = 800
    local w,h = self._anchorCard:getSize()
    local x,y = self.hangingNode:getPosition()
    local posX,posY = self._anchorCard:getPosition()

    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    for i,v in ipairs(self._cards) do
        local component = self:getComponent(i)
        local sz = component:getSize()
        -- 添加间隔，如果不需要修改上面的定义值
        width = sz.width + CARD_WIDTH_FIXED
        height = sz.height
        -- 剩余牌数
        local remain = gameService:getRemainCardValue(v.card)
        if remain < 0 then
            remain = 0
        end
        -- 判定是否为贵阳的癞子鸡
        local isSpecail = self:_isSpecailCard(v.card)
        if isSpecail == true and remain > 0 then 
            remain = remain - 1
        end 
        totalCardsNum = totalCardsNum + remain
        -- 更新组件显示信息，并显示

        -- 产品需要有一个卡一下的效果
        component:update(v, remain)
        component:setVisible(false)        
        -- scheduleOnce(function ()
        component:setVisible(true)
        -- end,0.04)
        component:setPosition(cc.p((i-1)*width, 5))
        self:setLocalZOrder(100)
        rw = rw + width
    end
    local innerWidth = rw - CARD_WIDTH_FIXED
    if rw > maxBgWidth then
        rw = maxBgWidth
    end
    -- 最后一张牌不需要间隔
    rw = rw - CARD_WIDTH_FIXED
    local half = rw/2
    local screen = CC_DESIGN_RESOLUTION.screen.size()
    local tx = x - half
    local max = screen.width - rw - WIDTH_FIXED*2
    local min = WIDTH_FIXED
    -- 右方超出屏
    if tx > max then
        tx = max
    end
    -- 左方超出屏
    if tx < min then
        tx = min
    end
    self._bg:setContentSize(cc.size(rw + WIDTH_FIXED*2 + PIC_X_FIXED*2 + LEFT_TEXT_FIXED, height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))
    self._scrollView:setInnerContainerSize(cc.size( innerWidth, height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))
    self._scrollView:setContentSize(cc.size(rw , height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))

    local pos = self._anchorCard:getParent():convertToWorldSpace(cc.p(posX ,posY))
    pos = self:convertToNodeSpace(pos)
    self._arrow:setPosition(cc.p(pos.x , pos.y + h/2))
    
    if self._isLongest then
        self._arrow:loadTexture("gaming/icon_duo.png")
    else
        self._arrow:loadTexture("gaming/jt.png")
    end

    -- print("PARENT NAME ================================= " .. self:getParent():getName())
    -- print("SELF ZORDER ================================= " .. self:getLocalZOrder())
    -- print("HEADFRAME ZORDER ================================= " .. self:getParent():getChildByName("Icon_img_player1_Scene"):getLocalZOrder())

    self._arrow:setVisible(true)
    self._arrow:setLocalZOrder(100)
    
    self.cardsNumText:setString(totalCardsNum)

    -- 坐标节点转，现在提示跟牌不在同一个节点了，需要进行坐标转换，哎，效率啊
    local pt = cc.p(tx - LEFT_TEXT_FIXED/2, y - 3)
    pt = self._anchorCard:getParent():convertToWorldSpace(pt)
    pt = self:getParent():convertToNodeSpace(pt)
    self:setPosition(pt)
end

function UIElemCardTips_HU:display(cards)
    local totalCardsNum = 0
    local rw = 0
    local width = 0
    local height = 0
    local maxBgWidth = 800
    local x,y = self.hangingNode:getPosition()
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if cards == nil or #cards == 0 then
        game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})		
        self:setVisible(false)
        return
    end    
    for i,v in ipairs(self._cards) do
        local component = self:getComponent(i)
        component:setVisible(false)
    end
    for i,v in ipairs(cards) do
        local component = self:getComponent(i)
        component:setVisible(true)
        local sz = component:getSize()
        -- 添加间隔，如果不需要修改上面的定义值
        width = sz.width + CARD_WIDTH_FIXED
        height = sz.height
        -- 剩余牌数
        local remain = gameService:getRemainCardValue(v.card)
        if remain < 0 then
            remain = 0
        end
        -- 判定是否为贵阳的癞子鸡
        local isSpecail = self:_isSpecailCard(v.card)
        if isSpecail == true and remain > 0 then 
            remain = remain - 1
        end 
        totalCardsNum = totalCardsNum + remain
        -- 更新组件显示信息，并显示
        component:update(v, remain)
        component:setPosition(cc.p((i-1)*width , 5))
        self:setLocalZOrder(-1)
        rw = rw + width
    end
    local innerWidth = rw - CARD_WIDTH_FIXED
    if rw > maxBgWidth then
        rw = maxBgWidth
    end
    -- 最后一张牌不需要间隔
    rw = rw - CARD_WIDTH_FIXED
    local half = rw/2
    local screen = CC_DESIGN_RESOLUTION.screen.size()
    local tx = x - half
    local max = screen.width - rw - WIDTH_FIXED*2
    local min = WIDTH_FIXED
    -- 右方超出屏
    if tx > max then
        tx = max
    end
    -- 左方超出屏
    if tx < min then
        tx = min
    end
    self._bg:setContentSize(cc.size(rw + WIDTH_FIXED*2 + PIC_X_FIXED*2 + LEFT_TEXT_FIXED, height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))
    self._scrollView:setInnerContainerSize(cc.size( innerWidth, height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))
    self._scrollView:setContentSize(cc.size(rw , height + HEIGHT_FIXED*2 + PIC_Y_FIXED*2))
    
    self.cardsNumText:setString(totalCardsNum)

    -- 坐标节点转，现在提示跟牌不在同一个节点了，需要进行坐标转换，哎，效率啊
    local pt = cc.p(tx - LEFT_TEXT_FIXED/2, y - 3)
    local roomseat = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByChair(CardDefines.Chair.Down):getRoomSeat():getSeatUI()
    pt = roomseat:getCardParentNode():convertToWorldSpace(pt)
    pt = self:getParent():convertToNodeSpace(pt)
    self._arrow:setVisible(false)
    self:setPosition(pt)
end

function UIElemCardTips_HU:dispose()
    self:unbind()
    self:removeFromParent()
    self:release()
end

-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
local UIElemCardTips_TING = class("UIElemCardTips_TING",function() return ccui.ImageView:create("gaming/jt.png") end)

function UIElemCardTips_TING:ctor()
    self._anchorCard = nil
    self._root = nil
    self:retain()
end

-- param isLongest: 是否需要使用 "多"的箭头表示其为胡最多牌
function UIElemCardTips_TING:bind(anchorCard, isLongest, root)
    self._anchorCard = anchorCard
    self._root = root
    -- 如果没有添加
    if not self:getParent() then
        self._root:addChild(self)
    end
    self:_update(isLongest)
end

function UIElemCardTips_TING:unbind()
    self._anchorCard = nil
    self:removeFromParent()
end

function UIElemCardTips_TING:_update(isLongest)
    local w,h = self._anchorCard:getSize()
    local x,y = self._anchorCard:getPosition()
    local pos = self._anchorCard:getParent():convertToWorldSpace(cc.p(x ,y))
    pos = self._root:convertToNodeSpace(pos)
    self:setPosition(cc.p(pos.x , pos.y + h/2))
    self:setAnchorPoint(0.5,0)
    -- self:setGlobalZOrder(66666)
    if isLongest then
        self:loadTexture("gaming/icon_duo.png")
    else
        self:loadTexture("gaming/jt.png")
    end
end

function UIElemCardTips_TING:dispose()
    self:unbind()
    self:release()
end

-----------------------------------------------------------------------------------------------------

UIElemCardTips.UIElemCardTips_HU = UIElemCardTips_HU
UIElemCardTips.UIElemCardTips_TING = UIElemCardTips_TING

return UIElemCardTips