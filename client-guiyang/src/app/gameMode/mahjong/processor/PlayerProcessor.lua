--[[--玩家打牌操作基类
--]]
local CardList = require("app.gameMode.mahjong.core.CardList")
local CardGroup = require("app.gameMode.mahjong.core.CardGroup")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local PlayStep = require("app.gameMode.mahjong.core.PlayStep")
local Constants = require("app.gameMode.mahjong.core.Constants")
local PlayType = Constants.PlayType
local SoundsInfo = require("app.gameMode.mahjong.core.SoundsInfo")
local UI_ANIM = require("app.manager.UIAnimManager")

local CommandCenter = require("app.manager.CommandCenter")
local PlayerFSM = require("app.gameMode.mahjong.processor.playerFSM.PlayerFSM")

local PlayerProcessor = class("PlayerProcessor")

function PlayerProcessor:ctor(roomUI, roomSeat, seatUI, enableClientDiscardCard)
	self._roomUI = roomUI;
	self._roomSeat = roomSeat;				-- 对应的座位
	self._seatUI = seatUI;
	self._nextIdleTime = kod.util.Time.now();					-- 下一次可以处理step的时间
	self._cardList = CardList.new(); 		-- 手上的牌
	self._isTingStatus = false	-- 当前是否为听牌只能胡的状态
	self._schedule = {}
	
	-- 设置支持的用户选择操作
	-- TODO : 调整到全局设置
	--[[k
	{
		op, 服务器提示的can操作
		targetOp, 对应的执行操作
		skip, 对应操作的图标
	}
	--]]
	self._operationSettings = {
		{op = PlayType.OPERATE_CAN_PASS, targetOp = PlayType.OPERATE_PASS, skin = "gaming/Btn_guo.png"},
		{op = PlayType.OPERATE_CAN_CHI_A_CARD, targetOp = PlayType.OPERATE_CHI_A_CARD, skin = "gaming/Btn_yl.png"},
		{op = PlayType.OPERATE_CAN_PENG_A_CARD, targetOp = PlayType.OPERATE_PENG_A_CARD, skin = "gaming/Btn_peng.png"},
		{op = PlayType.OPERATE_CAN_GANG_A_CARD, targetOp = PlayType.OPERATE_GANG_A_CARD, skin = "gaming/Btn_gang.png"},
		{op = PlayType.OPERATE_CAN_AN_GANG, targetOp = PlayType.OPERATE_AN_GANG, skin = "gaming/Btn_gang.png"},
		{op = PlayType.OPERATE_CAN_BU_GANG_A_CARD, targetOp = PlayType.OPERATE_BU_GANG_A_CARD, skin = "gaming/Btn_gang.png"},
		{op = PlayType.OPERATE_CAN_TING, targetOp = PlayType.OPERATE_TING, skin = "gaming/Btn_ting.png"},
		{op = PlayType.OPERATE_CAN_TING_CARD, targetOp = PlayType.OPERATE_TING_CARD, skin = "gaming/Btn_ting.png"},
		{op = PlayType.OPERATE_CAN_HU, targetOp = PlayType.OPERATE_HU, skin = "gaming/Btn_hu.png"},
		{op = PlayType.OPERATE_CAN_MEN, targetOp = PlayType.OPERATE_MEN, skin = "gaming/btn_mp.png"},
	}
	
	self._seatUI:setPlayerProcessor(self)
	
	-- 玩家状态机初始化
	self._stateMachine = PlayerFSM:new(self)
	self._stateMachine:enterState("PlayerState_Normal");
	
	-- 监听操作事件
	gameMode.mahjong.Context.getInstance():getGameService():addEventListener("PROC_STEP", function(event)
		self:_processStep(event.isRecover, event.stepGroup)
	end, self);
end

function PlayerProcessor:getPlayerFsm() return self._stateMachine end

function PlayerProcessor:dispose()
	self:clearForNextRound()
	self._cardList:dispose();
	self._seatUI:setPlayerProcessor(nil)
	gameMode.mahjong.Context.getInstance():getGameService():removeEventListenersByTag(self);
end

function PlayerProcessor:getRoomUI()
	return self._roomUI;
end

function PlayerProcessor:getRoomSeat()
	return self._roomSeat;
end

function PlayerProcessor:getSeatUI()
	return self._seatUI;
end

function PlayerProcessor:getCardList()
	return self._cardList;
end

function PlayerProcessor:_getOperationSetting(playType)
	for i, v in ipairs(self._operationSettings) do
		if v.op == playType then
			return v
		end
	end
	return nil;
end

function PlayerProcessor:clearForNextRound()
	self._seatUI:clearSeat()
	self._cardList:releaseAllCards()
	self._seatUI:clearShowCards()	
	self._stateMachine:enterState("PlayerState_Normal");
	self._cardList.lastDrewCard = nil
	
	table.foreach(self._schedule, function(k, v)
		unscheduleOnce(v)
	end)
	self._schedule = {}
end

-- 获取该Processor下次可以处理Step的时间
function PlayerProcessor:getNextIdleTime()
	return self._nextIdleTime;
end

-- 设置下次可以处理step的时间
function PlayerProcessor:addNextIdleTime(elapse)
	local nextTime = kod.util.Time.now() + elapse
	self._nextIdleTime = self._nextIdleTime < nextTime and nextTime or self._nextIdleTime
end

-- 获取其他人的processor
function PlayerProcessor:_getOtherPlayerProcessor(targetId)
	Logger.info("PlayerProcessor:_getOtherPlayerProcessor targetId = %d", targetId)
	return gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(targetId)
end

