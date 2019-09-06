--[[-- 本地玩家相关UI与操作
--]]
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local UIRoomSeat_Down = class("UIRoomSeat_Down", require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher"))
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local UITouch = require("app.gameMode.mahjong.ui.UITouchProcessor")
local UIElemCardTips = import(".UIElemCardTips")

local BG_HEIGHT = 94

local BASE_CARD_Z_ORDER = 10
local SHOUPAI_Z_ORDER = BASE_CARD_Z_ORDER + 100
local HU_DARK_MASK_ZORDER = SHOUPAI_Z_ORDER + 100
local HU_SHOUPAI_ZORDER = HU_DARK_MASK_ZORDER + 100
local HU_HEAD_ZORDER = HU_SHOUPAI_ZORDER + 100
local OP_BTN_Z_ORDER = BASE_CARD_Z_ORDER + 1000

local PREPARED_CARD_Y_DELTA = 26

function UIRoomSeat_Down:ctor(parent)
    self.super.ctor(self, parent, CardDefines.Chair.Down)
    self:_registerTouch()
    self:_registerHandCardsMouseEvent()
    game.service.LocalPlayerSettingService.getInstance():addEventListener("GAME_CLICK_TYPE_CHANGED", handler(self, self._registerTouch), self)
    game.service.LocalPlayerService.getInstance():addEventListener("GAME_HIDE_TING_TIPS", handler(self, self.recoverOperatingCard), self)

    -- 听牌数据
    self._tipsArray = {}
    self._tipsCache = {}
    self._tingMostCard = {}        -- 听牌听的最多的那张牌
    -- 改为顺序数组
    self._tipsNodes = {}
    for i = 1, config.GlobalConfig.MAX_HAND_CARDNUMBER - 1 do
        self._tipsNodes[i] = UIElemCardTips.UIElemCardTips_TING.new()
    end
    self._tingTips = UIElemCardTips.UIElemCardTips_HU.new(self._root)
    -- 延时动作节点，这里延时用节点来实现，方便安全
    self._actionNode = cc.Node:create()
    self._root:addChild(self._actionNode)
    self._actionNode:setVisible(false)
end

function UIRoomSeat_Down:_onClickPlayerHead()
    if game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		UIManager:getInstance():show("UIGoldPlayerInfo", self:getRoomSeat():getPlayer())
	else
		local _name 	= game.service.LocalPlayerService.getInstance():getName()
		local _id 		= game.service.LocalPlayerService.getInstance():getRoleId()
		local _ip 		= game.service.LocalPlayerService.getInstance():getIp()
		local _url 		= game.service.LocalPlayerService.getInstance():getIconUrl()
		local _identify = game.service.LocalPlayerService.getInstance():getCertificationService():getCertificationStatus()
		local _headFrame = game.service.LocalPlayerService.getInstance():getHeadFrameId()

        local state = GameFSM.getInstance():getCurrentState().class.__cname
	    if state == "GameState_MahjongReplay" then
            _name = self:getRoomSeat():getPlayer().name
            _id = self:getRoomSeat():getPlayer().roleId
            _ip = self:getRoomSeat():getPlayer().ip
            _url = self:getRoomSeat():getPlayer().headIconUrl
            _identify = self:getRoomSeat():getPlayer().isIdeneity
            _headFrame = self:getRoomSeat():getPlayer().headFrame
        end

		UIManager:getInstance():show("UIPlayerinfo2",_name,_id,_ip,_url,_identify,_headFrame);
	end
end

function UIRoomSeat_Down:clearSeat()
    self:recoverOperatingCard()
    self:clearCards()
    self.super.clearSeat(self)
end

function UIRoomSeat_Down:setPlayerName(playerName)
    local state = GameFSM.getInstance():getCurrentState().class.__cname
    local name = game.service.LocalPlayerService.getInstance():getName()
	if state == "GameState_MahjongReplay" then
        name = playerName
    end
    
	self._lablePlayerName:setString(kod.util.String.getMaxLenString(name, 8))
end

function UIRoomSeat_Down:setPlayerIcon(iconPath)
    local state = GameFSM.getInstance():getCurrentState().class.__cname
    local icon = game.service.LocalPlayerService.getInstance():getIconUrl()
	if state == "GameState_MahjongReplay" then
        icon = iconPath
    end

	game.util.PlayerHeadIconUtil.setIcon(self._imgPlayerIcon, icon)
end

function UIRoomSeat_Down:dispose()
    self.super.dispose(self)
    self:clearCardTips()
    game.service.LocalPlayerSettingService.getInstance():removeEventListenersByTag(self)
    game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
end

--[[*
 * 播放打出的牌到出牌区的动画(自己打牌)
 *]]
function UIRoomSeat_Down:onDiscardACard(cardValue,isTing)
	 -- 创建小牌， cardDiscard.cardNumber可能是无效的，使用cardNumber创建
     local card = CardFactory:getInstance():createCard2(self._chairType, CardDefines.CardState.Chupai, cardValue, false, self._cardLayout.discardedLayout.scale)
     card:changeColor(self._cardLayout.discardColor)
     self._playerProcessor._cardList:addDiscardedCard(card,isTing);
     self:getCardParentNode():addChild(card);
     local place = self:ManageDiscardedMahjongPositions(self._playerProcessor._cardList, self._cardLayout, false, {card})[card]
     card:setScale(1.5)
     card:setPosition(cc.p(place.pos.x, place.pos.y))
     card:setLocalZOrder(self._cardLayout.discardedAniStartZOrder)
     
     local scale2 = cc.ScaleTo:create(0.1, self:DISCARD_SCALE())
     local move = cc.MoveTo:create(0.1, cc.p(place.pos.x, place.pos.y))
     local spawn = cc.Spawn:create(scale2, move)
 
     local effectChuPaiFangDaTriggle = game.service.LocalPlayerSettingService:getInstance():getEffectValues().effect_ChuPaiTingLiu
     
     local callback = cc.CallFunc:create(function()
         -- 动画完成, 设置新打出的牌标记
         local gameService = gameMode.mahjong.Context.getInstance():getGameService();
         
         if not effectChuPaiFangDaTriggle then
             gameService:getRoomUI():markDiscardedCardIndicator(card);		
         end
         -- 重新排序
         card:setLocalZOrder(place.zOrder)
         card:setPosition(cc.p(place.pos.x, place.pos.y))
     end)
 
     local seq = cc.Sequence:create(spawn, callback)
     card:runAction(seq)
 
     game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})

     -- 添加一个听牌提示的打点：判断点多 和 正常的箭头比例
     if self._tingMostCard[cardValue] and table.nums(self._tipsArray) > 0 then        
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Ting_Tips_More)
     elseif table.nums(self._tipsArray) > 0 and table.nums(self._tingMostCard) > 0 and self._tingMostCard[cardValue] == nil and self._tipsArray[cardValue] ~= nil then
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Ting_Tips_Less)
     end
    -- local seq = cc.Sequence:create(spawn, callback)
    -- card:runAction(seq)
