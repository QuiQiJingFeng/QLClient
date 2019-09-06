local CommandCenter = require("app.manager.CommandCenter")
local Constants = require("app.gameMode.zhengshangyou.core.Constants_ZhengShangYou")
local PlayerProcessor_Local = require("app.gameMode.zhengshangyou.processor.PlayerProcessor_Local")
local PlayerProcessor_Other = require("app.gameMode.zhengshangyou.processor.PlayerProcessor_Other")
local RoomProcessor = require("app.gameMode.zhengshangyou.processor.RoomProcessor")
local PlayStep = require("app.gameMode.base.core.PlayStep")
local PlayType = Constants.PlayType
local PlayerStatus = Constants.PlayerStatus
local CombinedStepTypes = {
    { PlayType.POKER_OPERATE_CAN_PASS, PlayType.POKER_OPERATE_CAN_PLAY_A_CARD },
    --{ PlayType.POKER_OPERATE_LAST_PLAYER, PlayType.POKER_OPERATE_LAST_PLAY_A_CARD}
}

local super = require("app.gameMode.base.GameService")
local GameService_ZhengShangYou = class("GameService_ZhengShangYou", super)
function GameService_ZhengShangYou:ctor()
    super.ctor(self)
    self._players = {}
    self._mySelfServerPos = -1
    self._maxPlayerNum = 4
    self._isGameStarted = false
    self._roomProcessor = nil
end

-- called by GameState_Zhajinhua
function GameService_ZhengShangYou:initialize(gameScene)
    super.initialize(self, gameScene)

    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.BCBattlePlayerInfoSYN.OP_CODE, self, self._onBattlePlayerInfoSYN)
    requestManager:registerResponseHandler(net.protocol.BCPlayStepSYN.OP_CODE, self, self._onPlayStepSYN)
    requestManager:registerResponseHandler(net.protocol.BCMatchResultSYN.OP_CODE, self, self._onMatchResultSYN)
    requestManager:registerResponseHandler(net.protocol.BCFinalMatchResultSYN.OP_CODE, self, self._onBCFinalMatchResultSYN)

    -- 初始化处理器模块
    -- 创建RoomProcessor
    self._roomProcessor = RoomProcessor.new()
    self._roomProcessor:onGameWaitingStart()
    
    -- 注册command
    Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
    -- local areaId = 20001 
    local areaId = game.service.LocalPlayerService:getInstance():getArea()
    local roomService = game.service.RoomService:getInstance()
    local roomSetting = roomService:getRoomSettings()
    MultiArea.registCommands(areaId, roomService:getRoomSettings()._gameType)
    
    game.service.ChatService.getInstance():setRoomServerId(roomService:getRoomServerId())
    gameScene:showRoomRules(roomSetting)
end

--@override
function GameService_ZhengShangYou:_convertServerPos( serverPos )
    -- local basePosition
    -- if self._mySelfServerPos then
    --     basePosition = self._mySelfServerPos
    -- else
    --     basePosition = self._hostServerPos
    -- end
    -- local pos = (serverPos - basePosition + 4) % 4
    -- if pos == 3 or pos == 0 then
    --     assert(false)
    -- end
    -- Logger.debug("spos = " .. serverPos .. ", cpos = " .. pos)
    -- return pos
    
    local _pos = serverPos - self._mySelfServerPos + 1
    local ret = _pos % 4
    local ret = ret ~= 0 and ret or 4

    if ret == 3 and self._mySelfServerPos ~= 3 and game.service.LocalPlayerService:getInstance():isWatcher() then
        ret = 4
    end
    Logger.debug("spos = " .. serverPos .. ", cpos = " .. ret)
    return ret
end

--@override
function GameService_ZhengShangYou:_createPlayerProcessor( cPos, player, playerUIObj )
    local clz = nil
    if cPos ==  1 then
        clz = PlayerProcessor_Local
    else
        clz = PlayerProcessor_Other
    end
    return clz.new(pos, player, playerUIObj)
end