-- 处理step
-- @param isRecover: boolean
-- @param stepGroup: PlayStep[]
-- @return void
function PlayerProcessor:_processStep(isRecover, stepGroup)
	-- 基本打牌逻辑处理
	local firstStep = stepGroup[1];
	-- game.service.LocalPlayerService.getInstance():dispatchEvent({name = "GAME_UPDATE_TING_CARDS_NUM"})
	-- 为了处理
	if firstStep:getPlayType() == PlayType.OPERATE_LIGHT then
		--处理断线重连后指示灯错误
		self._seatUI._parentUI:showWaitingOperationIndicator(self._seatUI._parentUI:getPlayerSeat(firstStep._sourceRoleId))
	end
	
	-- 忽略不是自己的操作
	if self._roomSeat:hasPlayer() == false
	or firstStep:getRoleId() ~= self._roomSeat:getPlayer().id then
		return
	end
	
	if firstStep:getPlayType() == PlayType.OPERATE_DEAL then
		-- 摸牌
		Macro.assetFalse(isRecover == false)
		self:_onDrawCard(firstStep._cards[1])
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_PLAY_A_CARD then
		-- 可打牌
		Macro.assetFalse(isRecover == false)
		self:_onDiscardable(PlayType.OPERATE_PLAY_A_CARD, firstStep._cards);
	elseif firstStep:getPlayType() == PlayType.OPERATE_PLAY_A_CARD then
		-- 打牌
		Macro.assetFalse(isRecover == false)
		self:_onDiscardCard(firstStep._cards[1]);
		self:getRoomUI():cancelTrustCountDown()
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_AUTO_PLAY_LAST_DEALED_CARD then
		-- 自动打牌
		Macro.assetFalse(isRecover == false)
		self:_onAutoDiscardable(firstStep._cards[1]);
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP then
		--处理托管		
		self:_onTrusteeship(true)
		
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP_CANCLE then
		--处理托管
		self:_onTrusteeship(false)
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP_DELAY_TIME then
		--处理托管等待时间
		self:_onTrusteeshipDelayTime(firstStep)
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP_DELAY_TIME_ALL then
		--处理托管等待时间
		self:_onTrusteeshipDelayTime(firstStep)
	elseif firstStep:getPlayType() == PlayType.OPERATE_CHI_A_CARD then
		-- 吃
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		self:_onChi(isRecover, firstStep._cards, firstStep._sourceRoleId);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.OPERATE_PENG_A_CARD then
		-- 碰
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		self:_onPeng(isRecover, firstStep._cards, firstStep._sourceRoleId);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.OPERATE_GANG_A_CARD then
		-- 明杠
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		self:_onGang(isRecover, firstStep._cards, firstStep._sourceRoleId);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.OPERATE_AN_GANG then
		-- 暗杠
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		self:_onAnGang(isRecover, firstStep._cards, firstStep._sourceRoleId);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.OPERATE_PASS then
		-- 过
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.OPERATE_BU_GANG_A_CARD then
		-- 补杠
		self._seatUI:clearOpButtons();
		self:getRoomUI():cancelTrustCountDown()
		self:_onBuGang(isRecover, firstStep._cards, firstStep._sourceRoleId);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.DISPLAY_BE_CHI
	or firstStep:getPlayType() == PlayType.DISPLAY_BE_PENG
	or firstStep:getPlayType() == PlayType.DISPLAY_BE_GANG
	or firstStep:getPlayType() == PlayType.DISPLAY_BE_MEN then
		-- 被吃,被碰,被杠,被胡
		Macro.assetFalse(isRecover == false)
		self:_onRemoveDiscardedCard(firstStep._cards[1]);
		game.service.LocalPlayerSettingService.getInstance():dispatchEvent({name = "EVENT_CLOSE_CARD_SCALE"})
	elseif firstStep:getPlayType() == PlayType.DISPLAY_LIANZHUANG_COUNT then
		self._seatUI:updateBankerCount(firstStep._cards[1])
		-- elseif firstStep:getPlayType() == PlayType.DISPLAY_LIAN_ZHUANG then
-- 	self._seatUI:updateBankerCount(firstStep._cards[1])
-- 	self._seatUI:clearOpButtons();
-- 	if isRecover == false then
-- 		self:getRoomUI():playAnim(firstStep:getPlayType())
-- 	end
-- 	self._seatUI:setStatusImage(true, firstStep:getPlayType())
-- elseif firstStep:getPlayType() == PlayType.OPERATE_HU then
-- 	-- 胡牌
-- 	self:_onHu(isRecover, firstStep._cards[1]);
	elseif firstStep:getPlayType() == PlayType.HU_GANG_SHANG_HUA then
	elseif firstStep:getPlayType() == PlayType.DISPLAY_FINISH_ALL then
		Macro.assetFalse(false)	
	else
		local time = CommandCenter.getInstance():executeCommand(firstStep:getPlayType(), {isRecover, stepGroup, self})
		return time or - 1
	end
end

function PlayerProcessor:onRoundFinished()
	
end

-- @param outCards: number[]
-- @param handCards:  number[]
-- @param operateCards: PlayStep[]
function PlayerProcessor:onGameStarted(outCards, handCards, operateCards, isRecover, isReplay)
	local player = self._roomSeat:getPlayer();
	local seatUI = self._seatUI;
	
	-- 开局才能设置庄家
	seatUI:setBanker(player:isBanker())
	-- 开局后，隐藏准备按钮
	seatUI:setPlayerReady(false)
	-- 开局隐藏掉邀请界面
	if UIManager:getInstance():getIsShowing("UIFriendRoomInvite") then
		UIManager:getInstance():destroy("UIFriendRoomInvite")
	end
	if UIManager:getInstance():getIsShowing("UIClubRoomInvite") then
		UIManager:getInstance():destroy("UIClubRoomInvite")
	end
	
	-- 初始化已经打出的牌
	for i = 1, #outCards do
		local cardIndex =(i - 1) % seatUI._cardLayout.discardedLayout.lineSize + 1
		local roomService = game.service.RoomService.getInstance();
		local playerCount = roomService:getMaxPlayerCount();	-- 玩家人数
		
		local cardValue = 1
		if i <= #outCards then
			cardValue = string.byte(outCards, i);
		end
		local card = seatUI:createCard(CardDefines.CardState.Chupai, cardValue, self._cardList:getCardCornerTypes(cardValue), seatUI:DISCARD_SCALE(i), cardIndex)
		card:changeColor(seatUI:getCardLayout().discardColor, 1)
		self._cardList:addDiscardedCard(card)
	end
	
	-- 初始化手牌
	for i = 1, #handCards do
		local cardValue = string.byte(handCards, i);
		local card_scale = seatUI:CARD_SCALE()
		if seatUI:getChairType() ~= CardDefines.Chair.Down and cardValue ~= 255 then
			card_scale = seatUI:GROUP2_SCALE()
		end
		local card = seatUI:createCard(CardDefines.CardState.Shoupai, cardValue, self._cardList:getCardCornerTypes(cardValue), card_scale, i)
		if config.getIs3D() and seatUI._resizeCard then
			seatUI:_resizeCard(card, i - 1)
		end
		self._cardList:addHandCard(card)
	end
	
	-- 执行CardHeap操作
	for i = 1, #operateCards do
		local stepGroup = {}
		-- 加个打印协议的log，定位线上问题
		if operateCards[i].playType ~= nil and operateCards[i].playType == PlayType.OPERATE_PENG_A_CARD then
			Logger.debug("peng bug log=>PlayType:" .. operateCards[i].playType)
			if Macro.assertFalse(operateCards[i].roleId ~= nil) then
				Logger.debug("peng bug log=>roleId:" .. operateCards[i].roleId)
			end
			if Macro.assertFalse(operateCards[i].roleId ~= nil) then
				Logger.debug("peng bug log=>sourceRoleId:" .. operateCards[i].sourceRoleId)
			end
			if Macro.assertFalse(operateCards[i].roleId ~= nil) then
				Logger.debug("peng bug log=>cards:" .. json.encode(CardDefines.getCards(operateCards[i].cards)))
			end
		end
		table.insert(stepGroup, PlayStep.new():setProto(operateCards[i]))
		self:_processStep(isRecover, stepGroup);
	end
	
	-- 开局打印首牌信息
	Logger.debug("=>PlayerId:" .. player.id)
	Logger.debug("=>DiscardCards:" .. json.encode(CardDefines.getCards(outCards)))
	Logger.debug(self._cardList:toStrings())
	-- 手牌布局
	seatUI:ManageCardsPositions(self._cardList, seatUI:getCardLayout(), true)
	seatUI:ManageDiscardedMahjongPositions(self._cardList, seatUI:getCardLayout(), true)