end

-- 刚摸到的那张牌做插牌动画。
function UIRoomSeat_Down:onInsertDrewCard(lastDrewCard)
    lastDrewCard:setLocalZOrder(HU_HEAD_ZORDER);

    local x, y = lastDrewCard:getPosition()
    -- 排列其他手牌, 空出来要插入牌的位置
    local targetPosition = self:ManageCardsPositions(self._playerProcessor._cardList, self:getCardLayout(), false, { lastDrewCard })[lastDrewCard];
    local moveUp = cc.MoveTo:create(0.05, cc.p(x, y + BG_HEIGHT + 10))
    local move = cc.MoveTo:create(0.3, cc.p(targetPosition.pos.x, y + BG_HEIGHT + 10))
    local moveDown = cc.MoveTo:create(0.1, cc.p(targetPosition.pos.x, targetPosition.pos.y))
    local callback = cc.CallFunc:create(function()
        self:ManageCardsPositions(self._playerProcessor._cardList, self:getCardLayout(), true)
    end)
    local effectValues = game.service.LocalPlayerSettingService:getInstance():getEffectValues()
    local seq = nil
    seq = cc.Sequence:create(moveUp, move, moveDown, callback)
    lastDrewCard:runAction(seq)
end

--------------------------------
-- 手牌操作相关功能
--------------------------------
--[[-- 1、打牌 点击或者按住一张手牌，在手指接触牌面的时候，牌弹出
-- 
-- 2、 增加手牌滑动切换
--      a) 按住一张手牌呈弹出状态，在手牌区域内横向滑动手指，表现为延滑动方向顺序切换手牌，既依次下一张手牌呈弹出状态并增加音效。
--      b) 滑动到任意牌后按住纵向拖动出手牌区域时变回为现有的跟随状态。 
--]]
function UIRoomSeat_Down:_registerTouch()
    local clickType = game.service.LocalPlayerSettingService:getInstance():getClickType()
    if clickType == 1 then
        self._touchProcessor = UITouch.UITouchProcessorDoubleClick.new(self)
    else
        self._touchProcessor = UITouch.UITouchProcessorClick.new(self)
    end
