local RoomSeat = require("app.gameMode.mahjong.RoomSeat")
local RoomProcessor = require("app.gameMode.mahjong.processor.RoomProcessor")
local PlayerProcessor_Local = require("app.gameMode.mahjong.processor.PlayerProcessor_Local")
local PlayerProcessor_Other = require("app.gameMode.mahjong.processor.PlayerProcessor_Other")
local PlayStep = require("app.gameMode.mahjong.core.PlayStep")
local Player = require("app.gameMode.mahjong.core.Player")
local PlayType = require("app.gameMode.mahjong.core.Constants").PlayType
local PlayerStatus = require("app.gameMode.mahjong.core.Constants").PlayerStatus
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Time = kod.util.Time;
local CommandCenter = require("app.manager.CommandCenter")

--[[-- 进入牌局场景后, 牌局逻辑处理模块, 处于与打牌相关的操作
--]]
local GameService_Mahjong = class("GameService_Mahjong")

--------------------------------
function GameService_Mahjong:ctor()
	self._roomUI = nil
	self._roomSeats = {}
	
	--	self._maxPlayerCount = 0
	self._maxRoundCount = 0;
	self._currentRoundCount = 0;
	
	self._isGameStarted = false;	-- 当前牌局是否开始
	self._roomProcessor = nil
	self._playerProcessor = {}
	self._stepSequencer = {}
	self._timerScheduler = nil
	self._processStepTask = nil;
	self._isTrusteeship = false;
	
	-- 最终结算，如果收到，单局结算后就会显示最终结算
    self._finishMachResultProto = nil
	-- 当前是否处于胡的推牌状态(3D麻将计算一些特殊倍率需要)
	self._isOnHuStatus = false
    -- 报错监听
    self._reportErrorListener = nil
end

function GameService_Mahjong:initialize(gameScene)
	cc.bind(self, "event");
	
	-- 注册事件回调
	local requestManager = net.RequestManager.getInstance()
	requestManager:registerResponseHandler(net.protocol.BCBattlePlayerInfoSYN.OP_CODE, self, self._onBattlePlayerInfoSyn);
	requestManager:registerResponseHandler(net.protocol.BCPlayCardRES.OP_CODE, self, self._onPlayCardRes);
	requestManager:registerResponseHandler(net.protocol.BCPlayStepSYN.OP_CODE, self, self._onPlayStepSyn);
	requestManager:registerResponseHandler(net.protocol.BCMatchResultSYN.OP_CODE, self, self._onMatchResultSYN);
	requestManager:registerResponseHandler(net.protocol.BCFinalMatchResultSYN.OP_CODE, self, self._onBCFinalMatchResultSYN);
	requestManager:registerResponseHandler(net.protocol.BCOpenAutoHuRES.OP_CODE, self, self._onBCOpenAutoHuRES);
    
	self._reportErrorListener = listenGlobalEvent("MAHJONG_REPORT_ERROR", handler(self, self._reportError))
	
	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_REFRESH_ADVANCE_INFO", handler(self, self._onRefreshAdvanceStartInfo), self)
	
	local roomService = game.service.RoomService.getInstance();
	
	-- 保存RoomUI
	self._roomUI = gameScene:getRoomUI()
	self._roomUI:initialize()
	
	-- 初始化座位
	for i = CardDefines.Chair.Down, CardDefines.Chair.Left do
		local seatUI = gameScene:getSeatUI(i)
		local seat = RoomSeat.new(i, seatUI);
		seatUI:setRoomSeat(seat)
		seatUI:updateDiscardedLayout(roomService:getMaxPlayerCount())
		table.insert(self._roomSeats, seat)
	end
	
	-- 初始化处理器模块
	-- 创建RoomProcessor
	self._roomProcessor = RoomProcessor.new(self._roomUI)
	self._roomProcessor:onGameWaitingStart()
	self._roomUI:setRoomId(roomService:getRoomId())
	self._roomUI:onCampaignRankChange()
	self._roomUI:showRoomRules(roomService:getRoomSettings())
	
	-- 创建PlayerProcessor
	for i = 1, #self._roomSeats do
		local seat = self._roomSeats[i]
		
		-- 创建PlayerProcessor
		local playerProcessor = nil
		-- 是下面的玩家，但同时不是观战模式的时候，才使用local player
		if seat:isLocalSeat() and not game.service.LocalPlayerService:getInstance():isWatcher() then
			playerProcessor = PlayerProcessor_Local.new(self._roomUI, seat, seat:getSeatUI(), true)
		else
			playerProcessor = PlayerProcessor_Other.new(self._roomUI, seat, seat:getSeatUI(), false)
		end
		
		table.insert(self._playerProcessor, playerProcessor)
	end
	
	-- 注册command
	Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
	local areaId = game.service.LocalPlayerService:getInstance():getArea()	
	MultiArea.registCommands(areaId, roomService:getRoomSettings()._gameType)
	
	-- 初始化聊天模块
	game.service.ChatService.getInstance():setRoomServerId(roomService:getRoomServerId())
