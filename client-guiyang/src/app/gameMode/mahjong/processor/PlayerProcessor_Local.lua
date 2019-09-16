local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

local super = require("app.gameMode.mahjong.processor.PlayerProcessor")
local PlayerFSM = require("app.gameMode.mahjong.processor.playerFSM.PlayerFSM")
local RobotComponent = require("app.gameMode.mahjong.processor.component.RobotComponent")

local PlayerStatus = {
	NORMAL = 1,						-- 正常状态
	AUTO_DISCARD = 2				-- 自动出牌状态
}

local PlayerProcessor_Local = class("PlayerProcessor_Local", super)

function PlayerProcessor_Local:ctor(roomUI, roomSeat, seatUI)
	self.super.ctor(self, roomUI, roomSeat, seatUI)
	
	self._discardCardOperation = PlayType.UNKNOW	-- 等待出牌的operation
	self._recentDiscardedCardValue = CardDefines.CardType.Invalid	-- 上次客户端自动打出的牌
	self._robot = RobotComponent:new(self)
end

function PlayerProcessor_Local:getRobot()
	return self._robot
end

function PlayerProcessor_Local:_setClientDiscardCard(cardValue)

	if CardDefines.isValidCardNumber(cardValue) then
		-- 设置牌值, 原有的值应该是无效的
		Macro.assertFalse(CardDefines.isValidCardNumber(self._recentDiscardedCardValue) == false)
	else
		-- 清空牌值, 原有的值应该是有效的
		Macro.assertFalse(CardDefines.isValidCardNumber(self._recentDiscardedCardValue))
	end
	
	self._recentDiscardedCardValue = cardValue;
end

function PlayerProcessor_Local:_sendPlayStep(playType, cards)
	if Macro.assertTrue(game.service.RoomService:getInstance() == nil, "[ERROR]sendPlayStep") then
		-- TODO:在房间解散前收到，但是没有等待返回结果，服务器就解散房间了
		-- 输出一下是不是应该显示
		-- 现在的缺陷是只有在最后一局的时候，才能打印log，如果是其它局数的时候，无法打印
		Logger.debug(">===============ERROR-START=================<")
		Logger.debug("send info ==> playType:" .. playType .. " cards:"..json.encode(cards))
		Logger.debug(self._cardList:toStrings())
		-- 特殊代码，就不遵循正常的逻辑了
		-- 打印一下当前显示的内容，此时按钮应该还没有隐藏，打印一下看看结果
		for k,v in pairs(self._seatUI._operationBtns) do
			Logger.debug("button "..tostring(k).." isShow "..tostring(v:isVisible()))
		end
		Logger.debug(">================ERROR-END==================<")
		-- 下面继续再走会出错了，直接return吧
		return
	end
	gameMode.mahjong.Context.getInstance():getGameService():sendPlayStep(playType, cards);
end