end

function UIRoomSeat_Down:_registerHandCardsMouseEvent()
    self._rootNode:addTouchEventListener(function(sender, eventType)
        -- 如果绑定的玩家都没有，那么也没必要再处理
        if self._playerProcessor == nil then
            return
        end

        if eventType == ccui.TouchEventType.began then
            self._touchProcessor:onHandCardTouchBegan(sender, eventType)
        elseif eventType == ccui.TouchEventType.moved then
            self._touchProcessor:onHandCardTouchMove(sender, eventType)
        elseif eventType == ccui.TouchEventType.ended then
            self._touchProcessor:onHandCardTouchEnd(sender, eventType)
        elseif eventType == ccui.TouchEventType.canceled then
            self._touchProcessor:onHandCardTouchCancelled(sender, eventType)
        end
    end)
end

-- 设置玩家当前总分数
function UIRoomSeat_Down:setTotalScore(totalPoint)
    self.super.setTotalScore(self, totalPoint)
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() and totalPoint ~= nil then
        game.service.CampaignService.getInstance():getCampaignData():setTotalPoint(totalPoint)
    end
end

--[[	当前听牌的相关记录
    cards 数组第一个是，如果打出此牌，后面的就是要听的牌
    datas datas是个list，里面是对应的要打出的牌，分数，要打出的牌，分数，要打出的牌，分数，这样依次放
]]
function UIRoomSeat_Down:addCardTips(cards,datas)
    Logger.debug(string.format("Cards:%s", json.encode(cards)))
    local mycards = clone(cards)
    self._tipsArray = self._tipsArray or {}
    local key = mycards[1]
    table.remove(mycards, 1)
    self._tipsArray[key] = {}

    -- 需要从datas中取出所胡的牌对应的分数，所以做了下面这一通操作
    for i=1,#mycards do
        local scoreResult = 0
        scoreResult = datas[i * 2]

        table.insert(self._tipsArray[key], {card = mycards[i], score = scoreResult})
    end

    -- 因为这条消息是复数的，所以做个小延时，如果有下条消息过来，顶掉上次的延时
    self._actionNode:stopAllActions()
    local delay = cc.DelayTime:create(0.05)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(function()
        if self._playerProcessor:canDiscardCard() then
            self:updateCardTips()
        end
        self._tipsCache = clone(self._tipsArray)
    end))
    self._actionNode:runAction(sequence)
end

function UIRoomSeat_Down:getCacheTipsArray()
    return self._tipsCache
end

function UIRoomSeat_Down:setTipsArray(array)
    if next(array) then
        self._tipsArray = array
    end
end

function UIRoomSeat_Down:clearCacheTips()
    self._tipsCache = {}
    self._tipsArray = {}
    self._tingTips:setVisible(false)
end

-- 开关听牌提示 开/关切换
function UIRoomSeat_Down:switchCacheTips()
    if self._tingTips:isVisible() == true then
        self:clearCards(true)
        return false
    else
        return true
    end
end

-- 显示当前所听的牌
function UIRoomSeat_Down:displayTingCards()
    -- 提取出当前听的牌
    if self._playerProcessor._cardList:getLastTingDiscard() ~= 0 then
        local value = self._playerProcessor._cardList:getLastTingDiscard()
        if self._tipsCache[value] ~= nil and #self._tipsCache[value] ~= 0 then
            self._tingTips:setVisible(true)            
            self._tingTips:display(self._tipsCache[value])
        else
            game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})	
        end
    end
end

--[[	isTipsBtn 是否需要清楚原来的数据
]]
function UIRoomSeat_Down:clearCards(isTipsBtn)
    -- 自动打牌状态时 不自动关闭
    if self._playerProcessor ~= nil and self._playerProcessor:getPlayerFsm():getCurrentState():doNotCloseTingTips() and not isTipsBtn then
        return
    end

    if not isTipsBtn then
        self._tipsArray = {}        
    end
    self._tingTips:setVisible(false)
    for i, v in ipairs(self._tipsNodes) do
        v:setVisible(false)
    end
end

