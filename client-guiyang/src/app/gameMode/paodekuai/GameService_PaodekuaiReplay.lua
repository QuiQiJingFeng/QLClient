
local Player = require("app.gameMode.base.core.Player")
local PlayerProcessor_Local = require("app.gameMode.paodekuai.processor.PlayerProcessor_Local")
local PlayerProcessor_Other = require("app.gameMode.paodekuai.processor.PlayerProcessor_Other")
local RoomProcessor = require("app.gameMode.paodekuai.processor.RoomProcessor")
local PlayStep = require("app.gameMode.mahjong.core.PlayStep")
local PlayType = require("app.gameMode.paodekuai.core.Constants_Paodekuai").PlayType
local Constants = require("app.gameMode.paodekuai.core.Constants_Paodekuai")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local room = require("app.game.ui.RoomSettingHelper")
local Time = kod.util.Time;
local CommandCenter = require("app.manager.CommandCenter")
local super = require("app.gameMode.base.GameService")

--[[
-- 进入牌局场景后, 牌局逻辑处理模块, 处于与打牌相关的操作
--]]
local GameService_PaodekuaiReplay = class("GameService_PaodekuaiReplay", super)

--------------------------------
function GameService_PaodekuaiReplay:ctor()
    super.ctor(self)
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

    -- 房间详情修改显示的地方了，需要储存数据
    self._roomRecord = nil
    -- 当前播放的战绩，在roomRecord里面对应的索引
    self._roundReportIndex = nil
    -- 存储回放玩家数据
	self._playerDatas = nil
end

function GameService_PaodekuaiReplay:initialize(gameScene)
    super.initialize(self, gameScene)
    self._roomProcessor = RoomProcessor.new()
    self._roomProcessor:onGameWaitingStart()
end

function GameService_PaodekuaiReplay:dispose()
    self:_cancelProcessStepTask();

    self._roomSeats = {}
    -- 取消所有cmd的注册
    CommandCenter.getInstance():unregistAll()
    
    if self._roomProcessor ~= nil then
        self._roomProcessor:dispose();
    end
    self._roomProcessor = nil
    
    for _, processor in pairs(self._playerProcessors) do
        processor:dispose()
    end
    self._playerProcessors = {}
    -- self._roomUI:dispose()
    -- self._roomUI = nil
    
    -- cc.unbind(self, "event");
    self:removeAllPlayers()
    super.dispose(self)
end

function GameService_PaodekuaiReplay:getRoomUI()
    return self._roomUI;
end

function GameService_PaodekuaiReplay:getRoomSeats()
    return self._roomSeats;
end

function GameService_PaodekuaiReplay:getRoomSeat(chairType)
    for i=1,#self._roomSeats do
        if self._roomSeats[i]:getChairType() == chairType then
            return self._roomSeats[i]
        end
    end
    return nil
end

-- 设置游戏的最大局数
function GameService_PaodekuaiReplay:getMaxRoundCount()
    -- TODO : 未实现
    Macro.assetFalse(false, "Not implement");
    return 0
end

-- 设置游戏当前局数
function GameService_PaodekuaiReplay:getCurrentRoundCount()
    -- TODO : 未实现
    Macro.assetFalse(false, "Not implement");
    return 0
end

function GameService_PaodekuaiReplay:getMaxPlayerCount()
    return self._maxPlayerCount;
end

function GameService_PaodekuaiReplay:getRoomProcessor()
    return self._roomProcessor
end

function GameService_PaodekuaiReplay:getPlayerDatas()
	return self._playerDatas;
end

function GameService_PaodekuaiReplay:getActualPlayerCount()
    return self._actualPlayerCount
end
--==============================--
--desc: 让所有用户都准备
--time:2017-08-17 07:03:14
--@return 
--==============================--
function GameService_PaodekuaiReplay:setRoomPlayerReadyState()
    for i, seat in ipairs(self._roomSeats) do
        seat:getSeatUI():setPlayerReady(false)
    end
end

-- 当前播放的房间记录
function GameService_PaodekuaiReplay:getRoomRecord()
    return self._roomRecord
end

-- 墚前播放的对应房间记录的具体的索引
function GameService_PaodekuaiReplay:getRoundReportIndex()
    return self._roundReportIndex
end