--[[
-- 处理step
-- 
-- @param recover: boolean
-- @param stepGroup: PlayStep[]
-- @return number : 返回下次处理需要等待的时间, 如果是-1表示没有处理
--]]
function PlayerProcessor_Local:_processStep(recover, stepGroup)
	-- 忽略不是自己的操作
	local firstStep = stepGroup[1];

	if self._roomSeat:hasPlayer() == false 
		or firstStep:getRoleId() ~= self._roomSeat:getPlayer().id then
		return
	end

	-- 如果是自动胡牌之类的机器人操作 则先让机器人去处理 不能处理的再走下面逻辑
	if self._stateMachine:isState("PlayerState_AutoDiscard") 
		and self._robot:_robotProcessStep( recover, firstStep) == true then
		return
	end

	-- 交给父类处理
	self.super._processStep(self, recover, stepGroup);

	if firstStep:getPlayType() == PlayType.OPERATE_REJOIN_MASK then
		self:_onRejoinMask(firstStep._cards);
	-- 注意:如果增加操作不要忘记回放代码里面也进行监听
	elseif firstStep:getPlayType() == PlayType.OPERATE_WAIT
		or firstStep:getPlayType() == PlayType.OPERATE_CANCEL then 
		Macro.assertFalse(recover == false)
		self:getSeatUI():clearOpButtons();
	elseif firstStep:getPlayType() == PlayType.OPERATE_PASS then
		-- pass等待的操作,什么都不用处理
		Macro.assertFalse(recover == false)
	elseif  firstStep:getPlayType() == PlayType.OPERATE_CAN_CHI_A_CARD 
		or firstStep:getPlayType() == PlayType.OPERATE_CAN_PENG_A_CARD 
		or firstStep:getPlayType() == PlayType.OPERATE_CAN_GANG_A_CARD 
		or firstStep:getPlayType() == PlayType.OPERATE_CAN_AN_GANG 
		or firstStep:getPlayType() == PlayType.OPERATE_CAN_BU_GANG_A_CARD then
		-- 清楚听牌提示			
		-- self:getSeatUI():hideTingTips()
		-- game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})		

		-- 等待玩家选择的操作
		Macro.assertFalse(recover == false)
		self:_onWaitingOtherOperation(stepGroup);
		-- 当处理自己的可选操作的时候，显示操作指示器，重新计数
		self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());	
		
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_TING then
		-- 等待玩家选择的操作
		Macro.assertFalse(recover == false)
		self:_onWaitingOtherOperation(stepGroup);
		self:getSeatUI():hideTingTips()
		-- 当处理自己的可选操作的时候，显示操作指示器，重新计数
		self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_PASS then
		-- 等待玩家选择的操作
		Macro.assertFalse(recover == false)
		self:_onWaitingOtherOperation(stepGroup);
		-- 当处理自己的可选操作的时候，显示操作指示器，重新计数
		self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_HU then
		-- TODO: 为修复bug，canHU拿出来特殊处理一下
		Macro.assertFalse(recover == false)
		self:_onWaitingOtherOperation(stepGroup);
		-- self:_enableAll()
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_TING_CARD then
		-- 等待玩家选择听牌
		Macro.assertFalse(recover == false)
		self:_onWaitingTingCardOperation(stepGroup);
		-- 统计可以上听的次数
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.ReadyHand_Number);
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_AUTO_HU then	
		-- 自动胡牌
		Macro.assertFalse(recover == false)
		self:_sendPlayStep(PlayType.OPERATE_HU, firstStep:getCards());
	elseif firstStep:getPlayType() == PlayType.DISPLAY_MASK_ALL_HAND_CARD then	
		-- 开启蒙灰模式
--		self.isInMaskCardStatus = true;
		self:getSeatUI():maskAllHandCards();
	elseif firstStep:getPlayType() == PlayType.OPERATE_PLAY_A_CARD then
		-- self:getSeatUI():clearCardTips()
		self:getSeatUI():clearCards()
	elseif firstStep:getPlayType() == PlayType.OPERATE_TING_TIP then	
		self:getSeatUI():addCardTips(firstStep:getCards(),firstStep:getDatas());
		game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})						
    elseif firstStep:getPlayType() == PlayType.OPERATE_HU 
		or firstStep:getPlayType() == PlayType.OPERATE_MEN then
		self:getSeatUI():clearCards()
	elseif firstStep:getPlayType() == PlayType.DISPLAY_TING then
		-- 听牌显示出按钮来
		if next(self:getSeatUI():getCacheTipsArray()) then
			game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = true})
		end		
	elseif firstStep:getPlayType() == PlayType.DISPLAY_AUTO_PLAY_LAST_DEALED_CARD then
		self._isTingStatus = true
		self:getPlayerFsm():enterState("PlayerState_TianTing")
	end
end


-- 摸牌
function PlayerProcessor_Local:_onDrawCard(cardValue)
	if Macro.assertTrue(CardDefines.isValidCardNumber(cardValue) == false, "_onDrawCard invalid card=%d", cardValue) then
		return;
	end

	self.super._onDrawCard(self, cardValue)

	self:getSeatUI():updateCardTips()

	-- 如果不是听牌，则摸牌后关掉指示灯
	if self._isTingStatus == false and not self._stateMachine:isState("PlayerState_AutoDiscard") then
		game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})	
	end
end

function PlayerProcessor_Local:_enableAll()
	for idx=#self._cardList.handCards,1,-1 do
		self._cardList.handCards[idx]:enable();
	end
end