end

function GameService_Mahjong:_onRefreshAdvanceStartInfo()
	local roomService = game.service.RoomService.getInstance();
	self._roomUI:showRoomRules(roomService:getRoomSettings())
	if roomService:getAdvanceStartSwitch() == false then
		self._roomUI:hideAdvanceBtn()
	else
		if not self._isGameStarted  then
			self._roomUI:refreshAdvanceBtn()
		end
		self._roomUI:refreshStartText()
	end
end

function GameService_Mahjong:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);	
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
    
	unlistenGlobalEvent(self._reportErrorListener)
	
	self:_cancelProcessStepTask();
	
	self._roomSeats = {}
	-- 取消所有cmd的注册
	CommandCenter.getInstance():unregistAll()
	
	if self._roomProcessor ~= nil then
		self._roomProcessor:dispose();
	end
	self._roomProcessor = nil
	
	for i = 1, #self._playerProcessor do
		self._playerProcessor[i]:dispose();
	end
	self._playerProcessor = {}
	
	-- self._roomUI:dispose()
	-- self._roomUI = nil
	self._dataBCBattlePlayerInfoSYN = nil
	self._dataBCPlayStepSYN = {}
	game.service.RoomService.getInstance():removeEventListenersByTag(self)
	
	cc.unbind(self, "event");
end

function GameService_Mahjong:_reportError( data )
    -- local data = event.userdata
    local roomId = game.service.RoomService:getInstance():getRoomId()
    local roundIndex = self:getCurrentRoundCount()
    local cardsStr = ''
    local playerId = game.service.LocalPlayerService.getInstance():getRoleId() -- 自己的id
    local processor = self:getPlayerProcessorByPlayerId(playerId)
    if processor ~= nil then
        local cardList = processor._cardList
        if cardList ~= nil then
            cardsStr = "handCards:["
            for iddx = 1, #cardList.handCards do
                cardsStr = cardsStr .. cardList.handCards[iddx]._cardValue .. ","
            end
            for iddx=1, #cardList.cardGroups do
                local group = cardList.cardGroups[iddx];
                cardsStr = cardsStr .. "["
                for idddx=1, #group.cards do
                    cardsStr = cardsStr .. group.cards[idddx]._cardValue .. ","
                end
                cardsStr = cardsStr .. "]"
            end
            cardsStr = cardsStr .. "]"
        end
    end
    -- 多打印点信息
    local msg = string.format("[%s]%d,%d:%s", data.msg, roomId, roundIndex, cardsStr)
    game.service.DataEyeService.getInstance():reportError(data.type, msg)
end

-------------------------
-- Accessor
-------------------------
function GameService_Mahjong:getRoomUI()
	return self._roomUI;
end

function GameService_Mahjong:getRoomSeats()
	return self._roomSeats;
end