-- @param replayData: com.kodgames.message.proto.battle.MatchPlaybackProto
function GameService_PaodekuaiReplay:startReplay(followPlayerId, roomRecord, replayData, recordIndex)
    self._maxPlayerCount = #roomRecord.playerRecords
    self._maxRoundCount = roomRecord.roundCount
    self._actualPlayerCount = #replayData.playerDatas
    self._currentRoundCount = recordIndex + 1
    self._roomRecord = roomRecord

    self._playerDatas = replayData.playerDatas

    -- :setRoomId(roomRecord.roomId)
    local gameScene = UIManager:getInstance():getUI("UIGameScene_Paodekuai")
    gameScene:setRoomId(roomRecord.roomId)
    gameScene:setRoundCount(self._currentRoundCount, self._maxRoundCount)
    
    -- 构造房间规则
    local roomSettings = RoomSetting.CreateRoomSettingsClass.new();
    local localGamePlays = room.RoomSettingHelper.convert2ClientGameOptions(false, roomRecord.roundCount, roomRecord.gameplays);
    roomSettings._gameType = room.RoomSettingHelper.getGameTypeFromOptions(localGamePlays);
    roomSettings._ruleMap[roomSettings._gameType] = localGamePlays;
    gameScene:showRoomRules(roomSettings)
    
    -- 注册command
    Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
    local areaId = game.service.LocalPlayerService:getInstance():getArea()    
    MultiArea.registCommands(areaId, roomSettings._gameType)

    local roundReportData = {}
    roundReportData.matchResults = {}
    local curRoundDistroy = roomRecord.roundReportRecords[self._currentRoundCount].destroyerId > 0
    --FYD 如果当局是解散掉的
    if curRoundDistroy then
        --隐藏结算按钮
        local ui = UIManager:getInstance():getUI("UIPlayback")
        if ui and ui.hideForDistory then
            ui:hideForDistory()
        end
        local ui = UIManager:getInstance():getUI("UILastCrads")
        if ui and ui.hideForDistory then
            ui:hideForDistory()
        end
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
        -- player.id = playerInfo.roleId;
        -- player.name = playerInfo.roleName;
        -- player.headIconUrl = playerInfo.iconUrl;
        -- player.position = playerInfo.position;
        player.ip = "";
        -- player.sex = playerInfo.sex;
        player.status = Constants.PlayerStatus.ONLINE;
        player.nickname = playerInfo.roleName
        player.name = playerInfo.roleName
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
        -- playerProcessor:getSeatUI():updateDiscardedLayout(self._maxPlayerCount)
        -- playerProcessor:getSeatUI():maxCardNumberReset(roomRecord.playerMaxCardCount)
        -- playerProcessor:getPlayerInfo()
        playerProcessor:onGameStarted(recordPlayer, true);
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

        local combinedStepTypes = {}
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
    -- self._roomUI:setRoundCount(self:getCurrentRoundCount(), self:getMaxRoundCount())	

    -- 开始回放
    self:_processStep(false)
end

-- 设置游戏的最大局数
function GameService_PaodekuaiReplay:getMaxRoundCount()
    return self._maxRoundCount
end

-- 设置游戏当前局数
function GameService_PaodekuaiReplay:getCurrentRoundCount()
    return self._currentRoundCount
end

-- 是否正在播放
function GameService_PaodekuaiReplay:isReplaying()
    return self._replayPaused == false;
end

-- 暂停播放
function GameService_PaodekuaiReplay:pauseReplay()
    if self._replayPaused == false then
        self._replayPaused = true
        -- 暂停
        self:_cancelProcessStepTask();
    end
end

-- 继续播放
function GameService_PaodekuaiReplay:resumeReplay()
    if self._replayPaused then
        self._replayPaused = false
        -- 继续播放
        self:_processStep(false);
    end
end

-- 播放加速
function GameService_PaodekuaiReplay:increaseReplaySpeed()
    self._currentSpeedIdx = self._currentSpeedIdx + 1 <= #self._replaySpeed and self._currentSpeedIdx + 1 or 1;
end

function GameService_PaodekuaiReplay:getReplaySpeed()
    return self._replaySpeed[self._currentSpeedIdx]
end

function GameService_PaodekuaiReplay:getReplaySpeedIdx()
    return self._currentSpeedIdx;
end