end

-- 摸牌
function PlayerProcessor:_onDrawCard(cardValue)
	local card_scale =(not config.getIs3D() and self._seatUI:getChairType() ~= CardDefines.Chair.Down and cardValue ~= 255) and self._seatUI:GROUP2_SCALE() or self._seatUI:CARD_SCALE();
	local card = self._seatUI:createCard(CardDefines.CardState.Shoupai, cardValue, self._cardList:getCardCornerTypes(cardValue), card_scale, 13);
	self._cardList:addHandCard(card)
	-- Macro.assetFalse(self._cardList.lastDrewCard == nil);
	self._cardList.lastDrewCard = card;
	
	self._seatUI:onDrawCard(self._cardList.lastDrewCard);
	self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
end

-- 托管
function PlayerProcessor:_onTrusteeship(tf)
	local chairType = self._roomSeat:getChairType()
	self._seatUI._parentUI:getSeatUI(chairType):setTrusteeshipIcon(tf)
end

-- 托管 超时时间
function PlayerProcessor:_onTrusteeshipDelayTime(step)
	local step = step
	local second = step:getDatas() [1]
	if second ~= nil then
		game.service.CampaignService.getInstance():dispatchEvent({name = "EVENT_CAMPAIGN_CHANGE_COUNTDOWN", sec = math.ceil(second / 1000), chair = self._seatUI:getChairType()})
	end
end