function GameService_Mahjong:getRoomSeat(chairType)
	for i = 1, #self._roomSeats do
		if self._roomSeats[i]:getChairType() == chairType then
			return self._roomSeats[i]
		end
	end
	return nil
end

-- 设置游戏支持的最大玩家数
--function GameService_Mahjong:setMaxPlayerCount(count)
--	self._maxPlayerCount = count
--end
function GameService_Mahjong:getMaxPlayerCount()
	-- TODO : 直接存在这个类里面
	return game.service.RoomService.getInstance():getMaxPlayerCount()
end

function GameService_Mahjong:getPlayerNums()
	return game.service.RoomService.getInstance():getPlayerNum()
end

-- 设置游戏的最大局数
function GameService_Mahjong:setMaxRoundCount(count)
	self._maxRoundCount = count
end

-- 设置游戏的最大局数
function GameService_Mahjong:getMaxRoundCount()
	return self._maxRoundCount
end

-- 设置游戏当前局数
function GameService_Mahjong:setCurrentRoundCount(count)
	self._currentRoundCount = count
	-- TODO : 修改UI
end

-- 设置游戏当前局数
function GameService_Mahjong:getCurrentRoundCount()
	return self._currentRoundCount
end

function GameService_Mahjong:getRoomProcessor()
	return self._roomProcessor;
end

function GameService_Mahjong:isGameStarted()
	return self._isGameStarted
end

function GameService_Mahjong:IsOnHuStatus()
	return self._isOnHuStatus
end

function GameService_Mahjong:getPlayerProcessorByPlayerId(playerId)
	for i = 1, #self._playerProcessor do
		local processor = self._playerProcessor[i]
		if processor:getRoomSeat() ~= nil
		and processor:getRoomSeat():hasPlayer()
		and processor:getRoomSeat():getPlayer().id == playerId then
			return processor
		end
	end
	Logger.info("Failed GameService_Mahjong:getPlayerProcessorByPlayerId playerId = %s", playerId or "nil")
	return nil
end

function GameService_Mahjong:getPlayerProcessorByChair(chair)
	for i = 1, #self._playerProcessor do
		local processor = self._playerProcessor[i]
		if processor:getRoomSeat() and processor:getRoomSeat():hasPlayer() and processor:getSeatUI():getChairType() == chair then
			return processor
		end
	end
	
	return nil
end

function GameService_Mahjong:isHaveBeginFirstGame()
	return game.service.RoomService.getInstance():isHaveBeginFirstGame();
end

--==============================--
--desc: 让所有用户都准备
--time:2017-08-17 07:03:14
--@return 
--==============================--
function GameService_Mahjong:setRoomPlayerReadyState()
	self._isGameStarted = true
	for i, seat in ipairs(self._roomSeats) do
		seat:getSeatUI():setPlayerReady(false)
	end
end

-- 设置所有游戏玩家,
-- 没有增量设置, 只要有变化全都更新
function GameService_Mahjong:setRoomPlayers(players)
	local playerService = game.service.LocalPlayerService.getInstance();
	
	-- 获取本地玩家
	local localPlayer = nil
	local hostPlayer = nil
	local offline = false
	for i = 1, #players do
		if players[i].id == playerService:getRoleId() then
			localPlayer = players[i];
		end
		if players[i]:isHost() then
			hostPlayer = players[i]
		end

		if players[i]:isOnline() == false then
			offline = true
		end
	end
	-- 未开局的情况下有人离线就提示
	if not game.service.RoomService:getInstance():isHaveBeginFirstGame() and game.service.RoomService:getInstance():getRoomClubId() ~= 0 then
		if offline then
			self._roomUI:playOfflineAim(true)
		else
			self._roomUI:playOfflineAim(false)
		end
	else
		self._roomUI:playOfflineAim(false)
	end
	
	-- 当亲友圈群主观看录像的时候，localPlayer是空的, 使用host视角观战
	local basePosition = localPlayer ~= nil and localPlayer.position or (hostPlayer ~= nil and hostPlayer.position or players[1].position)
	
	-- 玩家入座
	for i = 1, #players do
		local player = players[i]
		Logger.info("GameService_Mahjong:setRoomPlayers player: %d", player.id)

		player.seat = CardDefines.CHAIR_MAP[(player.position - basePosition + 4) % 4];
		Logger.info("player.id = %s, player.seat = %s, player.position = %s", player.id, player.seat, player.position)
		local roomSeat = self:getRoomSeat(player.seat)
		roomSeat:setPlayer(player)
	end
	
	-- 清空没有玩家的座位
	for i = 1, #self._roomSeats do
		local roomSeat = self._roomSeats[i]
		
		-- 查看这个座位没有应玩家
		local found = false;
		for j = 1, #players do
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
	
	-- 通知界面更新(貌似没有需要更新的)
	self._roomProcessor:onPlayerChanged(players);