-- 设置所有游戏玩家,
-- 没有增量设置, 只要有变化全都更新
-- @players PlayerHistoryPROTO[]
function GameService_PaodekuaiReplay:_setRoomPlayers(localRoleId, players)
    -- 1.如果之前没有数据，清一遍，play it safe
    if table.nums(self._players) == 0 then
        self:removeAllPlayers()
    end


    local playerStatus = {}
    local playerMap = {} 
    -- 因为是回放，直接改为全是add即可，但是如果后续有中途离开房间或者中途加入房间则需要修改了
    self._mySelfServerPos = 1
    local playerStatus = {}
    for _, playerInfo in ipairs(players) do
        local pos = playerInfo.position
        playerMap[pos] = playerInfo
        local pos = playerInfo.position
        playerStatus[pos] = 'add'
        if playerInfo.roleId == localRoleId then
            self._mySelfServerPos = playerInfo.position
        elseif playerInfo:isHost() then
            self._hostServerPos = playerInfo.position
        end
    end
    
    -- 对玩家进行增删改
    for pos, status in pairs(playerStatus) do
        local playerInfo = playerMap[pos]
        local cPos = self:_convertServerPos(pos)
        playerInfo.cPosition = cPos
        if status == "add" then
            self:addPlayer(playerInfo) -- implement by base class
        elseif status == "update" then
            self:updatePlayer(playerInfo, cPos)
        elseif status == "remove" then
            playerInfo = self._players[pos] -- remove的玩家已经没有数据了，所以从上次的数据里取
            self:removePlayer(playerInfo, cPos)
        end
    end

    self._players = playerMap -- 记录一下上次的player
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
function GameService_PaodekuaiReplay:_processStep(isRecover)
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

        Logger.debug("===WAIT TIME === " .. tostring(waitTime))
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
function GameService_PaodekuaiReplay:_scheduleProcessStepTask(isRecover, nextTime)
    Macro.assetFalse(self._processStepTask == nil);
    self._processStepTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        -- 取消当前任务
        self:_cancelProcessStepTask();
        -- 处理操作
        self:_processStep(isRecover);
    end, nextTime, false);
end

-- 取消step处理任务
function GameService_PaodekuaiReplay:_cancelProcessStepTask()
    if self._processStepTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._processStepTask)
        self._processStepTask = nil
    end	
end

-- 当前是否在显示等待操作按钮
function GameService_PaodekuaiReplay:_hasWaitingOperation()
    for i=1, #self._roomSeats do
        if self._roomSeats[i]:getSeatUI():hasWaitingOperation() then
            return true;
        end
    end
    return false;
end

-- 如果有等待操作, 提示操作结果
function GameService_PaodekuaiReplay:_tryToShowNextOperation(operationWaitTime)
    if self:_hasWaitingOperation() == false then
        return
    end
    
    Macro.assetFalse(self._stepGroupIndex == 1);
    if self._recordIndex > #self._stepSequencer then
        return
    end

    -- 跑得快没有此提示
    -- local recordSteps = self._stepSequencer[self._recordIndex];
    
    -- for i=1, #recordSteps do
    --     local stepGroup = recordSteps[i];
        
    --     for j=1, #self._playerProcessors do
    --         --如果多人同时操作,同时播放动画
    --         for k=1,#stepGroup do
    --             self._playerProcessors[j]:hintWaitingOperationResult({stepGroup[k]}, operationWaitTime)
    --         end
    --     end
    -- end	
    return true;
end


function GameService_PaodekuaiReplay:_needWaitOperation(stepGroup)
    for idx, step in ipairs(stepGroup) do
        local playType = step:getPlayType()
        if playType == PlayType.POKER_OPERATE_CAN_PASS or
        playType == PlayType.POKER_OPERATE_CAN_PLAY_A_CARD then 
            Logger.debug("RETURN FALSE NEED WAIT")
            return false
        else
            Logger.debug("RETURN TRUE NEED WAIT")
            return true
        end
    end
end

--@overwrite
function GameService_PaodekuaiReplay:_convertServerPos( serverPos )
    local _pos = serverPos - self._mySelfServerPos + 1
    local ret = _pos % 4
    local ret = ret ~= 0 and ret or 4
    -- 回放需要特殊修改position,服务器只会发1,2,3 ,跑得快最多3个人
    if ret == 3 and self._mySelfServerPos ~= 3 then
        ret = 4
    end
    Logger.debug("spos = " .. serverPos .. ", cpos = " .. ret)
    return ret
end

--@overwrite
function GameService_PaodekuaiReplay:_createPlayerProcessor( cPos, player, playerUIObj )
    local clz = nil
    if cPos ==  1 then
        clz = PlayerProcessor_Local
    else
        clz = PlayerProcessor_Other
    end
    return clz.new(pos, player, playerUIObj)
end

function GameService_PaodekuaiReplay:isInReplay()
    return true
end

function GameService_PaodekuaiReplay:getLastDiscardInfo()
    return self._lastDiscardInfo or {}
end

function GameService_PaodekuaiReplay:setLastDiscardInfo(info)
    Logger.debug("====SET LAST DISCARD INFO")
    dump(info)
    self._lastDiscardInfo = self._lastDiscardInfo or {}
    if info.value then
        self._lastDiscardInfo.value = info.value
    end
    if info.type then
        self._lastDiscardInfo.type = info.type
    end
    if info.roleId then
        self._lastDiscardInfo.roleId = info.roleId
    end
end

return GameService_PaodekuaiReplay