function UIRoomSeat_Down:hideTingTips()
    -- 自动打牌状态时 不自动关闭
    if self._playerProcessor ~= nil and self._playerProcessor:getPlayerFsm():getCurrentState():doNotCloseTingTips()then
        return
    end

    self._tingTips:setVisible(false)
    for i, v in ipairs(self._tipsNodes) do
        v:setVisible(false)
    end
end

--[[	清除当前的听牌相关控件
]]
function UIRoomSeat_Down:clearCardTips()
    self._tipsArray = {}
    -- 改为顺序数组
    for i = 1, #self._tipsNodes do
        self._tipsNodes[i]:dispose()
    end
    self._tipsNodes = {}
    self._tingTips:dispose()
    self._actionNode:stopAllActions()
end

-- 挂载提示
function UIRoomSeat_Down:updateCardTips(justHideTips)
    self._tipsNodes = self._tipsNodes or {}
    self._tipsArray = self._tipsArray or {}

    if self._tingTips == nil then
        return
    end

    -- 自动打牌状态时 不自动关闭
    if self._playerProcessor ~= nil and self._playerProcessor:getPlayerFsm():getCurrentState():doNotCloseTingTips() then
        for i, v in ipairs(self._tipsNodes) do
            v:setVisible(false)
        end
        return
    end
    
    self._tingTips:setVisible(false)     

    -- 如果没有听牌，就不向下处理了
    if next(self._tipsArray) == nil then
        for i, v in ipairs(self._tipsNodes) do
            v:setVisible(false)
        end
        return
    end    

    -- 如果听牌了，需要算出客户端牌数最多的那些牌，为其标记成 "多"
    local longest = 0
    local longestMap = {}
    local longestCard = {}
    local isTheSame = true -- 是否为都一样大的牌
    
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    table.foreach(self._tipsArray,function (k,v)
        local total = 0
        table.foreach(v,function (k2,v2)
            local remain = gameService:getRemainCardValue(v2.card)
            if remain < 0 then
                remain = 0
            end
            total = total + remain
        end)
        longestMap[k] = total
        if total > longest then             
            longest = total
        end        
    end)

    table.foreach(longestMap,function (k,v)
        if longest ~= v then
            isTheSame = false
        else
            longestCard[k] = true
        end
    end)

    local displayDuo = table.nums(self._tipsArray) > 1 and not isTheSame
    if displayDuo then
        self._tingMostCard = longestCard
    else
        self._tingMostCard = {}
    end

    local idx = 0
    for _, card in ipairs(self._playerProcessor._cardList.handCards) do
        idx = idx + 1
        if card == self._operatingCard and self._tipsArray[card:getCardValue()] then
            -- 是不是要关掉可以听牌的标记
            if self._tipsNodes[idx] ~= nil then 
                self._tipsNodes[idx]:setVisible(false)
            end 
            self._tingTips:unbind()
            self._tingTips:setVisible(true)
            self._tingTips:bind(self._tipsArray[card:getCardValue()], card, longest == longestMap[card:getCardValue()] and longest > 1 and table.nums(self._tipsArray) > 1 and not isTheSame)
            -- 统计点击听牌的次数
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.HearingTips);
        elseif self._tipsArray[card:getCardValue()] then
            if self._tipsNodes[idx] ~= nil then 
                self._tipsNodes[idx]:bind(card, longest == longestMap[card:getCardValue()] and longest > 1 and table.nums(self._tipsArray) > 1 and not isTheSame, self._root)
                self._tipsNodes[idx]:setVisible(true)
            end 
        else
            if self._tipsNodes[idx] ~= nil then 
                self._tipsNodes[idx]:setVisible(false)
            end 
        end
    end
    -- 用不到的不显示
    for i = idx + 1, config.GlobalConfig.MAX_HAND_CARDNUMBER - 1 do
        if self._tipsNodes[i] ~= nil then 
            self._tipsNodes[i]:setVisible(false)
        end 
    end
end

function UIRoomSeat_Down:ManageCardsPositions(cardList, layout, setPos, cardsNeedPlaceHolder,isDrag)
    local res = self.super.ManageCardsPositions(self, cardList, layout, setPos, cardsNeedPlaceHolder,isDrag)
    -- 现在的代码已经不好掌控，只能在手牌变动的时候，同时处理一下提示信息 如果没有setPos 则不update
    if not isDrag then
        self:updateCardTips()
    end
    return res
end

function UIRoomSeat_Down:_getSelectedCard(cardlist, pt)
    if #(cardlist.handCards) > 0 then
        for _, card in ipairs(cardlist.handCards) do
            if card:isIn(pt) then
                return card
            end
        end
    end