-- 可出牌
-- @param  playType: number
-- @param cardValues: number[], 表示可以打的牌
function PlayerProcessor_Local:_onDiscardable(playType, cardValues)
	self.super._onDiscardable(self, playType, cardValues);
	
	Macro.assertTrue(self._discardCardOperation ~= PlayType.UNKNOW, "the OPERATE_CAN_PLAY_A_CARD received twice！！！")

	-- 清除操作牌
	self._seatUI:recoverOperatingCard()

	self._discardCardOperation = playType;
	if cardValues and #cardValues ~= #self._cardList.handCards then
		-- 当前可以出牌跟实际手牌数量不同，不可出的牌遮黑
		-- 因为同一张牌可能存在多个，所以要想好怎么判断
		local cardTypeArray = {};
		table.foreach(cardValues, function(key, cardValue)
			cardTypeArray[cardValue] = cardTypeArray[cardValue] and cardTypeArray[cardValue] + 1 or 1
		end)

		-- 为了表现，这里在normalcardlist 倒序检查
		for idx=#self._cardList.handCards,1,-1 do
			local cardValue = self._cardList.handCards[idx]._cardValue;
			if cardTypeArray[cardValue] and cardTypeArray[cardValue] > 0 then
				cardTypeArray[cardValue] = cardTypeArray[cardValue] - 1;
				self._cardList.handCards[idx]:enable();
			else 
				self._cardList.handCards[idx]:disable();
			end
		end
	else 
		self:_enableAll()
	end
end

function PlayerProcessor_Local:onRoundFinished()
	self._seatUI:clearCacheTips()
	self._seatUI._tipsCache = {}
	self:getPlayerFsm():enterState("PlayerState_Normal")
	game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})
end

--比赛场若托管需要重置discard
function PlayerProcessor_Local:clearForNextRound()
	self.super.clearForNextRound(self);
	self._seatUI:clearOpButtons()
	self._seatUI:clearShowCards()
	self._seatUI:clearCacheTips()
	self._isTingStatus = false
	self._seatUI._tipsCache = {}
	self._discardCardOperation = PlayType.UNKNOW
end

function PlayerProcessor_Local:_onRejoinMask(cardValues)
	if cardValues and #cardValues ~= #self._cardList.handCards then
		-- 当前可以出牌跟实际手牌数量不同，不可出的牌遮黑
		-- 因为同一张牌可能存在多个，所以要想好怎么判断
		local cardTypeArray = {};
		table.foreach(cardValues, function(key, cardValue)
			cardTypeArray[cardValue] = cardTypeArray[cardValue] and cardTypeArray[cardValue] + 1 or 1
		end)

		-- 为了表现，这里在normalcardlist 倒序检查
		for idx=#self._cardList.handCards,1,-1 do
			local cardValue = self._cardList.handCards[idx]._cardValue;
			if cardTypeArray[cardValue] and cardTypeArray[cardValue] > 0 then
				cardTypeArray[cardValue] = cardTypeArray[cardValue] - 1;
				self._cardList.handCards[idx]:enable();
			else 
				self._cardList.handCards[idx]:disable();
			end
		end
	else 
		self:_enableAll()
	end
end

function PlayerProcessor_Local:maskCards(cardValues)
	return self:_onRejoinMask(cardValues)
end

function PlayerProcessor_Local:maskCardsReverse(cardValues)
	local maskValues = self._cardList:getHandCardValuesWithoutThose(cardValues)
	return self:_onRejoinMask(maskValues)
end

--[[ Q：为什么要重复写value和object的遮罩
	 A：因为，如果手中有四个一万，而我选择了第1、2、4个，那么依靠value是不能辨别的
]]
function PlayerProcessor_Local:maskCardsByObject(cardObjects)
	self:_enableAll()
	for _, object in ipairs(cardObjects) do
		object:disable()
	end
end

function PlayerProcessor_Local:maskCardsReverseByObject(cardObjects)
	for _, object in ipairs(self._cardList.handCards) do
		object:disable()
	end
	for _, object in ipairs(cardObjects) do
		object:enable()
	end
end


-- 客户端可以自动打指定的牌
function PlayerProcessor_Local:_onAutoDiscardable(cardValue)
	-- 托管不处理自动打牌
	if gameMode.mahjong.Context.getInstance():getGameService():getIsTrusteeship() == true and not game.service.RoomService.getInstance():isFastMode() then
		return
	end
	-- 显示操作指示器
	self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
	
	self:_autoDiscardCard(PlayType.OPERATE_PLAY_A_CARD, cardValue);
end

