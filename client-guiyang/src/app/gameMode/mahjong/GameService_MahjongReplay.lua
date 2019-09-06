local RoomSeat = require("app.gameMode.mahjong.RoomSeat")
local Player = require("app.gameMode.base.core.Player")
local RoomProcessor = require("app.gameMode.mahjong.processor.RoomProcessor")
local PlayerProcessor_Replay = require("app.gameMode.mahjong.processor.PlayerProcessor_Replay")
local PlayStep = require("app.gameMode.mahjong.core.PlayStep")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local room = require("app.game.ui.RoomSettingHelper")
local Time = kod.util.Time;
local CommandCenter = require("app.manager.CommandCenter")

--[[
-- 进入牌局场景后, 牌局逻辑处理模块, 处于与打牌相关的操作
--]]
local GameService_MahjongReplay = class("GameService_MahjongReplay")

--------------------------------
function GameService_MahjongReplay:ctor()
	self._roomUI = nil
	self._roomSeats = {}
	self._players = {}
	
	self._roomProcessor = nil
	self._playerProcessors = {}
	
	self._stepSequencer = {}
	self._recordIndex = 1;
	self._stepGroupIndex = 1
	self._processStepTask = nil
	
	self._replayPaused = false;
	self._replaySpeed = { 2, 1, 0.5}
	self._currentSpeedIdx = 1;
	
	self._maxPlayerCount = 0
	self._maxRoundCount = 0;
	self._currentRoundCount = 0;
	self._actualPlayerCount = 0;
	self.roomSettings = nil

	-- 房间详情修改显示的地方了，需要储存数据
	self._roomRecord = nil
	-- 当前播放的战绩，在roomRecord里面对应的索引
	self._roundReportIndex = nil
	-- 存储回放玩家数据
	self._playerDatas = nil
end

function GameService_MahjongReplay:initialize(gameScene)
	cc.bind(self, "event");
	
	-- 保存RoomUI
	self._roomUI = gameScene:getRoomUI()
	
	-- 初始化座位
	for i=CardDefines.Chair.Down,CardDefines.Chair.Left do
		local seatUI = gameScene:getSeatUI(i)
		local seat = RoomSeat.new(i, seatUI);
		seatUI:setRoomSeat(seat)
		table.insert(self._roomSeats, seat)
	end
	
	-- 创建RoomProcessor
	self._roomProcessor = RoomProcessor.new(self._roomUI)
	self._roomProcessor:onGameWaitingStart()
	
	-- 创建PlayerProcessor
	for i=1,#self._roomSeats do
		local seat = self._roomSeats[i]
		
		-- 创建PlayerProcessor
		local playerProcessor = PlayerProcessor_Replay.new(self._roomUI, seat, seat:getSeatUI())
		table.insert(self._playerProcessors, playerProcessor)
	end	
end

function GameService_MahjongReplay:dispose()
	self:_cancelProcessStepTask();

	self._roomSeats = {}
	-- 取消所有cmd的注册
	CommandCenter.getInstance():unregistAll()
	
	if self._roomProcessor ~= nil then
		self._roomProcessor:dispose();
	end
	self._roomProcessor = nil
	
	for i=1, #self._playerProcessors do
		self._playerProcessors[i]:dispose();
	end
	self._playerProcessors = {}
	
	cc.unbind(self, "event");
end

function GameService_MahjongReplay:getRoomUI()
	return self._roomUI;
end

function GameService_MahjongReplay:getRoomSeats()
	return self._roomSeats;
end

function GameService_MahjongReplay:getRoomSeat(chairType)
	for i=1,#self._roomSeats do
		if self._roomSeats[i]:getChairType() == chairType then
			return self._roomSeats[i]
		end
	end
	return nil
end

-- 设置游戏的最大局数
function GameService_MahjongReplay:getMaxRoundCount()
	-- TODO : 未实现
	Macro.assetFalse(false, "Not implement");
	return 0
end

-- 设置游戏当前局数
function GameService_MahjongReplay:getCurrentRoundCount()
	-- TODO : 未实现
	Macro.assetFalse(false, "Not implement");
	return 0
end

function GameService_MahjongReplay:getMaxPlayerCount()
	return self._maxPlayerCount;
end
function GameService_MahjongReplay:getRoomProcessor()
	return self._roomProcessor
end

function GameService_MahjongReplay:getActualPlayerCount()
	return self._actualPlayerCount
end

function GameService_MahjongReplay:getPlayerDatas()
	return self._playerDatas;