function GameService_ZhengShangYou:setRoomPlayers( players )
    -- 1.如果之前没有数据，清一遍，play it safe
    if table.nums(self._players) == 0 then
        self:removeAllPlayers()
    end
    -- 每个位置玩家的数据状态：add(新增)、update(更新)、remove(删除)
    local playerStatus = {}
    local playerMap = {} -- 之后会赋值给self._players
    -- 记录我的位置
    self._mySelfServerPos = 0
    local localRoleId = game.service.LocalPlayerService:getInstance():getRoleId()
    for _, playerInfo in ipairs(players) do
        local pos = playerInfo.position
        playerMap[pos] = playerInfo -- 把player记录到map里，key为position
        local old = self._players[pos] -- 之前这个位置记录的玩家
        if old == nil then
            playerStatus[pos] = "add"
        else
            playerStatus[pos] = "update"
        end
        -- 顺便找一下自己的位置
        if playerInfo.roleId == localRoleId then
            self._mySelfServerPos = playerInfo.position
        elseif playerInfo:isHost() then
            self._hostServerPos = playerInfo.position
        end
    end
    -- 若是观战，则用host视角
    if game.service.LocalPlayerService:getInstance():isWatcher() then
        self._mySelfServerPos = self._hostServerPos
    end

    -- 如果之前有，现在没有，那么这个位置的人删了
    for pos, _ in pairs(self._players) do
        if playerMap[pos] == nil then
            playerStatus[pos] = "remove"
        end
    end
    
    local roomService = game.service.RoomService:getInstance()
    self._maxPlayerNum = roomService:getMaxPlayerCount()

    -- 对玩家进行增删改
    for pos, status in pairs(playerStatus) do
        local playerInfo = playerMap[pos]
        local cPos = self:_convertServerPos(pos)
        if status == "add" then
            self:addPlayer(playerInfo) -- implement by base class
            playerInfo.cPosition = cPos
        elseif status == "update" then
            self:updatePlayer(playerInfo, cPos)
            playerInfo.cPosition = cPos
        elseif status == "remove" then
            playerInfo = self._players[pos] -- remove的玩家已经没有数据了，所以从上次的数据里取
            self:removePlayer(playerInfo, cPos)
        end
    end

    self._players = playerMap -- 记录一下上次的player
end

function GameService_ZhengShangYou:dispose()
    -- self._gameScene:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    CommandCenter.getInstance():unregistAll()
    self:removeAllPlayers()
    -- 调用基类的dispose应该在最后， 设计到了 cc.unbind
    self.super.dispose(self)
end

function GameService_ZhengShangYou:prepareForNextRound(ignorePlayerStatus)
    self._gameScene:prepareForNextRound()
    for _, processor in pairs(self._playerProcessors) do
        processor:prepareForNextRound()
    end

    if ignorePlayerStatus == nil then
        if game.service.RoomService.getInstance() ~= nil then
            game.service.RoomService.getInstance():updateStatus(PlayerStatus.READY)
        end
    end
    
    self._lastDiscardInfo = nil
end

-- 设置游戏的最大局数
function GameService_ZhengShangYou:setMaxRoundCount(count)
    self._maxRoundCount = count
    self._gameScene:setRoundCount(self._currentRoundCount or 0, self._maxRoundCount or 0)
end

-- 设置游戏的最大局数
function GameService_ZhengShangYou:getMaxRoundCount()
    return self._maxRoundCount
end

-- 设置游戏当前局数
function GameService_ZhengShangYou:setCurrentRoundCount(count)
    self._currentRoundCount = count
    self._gameScene:setRoundCount(self._currentRoundCount or 0, self._maxRoundCount or 0)
end

-- 设置游戏当前局数
function GameService_ZhengShangYou:getCurrentRoundCount()
    return self._currentRoundCount
end

function GameService_ZhengShangYou:isGameStarted()
    return self._isGameStarted
end