-- 客户端自动打出一张牌
-- @param operation: number
-- @param cardValue: number
function PlayerProcessor_Local:_autoDiscardCard(operation, cardValue)
	-- 发送出牌消息
	self:_sendPlayStep(operation, {cardValue})
	
	-- 直接出牌,不等服务器返回
	self:_setClientDiscardCard(cardValue)

	-- 选择要打出的牌
	local cardDiscard = nil;
	if self._cardList.lastDrewCard ~= nil and self._cardList.lastDrewCard._cardValue == cardValue then
		-- 优先选择刚摸到的那张
		cardDiscard = self._cardList.lastDrewCard;
	else
		-- 从手牌中选择一张对应的牌
		cardDiscard = self._cardList:getCard(cardValue, true);
	end

	if Macro.assertTrue(cardDiscard == nil) then
		return;
	end

	-- 清除操作牌
	self:getSeatUI():recoverOperatingCard();
	-- 打牌
	self:_onDiscardCard_Internal(cardValue, cardDiscard);

	-- 更新蒙灰状态
	-- self:refreshMaskCardStatus();
end

function PlayerProcessor_Local:canDiscardCard()
	return self._discardCardOperation ~= PlayType.UNKNOW and self._stateMachine:isState("PlayerState_AutoDiscard") == false
end

-- 本地玩家打一张牌
function PlayerProcessor_Local:discardCard(cardDiscard,isAutoDiscard)
	if self:canDiscardCard() == false and not isAutoDiscard then
        return
    end

	-- 发送出牌消息
	local cardValue = cardDiscard:getCardValue();
	self:_sendPlayStep(self._discardCardOperation, {cardValue})
	self._discardCardOperation = PlayType.UNKNOW
	
	-- 直接出牌,不等服务器返回
	self:_setClientDiscardCard(cardValue)
	
	-- 清除操作牌
	self._seatUI:recoverOperatingCard()
	-- 打牌
	self:_onDiscardCard_Internal(cardValue, cardDiscard)
	-- 更新蒙灰状态
	-- self:refreshMaskCardStatus()
	-- 如果打出的牌听了，则显示出按钮
	local shoudDisplay = false
	local tingCards = self:getSeatUI():getCacheTipsArray()
	-- 如果有1张以上听得牌则显示按钮
	local len = table.nums(tingCards)
	if len >= 1 then
		for k,v in pairs(tingCards) do
			if cardValue == k then
				shoudDisplay = true
				break
			end
		end
		game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = shoudDisplay})
	end
	-- 如果打出去的牌不在听牌的里面，则清楚cache
	if shoudDisplay == false then
		self:getSeatUI():clearCacheTips()
	end
end

-- 出牌
--@return number, 下个操作的等待时间
function PlayerProcessor_Local:_onDiscardCard(cardValue)
	-- 客户端提前出牌, 检测有效性

	-- 托管不处理自动打牌
	if gameMode.mahjong.Context.getInstance():getGameService():getIsTrusteeship() == true then
		-- 收到服务器通知出牌(只有托管时)
		-- 尝试按照牌值选择，即便不是明打，出牌的时候也有值
		local cardDiscard = nil;

		--托管时需要置为unknow
        self._discardCardOperation = PlayType.UNKNOW
        
        -- 托管下，如果牌值相同 优先打出刚刚摸的牌
        if self._cardList.lastDrewCard ~= nil and self._cardList.lastDrewCard._cardValue == cardValue then
            cardDiscard = self._cardList.lastDrewCard
		elseif CardDefines.isValidCardNumber(cardValue) then
			cardDiscard = self._cardList:getCard(cardValue, true);
        end

        -- 如果依然是空的话，打出手牌第一张
		if cardDiscard == nil then
			cardDiscard = self._cardList.lastDrewCard;
		end
		if cardDiscard == nil then
			cardDiscard = self._cardList.handCards[1];
		end
		self:_onDiscardCard_Internal(cardValue, cardDiscard);

		-- 如果打出的牌听了，则显示出按钮
		local shoudDisplay = false
		local tingCards = self:getSeatUI():getCacheTipsArray()
		-- 如果有1张以上听得牌则显示按钮
		local len = table.nums(tingCards)
		if len >= 1 then
			for k,v in pairs(tingCards) do
				if cardValue == k then
					shoudDisplay = true
					break
				end
			end
			game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = shoudDisplay})
		end
		-- 如果打出去的牌不在听牌的里面，则清楚cache
		if shoudDisplay == false then
			self:getSeatUI():clearCacheTips()
		end
	else
	 	Macro.assertFalse(CardDefines.isValidCardNumber(cardValue), tostring(cardValue))
	 	Macro.assertFalse(self._recentDiscardedCardValue == cardValue, tostring(self._recentDiscardedCardValue)..","..tostring(cardValue))
	 	self:_setClientDiscardCard(CardDefines.CardType.Invalid)
	end