-- 可出牌
-- @param playType: number
-- @param cardNumbers: number[]
function PlayerProcessor:_onDiscardable(playType, cardNumbers)
	-- -- 如果碰牌后，轮到自己出牌的时候，此时复牌，所有牌都会在左边，会多一张牌, 此时，把最后一张牌当作摸牌，放置在最右侧
	-- if self._cardList.lastDrewCard == nil then
	-- 	self._cardList.lastDrewCard = self._cardList.handCards[#self._cardList.handCards];
	-- 	self._seatUI:ManageDiscardedMahjongPositions(self._cardList, self._seatUI:getCardLayout(), true)
	-- end	
	-- 显示操作指示器
	self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
end

-- 可出牌
-- @param cardValue: number
function PlayerProcessor:_onAutoDiscardable(cardValue)
	-- 如果碰牌后，轮到自己出牌的时候，此时复牌，所有牌都会在左边，会多一张牌, 此时，把最后一张牌当作摸牌，放置在最右侧
	-- if self._cardList.lastDrewCard == nil then
	-- 	self._cardList.lastDrewCard = self._cardList.handCards[#self._cardList.handCards];
	-- 	self._seatUI:ManageDiscardedMahjongPositions(self._cardList, self._seatUI:getCardLayout(), true)
	-- end	
	-- 显示操作指示器
	self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
end

-- 出牌
--@return number, 下个操作的等待时间
function PlayerProcessor:_onDiscardCard(cardValue)
	Macro.assetFalse(false, "abstract method");
end

-- 打牌处理
-- @param cardValue: number
-- @param cardDiscard: Card
function PlayerProcessor:_onDiscardCard_Internal(cardValue, cardDiscard)
	-- Macro.assetFalse(self._cardList.lastDrewCard ~= nil)
	-- 打出牌
	self._cardList:removeHandCard(cardDiscard);
	
	if cardDiscard ~= self._cardList.lastDrewCard and self._cardList.lastDrewCard ~= nil then
		-- 如果打的不是摸的那一张，需要重排并计算摸牌的位置，做摸牌的插入动画
		local lastDrewCard = self._cardList.lastDrewCard;
		self._cardList.lastDrewCard = nil;
		self._seatUI:onInsertDrewCard(lastDrewCard);
	else
		-- 打掉摸得牌
		self._cardList.lastDrewCard = nil;
		self._seatUI:ManageCardsPositions(self._cardList, self._seatUI:getCardLayout(), true);
	end
	
	-- 回收牌
	CardFactory:getInstance():releaseCard(cardDiscard)
	
	-- 打出牌的时候，打印一下
	Logger.debug("=>RoleId:" .. tostring(self._roomSeat:getPlayer().id))
	Logger.debug("=>DiscardCard:" .. cardValue)
	-- 向出牌区打出一张牌
	self._seatUI:onDiscardACard(cardValue, self._isTingStatus);
	
	self._cardList.lastDrewCard = nil
	SoundsInfo:getInstance():playSound(cardValue, self._roomSeat:getPlayer().sex)
end

-- 从打出的牌中删除指定牌
function PlayerProcessor:_onRemoveDiscardedCard(cardValue, stepGroup)
	if Macro.assetFalse(#self._cardList.discardedCardList > 0, "[ERROR]OnRemoveDiscardedCardFailed") then
		-- 删掉最后一张
		local removedCard = self._cardList:removeDiscardedCardTail(cardValue);
		if Macro.assetFalse(removedCard ~= nil) then
			CardFactory:getInstance():releaseCard(removedCard)
		end
		
		-- TODO : 重新排序		
		--		self.ManageDiscardedMahjongPositions(self.cardLayout, true);
		Logger.debug(">=============_onRemoveDiscardedCard[NORMAL]===============<")
		Logger.debug("cardValue:" .. cardValue)
	else
		-- TODO： 删除失败，打印一下当前玩家的相关信息
		Logger.debug(">===============ERROR-START=================<")
		Logger.debug("RoleId:" .. tostring(game.service.LocalPlayerService.getInstance():getRoleId()) .. " RoomId:" .. game.service.RoomService:getInstance():getRoomId())
		Logger.debug(self._cardList:toStrings())
		
		-- 打印playstep
		if stepGroup then
			-- 当前的playstep有可是能复数个
			for idx = 1, #stepGroup do
				Logger.debug("PlayStep:%d,%d,%d,%s",
				stepGroup[idx]:getPlayType(),
				stepGroup[idx]:getRoleId(),
				stepGroup[idx]:getSourceRoleId(),
				json.encode(stepGroup[idx]._cards))
			end
		end
		Logger.debug(">================ERROR-END==================<")
	end
	
	-- 隐藏操作指示器
	self._roomUI:hideDiscardedCardIndicator();
end

-- 提示听操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor:_onWaitingTingCardOperation(stepGroup)
	Macro.assetFalse(false, "abstract method");
end

-- 提示除了听之外的其他操作操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor:_onWaitingOtherOperation(stepGroup)
	Macro.assetFalse(false, "abstract method");
end

-- 提示当前吃碰扛的来源
function PlayerProcessor:_showTips(cardGroup, targetId)
	local cardPos = {
		[CardDefines.Chair.Down]	= 2,
		[CardDefines.Chair.Right]	= 1,
		[CardDefines.Chair.Top]	= 2,
		[CardDefines.Chair.Left]	= 3,
	}
	Logger.info("PlayerProcessor:_showTips targetId = %d", targetId)
	local processor = self:_getOtherPlayerProcessor(targetId)
	if Macro.assertFalse(processor ~= nil, "PlayerProcessor _showTips") then
		local targetChair = processor:getSeatUI():getChairType();
		local pos =(targetChair < self._seatUI:getChairType() and 4 + targetChair or targetChair) - self._seatUI:getChairType() + 1
		local cp = cardPos[self._seatUI:getChairType()]
		if cardGroup.cardState == CardDefines.CardState.GangPai or cardGroup.cardState == CardDefines.CardState.GangPai2 then
			cp = 4
		end
		local card = cardGroup.cards[cp]
		card:showTips(pos)
	end
end

function PlayerProcessor:_createCard(chairType, cardState, cardValue, tagIconType, cardScale, cardIndex)
	return self._seatUI:createCard(cardState, cardValue, tagIconType, cardScale, cardIndex)
end

-- 吃
-- @param isRecover: boolean
-- @param  cardNumbers: number[]
-- @param  targetId: number
-- @return number, 延迟时间
function PlayerProcessor:_onChi(isRecover, cardNumbers, targetId)
	-- 吃:第一张牌是要吃别人的牌
	local targetCard = cardNumbers[1];
	if isRecover then
		-- 复牌
		-- 第一张为吃的排
		local chiNumber = cardNumbers[1];
		table.sort(cardNumbers);
		local chiGroup = CardGroup.new(CardDefines.CardState.ChiPai);
		-- 当前有的吃碰杠的总组数
		local startIndex = #self._cardList.cardGroups * 3
		for idx = 1, 3 do
			local cardValue = cardNumbers[idx];
			local card = self:_createCard(self._seatUI:getChairType(), CardDefines.CardState.ChiPai, cardValue, false, self._seatUI:GROUP_SCALE(), startIndex + idx);
			table.insert(chiGroup.cards, card);
		end
		table.insert(self._cardList.cardGroups, chiGroup)
		self:_showTips(chiGroup, targetId)
		return 0;
	else
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.Chi, self._roomSeat:getPlayer().sex)
		return self:_doCombineAnimation(CardDefines.CardState.ChiPai, cardNumbers, targetCard, targetId);
	end
end

-- 碰
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor:_onPeng(isRecover, cardNumbers, targetId)
	if isRecover then
		-- 复牌
		-- 当前有的吃碰杠的总组数
		local startIndex = #self._cardList.cardGroups * 3
		local pengGroup = CardGroup.new(CardDefines.CardState.Pengpai);
		for j = 1, 3 do
			local card = self:_createCard(self._seatUI:getChairType(), CardDefines.CardState.Pengpai, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), startIndex + j);
			table.insert(pengGroup.cards, card)
		end
		table.insert(self._cardList.cardGroups, pengGroup)
		self:_showTips(pengGroup, targetId)
		return 0;
	else
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.Peng, self._roomSeat:getPlayer().sex)
		return self:_doCombineAnimation(CardDefines.CardState.Pengpai, cardNumbers, nil, targetId);
	end
end

-- 明杠
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor:_onGang(isRecover, cardNumbers, targetId)
	if isRecover then
		-- 复牌
		local gangGroup = CardGroup.new(CardDefines.CardState.GangPai);
		
		-- 当前有的吃碰杠的总组数
		local startIndex = #self._cardList.cardGroups * 3
		
		for j = 1, 4 do
			local index = j == 4 and 2 or j
			local card = self:_createCard(self._seatUI:getChairType(), CardDefines.CardState.GangPai, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), startIndex + index);
			if j == 4 then
				-- 最后一张是上面的那张
				gangGroup.cardTop = card;
			end			
			table.insert(gangGroup.cards, card)
		end
		
		table.insert(self._cardList.cardGroups, gangGroup)
		self:_showTips(gangGroup, targetId)
		return 0;
	else
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.MingGang, self._roomSeat:getPlayer().sex)
		return self:_doCombineAnimation(CardDefines.CardState.GangPai, cardNumbers, nil, targetId);
	end
end

-- 暗杠
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor:_onAnGang(isRecover, cardNumbers, targetId)
	if isRecover then
		-- 当前有的吃碰杠的总组数
		local startIndex = #self._cardList.cardGroups * 3
		-- 复牌
		local gangGroup = CardGroup.new(CardDefines.CardState.GangPai2);
		for j = 1, 3 do
			local card = self:_createCard(self._seatUI:getChairType(),
			CardDefines.CardState.GangPai2, cardNumbers[1],
			false,
			self._seatUI:GROUP_SCALE(), startIndex + j);
			table.insert(gangGroup.cards, card)
		end
		
		-- 最后一张是上面的那张
		gangGroup.cardTop = self:_createCard(self._seatUI:getChairType(),
		CardDefines.isValidCardNumber(cardNumbers[1]) and CardDefines.CardState.GangPai or CardDefines.CardState.GangPai2, cardNumbers[1],
		false,
		self._seatUI:GROUP_SCALE(), startIndex + 2);
		table.insert(gangGroup.cards, gangGroup.cardTop)
		table.insert(self._cardList.cardGroups, gangGroup)
		self:_showTips(gangGroup, targetId)
		return 0;
	else
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.AnGang, self._roomSeat:getPlayer().sex)
		return self:_doCombineAnimation(CardDefines.CardState.GangPai2, cardNumbers, nil, targetId);
	end