end
--==============================--
--desc: 让所有用户都准备
--time:2017-08-17 07:03:14
--@return 
--==============================--
function GameService_MahjongReplay:setRoomPlayerReadyState()
	for i, seat in ipairs(self._roomSeats) do
		seat:getSeatUI():setPlayerReady(false)
	end
end

function GameService_MahjongReplay:getPlayerProcessorByPlayerId(playerId)
	for i=1,#self._playerProcessors do
		local processor = self._playerProcessors[i]
		if processor:getRoomSeat() and processor:getRoomSeat():hasPlayer() and processor:getRoomSeat():getPlayer().id == playerId then
			return processor
		end
	end
	
	return nil
end

function GameService_MahjongReplay:getPlayerProcessorByChair(chair)
	for i=1,#self._playerProcessors do
		local processor = self._playerProcessors[i]
		if processor:getRoomSeat() and processor:getRoomSeat():hasPlayer() and processor:getRoomSeat():getChairType() == chair then
			return processor
		end
	end

	return nil
end

-- 当前播放的房间记录
function GameService_MahjongReplay:getRoomRecord()
	return self._roomRecord
end

-- 墚前播放的对应房间记录的具体的索引
function GameService_MahjongReplay:getRoundReportIndex()
	return self._roundReportIndex
end