end

-- 收回打错的牌
function PlayerProcessor_Local:_onRecoverErrorCard()
	-- body
	local card_scale = (not config.getIs3D() and self._seatUI:getChairType() ~= CardDefines.Chair.Down and cardValue ~= 255) and self._seatUI:GROUP2_SCALE() or self._seatUI:CARD_SCALE();
	local card = self._seatUI:createCard(CardDefines.CardState.Shoupai, self._recentDiscardedCardValue, false, card_scale, 7);

	self._cardList:addHandCard(card)
	self._cardList:removeDiscardedCardTail(self._recentDiscardedCardValue)
end

-- 提示听操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor_Local:_onWaitingTingCardOperation(stepGroup)
	Macro.assertFalse(#stepGroup == 1);
	local step = stepGroup[1]
	Macro.assertFalse(step._playType == PlayType.OPERATE_CAN_TING_CARD);
	Macro.assertFalse(#step._cards ~= 0);

	if gameMode.mahjong.Context.getInstance():getGameService():getIsTrusteeship()  == true and not game.service.RoomService:getInstance():isFastMode() then
		return
	end
	
	-- 获得对应的操作设置
	local setting = self:_getOperationSetting(step._playType)

	self._seatUI:onWaitingOperation(step._playType, function()
		if #step._cards == 1 then
			-- 自动打出这张牌
			self:_autoDiscardCard(setting.targetOp, step._cards[1]);
			self:getSeatUI():clearOpButtons();
		elseif #step._cards > 1 then
			-- 让用户选择打出的牌
			self:_onDiscardable(setting.targetOp, step._cards);
			self:getSeatUI():clearOpButtons();
		else
			-- 让用户选择打出的牌
			self:_onDiscardable(setting.targetOp, step._cards);
			self:getSeatUI():clearOpButtons();
		end
		-- 这时候要把听牌都显示出来
		self:getSeatUI():setTipsArray(self:getSeatUI():getCacheTipsArray())
		self:getSeatUI():updateCardTips()

	end, setting);
end

-- 提示除了听之外的其他操作操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor_Local:_onWaitingOtherOperation(stepGroup)
	-- 获得对应的操作设置
	local setting = self:_getOperationSetting(stepGroup[1]._playType)
	-- TODO：现在会出现有玩家操作没有等待结果就结束的问题，打印一下log
	-- 当前的playstep有可是能复数个，log打印
	for idx=1,#stepGroup do
		Logger.debug(">>>"..stepGroup[idx]:getPlayType()
			.." "..json.encode(stepGroup[idx]._cards))
	end

	self._seatUI:onWaitingOperation(stepGroup[1]._playType, function()
		if #stepGroup == 1 then
			local step = stepGroup[1];
			-- 只能有一个操作			
			if Macro.assertFalse(setting ~= nil) then
				if step._cards == nil or #step._cards == 0 then
					-- 没有操作牌
					if self._seatUI:isGuoHu(setting.targetOp) then
						--属于过胡操作
						game.ui.UIMessageBoxMgr.getInstance():show("确定要过胡吗？", {"确定","取消"}, function()
							--继续,如果此时托管了，不进行处理
							if gameMode.mahjong.Context.getInstance():getGameService():getIsTrusteeship() == true then
								self._seatUI:clearOpButtons();
								return
							end
							if game.service.RoomService:getInstance() ~= nil then
								self:_sendPlayStep(setting.targetOp, {})
								self._stateMachine:enterState("PlayerState_Normal")
							end
							self._seatUI:clearOpButtons();
						end,
						function()
							--过胡，直接返回
							return ;
						end)
					else
						self:_sendPlayStep(setting.targetOp, {})
						if setting.targetOp ~= PlayType.OPERATE_PASS and  setting.targetOp ~= PlayType.OPERATE_MEN then
							game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})	
							self._seatUI:clearCacheTips()	
						end							
						self._seatUI:clearOpButtons();
						self._stateMachine:enterState("PlayerState_Normal")
					end

				else
					-- 只有一张操作牌
					self:_sendPlayStep(setting.targetOp, step._cards)
					if setting.targetOp ~= PlayType.OPERATE_PASS and  setting.targetOp ~= PlayType.OPERATE_MEN then
						game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})		
						self._seatUI:clearCacheTips()	
					end							
					self._seatUI:clearOpButtons();
					self._stateMachine:enterState("PlayerState_Normal")
				end
				-- TODO：点击操作的时候
				Logger.debug("<<<"..setting.targetOp.." "
					..(step._cards == nil and "nil" or json.encode(step._cards)))
			end
		else
			-- 包含有多个操作, 需要弹出对话框选择
			-- 多张操作牌可选
			UIManager:getInstance():show("UIMahjongSelector", stepGroup, function(step)
				if Macro.assertFalse(setting ~= nil) then
					-- TODO:暂时先这样处理暗杠和补杠同时出现的情况
					local __playType = setting.targetOp
					for _,data in ipairs(stepGroup) do
						if data._cards == step._cards then
							__playType = data._playType
						end
					end
					for _,data in ipairs(self._operationSettings) do
						if __playType == data.op then
							__playType = data.targetOp
						end
					end
					self:_sendPlayStep(__playType, step._cards)
					self._seatUI:clearOpButtons();
					if __playType ~= PlayType.OPERATE_PASS and __playType ~= PlayType.OPERATE_MEN then
						game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})
						self._seatUI:clearCacheTips()			
					end				
				end
			end)
		end
	end, setting)