end

-- 标记并弹出操作牌
function UIRoomSeat_Down:_popupOperatingCard(card)
    if Macro.assertTrue(self._canMulitSelect) then
        -- 只有多选的时候才有操作牌
        return;
    end

    -- 如果点击的牌忽视点击 则不弹出
    if card._ignoreClick == true then
        return
    end

    -- 非多选情况记录当前的操作牌
    if self._operatingCard ~= nil and self._operatingCard ~= card then
        -- 清除之前弹出的牌
        self:recoverOperatingCard();
    end

    -- 记录操作牌
    self._operatingCard = card;

    -- 弹出新的牌
    self:_popupCard(card);

    self:updateCardTips()
    -- 检测当前的同值牌
    self:syncCard(true, card)
end

-- 清除操作牌
function UIRoomSeat_Down:recoverOperatingCard()
    -- if Macro.assertTrue(self._canMulitSelect) then
    -- 只有多选的时候才有操作牌
    -- return;
    -- end    
    if self._canMulitSelect then
        return
    end

    if self._operatingCard == nil then
        -- 如果听牌提示在有显示则关掉
        if  self._tingTips ~= nil and self._tingTips:isVisible() == true then
            self:updateCardTips()
        end
        return;
    end

    -- 当前有可能在拖拽, 终止拖拽
    if self._draggingCard then
        self:_endDragging();
    end

    -- 恢复位置
    for _, card in ipairs(self._playerProcessor._cardList.handCards) do
        if card == self._operatingCard then
            self:_recoverPopupCard(self._operatingCard);
        end
    end
    -- 这里保险清空牌的时候也回复一下颜色
    self:syncCard(false, self._operatingCard)
    -- 清空操作牌
    self._operatingCard = nil;

    -- 情况双击标记
    self._operatingCardDoubleDown = false;

    -- 更新当前听牌显示
    self:updateCardTips(true)
end

-- 查找相同卡牌
function UIRoomSeat_Down:syncCard(b, card)
    local gameService = gameMode.mahjong.Context.getInstance():getGameService()
    if gameService then
        gameService:changeCardColor(b, card:getCardValue())
    end
end

-- 弹出指定一张牌
function UIRoomSeat_Down:_popupCard(card)
    local place = self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, false, { card })[card];
    card:setPosition(cc.p(place.pos.x, place.pos.y + self._touchProcessor:getOffset()));
    manager.AudioManager.getInstance():playEffect("sound/SFX/pai.mp3")
end

-- 收回一张弹出的牌
function UIRoomSeat_Down:_recoverPopupCard(card)
    local place = self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, false, { card })[card];
    card:setPosition(cc.p(place.pos.x, place.pos.y));
end

-- 回复所有弹出的牌
function UIRoomSeat_Down:_recoverAllPopupCards()
    self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, true);
end

-- 开始操作牌拖拽
function UIRoomSeat_Down:_startDragging()
    Macro.assertFalse(self._draggingCard == false);
    Macro.assertFalse(self._operatingCard ~= nil);
    -- 从未拖拽进入拖拽状态
    self._draggingCard = true;

    -- 创建影子牌
    for _, card in ipairs(self._playerProcessor._cardList.handCards) do
        if card == self._operatingCard then
            self:_createDraggingShadow(self._operatingCard);
            -- 拖动中的牌，要盖在其他牌上面
            self._operatingCard:setLocalZOrder(HU_HEAD_ZORDER + 1)
            return
        end
    end
    self._operatingCard = nil
end

-- 终止操作牌拖拽
function UIRoomSeat_Down:_endDragging()
    if self._draggingCard == false then
        return;
    end
    self._draggingCard = false;
    self._dragOut = false;

    if Macro.assertTrue(self._operatingCard == nil) then
        return;
    end

    -- 释放影子牌
    self:_releaseDraggingShadow();

    -- 复原拖动牌的位置, 但是还保持pop状态
    local place = self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, false, { self._operatingCard }, true)[self._operatingCard];
    self._operatingCard:setPosition(cc.p(place.pos.x, place.pos.y + self._touchProcessor:getOffset()));
end