-- @param replayData: com.kodgames.message.proto.battle.MatchPlaybackProto
function GameService_MahjongReplay:startReplay(followPlayerId, roomRecord, replayData, recordIndex)
	self._maxPlayerCount = #roomRecord.playerRecords
	self._maxRoundCount = roomRecord.roundCount
	self._actualPlayerCount = #replayData.playerDatas
	self._currentRoundCount = recordIndex + 1
	self._roomRecord = roomRecord

	self._playerDatas = replayData.playerDatas

	self._roomUI:setRoomId(roomRecord.roomId)
	
	-- 构造房间规则
	local roomSettings = RoomSetting.CreateRoomSettingsClass.new();
	local localGamePlays = room.RoomSettingHelper.convert2ClientGameOptions(false, roomRecord.roundCount, roomRecord.gameplays);
	roomSettings._gameType = room.RoomSettingHelper.getGameTypeFromOptions(localGamePlays);
	roomSettings._ruleMap[roomSettings._gameType] = localGamePlays;
	self._roomUI:showRoomRules(roomSettings, roomRecord.scoreRatio )
	
	self.roomSettings = roomSettings
	-- 注册command
	Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
	local areaId = game.service.LocalPlayerService:getInstance():getArea()    
	MultiArea.registReplayCommands(areaId, roomSettings._gameType)

	local roundReportData = {}
    roundReportData.matchResults = {}
    local curRoundDistroy = roomRecord.roundReportRecords[self._currentRoundCount].destroyerId > 0
    --FYD 如果当局是解散掉的
    if curRoundDistroy then
        --隐藏结算按钮
        local ui = UIManager:getInstance():getUI("UIPlayback")
        ui:hideForDistory()
        local ui = UIManager:getInstance():getUI("UILastCrads")
        ui:hideForDistory()
    end

	local record = nil
	if roomRecord.currectRound ~= nil then
		-- TODO: [小坑]如果是观看其它人的战绩，这时局数跟索引是不对应的，我们能拿到的只有一局的信息，但显示的时候，还是要显示正确的局数
		record = roomRecord.roundReportRecords[1].playerDetailRecords
		self._roundReportIndex = 1
		roundReportData.isHuang = roomRecord.roundReportRecords[1].isHuang
	else
		record = roomRecord.roundReportRecords[self._currentRoundCount].playerDetailRecords
		self._roundReportIndex = self._currentRoundCount
		roundReportData.isHuang = roomRecord.roundReportRecords[self._currentRoundCount].isHuang
    end
    
    -- 创建玩家
    for i = 1, #record do
        local playerInfo = roomRecord.playerRecords[i]
        local player = Player.new(playerInfo)
        player.ip = ""
        player.status = Constants.PlayerStatus.ONLINE;
        -- 牌局回放判断庄家
        if bit.band(record[i].status, Constants.PlayerStatus.ZHUANGJIA) ~= 0 then
            player.status = bit.bor(player.status, Constants.PlayerStatus.ZHUANGJIA)
        end
        if bit.band(record[i].status, Constants.PlayerStatus.HOST) ~= 0 then
            player.status = bit.bor(player.status, Constants.PlayerStatus.HOST)
        end
        player.totalPoint = record[i].totalPoint; -- playerInfo.totalPoint;
        player.pointInGame = record[i].pointInGame;

        table.insert(self._players, player);
        table.insert(roundReportData.matchResults, record[i])
    end
 

	local event = {name = "EVENT_RULE_CHANGE", roomRule = roomSettings, players = self._players}
	self:dispatchEvent(event)

	-- 玩家入座
	self:_setRoomPlayers(followPlayerId, self._players)
	
	-- 初始化牌局玩家
	for i=1,#replayData.playerDatas do
		local recordPlayer = replayData.playerDatas[i];
		local playerProcessor = self:getPlayerProcessorByPlayerId(recordPlayer.roleId)
		local roomService = game.service.RoomService.getInstance()
		roomService._maxPlayerCount = self._maxPlayerCount
		playerProcessor:getSeatUI():updateDiscardedLayout(self._maxPlayerCount)
		playerProcessor:getSeatUI():maxCardNumberReset(roomRecord.playerMaxCardCount)
		playerProcessor:onGameStarted({}, recordPlayer.handCards, {}, true, true);
	end
	
	for i=1, #replayData.records do
		local recordSteps = replayData.records[i]
		
		local convertedRecordSteps = {} 
		table.insert(self._stepSequencer, convertedRecordSteps)
		
		-- 构造PlayStep
		local stepsData = {};
		for i = 1,#recordSteps.steps do
			table.insert(stepsData, PlayStep.new():setProto(recordSteps.steps[i]))
		end

		-- console.log(`On_BC_PlayStepSync:${GFunc.dump(stepsData)}`);

		-- 需要合并的类型
		local combinedStepTypes = {
			{PlayType.OPERATE_HU},
			{PlayType.DISPLAY_DEAL_BETTING_HORSE, PlayType.DISPLAY_BETTING_HORSE},
			{PlayType.OPERATE_CAN_CHI_A_CARD},
			{PlayType.OPERATE_CAN_AN_GANG, PlayType.OPERATE_CAN_BU_GANG_A_CARD},
			{PlayType.DISPLAY_JI_SELF, PlayType.DISPLAY_JI_FANPAI, PlayType.DISPLAY_JI_CHUIFENG, PlayType.DISPLAY_JI_XINGQI},
		}

		while #stepsData > 0 do
			local stepData = stepsData[1];

			local needCombined = false
			for _,v in ipairs(combinedStepTypes) do
				for _,pType in ipairs(v) do
					if pType == stepData._playType then
						needCombined = true
					end
				end
			end

			if needCombined then
				local steps = {}
				table.foreach(stepsData, function(i,v)
					for _,v2 in ipairs(combinedStepTypes) do
						if table.indexof(v2, v._playType) ~= false then
							table.insert(steps, v)
						end
					end
				end)
				table.insert(convertedRecordSteps, steps);
				local index = 1
				while index <= #steps do
					table.remove(stepsData, table.indexof(stepsData, steps[index]))
					index = index + 1
				end
			else
				table.insert(convertedRecordSteps, {stepData})
				table.remove(stepsData, table.indexof(stepsData, stepData))
			end
		end
	end

	-- 插入结算数据
    local step = PlayStep.new()
    if curRoundDistroy then
        step._playType = PlayType.DISTORY_FINISH_ROOM
    else
        step._playType = PlayType.DISPLAY_FINISH_ALL_REPLAY
        step._result = roundReportData
    end

	table.insert(self._stepSequencer, {{step}})
	----------------------------------------

    self._roomProcessor:onGameStarted();
    
    local curRound = self:getCurrentRoundCount()
    if roomRecord.realRecordIndex then
        curRound = roomRecord.realRecordIndex + 1
    end
	self._roomUI:setRoundCount(curRound, self:getMaxRoundCount())	

	-- 开始回放
	self:_processStep(false)
end

function GameService_MahjongReplay:getPlayerNums()
	local count = 0
	for i,v in pairs(self._playerDatas) do
		count = count + 1
	end
	return count
end

-- 设置游戏的最大局数
function GameService_MahjongReplay:getMaxRoundCount()
	return self._maxRoundCount
end

-- 设置游戏当前局数
function GameService_MahjongReplay:getCurrentRoundCount()
	return self._currentRoundCount
end

-- 是否正在播放
function GameService_MahjongReplay:isReplaying()
	return self._replayPaused == false;
end

-- 暂停播放
function GameService_MahjongReplay:pauseReplay()
	if self._replayPaused == false then
		self._replayPaused = true
		-- 暂停
		self:_cancelProcessStepTask();
	end
end