end

-------------------------
-- 协议处理
-------------------------
-- 服务器同步玩家牌局信息 打牌开始
function GameService_Mahjong:_onBattlePlayerInfoSyn(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local roomService = game.service.RoomService.getInstance();

	-- 对结算继续倒计时处理下，避免牌局自动开始后，结算相关缓存没有清空
	self:_checkClearReport()

	-- 如果是金币场则显示对应动画
	if roomService:getRoomType() == game.globalConst.roomType.gold and not protocol.isRecover then
		UIManager.getInstance():show("UIGoldBegin")
	end
	
	-- TODO：现在线上有个问题，在开局发牌后，手里的牌没有清除，想了好多种情况，不知道怎么出现的
	-- 先保证一下正常运行，在开局的时候，清除一下，看看是服务器发下来就多了，还是客户端自己存下的
	-- 已经想出怎么回事了！！！
	-- 当观战中的两个玩家全部掉线，然后重连，但是观战的人却没有掉线，仍然在看动画，这时其它两人的牌局其实已经开始下一局了，观战的人在显示结算界面的时候
	-- 清除数据的时候，其实是把两局的时候数据全部清除了，然后再从结算界面回来的时候，已经没有数据了！！
	if #self._playerProcessor[1]._cardList.handCards > 0 and not campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
		self:prepareForNextRound(true)
		roomService:updatePlayerStatus()
	end
	
	--比赛的情况下,应该在收到打牌开始后，清除牌桌，因为比赛是一个被动的过程，故没收到消息客户端不应该主动清理
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
		self:prepareForNextRound(true)
		roomService:updatePlayerStatus()
	end
	
	-- 默认不托管
	self:setIsTrusteeship(false)
	
	-- 牌局开始。
	self._isGameStarted = true;
	roomService:setHaveBeginFirstGame(true);
	
	-- 是不是复牌
	local isRecover = protocol.isRecover;
	-- 更新玩家信息
	local battlePlayers = protocol.players;
	for i = 1, #battlePlayers do
		local battlePlayer = battlePlayers[i];
		local roleId = battlePlayer.roleId;
		local player = roomService:getPlayerById(roleId)
		
		player.totalPoint = battlePlayer.totalPoint;
		player.pointInGame = battlePlayer.pointInGame;
		player.status = battlePlayer.status;
		
		local playerProcessor = self:getPlayerProcessorByPlayerId(roleId)
		playerProcessor:getSeatUI():maxCardNumberReset(protocol.totalCardsNum)
		-- 牌局开始时重置一下玩家的打牌位置，因为可能是提前开局3人变成2人布局需要刷新
		playerProcessor:getSeatUI():updateDiscardedLayout(roomService:getPlayerNum())

		if(roomService:getRoomType() ~= game.globalConst.roomType.gold) then
			playerProcessor:getSeatUI():setTotalScore(player.totalPoint)
		end
		
		playerProcessor:onGameStarted(battlePlayer.outCards, battlePlayer.handCards, battlePlayer.operateCards, isRecover);		
	end
	
	-- 设置房间局数信息
	self._roomProcessor:onGameStarted()
	-- 打完后，roomservice会销毁，这里需要先把相关数据保存进去
	self:getRoomUI():getHuHandler():setRoomClubId(game.service.RoomService:getInstance():getRoomClubId())
	self:getRoomUI():getHuHandler():setRoomLeagueId(game.service.RoomService:getInstance():getRoomLeagueId())
	
	--牌局开始统计冲突的房间
	game.service.RoomService.getInstance():getSecurityChecker():statisticalConflictRoom()
	
	-- 广播游戏开始
	local event = {name = "EVT_NEW_GAME_ROUND_BEGIN"}
	self:dispatchEvent(event);
end

function GameService_Mahjong:_checkClearReport()
	local _tab = {"UILastCrads", "UICardsInfo_new", "UIRoundReportPage2"}
	for _, uiName in pairs(_tab) do 
		UIManager:getInstance():hide(uiName)
		UIManager:getInstance():destroy(uiName)
	end 

	-- 牌桌界面显示设置按钮
	local event = {name = "EVENT_ROOMCARD_HIDESETTIN", isVisible = true}
    game.service.LocalPlayerService:getInstance():dispatchEvent(event)
end 

-- 发送打牌消息
-- @param playType: number
-- @param  cards: number[]
function GameService_Mahjong:sendPlayStep(playType, cards)
	local roomService = game.service.RoomService.getInstance();
	-- 如果roomserice没了，就不发
	if roomService == nil or roomService:getRoomId() == 0 then
		return
	end
	local request = net.NetworkRequest.new(net.protocol.CBPlayCardREQ, roomService:getRoomServerId());
	request:setWaitForResponse(false);
	request:getProtocol():setData(playType, cards);
	game.util.RequestHelper.request(request);

end

-- 玩家打牌消息的相应
function GameService_Mahjong:_onPlayCardRes(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local request = response:getRequest()
	
	local isInCampaignBattle = campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign()
	-- 目前const定义只有金币场，其他类型房间类型值为0
	local isInGoldBattle = game.service.RoomService.getInstance():getRoomType() == game.globalConst.roomType.gold
	-- 极速模式
	local isFastMode = game.service.RoomService.getInstance():isFastMode()
	-- 比赛场和金币场若失败则复牌
	local roomId = game.service.RoomService:getInstance():getRoomId()
	local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
	if isInCampaignBattle or isInGoldBattle or isFastMode then
		if protocol.result ~= net.ProtocolCode.BC_PLAYCARD_SUCCESS 
			-- and protocol.result ~= net.ProtocolCode.BC_PLAYCARD_FAILED_NOT_YOUR_TURN
			and protocol.result ~= net.ProtocolCode.BC_PLAYCARD_FAILED_NOT_IN_ROOM then
			local joinStyle = "none"
			if isInCampaignBattle then
				joinStyle = game.globalConst.JOIN_ROOM_STYLE.Campaign
			elseif isInGoldBattle then
				joinStyle = game.globalConst.JOIN_ROOM_STYLE.Gold
			else
			end
			game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, joinStyle, false);
			-- TODO:当玩家发送step，服务器返回失败的时候，打印相关信息, 解决之后记得删除信息
			local requestProto = response:getRequest():getProtocol():getProtocolBuf()
			Logger.debug(">===============ERROR-START=================<")
			Logger.debug(string.format("ErrorCode:%x, PlayType:%d Cards:%s", protocol.result, requestProto.playType, json.encode(CardDefines.getCards(requestProto.cards))))
			
			local roomService = game.service.RoomService:getInstance()
			if roomService then
				Logger.debug("RoleId:" .. roleId .. " RoomId:" .. roomId)
			end
			
			local processor = self:getPlayerProcessorByChair(CardDefines.Chair.Down)
			if processor then
				Logger.debug(processor._cardList:toStrings())
			end
			Logger.debug(">================ERROR-END==================<")
		end
	else
		-- 关于BC_PLAYCARD_FAILED_NOT_YOUR_TURN 服务器反馈该索引虽不合理但属于正常操作，故此忽略掉
		local errMsg = string.format("[ERROR]onPlayCardRes result:%x",protocol.result or "nil")
		if Macro.assertTrue((protocol.result ~= net.ProtocolCode.BC_PLAYCARD_SUCCESS
			-- and protocol.result ~= net.ProtocolCode.BC_PLAYCARD_FAILED_NOT_YOUR_TURN
			and protocol.result ~= net.ProtocolCode.BC_PLAYCARD_FAILED_NOT_IN_ROOM), errMsg) then
			-- game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
			-- TODO:当玩家发送step，服务器返回失败的时候，打印相关信息, 解决之后记得删除信息
			local requestProto = response:getRequest():getProtocol():getProtocolBuf()
			Logger.debug(">===============ERROR-START=================<")
			Logger.debug(string.format("ErrorCode:%x, PlayType:%d Cards:%s", protocol.result, requestProto.playType, json.encode(CardDefines.getCards(requestProto.cards))))
			
			local roomService = game.service.RoomService:getInstance()
			if roomService then
				Logger.debug("RoleId:" .. roleId .. " RoomId:" .. roomId)
			end
			
			local processor = self:getPlayerProcessorByChair(CardDefines.Chair.Down)
			if processor then
				Logger.debug(processor._cardList:toStrings())
			end
			Logger.debug(">================ERROR-END==================<")
		end
	end
end

-- 服务器推送的牌局变化消息
function GameService_Mahjong:_onPlayStepSyn(response)
	local protocol = response:getProtocol():getProtocolBuf()
	
	--如果玩家数据没用则缓存牌局开始消息等待玩家数据有了以后再触发
	local roomService = game.service.RoomService.getInstance();

	-- 打印step里的关键信息，方便定位bug
	Logger.debug(string.format("onPlayStepSyn Sequence:0x%x", protocol.protocolSeq))	
	for i, step in ipairs(protocol.steps) do
		Logger.debug(string.format("roleId:%d PlayType:%d Cards:%s", step.roleId, step.playType, json.encode(CardDefines.getCards(step.cards))))	
	end
	
	-- 构造PlayStep
	local stepsData = {};
	for i = 1, #protocol.steps do
		table.insert(stepsData, PlayStep.new():setProto(protocol.steps[i]))
	end
	
	-- console.log(`On_BC_PlayStepSync:${GFunc.dump(stepsData)}`);
	-- 需要合并的类型
	local combinedStepTypes = {
		{PlayType.OPERATE_HU},
		{PlayType.DISPLAY_DEAL_BETTING_HORSE, PlayType.DISPLAY_BETTING_HORSE},
		{PlayType.OPERATE_CAN_CHI_A_CARD},
		{PlayType.OPERATE_CAN_AN_GANG, PlayType.OPERATE_CAN_BU_GANG_A_CARD},
		{PlayType.DISPLAY_JI_SELF, PlayType.DISPLAY_FINISH_ALL, PlayType.DISPLAY_FINISH_ALL_REPLAY, PlayType.DISPLAY_JI_FANPAI, PlayType.DISPLAY_JI_CHUIFENG, PlayType.DISPLAY_JI_XINGQI},
	}
	
	while #stepsData > 0 do
		local stepData = stepsData[1];
		
		local needCombined = false
		for _, v in ipairs(combinedStepTypes) do
			for _, pType in ipairs(v) do
				if pType == stepData._playType then
					needCombined = true
				end
			end
		end
		
		if needCombined then
			local steps = {}
			table.foreach(stepsData, function(i, v)
				for _, v2 in ipairs(combinedStepTypes) do
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
	
	-- 执行操作
	self:_processStep(false);
end


-- 服务器推送牌局结算
function GameService_Mahjong:_onMatchResultSYN(data)
	local roomService = game.service.RoomService.getInstance()
	if roomService ~= nil then 
		local protocol = data:getProtocol():getProtocolBuf()
		roomService:setBattleEndData(protocol.battleEndTime, protocol.canAutoStartNextRound)
	end 

	local step = PlayStep.new()
	step._playType = PlayType.DISPLAY_FINISH_ALL
	step._result = data
	self._isOnHuStatus = true
	table.insert(self._stepSequencer, {step})
    self:_processStep(false);
	dispatchGlobalEvent("EVENT_BATTLE_GAME_ENDED", { type = "round" })
	
	
end

-- 服务器推送牌局最终结算
function GameService_Mahjong:_onBCFinalMatchResultSYN(data)
    self._finishMachResultProto = data:getProtocol():getProtocolBuf()
    dispatchGlobalEvent("EVENT_BATTLE_GAME_ENDED", { type = "final" })
end

function GameService_Mahjong:_onBCOpenAutoHuRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	-- if protocol.result ~= net.ProtocolCode.P_BC_OPEN_AUTO_HU_RES
end

function GameService_Mahjong:queryBOpenAutoHu(isOpen)
	local roomService = game.service.RoomService.getInstance();
	local request = net.NetworkRequest.new(net.protocol.CBOpenAutoHuREQ, roomService:getRoomServerId());
	request:getProtocol():setData(isOpen);
	game.util.RequestHelper.request(request);
end

-- 获取最终结算数据
function GameService_Mahjong:getFinishMachResult()
	return self._finishMachResultProto;
end

-------------------------------------------------
-- 操作队列处理相关
-------------------------------------------------
--[[StepEvent相关的Event
event = {
name = "PROC_EVENT"
isRecover = false
stepGroup = nil
}
]]
-- 处理当前缓存的操作
-- @param isRecover: boolean, 当前是否是复牌模式
function GameService_Mahjong:_processStep(isRecover)
	if self._processStepTask ~= nil then
		Macro.assertFalse(isRecover == false)
		-- 有正在等待的处理, 不用执行
		return
    end
	
	while #self._stepSequencer ~= 0 do
		-- 获取下一个要执行的Step
		local stepGroup = self._stepSequencer[1]
        table.remove(self._stepSequencer, 1)
        if stepGroup[1]:getPlayType() == PlayType.OPERATE_DEAL_FIRST then
            -- 正在开始游戏了，客户端与服务器都准备好了
            dispatchGlobalEvent("EVENT_BATTLE_GAME_STARTED")
        end
		
		local roleId = stepGroup[1]:getRoleId() -- roleId == -1 表示基于房间的操作
		local playerProcessor = roleId == - 1 and nil or self:getPlayerProcessorByPlayerId(roleId)
		
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
			-- Macro.assertFalse(Time.now() >= checkTime)
			-- 派发操作处理事件
			local event = {name = "PROC_STEP", isRecover = isRecover, stepGroup = stepGroup}
			self:dispatchEvent(event);
			
			-- 检查是否可以继续处理
			local nextIdleTime = self._roomProcessor:getNextIdleTime();
			nextIdleTime = playerProcessor == nil and nextIdleTime or math.max(nextIdleTime, playerProcessor:getNextIdleTime())
			if Time.now() < nextIdleTime then
				-- 当前还不能继续操作, 计划下次更新
				self:_scheduleProcessStepTask(isRecover, nextIdleTime - Time.now())
				return;
			end
		end
	end
end

-- 规划下一次处理step的任务
function GameService_Mahjong:_scheduleProcessStepTask(isRecover, nextTime)
	Macro.assertFalse(self._processStepTask == nil);
	
	self._processStepTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		-- 取消当前任务
		self:_cancelProcessStepTask();
		-- 处理操作
		self:_processStep(isRecover);
	end, nextTime, false);
end

-- 取消step处理任务
function GameService_Mahjong:_cancelProcessStepTask()
	if self._processStepTask ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._processStepTask)
		self._processStepTask = nil
	end
