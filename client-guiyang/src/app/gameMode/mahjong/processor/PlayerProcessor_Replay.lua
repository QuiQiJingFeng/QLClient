local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Super = require("app.gameMode.mahjong.processor.PlayerProcessor_Other")
local PlayerProcessor_Replay = class("PlayerProcessor_Replay", Super)
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType

function PlayerProcessor_Replay:ctor(roomUI, roomSeat, seatUI)
	Super.ctor(self, roomUI, roomSeat, seatUI)
end

--[[-- 处理step
-- 
-- @param recover: boolean^
-- @param stepGroup: PlayStep[]
-- @return number : 返回下次处理需要等待的时间, 如果是-1表示没有处理
--]]
function PlayerProcessor_Replay:_processStep(recover, stepGroup)
	
	if stepGroup[1]:getPlayType() == PlayType.OPERATE_LACK_START then
		-- TODO : 怎么能写在这里呢?
		if UIManager:getInstance():getIsShowing("UILack") == false then
			UIManager:getInstance():show("UILack", function(cardType)
			end, gameMode.mahjong.Context.getInstance():getGameService():getMaxPlayerCount(),
			gameMode.mahjong.Context.getInstance():getGameService():getActualPlayerCount())
		end
	else
		-- 先交给父类处理
		Super._processStep(self, recover, stepGroup);
	end
	
	local firstStep = stepGroup[1];
	
	-- 忽略不是自己的操作
	if self._roomSeat:hasPlayer() == false
	or firstStep:getRoleId() ~= self._roomSeat:getPlayer().id then
		return
	end
	
	if firstStep:getPlayType() == PlayType.OPERATE_WAIT
	or firstStep:getPlayType() == PlayType.OPERATE_CANCEL
	or firstStep:getPlayType() == PlayType.OPERATE_TING
	or firstStep:getPlayType() == PlayType.OPERATE_TING_CARD then
		Macro.assetFalse(recover == false)
		self:getSeatUI():clearOpButtons();
	elseif firstStep:getPlayType() == PlayType.OPERATE_HU then
		Macro.assetFalse(recover == false)
		-- 在回放的时候，如果有一炮多响，需要将其它的玩家按钮也要隐藏
		for ii = 1, #stepGroup do
			local step = stepGroup[ii]
			local gameService = gameMode.mahjong.Context.getInstance():getGameService()
			local player = gameService:getPlayerProcessorByPlayerId(step:getRoleId())
			player:getSeatUI():clearOpButtons()
		end
	elseif firstStep:getPlayType() == PlayType.OPERATE_PASS then
		-- pass等待的操作,什么都不用处理
		Macro.assetFalse(recover == false)
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_PASS
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_CHI_A_CARD
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_PENG_A_CARD
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_GANG_A_CARD
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_AN_GANG
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_BU_GANG_A_CARD
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_TING
	or firstStep:getPlayType() == PlayType.OPERATE_CAN_HU then
		-- 等待玩家选择的操作
		Macro.assetFalse(recover == false)
		self:_onWaitingOtherOperation(stepGroup);
		-- 当处理自己的可选操作的时候，显示操作指示器，重新计数
		-- 这里的效果还要观察一下，再重新定义一下，因为观战的时候，是可以看到别人操作的，这时也会跳转光标
		self._seatUI._parentUI:showWaitingOperationIndicator(self._roomSeat:getChairType());
	elseif firstStep:getPlayType() == PlayType.OPERATE_CAN_TING_CARD then
		-- 等待玩家选择听牌
		Macro.assetFalse(recover == false)
		self:_onWaitingTingCardOperation(stepGroup);
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP then
		--处理托管		
		self:_onTrusteeship(true)
	elseif firstStep:getPlayType() == PlayType.OPERATE_TRUSTEESHIP_CANCLE then
		--处理托管
		self:_onTrusteeship(false)
	end
end

-- 托管
function PlayerProcessor_Replay:_onTrusteeship(tf)
	local chairType = self._roomSeat:getChairType()
	self._seatUI._parentUI:getSeatUI(chairType):setTrusteeshipIcon(tf)
end

-- 提示等待操作的操作结果
function PlayerProcessor_Replay:hintWaitingOperationResult(stepGroup, operationWaitTime)
	local firstStep = stepGroup[1];
	
	-- 忽略不是自己的操作
	if self._roomSeat:hasPlayer() == false
	or firstStep:getRoleId() ~= self._roomSeat:getPlayer().id then
		return
	end
	
	self:getSeatUI():hintWaitingOperationResult(firstStep:getPlayType(), operationWaitTime);
end

-- 提示听操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor_Replay:_onWaitingTingCardOperation(stepGroup)
	Macro.assetFalse(#stepGroup == 1);	
	local step = stepGroup[1]	
	Macro.assetFalse(step._playType == PlayType.OPERATE_CAN_TING_CARD);
	Macro.assetFalse(#step._cards ~= 0);
	
	-- 显示操作按钮
	self._seatUI:onWaitingOperation(step._playType, function() end, self:_getOperationSetting(step._playType));
end

-- 提示除了听之外的其他操作操作
-- @param stepGroup: PlayStep[]
function PlayerProcessor_Replay:_onWaitingOtherOperation(stepGroup)
	-- 显示操作按钮
	self._seatUI:onWaitingOperation(stepGroup[1]._playType, function() end, self:_getOperationSetting(stepGroup[1]._playType))
end

return PlayerProcessor_Replay 