end

-- 补杠
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor:_onBuGang(isRecover, cardNumbers, targetId)
	if isRecover then
		-- 当前有的吃碰杠的总组数
		local startIndex = #self._cardList.cardGroups * 3
		-- 复牌
		local gangGroup = CardGroup.new(CardDefines.CardState.GangPai);
		for j = 1, 4 do
			local index = j == 4 and 2 or j
			
			local card = self:_createCard(self._seatUI:getChairType(), j == 4 and CardDefines.CardState.GangPai2 or CardDefines.CardState.GangPai, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), startIndex + index);
			if j == 4 then
				-- 最后一张是上面的那张
				gangGroup.cardTop = card;
			end
			table.insert(gangGroup.cards, card)
		end
		table.insert(self._cardList.cardGroups, gangGroup)
		self:_showTips(gangGroup, targetId)
		gangGroup.cards[4]:showTips(- 1)
		return 0;
	else
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.BuGang, self._roomSeat:getPlayer().sex)
		return self:_doBuGang(cardNumbers[1]);
	end
end

function PlayerProcessor:_getGangEffect()
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() or
	game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold then
		return
	end
	local effects = self._roomSeat:getPlayer():getSpecialEffect();
	local effect = nil
	if effects ~= nil then
		table.foreach(effects, function(k, v)
			if Constants.EffectMap.gang[v] ~= nil then
				effect = Constants.EffectMap.gang[v]
			end
		end)
	end
	local anim = nil
	if effect ~= nil then
		anim = UI_ANIM.UIAnimConfig.new(effect, nil, nil, nil, 5)
	end
	return anim
end

-- 听牌
-- @param isRecover:是否是复牌
function PlayerProcessor:_onTing(isRecover)
	self._seatUI:setStatusImage(true, "mahjong_tile/img_55.png")
	if not isRecover then
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.TianTing, self._roomSeat:getPlayer().sex)
	end
	return 0;
end

-- 胡牌 TODO : 当前全都放到了胡牌区
function PlayerProcessor:_onHu(isRecover, cardValue)
	if self.enableMutilHu then
		-- 多次胡牌才会放到胡牌区
		local state = CardState.Chupai
		if config.getIs3D() then
			state = CardState.MingPai
		end
		local card = CardFactory.createCard(self.chairType, state, cardValue, self._cardList:getCardCornerTypes(cardValue), HUA_CARD_SCALE, 13)
		self._cardList.huCards.push(card);
		self.parent.addChild(card);
		--self.imgHu.visible = true;
		if isRecover == false then
			self.ManageHuPositions(self.cardLayout, true);
		end
	end
	if not isRecover then
		SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.HU, self._roomSeat:getPlayer().sex)
	end
	return 0;
end

-- 自摸时,删除刚摸的手牌
function PlayerProcessor:_onZiMo(cardValue)
	if self._cardList.lastDrewCard ~= nil then
		self._cardList.removeHandCard(self._cardList.lastDrewCard);
		CardFactory:getInstance():releaseCard(self._cardList.lastDrewCard);
		self._cardList.lastDrewCard = nil;
	end
	SoundsInfo:getInstance():playSound(Constants.SFX_OpKey.ZiMo, self._roomSeat:getPlayer().sex)
end

-- 点炮时,删除放炮的牌
function PlayerProcessor:_onBeHu(cardValue)
	self:_onRemoveDiscardedCard(cardValue);
end