end

-- 自摸
-- @param cardValue: number
function PlayerProcessor_Local:_onZiMo(cardValue)
--	this.BreakCardOperation();
	self.super._onZiMo(self, cardValue);
end

-- 托管
function PlayerProcessor_Local:_onTrusteeship(tf)
	self.super._onTrusteeship(self, tf);
	-- 恢复手牌
	self._seatUI:recoverOperatingCard()
	-- 听牌时_discardCardOperation有冲突
	if tf == true then
		self._discardCardOperation = PlayType.UNKNOW
		if not game.service.RoomService.getInstance():isFastMode() then
			local roomType = game.service.LocalPlayerService.getInstance():getCurrentRoomType()
			if roomType and roomType == game.globalConst.roomType.gold then
				game.ui.UIMessageTipsMgr.getInstance():showTips("出牌超时将会减少您的出牌时间")
			end 
		end
	end

	-- 设置托管状态
	gameMode.mahjong.Context.getInstance():getGameService():setIsTrusteeship(tf)	
end

-- 暗杠
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor_Local:_onAnGang(isRecover, cardNumbers, targetId)
	-- 暗杠的时候，这时其实玩家是可以操作的，要将操作还原
	self._seatUI:recoverOperatingCard()
	-- 被杠可能被抢杠，这时需要清空一下，要不会残留
	self._seatUI:clearCards()
	self.super._onAnGang(self, isRecover, cardNumbers, targetId)
	game.service.RoomService.getInstance():dispatchEvent({name = "DISPLAY_TING_HELP_BTN",display = false})	
	self._seatUI:clearCacheTips()	
end

-- 补杠
-- @param isRecover: boolean
-- @param cardNumbers: number[]
-- @param targetId: number
-- @return number, 
function PlayerProcessor_Local:_onBuGang(isRecover, cardNumbers, targetId)
	-- 补杠的时候，这时其实玩家是可以操作的，要将操作还原
	self._seatUI:recoverOperatingCard()
	-- 被杠可能被抢杠，这时需要清空一下，要不会残留
	self._seatUI:clearCards()
	self.super._onBuGang(self, isRecover, cardNumbers, targetId)
end

function PlayerProcessor_Local:_onPeng(isRecover, cardNumbers, targetId)
	self.super._onPeng(self, isRecover, cardNumbers, targetId)
end

function PlayerProcessor_Local:_onChi(isRecover, cardNumbers, targetId)
	self.super._onChi(self, isRecover, cardNumbers, targetId)
end

-- function PlayerProcessor_Local:onGameStarted( outCards, handCards, operateCards, isRecover )
-- 	-- Logger.debug("onGameStarted".."handCardsCount:"..#handCards.."  isRecover:"..isRecover)
-- 	Macro.assertTrue(not isRecover and #handCards ~= 13, "收到的手牌数据不为13")
	
-- 	self.super.onGameStarted(self, outCards, handCards, operateCards, isRecover)
-- end

return PlayerProcessor_Local