end

-------------------------------------------------
--
-------------------------------------------------
function GameService_Mahjong:clearForNextRound()
end

function GameService_Mahjong:prepareForNextRound(ignoreStatus)
	self:clearForNextRound()
	self:getRoomUI():getHuHandler():clear()
	self:getRoomUI():hideDiscardedCardIndicator()
	self:getRoomUI():showInviteButton(false)
	self:getRoomUI():showGameUI(false)
	self:getRoomUI():clearGuiPai()
	if ignoreStatus == nil then
		-- 比赛最后一局结束后roomservice可能为空
		if game.service.RoomService.getInstance() ~= nil then
			game.service.RoomService.getInstance():updateStatus(PlayerStatus.READY);
		end
	end
	
	table.foreach(self._playerProcessor, function(key, player)
		player:clearForNextRound()
	end)
	self._isOnHuStatus = false
	self._isGameStarted = false
end

-------------------------------------------------
-- 托管
-------------------------------------------------
function GameService_Mahjong:setIsTrusteeship(value)			
	self._isTrusteeship = value;
	
	if value == true and not game.service.RoomService:getInstance():isFastMode() then
		UIManager:getInstance():show("UITrusteeship")
		self:getRoomUI():cancelTrustCountDown()
	else
		UIManager:getInstance():hide("UITrusteeship")
	end