-- 吃,碰,明杠,暗杠的动画处理
-- @param cardState: CardState
-- @param cardNumbers: number[]
-- @param targetCard: number
-- @param targetId: number
function PlayerProcessor:_doCombineAnimation(cardState, cardNumbers, targetCard, targetId)
	local gangEffect = nil
	-- 当前有的吃碰杠的总组数
	local startIndex = #self._cardList.cardGroups * 3
	
	-- 删除对应的手牌
	self:removeOperationCards(cardState, cardNumbers, targetCard);
	-- 这几种类型牌处理时 有操作的牌 回复颜色
	-- 创建牌
	local cardGroup = nil
	if cardState == CardDefines.CardState.ChiPai then
		-- -- 为了保证手牌排序,设置刚摸得牌
		-- self._cardList.lastDrewCard = self._cardList.handCards[#self._cardList.handCards];
		-- 创建吃牌组
		cardGroup = CardGroup.new(cardState);
		
		local chiNumber = cardNumbers[1];
		table.sort(cardNumbers)
		for i = 1, 3 do
			local card = self:_createCard(self._seatUI:getChairType(), cardState, cardNumbers[i], false, self._seatUI:GROUP_SCALE(), - 1);
			table.insert(cardGroup.cards, card)
		end
		
		self._cardList.cardGroups[#self._cardList.cardGroups + 1] = cardGroup
	elseif cardState == CardDefines.CardState.Pengpai then
		-- -- 为了保证手牌排序,设置刚摸得牌
		-- self._cardList.lastDrewCard = self._cardList.handCards[#self._cardList.handCards];
		-- 创建碰牌组
		cardGroup = CardGroup.new(cardState);
		for i = 1, 3 do
			local card = self:_createCard(self._seatUI:getChairType(), cardState, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), - 1);
			table.insert(cardGroup.cards, card)
		end
		
		self._cardList.cardGroups[#self._cardList.cardGroups + 1] = cardGroup
	elseif cardState == CardDefines.CardState.GangPai or cardState == CardDefines.CardState.GangPai2 then
		-- 杠之后要重新摸一张,为了排布没有问题,清楚最后摸得牌
		self._cardList.lastDrewCard = nil;
		
		-- 创建杠牌组
		cardGroup = CardGroup.new(cardState);
		for i = 1, 3 do
			local card = self:_createCard(self._seatUI:getChairType(), cardState, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), - 1);
			table.insert(cardGroup.cards, card)
		end
		
		-- 杠牌，创建第四张牌，即放在上面的那一张, 上面这张牌永远是有牌面的.
		local card = self:_createCard(self._seatUI:getChairType(), CardDefines.isValidCardNumber(cardNumbers[1]) and CardDefines.CardState.GangPai or CardDefines.CardState.GangPai2, cardNumbers[1], false, self._seatUI:GROUP_SCALE(), - 1)
		cardGroup.cardTop = card
		table.insert(cardGroup.cards, card)
		
		table.insert(self._cardList.cardGroups, cardGroup)
		gangEffect = self:_getGangEffect()
	end
	self:_showTips(cardGroup, targetId)
	
	-- 重新排布, 空出来刚形成的card
	self._seatUI:ManageDiscardedMahjongPositions(self._cardList, self._seatUI:getCardLayout(), true)
	
	-- 构造动画数据
	-- 因为横牌的存在，这里用固定值，不再适合
	local cardLayout = self._seatUI:getCardLayout()
	local selfChair = self._seatUI:getChairType()
	--TODO 临时解决方案把3D下的左侧倍率调整一下
	local cardStartScal = 1.5 * self._seatUI:GROUP_SCALE(true)
	local tranScale = 1.5
	local widths = {
		cc.pMul(cardLayout.bgAcvanceLie, 0.5 * tranScale),
		cc.pMul(cardLayout.bgAcvanceLie, 0.5 * tranScale),
		cc.pMul(cardLayout.bgAcvanceLie, 0.5 * tranScale),
	}
	local animPositions = {
		{
			-- 左边牌
			-- 起始zOrder
			zOrder = cardLayout.discardedAniStartZOrder - cardLayout.zOrderAcvance,
			-- 起始位置
			start = cc.pSub(cardLayout.discardedAniStart, cc.pMul(cardLayout.bgAcvanceLie, 4)),
			-- 目标位置
			_end = cc.pSub(cardLayout.discardedAniStart, cc.pAdd(widths[2], widths[1])),
		},
		{
			-- 中间牌
			zOrder = cardLayout.discardedAniStartZOrder,
			start = cardLayout.discardedAniStart,
			_end = cardLayout.discardedAniStart,
		},
		{
			-- 右边牌
			zOrder = cardLayout.discardedAniStartZOrder + cardLayout.zOrderAcvance,
			start = cc.pAdd(cardLayout.discardedAniStart, cc.pMul(cardLayout.bgAcvanceLie, 4)),
			_end = cc.pAdd(cardLayout.discardedAniStart, cc.pAdd(widths[2], widths[3])),
		},
		{
			-- 上面牌
			zOrder = cardLayout.discardedAniStartZOrder + cardLayout.gangZOrderOffset,
			start = cc.pSub(cardLayout.discardedAniStart, cardLayout.gangOffset),
			_end = cc.pSub(cardLayout.discardedAniStart, cardLayout.gangOffset),
		},
	}
	if config.getIs3D() then
		animPositions = {
			{
				-- 左边牌
				-- 起始zOrder
				zOrder = cardLayout.discardedAniStartZOrder - cardLayout.zOrderAcvance,
				-- 起始位置
				start = cc.pSub(cardLayout.discardedAniStart, cc.pMul(cardLayout.bgAcvanceLie, 4)),
				-- 目标位置
				_end = cc.pSub(cardLayout.discardedAniStart, cc.pAdd(widths[2], widths[1])),
			},
			{
				-- 中间牌
				zOrder = cardLayout.discardedAniStartZOrder,
				start = cardLayout.discardedAniStart,
				_end = cardLayout.discardedAniStart,
			},
			{
				-- 右边牌
				zOrder = cardLayout.discardedAniStartZOrder + cardLayout.zOrderAcvance,
				start = cc.pAdd(cardLayout.discardedAniStart, cc.pMul(cardLayout.bgAcvanceLie, 4)),
				_end = cc.pAdd(cardLayout.discardedAniStart, cc.pAdd(widths[2], widths[3])),
			},
			{
				-- 上面牌
				zOrder = cardLayout.discardedAniStartZOrder + cardLayout.gangZOrderOffset,
				start = cc.pAdd(cardLayout.discardedAniStart, cc.pMul(cardLayout.gangOffset, 4)),
				_end = cc.pAdd(cardLayout.discardedAniStart, cc.pMul(cardLayout.gangOffset, tranScale)),
			},
		}
	end
	
	-- 执行动画
	self._seatUI:ManageCardsPositions(self._cardList, cardLayout, true)
	
	
	for i = 1, #cardGroup.cards do
		local card = cardGroup.cards[i]
		card:setPosition(animPositions[i].start)
		card:setScale(cardStartScal)
		card:setZOrder(animPositions[i].zOrder)
		
		local move1 = cc.MoveTo:create(0.1, cc.p(animPositions[i]._end.x, animPositions[i]._end.y))
		local delay1 = cc.DelayTime:create(0.3)
		local placeHolder = self._seatUI:ManageCardsPositions(self._cardList, cardLayout, false, cardGroup.cards) [card]
		local move2 = cc.MoveTo:create(0.1, cc.p(placeHolder.pos.x, placeHolder.pos.y))
		local delay2 = cc.DelayTime:create(0.1)
		
		local cardIndex = startIndex + i
		if i == 4 then
			cardIndex = startIndex + 2
		end
		local callback1 = cc.CallFunc:create(function()
			if(config.getIs3D()) then
				card:resetCardCsbFor3DIndex(self._seatUI:getShowCardIndex(card._cardState, cardIndex))
			end
		end)
		local scale2 = cc.ScaleTo:create(0.1, self._seatUI:GROUP_SCALE())
		local spwan2 = cc.Spawn:create(move2, scale2)
		
		local callback2 = cc.CallFunc:create(function()
			card:setZOrder(placeHolder.zOrder)
		end)
		if i == #cardGroup.cards then
			local this = self
			callback2 = cc.CallFunc:create(function()
				card:setZOrder(placeHolder.zOrder)
				this._seatUI:ManageCardsPositions(self._cardList, cardLayout, true)
			end)
		end
		local seq = cc.Sequence:create(move1, delay1, callback1, spwan2, delay2, callback2)
		card:runAction(seq)
	end
	
	if cardGroup.cards[2] ~= nil and gangEffect ~= nil then
		local effectCb = function()
			if gangEffect ~= nil then
				local anim = UI_ANIM.UIAnimManager:getInstance():onShow(gangEffect)
				anim._csbAnim:setPositionX(cardGroup.cards[2]:getPositionX())
				anim._csbAnim:setPositionY(cardGroup.cards[2]:getPositionY())
			end
		end
		local schedule = scheduleOnce(effectCb, 0.65)		
		table.insert(self._schedule, schedule)
	end	
end

-- 补杠
function PlayerProcessor:_doBuGang(cardValue)
	-- 找到对应的碰组
	local gangEffect = self:_getGangEffect()
	--	local pengGroup = Collection.FirstOrDefault(self._cardList.cardGroups, n => (n.cardState == CardDefines.CardState.Pengpai && n.GetCardValue() == cardValue));
	local pengGroup = nil
	local groupIndex = 0
	table.foreach(self._cardList.cardGroups, function(key, val)
		if val.cardState == CardDefines.CardState.Pengpai and val:getCardValue() == cardValue then
			pengGroup = val
			groupIndex = key
		end
	end)
	if Macro.assetTrue(pengGroup == nil, "Invalid bugang: %d", cardValue) then
		return;
	end
	
	-- 删除手中的牌
	-- 这里的杠有两种情况，一种是过杠，一种是正常补杠，如果是过杠的话，牌值跟摸值是不同的
	if self._cardList.lastDrewCard ~= nil then
		if CardDefines.isValidCardNumber(self._cardList.lastDrewCard._cardValue) then
			-- 当前是有效的牌值
			if self._cardList.lastDrewCard._cardValue == cardValue then
				-- 补的牌就是刚摸到的牌
				self._cardList:removeHandCard(self._cardList.lastDrewCard);
				CardFactory:getInstance():releaseCard(self._cardList.lastDrewCard);
				self._cardList.lastDrewCard = nil;
			else
				-- 补的牌不是刚摸到的牌, 找到对应的牌
				local cards = {}
				table.foreach(self._cardList.handCards, function(key, val)
					if val._cardValue == cardValue then
						table.insert(cards, val)
					end
				end)
				-- 一次只应该移除一个
				while #cards > 1 do
					table.remove(cards, 1)
				end
				if #cards > 0 then
					-- 删除牌
					local card = cards[1]
					table.remove(cards, 1)
					self._cardList:removeHandCard(card);
					CardFactory:getInstance():releaseCard(card);
				end
				
				-- 将最后摸得牌放入手牌
				self._cardList.lastDrewCard = nil;
			end
		else
			-- 当前牌不是有效的, 随意删除一张
			self._cardList.lastDrewCard = nil
			CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
			table.remove(self._cardList.handCards, 1)
		end
	end
	
	-- 将碰改为杠
	pengGroup.cardState = CardDefines.CardState.GangPai;
	-- 补杠的那张牌方向与中间的那张牌相同
	local midCardChair = pengGroup.cards[2]:getChairType();
	--当前牌的位置(3D麻将需要)
	local cardIndex =(groupIndex - 1) * 3 + 2
	local card = self:_createCard(midCardChair, CardDefines.CardState.GangPai2, cardValue, false, self._seatUI:GROUP_SCALE(), cardIndex);
	table.insert(pengGroup.cards, card)
	pengGroup.cardTop = card;
	
	pengGroup.cards[4]:showTips(- 1)
	
	-- 重新排列手牌
	local place = self._seatUI:ManageCardsPositions(self._cardList, self._seatUI:getCardLayout(), true, {pengGroup.cardTop}) [pengGroup.cardTop];
	-- 初始位置
	card:setScale(1.5 * self._seatUI:GROUP_SCALE())
	card:setPosition(self._seatUI:getCardLayout().discardedAniStart)
	card:setZOrder(self._seatUI:getCardLayout().discardedAniStartZOrder)
	
	local scale1 = cc.ScaleTo:create(0.1, 1.8)
	local delay1 = cc.DelayTime:create(0.3)
	local move2 = cc.MoveTo:create(0.1, cc.p(place.pos.x, place.pos.y))
	local scale2 = cc.ScaleTo:create(0.1, self._seatUI:GROUP_SCALE())
	local delay2 = cc.DelayTime:create(0.1)
	local this = self
	local callback2 = cc.CallFunc:create(function()
		card:setZOrder(place.zOrder)
		this._seatUI:ManageCardsPositions(self._cardList, this._seatUI:getCardLayout(), true)
		if(config.getIs3D()) then
			card:resetCardCsbFor3DIndex(self._seatUI:getShowCardIndex(card._cardState, cardIndex))
		end
	end)
	local spwan = cc.Spawn:create(move2, scale2)
	local seq = cc.Sequence:create(scale1, delay1, spwan, delay2, callback2)
	card:runAction(seq)
	if pengGroup.cards[2] ~= nil and gangEffect ~= nil then
		local effectCb2 = function()
			if gangEffect ~= nil then
				local anim = UI_ANIM.UIAnimManager:getInstance():onShow(gangEffect)
				anim._csbAnim:setPositionX(pengGroup.cards[2]:getPositionX())
				anim._csbAnim:setPositionY(pengGroup.cards[2]:getPositionY())
			end
		end
		local schedule = scheduleOnce(effectCb2, 0.65)
		table.insert(self._schedule, schedule)
	end	
end

-- 抢杠胡
function PlayerProcessor:_doQiangGangHu(cardValue)
	-- 找到对应的碰组
	--	local gangGroup = Collection.FirstOrDefault(this.cardList.cardGroups, n => (n.cardState == CardDefines.CardState.GangPai && n.GetCardValue() == cardValue));
	local gangGroup = nil
	table.foreach(self._cardList.cardGroups, function(key, val)
		if val.cardState == CardDefines.CardState.GangPai and val:getCardValue() == cardValue then
			gangGroup = val
		end
	end)
	if Macro.assetTrue(gangGroup == nil, "Invalid QiangGang:%d", cardValue) then
		return;
	end
	
	-- 将碰改为杠
	gangGroup.cardState = CardDefines.CardState.Pengpai;
	local card = gangGroup.cards[4];
	
	if card == gangGroup.cardTop then
		table.remove(gangGroup.cards, 4)
		CardFactory:getInstance():releaseCard(card);		
	else
		-- 理论上来说不会进来。。。如果最上面的那边牌不是在最后的时候才会进来
		-- table.insert(gangGroup.cards, card, 1)
		for i = 1, 4 do
			if gangGroup.cards[i] == gangGroup.cardTop then
				table.remove(gangGroup.cards, i)
				CardFactory:getInstance():releaseCard(gangGroup.cardTop);
				break;
			end
		end
	end
	gangGroup.cardTop = nil;
end

--[[**
 * 根据操作类型从手牌中删除牌
 *]]
function PlayerProcessor:removeOperationCards(cardState, cardNumbers, targetCard)
	if CardDefines.isValidCardNumber(self._cardList.handCards[1]._cardValue) then
		self:_removeValidOperationCards(cardState, cardNumbers, targetCard);
	else
		self:_removeInvalidOperationCards(cardState);
	end
end

--[[**
 * 根据操作类型删除手牌:有牌值
 *]]
function PlayerProcessor:_removeValidOperationCards(cardState, cardNumbers, targetCard)
	-- // 如果当前是有效的牌值， 要删除对应的牌
	local isGang =(cardState == CardDefines.CardState.GangPai or cardState == CardDefines.CardState.GangPai2);
	if cardState ~= CardDefines.CardState.ChiPai then
		local cardValue = cardNumbers[1];
		local shoupai = {}
		table.foreach(self._cardList.handCards, function(key, val)
			if val._cardValue == cardValue then
				table.insert(shoupai, val)
			end
		end)
		
		if not isGang and #shoupai < 2 then
			-- console.error(`${GetCardName(cardValue)} 数量小于2 无法处理碰`);
			return;
		end
		
		-- // 删牌控制。由于配牌的问题，手上同一牌值的牌会有很多张。
		if cardState == CardDefines.CardState.GangPai then
			-- // 明杠只删3张
			while #shoupai > 3 do
				table.remove(shoupai, 1);
			end
		elseif cardState == CardDefines.CardState.GangPai2 then
			-- // 暗杠只删4张
			while #shoupai > 4 do
				table.remove(shoupai, 1);
			end
		else
			-- // 碰牌只删2张
			while #shoupai > 2 do
				table.remove(shoupai, 1);
			end
		end
		
		-- // 移除手牌
		while #shoupai > 0 do
			local card = shoupai[1];
			self._cardList:removeHandCard(card)
			if card == self._cardList.lastDrewCard then
				self._cardList.lastDrewCard = nil
			end
			CardFactory:getInstance():releaseCard(card)
			table.remove(shoupai, 1)
		end
	else
		-- // 吃牌后，移除手牌。
		local tempList = {}
		local shoupai = {}
		for i, card in ipairs(cardNumbers) do
			if card ~= targetCard then
				for j, v in ipairs(self._cardList.handCards) do
					if v._cardValue == card then
						table.insert(shoupai, v)
					end
				end
				
				if #shoupai > 0 then
					table.insert(tempList, shoupai[1])
					shoupai = {}
				end
			end
		end
		
		-- // 从手上干掉找到的牌
		while #tempList > 0 do
			local card = tempList[1]
			table.remove(tempList, 1)
			self._cardList:removeHandCard(card)
			if card == self._cardList.lastDrewCard then
				self._cardList.lastDrewCard = nil
			end
			CardFactory:getInstance():releaseCard(card);
		end
	end
end

--[[**
 * 根据操作类型删除手牌:无牌值
 *]]
function PlayerProcessor:_removeInvalidOperationCards(cardState)
	-- // 当前是无效的牌值，直接从手牌删除
	local isGang =(cardState == CardDefines.CardState.GangPai or cardState == CardDefines.CardState.GangPai2)
	
	-- KodGames.Macro.AssetFalse(this.isValidCard(this.cardList.normalCards[0].CardNumber));
	-- // 吃、碰，从手牌中干掉两张。
	CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
	table.remove(self._cardList.handCards, 1)
	CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
	table.remove(self._cardList.handCards, 1)
	
	-- // 明杠，干掉3张
	if cardState == CardDefines.CardState.GangPai then
		CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
		table.remove(self._cardList.handCards, 1)
	end
	
	-- // 暗杠，干掉4张
	if cardState == CardDefines.CardState.GangPai2 then
		CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
		table.remove(self._cardList.handCards, 1)
		CardFactory:getInstance():releaseCard(self._cardList.handCards[1]);
		table.remove(self._cardList.handCards, 1)
	end
end

function PlayerProcessor:setLackCardType(cardType)
	self._cardList.lackCardType = cardType;
	self._seatUI:ManageCardsPositions(self._cardList, self._seatUI:getCardLayout(), true)
	self._seatUI:onLack(cardType)
end

--[[
]]
function PlayerProcessor:showHandCardsWhenFinished(handCards, huCards, hu, machResult, huStatus)
	self._seatUI._hasHuWhenBattleFinished = false -- TODO : 改为函数设置
	for idx, val in ipairs(self._cardList.handCards) do
		CardFactory:getInstance():releaseCard(val)
	end
	self._cardList.handCards = {}
	local cardLayout = self._seatUI:getCardLayout()
	local scale = self._seatUI:GROUP2_SCALE()
	self._cardList:sortValue(handCards)
	for idx, val in ipairs(handCards) do
		local state = CardDefines.CardState.Chupai
		if config.getIs3D() then
			state = CardDefines.CardState.MingPai
		end
		local corners = self._cardList:getCardCornerTypes(val)
		local cornerType = corners[1] or false 
		local card = self._seatUI:createCard(state, val, cornerType, scale, idx + #self._cardList.cardGroups * 3)
		table.insert(self._cardList.handCards, card)
	end
	
	self._seatUI:setHuStatus(huStatus)
	
	-- 多胡相关
	-- for idx, val in ipairs(self._cardList.huCards) do
	-- 	CardFactory:getInstance():releaseCard(val)
	-- end
	-- self._cardList.huCards = {}
	-- -- 清空吃碰扛信息
	-- for idx, val in ipairs(self._cardList.cardGroups) do
	-- 	for idx2, val2 in ipairs(val.cards) do
	-- 		CardFactory:getInstance():releaseCard(val2)
	-- 	end
	-- 	val.cards = {}
	-- 	val.cardTop = nil
	-- end
	-- self._cardList.cardGroups = {}
	-- -- 重新创建吃碰扛信息
	-- for i, v in ipairs( `chResult ) do
	-- 	if self:getRoomSeat():getPlayer().id == v.roleId then
	-- 		for idx, val in ipairs( v.operateCards ) do
	-- 			if PlayType.Check(val.playType, PlayType.DISPLAY_MASTER_HONG_ZHONG) then
	-- 				-- 鬼牌
	-- 			elseif PlayType.Check(val.playType, PlayType.DISPLAY_SHOW_MASTER_CARD) then
	-- 				-- 鬼牌
	-- 			elseif PlayType.Check(val.playType, PlayType.DISPLAY_HUA_PAI) then
	-- 				-- 鬼牌
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_GANG_A_CARD) then
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_BU_GANG_A_CARD) then
	-- 			elseif PlayType.Check(val.playType, PlayType.DISPLAY_EX_CARD) then
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_AN_GANG) then
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_PENG_A_CARD) then
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_CHI_A_CARD) then
	-- 			elseif PlayType.Check(val.playType, PlayType.OPERATE_HU) then
	-- 			end
	-- 		end
	-- 	end
	-- end
	if #huCards == 1 then
		local state = CardDefines.CardState.Chupai
		if config.getIs3D() then
			state = CardDefines.CardState.MingPai
		end
		local corners = self._cardList:getCardCornerTypes(huCards[1])
		local cornerType = corners[1] or false 
		local card = self._seatUI:createCard(state, huCards[1], cornerType, scale, 14)
		table.insert(self._cardList.handCards, card)
		-- 设置为摸牌，放在最后一个
		self._cardList.lastDrewCard = card
	end
	
	self._seatUI:ManageCardsPositions(self._cardList, cardLayout, true, nil, false, false)
end

return PlayerProcessor 