-- 继续播放
function GameService_MahjongReplay:resumeReplay()
	if self._replayPaused then
		self._replayPaused = false
		-- 继续播放
		self:_processStep(false);
	end
end

-- 播放加速
function GameService_MahjongReplay:increaseReplaySpeed()
	self._currentSpeedIdx = self._currentSpeedIdx + 1 <= #self._replaySpeed and self._currentSpeedIdx + 1 or 1;
end

function GameService_MahjongReplay:getReplaySpeed()
	return self._replaySpeed[self._currentSpeedIdx]
end

function GameService_MahjongReplay:getReplaySpeedIdx()
	return self._currentSpeedIdx;
end


-- 设置所有游戏玩家,
-- 没有增量设置, 只要有变化全都更新
-- @players PlayerHistoryPROTO[]
function GameService_MahjongReplay:_setRoomPlayers(localPlayerId, players)
	-- 获取本地玩家
	local localPlayer = nil
	for i=1,#players do
		if players[i].id == localPlayerId then
			localPlayer = players[i];
			break;
		end
	end
	-- Macro.assetFalse(localPlayer ~= nil)

	-- TODO：当亲友圈群主观看录像的时候，localPlayer是空的。。。
	local basePosition = localPlayer ~= nil and localPlayer.position or players[1].position
	-- 如果两，三个玩家的时候，position需要改动
	-- 玩家入座
	for i=1,#players do
		local player = players[i]
		player.seat = math.abs(CardDefines.CHAIR_MAP[(player.position - basePosition + #players) % #players]);
		if 2 == #players then
			-- 右家移到上家
			if player.seat == CardDefines.Chair.Right then
				player.seat = CardDefines.Chair.Top
			end
		elseif 3 == #players then
			-- 对家移到左家
			if player.seat == CardDefines.Chair.Top then
				player.seat = CardDefines.Chair.Left
			end
		end
		
		local roomSeat = self:getRoomSeat(player.seat)
		roomSeat:setPlayer(player)
		--清除手牌的点击事件
		local uiroomSeat = roomSeat:getSeatUI()
		if uiroomSeat._rootNode ~= nil then
			uiroomSeat._rootNode:addTouchEventListener(function (sender, eventType)
			end)
		end
	end

	-- 清空没有玩家的座位
	for i=1,#self._roomSeats do		
		local roomSeat = self._roomSeats[i]
		
		-- 查看这个座位没有应玩家
		local found = false;
		for j=1,#players do
			local player = players[j]
			if player.seat == roomSeat:getChairType() then
				found = true
				break;
			end
		end
		
		if found == false then
			-- 没有就清空座位
			roomSeat:setPlayer(nil)
		end
	end
	
	-- 通知界面更新
end

-------------------------------------------------
-- 操作队列处理相关
-------------------------------------------------

--[[
StepEvent相关的Event
event = {
name = "PROC_EVENT"
isRecover = false
stepGroup = nil
}
]]

-- 处理当前缓存的操作
-- @param isRecover: boolean, 当前是否是复牌模式
function GameService_MahjongReplay:_processStep(isRecover)
	if self._processStepTask ~= nil then
		Macro.assetFalse(isRecover == false)
		-- 有正在等待的处理, 不用执行
		return
	end

	while self._recordIndex <= #self._stepSequencer do
		-- 执行下一个协议组
		local recordSteps = self._stepSequencer[self._recordIndex];
		self._recordIndex = self._recordIndex + 1;
		local waitTime = nil
		while self._stepGroupIndex <= #recordSteps do
			-- 执行下一个Group
			local stepGroup = recordSteps[self._stepGroupIndex]
			self._stepGroupIndex = self._stepGroupIndex + 1
			local roleId = stepGroup[1]:getRoleId() -- roleId == -1 表示基于房间的操作
			local playerProcessor = roleId == -1 and nil or self:getPlayerProcessorByPlayerId(roleId)
			local breakForDelayProcess = false;
			
			if isRecover == true then
				-- 复牌不需要等待

				-- 交给相应的处理器
				if playerProcessor == nil then
					self._roomProcessor:processStep(isRecover, stepGroup)
				else
					playerProcessor:processStep(isRecover, stepGroup)
				end
			else
				-- 正常处理过程

				-- 这里应该是可以处理状态
				local checkTime = self._roomProcessor:getNextIdleTime();
				checkTime = playerProcessor == nil and checkTime or math.max(checkTime, playerProcessor:getNextIdleTime())			
				-- TOOD : 回放到最后的时候, 点击继续这里有异常
				Macro.assetFalse(Time.now() >= checkTime)

				-- 派发操作处理事件
				local event = {name = "PROC_STEP", isRecover = isRecover, stepGroup = stepGroup}			
				self:dispatchEvent(event);

				-- 检查是否可以继续处理
				local nextIdleTime = self._roomProcessor:getNextIdleTime();
				nextIdleTime = playerProcessor == nil and nextIdleTime or math.max(nextIdleTime, playerProcessor:getNextIdleTime())
				
				if self._stepGroupIndex <= #recordSteps and Time.now() < nextIdleTime then
					-- 当前还不能继续操作, 计划下次更新
					-- 如果是同一组的最后一个操作, 不用自动计划更新
					self:_scheduleProcessStepTask(isRecover, nextIdleTime - Time.now())
					return
				end

				-- 本组播放完成后
				-- 如果此次等待的时候，要超过设计等待的时候，那么依此次等待的时候为准
				if Time.now() < nextIdleTime and nextIdleTime - Time.now() > self:getReplaySpeed() then
					waitTime = nextIdleTime - Time.now()
				end
			end
		end

		-- 本组遍历完了, 重置
		self._stepGroupIndex = 1;

		-- 获取当前是否有等待操作
		local operationWaitTime = 1 * self:getReplaySpeed();
		if self:_tryToShowNextOperation(operationWaitTime) == true then
			-- 当前是等待操作, 增加延迟时间
			waitTime = math.max(waitTime and waitTime or 0, operationWaitTime)
		elseif self._recordIndex <= #self._stepSequencer then
			-- 判断后续操作是否要等待
			for _, stepGroup in ipairs(self._stepSequencer[self._recordIndex]) do
				if self:_needWaitOperation(stepGroup) == false then
					waitTime = 0
				end
			end
		end

		self:_scheduleProcessStepTask(isRecover, waitTime and waitTime or self:getReplaySpeed())
		return;
	end

	-- 此时应该是全部完成了
	-- 派发操作处理事件
	local event = {name = "PROC_END"}			
	self:dispatchEvent(event);
end

-- 规划下一次处理step的任务
-- @param nextTime: number second
function GameService_MahjongReplay:_scheduleProcessStepTask(isRecover, nextTime)
	Macro.assetFalse(self._processStepTask == nil);
	self._processStepTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		-- 取消当前任务
		self:_cancelProcessStepTask();
		-- 处理操作
		self:_processStep(isRecover);
	end, nextTime, false);
end

-- 取消step处理任务
function GameService_MahjongReplay:_cancelProcessStepTask()
	if self._processStepTask ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._processStepTask)
		self._processStepTask = nil
	end	
end

-- 当前是否在显示等待操作按钮
function GameService_MahjongReplay:_hasWaitingOperation()
	for i=1, #self._roomSeats do
		if self._roomSeats[i]:getSeatUI():hasWaitingOperation() then
			return true;
		end
	end
	return false;
end

-- 如果有等待操作, 提示操作结果
function GameService_MahjongReplay:_tryToShowNextOperation(operationWaitTime)
	if self:_hasWaitingOperation() == false then
		return
	end
	
	Macro.assetFalse(self._stepGroupIndex == 1);
	if self._recordIndex > #self._stepSequencer then
		return
	end

	local recordSteps = self._stepSequencer[self._recordIndex];
	
	for i=1, #recordSteps do
		local stepGroup = recordSteps[i];
		
		for j=1, #self._playerProcessors do
			--如果多人同时操作,同时播放动画
			for k=1,#stepGroup do
				self._playerProcessors[j]:hintWaitingOperationResult({stepGroup[k]}, operationWaitTime)
			end
		end
	end	
	return true;
end


function GameService_MahjongReplay:_needWaitOperation(stepGroup)
	local skipOperation = {
		PlayType.OPERATE_PASS,
		PlayType.OPERATE_CAN_PLAY_A_CARD,
		PlayType.OPERATE_CAN_AUTO_PLAY_LAST_DEALED_CARD,
		PlayType.DISPLAY_LAST_CARD_COUNT,
	}
	
	for _, step in ipairs(stepGroup) do
		-- 跳过需要等待的操作
		for __, op in ipairs(skipOperation) do
			if step._playType == op then
				return false
			end
		end

		-- 如果是按钮操作, 不等待
		for _, setting in ipairs(self._playerProcessors[1]._operationSettings) do
			if step._playType == setting.op then
				return false
			end
		end
	end
	
	return true
end

return GameService_MahjongReplay