end

function GameService_Mahjong:getIsTrusteeship()					
	return self._isTrusteeship;
end

-------------------------------------------------
-- 获取当前已经出牌的数量
-------------------------------------------------
function GameService_Mahjong:getRemainCardValue(cardValue)
	local max = 4
	for i, v in ipairs(self._playerProcessor) do
		-- 如果是自己，则要计算自己手牌
		if v:getRoomSeat() ~= nil
		and v:getRoomSeat():hasPlayer()
		and v:getRoomSeat():getPlayer().id == game.service.LocalPlayerService:getInstance():getRoleId() then
			for i1, v1 in ipairs(v._cardList.handCards) do
				if v1:getCardValue() == cardValue then
					max = max - 1
				end
			end
		end
		
		-- 当前的吃碰杠
		for i1, v1 in ipairs(v._cardList.cardGroups) do
			if v1.cardState == CardDefines.CardState.Pengpai then
				-- 碰
				if v1.cards[1]:getCardValue() == cardValue then
					max = max - 3
				end
			elseif v1.cardState == CardDefines.CardState.Pengpai then
				-- 吃
				for i2, v2 in ipairs(v1.cards) do
					if v2:getCardValue() == cardValue then
						max = max - 1
					end
				end
			else
				-- 3种杠
				if v1.cards[1]:getCardValue() == cardValue then
					max = max - 4
				end
			end
		end
		
		-- 当前的弃牌堆
		for i1, v1 in ipairs(v._cardList.discardedCardList) do
			if v1:getCardValue() == cardValue then
				max = max - 1
			end
		end
		
		-- 当前的已胡牌堆
		for i1, v1 in ipairs(v._cardList.huCards) do
			if v1:getCardValue() == cardValue then
				max = max - 1
			end
		end
		
		-- TODO-NOTICE
		-- 其它情况，如果有翻鬼，已经翻开的牌也要处理
	end
	-- if max < 0 then
	-- 	-- 当前出现了 4张以上的牌
	-- 	Macro.assertTrue(true, "card max num > 4 !")
	-- end
	return max
end

--[[	@param isSameJudge 当前是否是显示同牌
	@param cardValue 当前要处理的牌值
	@return 当前的牌值
]]
function GameService_Mahjong:changeCardColor(isSameJudge, cardValue)
	for i, v in ipairs(self._playerProcessor) do
		-- 如果有玩家
		if v:getRoomSeat() ~= nil then
			v:getSeatUI():changeCardColor(isSameJudge, cardValue)
		end
	end
	
	-- TODO-NOTICE
	-- 这里是一些特殊情况的处理，同上，如果有它从牌堆拿出牌的情况，且知道牌值的情况都要在这里处理
	-- 其它情况，如果有翻鬼，已经翻开的牌也要处理
	return cardValue
end

return GameService_Mahjong;