function GameService_ZhengShangYou:_onBattlePlayerInfoSYN(response)
    self._isGameStarted = true
    local ignorePlayerStatus = true
    self:prepareForNextRound(ignorePlayerStatus)

    local protocol = response:getProtocol():getProtocolBuf()

    local localRoleId = game.service.LocalPlayerService:getInstance():getRoleId()
    local players = protocol.players
    for _, player in ipairs(players) do
        -- local processors = self._playerProcessors
        local processor = self:getPlayerProcessorByPlayerId(player.roleId)
        -- assert(processor ~= nil)
        processor:onGameStarted(player, protocol.isRecover)
        
        if player.roleId == localRoleId then
            local steps = player.operateCards
            for _, step in ipairs(steps) do
                local clientStep = PlayStep.new():setProto(step)
                table.insert(self._stepSequencer, {clientStep})
                -- local key = table.keyof(PlayType, step.playType)
                -- print(key .. ':')
                -- dump(step)
            end
            -- dump("-----------------------------------")
        end
    end
    self:_processStep(protocol.isRecover)
    self._gameScene:onGameStarted(protocol.isRecover)

    --牌局开始统计冲突的房间
    game.service.RoomService.getInstance():getSecurityChecker():statisticalConflictRoom()
    
    -- 好友圈经理观战需要这个event来关闭结算界面
    local event = {name = "EVT_NEW_GAME_ROUND_BEGIN"}
	self:dispatchEvent(event);
end

function GameService_ZhengShangYou:_onPlayStepSYN(response)
    -- assert(false, 'unimplement')
    local protocol = response:getProtocol():getProtocolBuf()
    local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
    -- dump(protocol.steps)

    -- 这个合并类型，以后到放Command中去，通过Processor来获取
    local _combinedStepTypes = CombinedStepTypes or {}
    
    -- 构造PlayStep
    local stepsData = {};
    for i = 1,#protocol.steps do
        local step = protocol.steps[i]
        -- dump(step)
        table.insert(stepsData, PlayStep.new():setProto(protocol.steps[i]))
    end
    
    -- 这个循环会把steps合并放到Sequencer中去
    while #stepsData > 0 do
        local stepData = stepsData[1];

        local needCombined = false
        for _,v in ipairs(_combinedStepTypes) do
            for _,pType in ipairs(v) do
                if pType == stepData._playType then
                    needCombined = true
                end
            end
        end

        if needCombined then
            local steps = {}
            table.foreach(stepsData, function(i,v)
                for _,v2 in ipairs(_combinedStepTypes) do
                    if table.indexof(v2, v._playType) ~= false then
                        table.insert(steps, v)
                    end
                end
            end)
            table.insert(self._stepSequencer, steps);
            local index = 1
            while index <= #steps do
                table.remove(stepsData, table.indexof(stepsData, steps[index]))
                index = index + 1
            end
        else
            table.insert(self._stepSequencer, {stepData})
            table.remove(stepsData, table.indexof(stepsData, stepData))
        end
    end

    self:_processStep(false)
end

--[[
    单局结算，当做Step插入到 sequence 中 处理
]]
function GameService_ZhengShangYou:_onMatchResultSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()

    local roomService = game.service.RoomService.getInstance()
	if roomService ~= nil then 
        roomService:setBattleEndData(protocol.battleEndTime, protocol.canAutoStartNextRound)
	end 

    local step = PlayStep.new()
    step._roleId = -1
    step._playType = PlayType.DISPLAY_FINISH_ALL
    step._result = protocol
    table.insert(self._stepSequencer, {step})
    self:_processStep(false)
end

function GameService_ZhengShangYou:_onBCFinalMatchResultSYN(response)
    -- assert(false)
    self._finishMatchResultProto = response:getProtocol():getProtocolBuf()
end

function GameService_ZhengShangYou:getFinishMatchResult()
    return self._finishMatchResultProto;
end

function GameService_ZhengShangYou:getFinishMachResult()
    return self:getFinishMatchResult()
end


function GameService_ZhengShangYou:sendPlayStep(playType, cards, datas)
    local roomService = game.service.RoomService.getInstance()
    local request = net.NetworkRequest.new(net.protocol.CBPlayCardREQ, roomService:getRoomServerId())
    request:setWaitForResponse(false)
    request:getProtocol():setData(playType, cards, datas)
    game.util.RequestHelper.request(request)
end

function GameService_ZhengShangYou:setLastDiscardInfo(info)
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

function GameService_ZhengShangYou:getLastDiscardInfo()
    return self._lastDiscardInfo or {}
end

function GameService_ZhengShangYou:isInReplay() return false end

return GameService_ZhengShangYou