-- 创建拖拽时的残影牌
function UIRoomSeat_Down:_createDraggingShadow(draggingCard)
    self:_releaseDraggingShadow();

    Macro.assertFalse(self._operatingCard == draggingCard);

    local card = CardFactory:getInstance():createCard2(self._chairType, CardDefines.CardState.Shoupai, draggingCard._cardValue, self._playerProcessor._cardList:getCardCornerTypes(draggingCard._cardValue), self:CARD_SCALE());
    card:disable();
    self:getCardParentNode():addChild(card);

    -- 残影位置保持跟拖动前一样, 位置与弹出状态高度一致
    local place = self:ManageCardsPositions(self._playerProcessor._cardList, self._cardLayout, false, { draggingCard }, true)[draggingCard];
    card:setPosition(cc.p(place.pos.x, place.pos.y + self._touchProcessor:getOffset()));
    card:setLocalZOrder(draggingCard:getLocalZOrder() - 1);

    self._shadowCard = card;
end

-- 释放拖拽时的残影牌
function UIRoomSeat_Down:_releaseDraggingShadow()
    if self._shadowCard == nil then
        return;
    end

    CardFactory:getInstance():releaseCard(self._shadowCard);
    self._shadowCard = nil;
end

-- 中断手牌操作，选中和拖拽
function UIRoomSeat_Down:_breakCardOperation()
    self:recoverOperatingCard();
    self._mouseDown = false;
end

------------------------------------
-- 手牌操作:多选模式
------------------------------------
-- 开启/关闭卡牌多选模式
-- @param can: boolean, 是否可以选中
-- @param callback: (card: Card, willSelect: boolean): boolean, 当一个牌点击时候的回调, 返回值为是否能够选中
function UIRoomSeat_Down:setMultiSelectedEnabled(can, callbackFunc)
    self._canMulitSelect = can;
    self._multiSelectWillSelectCallback = callbackFunc;

    self:_resetMultiSelectInfo();
end

-- @return Card[]
function UIRoomSeat_Down:getMuiltSelectCards()
    return self._multiSelectList;
end

function UIRoomSeat_Down:_onMultiSelectedCard(card, selected)
    if selected then
        -- 选中
        Macro.assertFalse(table.indexof(self._multiSelectList, card) == false);
        self._multiSelectList[#self._multiSelectList + 1] = card;
        self:_popupCard(card);
    else
        -- 取消选择
        local idx = table.indexof(self._multiSelectList, card);
        if Macro.assertFalse(idx >= 0) then
            table.remove(self._multiSelectList, idx)
            self:_recoverPopupCard(card);
        end
    end
end

-- 设置选中了哪些牌，这个方法只会把传入的参数设置为选中，并不会把已经选中的给取消
function UIRoomSeat_Down:setMultiSelectedCardByObjects(cardObjects)
    if Macro.assertFalse(self._canMulitSelect, 'multi select mode is disable') then
        table.foreach(cardObjects, function(_, object)
            self:_onMultiSelectedCard(object, true)
        end)
    end
end

function UIRoomSeat_Down:setMultiSelectedCardByValues(cardValues)
    if Macro.assertFalse(self._canMulitSelect, 'multi select mode is disable') then
        local handCardObjects = self._playerProcessor._cardList.handCards
        local selectedCardObejects = {}
        cardValues = { unpack(cardValues, 1, #cardValues) }
        table.foreach(handCardObjects, function(_, cardObject)
            local index = table.indexof(cardValues, cardObject._cardValue)
            if index then
                table.remove(cardValues, index)
                table.insert(selectedCardObejects, cardObject)
            end
        end)
        self:setMultiSelectedCardByObjects(selectedCardObejects)
        return selectedCardObejects
    end
end

function UIRoomSeat_Down:_resetMultiSelectInfo()
    self._multiSelectList = {};
    self:_recoverAllPopupCards();
end

function UIRoomSeat_Down:maskAllHandCards()
    table.foreach(self._playerProcessor._cardList.handCards, function(key, val)
        val:disable()
    end)
end

--[[	@param isSameJudge 当前是否是显示同牌
	@param cardValue 当前要处理的牌值
]]
function UIRoomSeat_Down:changeCardColor(isSameJudge, cardValue)
    -- 如果是自己，手牌也要处理，如果是观战应该不会进入这里
    local v = self._playerProcessor
    for i1, v1 in ipairs(v._cardList.handCards) do
        if v1:getCardValue() == cardValue then
            v1:changeColor(self:getColor("handCards", isSameJudge and self._operatingCard ~= v1), true)
        end
    end
    self.super.changeCardColor(self, isSameJudge, cardValue)
end

return UIRoomSeat_Down