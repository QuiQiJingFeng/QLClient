local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local Constants = require("app.gameMode.mahjong.core.Constants")
local RoomSettingInfo = require("app.game.RoomSettingInfo")
local RoomSetting = config.GlobalConfig.getRoomSetting()

local HistoryRecordDatas = class("HistoryRecordDatas")
function HistoryRecordDatas:ctor()
	self._recordDatas = {} -- RecordData list
end

local RecordData = class("RecordData")
function RecordData:ctor()
	self._version = 0
	self.roomRecordDatas = {} -- RoomRecordData list
end

local RoomRecordData = class("RoomRecordData")
function RoomRecordData:ctor()
	self.roomId			= 0; -- 房间号
	self.createTime		= 0; -- 房间创建时间?
	self.playerRecords	= {} -- PlayerTotalData list
	self.roundReportRecords = {} -- RoundReportData list
end

-- 玩家信息和总分用于外部显示
local PlayerTotalData = class("PlayerTotalData")
function PlayerTotalData:ctor()
	self.roleId		= 0;
	self.iconUrl	= "";
	self.roleName = "";
	self.position = 0;
	self.seat	= 0;
	self.totalScore = 0;
	self.sex		= 0;
	self.status	= 0;
end

-- 每局的具体信息
local RoundReportData = class("RoundReportData")
function RoundReportData:ctor()
	self.startTime = 0; -- 开始时间
	self.lastCards = {}; --
	self.playerDetailRecords = {} -- 玩家的具体内容列表
end

-- 玩家的具体内容，用于结算界面和牌型
local PlayerDetailData = class("PlayerDetailData")
function PlayerDetailData:ctor()
	self.roleId	= 0;                           -- 角色ID
	self.totalPoint = 0;                           -- 房间内累计得分
	self.pointInGame = 0;                           -- 当前局得分
	self.events	= {}                           -- 结算事件列表
	self.handCards	= {}                           -- 手里的牌
	self.outCards	= {}                            -- 弃掉的牌
	self.operateCards = {}                           -- 吃碰杠等操作牌
	self.status	= 0
end

local PlayStepData = class("PlayStepData")
function PlayStepData:ctor()
	self.playType = 0;                            -- 操作类型
	self.cards	= {};                           -- 操作的牌
end

-- 玩家结算event用于结算界面的事件
local ResultEventData = class("ResultEventData")
function ResultEventData:ctor()
	self.addOperation = false;                     -- 主动或被动
	self.score		= nil                        -- 分数信息 ResultScore
	self.subScores	= nil                        -- ResultScore 子分数列表
	self.targets	= {};                     -- 目标玩家
	self.combinedTimes = 0;                      -- 合并次数
	self.combinedPoint = 0;                      -- 合并后对每一个人收取的分数
	self.eventPoint	= 0;                      -- 事件总分
	self.sourceCard	= 0;
end

local ResultScore = class("ResultScore")
function ResultScore:ctor()
	self.type	= 0;
	self.calcType = 0;
	self.point	= 0;
end

local OperateCard = class("OperateCard")
function OperateCard:ctor()
	self.playType = 0;
	self.cards	= {}
end

-- 观看类型 和UIHistoryDetail一致
local HISTORY_WATCH_TYPE = {
	SELF = 1,
	MANAGER = 2,
	SHARE = 3
}

local ns = namespace("game.service")

--------------------------------------------
-- 处理登录相关逻辑流程
--------------------------------------------
local HistoryRecordService = class("HistoryRecordService")
ns.HistoryRecordService = HistoryRecordService

-- 单例支持
-- @return HistoryRecordService
function HistoryRecordService:getInstance()
	if game.service.LocalPlayerService.getInstance() == nil then
		return nil;
	end
	return game.service.LocalPlayerService.getInstance():getHistoryRecordService();
end

function HistoryRecordService:ctor()
	self:clear()
end

function HistoryRecordService:clear()
	self.constTimeLimitDays = 3;
	self.constCountLimit	= 100;
	self.datas			= nil    -- HistoryRecordDatas,自己的战绩信息保存在本地
	self.otherDatas		= {}    -- 查询别的战绩信息不存储在本地
	self.showData		= {};
	self._saveKey = "HistoryRecord1"
	self._lastState		= nil    -- 进入回放前的gamestate
	self._oldHistory = false
	-- 是不是极速模式
	self._isFastMode = false
end

function HistoryRecordService:constTimeLimit()
	return kod.util.Time.now() * 1000 - self.constTimeLimitDays * 24 * 3600 * 1000;
end

function HistoryRecordService:initialize()
	-- 监听网络操作
	local requestManager = net.RequestManager:getInstance();
	requestManager:registerResponseHandler(net.protocol.RCGameHistoryRES.OP_CODE, self, self._onHistoryRES);
	requestManager:registerResponseHandler(net.protocol.RCHistoryRoomRES.OP_CODE, self, self._onHistoryRoomRES);
	requestManager:registerResponseHandler(net.protocol.RCHistoryPlaybackRES.OP_CODE, self, self._onHistoryPlaybackRES);
	requestManager:registerResponseHandler(net.protocol.RCShareHistoryRES.OP_CODE, self, self._onShareHistoryRES);
	requestManager:registerResponseHandler(net.protocol.RCShareHistoryRoundForCodeRES.OP_CODE, self, self._onShareBattleCode);
	requestManager:registerResponseHandler(net.protocol.RCHistoryRoomByCodeRES.OP_CODE, self, self._onHistoryRoomByCode);
	-- game.service.MagicWindowService.getInstance():addEventListener("MW_ON_DELWITH_MLINK", handler(self, self._qureyHistory), self);	
end

function HistoryRecordService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	-- if game.service.MagicWindowService.getInstance() ~= nil then
	--     game.service.MagicWindowService.getInstance():removeEventListenersByTag(self)
	-- end
	self.datas = nil;
end

-- 清除数据
function HistoryRecordService:_clearData()
	manager.LocalStorage.setUserData(game.service.LocalPlayerService.getInstance().getRoleId(), self._saveKey, {})
	self.loadLocalStorage()
end

function HistoryRecordService:getDatas()
	return self.datas;
end

function HistoryRecordService:getOtherData()
	return self.otherDatas
end

function HistoryRecordService:isFastMode()
	return self._isFastMode
end

-- 加载本地存储的数据
function HistoryRecordService:loadLocalStorage()
	self.datas = HistoryRecordDatas.new() -- manager.LocalStorage.getUserData(game.service.LocalPlayerService.getInstance():getRoleId(), self._saveKey, HistoryRecordDatas)
	if(#self.datas._recordDatas > 0) then
		self:normalizeDatas();
	end
end

-- 保存本地缓存数据
function HistoryRecordService:saveLocalStorage()
	-- manager.LocalStorage.setUserData(
	-- game.service.LocalPlayerService.getInstance():getRoleId(), self._saveKey,
	-- self.datas)
end

-- 删除超过最大存储量以及超时的消息
function HistoryRecordService:normalizeDatas()
	-- 删除超过最大存储量的消息以及超时的
	for i = 1, #self.datas._recordDatas do
		local recordData = self.datas._recordDatas[i]
		if #recordData.roomRecordDatas > self.constCountLimit then
			for j = self.constCountLimit + 1, #recordData.roomRecordDatas do
				recordData.roomRecordDatas[j] = nil
			end
		end
		
		for k = #recordData.roomRecordDatas, 1, - 1 do
			if recordData.roomRecordDatas[k].createTime + self:constTimeLimit() < kod.util.Time.now() * 1000 then
				recordData.roomRecordDatas[k] = nil
			end
		end
	end
	
	-- manager.LocalStorage.setUserData(game.service.LocalPlayerService.getInstance():getRoleId(), self._saveKey, self.datas)
end

-- 请求战绩总数据
--@param version:为0时会查询本地的版本号,-1则是全部查询
--@param bySelf: 是否是自己的查询
function HistoryRecordService:queryHistory(version, bySelf)
	self.datas._recordDatas = {}
	local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
	local req = net.NetworkRequest.new(net.protocol.CRGameHistoryREQ, serverId);
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
	req:getProtocol():setData(version, areaId, bySelf)
	game.util.RequestHelper.request(req);
end

-- 收到服务器战绩列表的响应
function HistoryRecordService:_onHistoryRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.RC_GAME_HISTORY_SUCCESS then
		-- 展示战绩列表
		local refresh = false
		local recordData = nil
		-- 是否是本人的查询
		local bySelf = response:getRequest():getProtocol().bySelf
		if bySelf == true then
			-- 本人战绩数据保存到本地
			recordData = RecordData.new()
			recordData.roomRecordDatas = {}
			table.insert(self.datas._recordDatas, recordData)
		else
			-- 非本人不存储, 暂时记着
			self.otherDatas = {};
			recordData = RecordData.new()
			recordData.roomRecordDatas = {}
			table.insert(self.otherDatas, recordData)
		end
		
		if recordData.version == protocol.version then
			refresh = false
		else
			refresh = self:combineHistory(protocol, recordData, bySelf)
		end
		
		-- 查询别人战绩时按时间顺序排序
		if bySelf == false then
			table.sort(recordData, function(l, r) return l.destroyTime < r.destroyTime end)
		end
		
		UIManager:getInstance():show("UIHistoryRecord", refresh)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 向服务器请求战绩房间信息
-- roomRecord: Club请求战绩时，用来显示界面使用，普通的可以不处理此参数
function HistoryRecordService:queryHistoryRoom(createTime, roomId, queryRoleId, bySelf, roomRecord, clubId, isAbnormalRoom)
	-- 断线重连需要再次请求战绩
	if #self.datas._recordDatas == 0 and bySelf then
		self:queryHistory(0, true)
	end
	local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
	local req = net.NetworkRequest.new(net.protocol.CRHistoryRoomREQ, serverId);
	req.roomRecord = roomRecord
	-- 保存一下当前的亲友圈ID，在分享的时候，会用到，不会发送到服务器
	req.clubId = clubId
	req.isAbnormalRoom = isAbnormalRoom
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
	req:getProtocol():setData(createTime, roomId, queryRoleId, areaId, bySelf);
	game.util.RequestHelper.request(req);
end

-- 收到服务器战绩房间信息的响应
function HistoryRecordService:_onHistoryRoomRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.RC_HISTORY_ROOM_SUCCESS then
		-- 展示战绩列表
		local foundData = {}
		local currentData = nil
		local bySelf = response:getRequest():getProtocol().bySelf
		-- 是否是本人的查询
		if bySelf == true then
			for _, recordData in ipairs(self.datas._recordDatas) do
				for i = 1, #recordData.roomRecordDatas do
					if recordData.roomRecordDatas[i].createTime == protocol.createTime and recordData.roomRecordDatas[i].roomId == protocol.roomId then
						foundData[#foundData + 1] = recordData.roomRecordDatas[i]
					end
				end
				
				if #foundData > 0 then
					break
				end
			end
		else
			-- 将club的房间记录转换
			local roomRecord = response:getRequest().roomRecord
			-- TODO : 直接保存protocol
			local roomData = RoomRecordData.new()
			roomData.roomId = roomRecord.roomId
			roomData.createTime = roomRecord.createTime
			roomData.playerRecords = self:_convert2PlayerRecord(roomRecord.playerRecords)
			roomData.roundType = roomRecord.roundType
			roomData.gameplays = clone(roomRecord.gameplays)
			roomData.roundCount = roomRecord.roundCount
			roomData.playerMaxCardCount = roomRecord.playerMaxCardCount
			roomData.enableMutilHu = roomRecord.enableMutilHu
			roomData.destroyTime = roomRecord.destroyTime
			roomData.scoreRatio = roomRecord.scoreRatio
			roomData.gameplayName = roomRecord.gameplayName
			table.insert(foundData, roomData)
		end
		
		if #foundData == 0 or #foundData > 1 then
			game.ui.UIMessageTipsMgr.getInstance():showTips("数据错误,请重试。");
		else
			local currentData = foundData[1]
			currentData.roundReportRecords = self:_detailRoundsProtoToData(protocol.roundReportRecords, currentData.playerRecords)
			-- 将亲友圈ID填充进去，分享的时候使用
			currentData.clubId = response:getRequest().clubId
			-- 保存一下是不是异常战绩
			currentData.isAbnormalRoom = response:getRequest().isAbnormalRoom
			-- 回放是否过期
			currentData.playbackExist = protocol.playbackExist

			if bySelf == true then
				self:saveLocalStorage()
			end
			
			local type = HISTORY_WATCH_TYPE.MANAGER
			for _, palyer in ipairs(currentData.playerRecords) do
				if palyer.roleId == game.service.LocalPlayerService:getInstance():getRoleId() then
					type = HISTORY_WATCH_TYPE.SELF
					break
				end
			end
			
			-- Logger.dump(currentData)
			UIManager:getInstance():show("UIHistoryDetail", currentData, type)
		end
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 向服务器请求回放牌局
function HistoryRecordService:queryHistoryPlayback(serverId, createTime, roomId, recordIndex, roomData, roundReportData)
	local req = net.NetworkRequest.new(net.protocol.CRHistoryPlaybackREQ, serverId);
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
	req:getProtocol():setData(createTime, roomId, recordIndex, areaId);
	req.roomData = roomData; -- 作为回调保存
	req.recordIndex = recordIndex
	req.roundReportData = roundReportData
	game.util.RequestHelper.request(req);
end

-- 收到服务器回放牌局的响应
function HistoryRecordService:_onHistoryPlaybackRES(response)
	local request = response:getRequest();
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.RC_HISTORY_PLAYBACK_SUCCESS then
		-- 回放牌局
		local replayData = net.core.ProtocolManager.getInstance():decodeProtocolStruct(self._oldHistory and "FixedMatchPlaybackProto" or "MatchPlaybackProto", protocol.playbackDatas)
		if replayData == false then
			return;
		end
		
		self._lastState = GameFSM.getInstance():getCurrentState().class.__cname
		-- Logger.dump(replayData)
		-- 如果是分享战绩，要以分享战绩的人为主视角来观看
		local followPlayerId = request.roomData.requestRoleId ~= nil and request.roomData.requestRoleId or game.service.LocalPlayerService.getInstance():getRoleId()
		--FYD 如果是查看他人回放码的话 recordDetail里面只有一个元素,所以这里应该传0
		local index = request.recordIndex
		if request.roomData.lookOther then
            request.roomData.realRecordIndex = index
			index = 0
		end
		self._replayParams = {followPlayerId, request.roomData, replayData, index, request.roundReportData}

		local roomSettingInfo = RoomSettingInfo.new(request.roomData.gameplays, request.roomData.roundType)
		self.gameType = roomSettingInfo:getENArray()[1]
		Constants.SpecialEvents.setGameType(self.gameType)

		-- 判断是否有极速模式玩法
		self._isFastMode = false
		for _, gamePlay in ipairs(roomSettingInfo:getNumberValueArray()) do
			if gamePlay == RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN then
				self._isFastMode =  true
				break
			end
		end
		
		self:restartReplay()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

function HistoryRecordService:restartReplay()
	Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
	local areaId = game.service.LocalPlayerService:getInstance():getArea()
	local state = MultiArea.getGameUI(areaId, self.gameType, Constants.GameUIType['UI_GAME_SCENE'])
	state = state or "GameState_Mahjong"
	state = state .. "Replay"
	GameFSM:getInstance():enterState(state):startReplay(unpack(self._replayParams));
end

function HistoryRecordService:enterNextGameState()
	-- 不判断的话，断线重连会进登陆 
	if self._lastState ~= nil and(self._lastState == "GameState_Lobby" or self._lastState == "GameState_Club" or self._lastState == "GameState_League") then
		GameFSM:getInstance():enterState(self._lastState);
		return
	end
	GameFSM:getInstance():enterState("GameState_Lobby");
end

-- 将新的战绩跟原战绩合并
--@param protocolBuf:
--@param recordData: 需要合并的记录数据
--@param isSave: 是否需要保存到本地
--@return boolean
function HistoryRecordService:combineHistory(protocolBuf, recordData, isSave)
	recordData.version = protocolBuf.version
	local newRoomDatas = {}
	local roomRecordDatas = protocolBuf.roomRecords
	for i = 1, #roomRecordDatas do
		-- TODO : 直接保存protocol
		local roomData = RoomRecordData.new()
		roomData.roomId = roomRecordDatas[i].roomId
		roomData.createTime = roomRecordDatas[i].createTime
		-- 战绩时间为结束时间
		roomData.destroyTime = roomRecordDatas[i].destroyTime
		--roomData.destroyTime = roomRecordDatas[i].createTime
		roomData.playerRecords = self:_convert2PlayerRecord(roomRecordDatas[i].playerRecords)
		roomData.roundType = roomRecordDatas[i].roundType
		roomData.gameplays = clone(roomRecordDatas[i].gameplays)
		roomData.roundCount = roomRecordDatas[i].roundCount
		roomData.playerMaxCardCount = roomRecordDatas[i].playerMaxCardCount
		roomData.enableMutilHu = roomRecordDatas[i].enableMutilHu
		newRoomDatas[#newRoomDatas + 1] = roomData
	end
	
	-- 按时间倒序排序
	table.sort(newRoomDatas, function(l, r) return l.destroyTime < r.destroyTime end)
	-- 合并到原数据
	for i = 1, #newRoomDatas do
		table.insert(recordData.roomRecordDatas, 1, newRoomDatas[i])
	end
	
	local count = #recordData.roomRecordDatas
	if count > self.constCountLimit then
		for i = self.constCountLimit + 1, count do
			recordData.roomRecordDatas[i] = nil
		end
	end
	
	for i = self.constCountLimit, #recordData do
		recordData[i] = nil
	end
	
	-- 新的数据存储到本地
	if #newRoomDatas > 0 and isSave then
		self:saveLocalStorage()
	end
	
	return #newRoomDatas > 0
end

-- 获得每一个玩家的在一个房间中的所有数据
function HistoryRecordService:_convert2PlayerRecord(playerRecords)
	local playerTotalDatas = {}
	for i = 1, #playerRecords do
		-- TODO :直接保存protocol
		local onePlayerData = PlayerTotalData.new()
		onePlayerData.roleId = playerRecords[i].roleId
		onePlayerData.roleName = playerRecords[i].nickname
		onePlayerData.position = playerRecords[i].position
		onePlayerData.seat = playerRecords[i].position
		onePlayerData.totalScore = playerRecords[i].totalPoint
		onePlayerData.sex = playerRecords[i].sex
		onePlayerData.iconUrl = playerRecords[i].headImgUrl
        onePlayerData.clubId = playerRecords[i].clubId or 0
        onePlayerData.clubName = playerRecords[i].clubName or ""
		
		playerTotalDatas[#playerTotalDatas + 1] = onePlayerData
	end
	
	table.sort(playerTotalDatas, function(l, r) return l.seat < r.seat end)
	
	return playerTotalDatas
end

function HistoryRecordService:_detailRoundsProtoToData(protoRoundRecords, playerInfos)
	local roundReportDatas = {}
	local playerMap = {}
	for i = 1, #playerInfos do
		playerMap[playerInfos[i].roleId] = playerInfos[i].seat
	end
	
	for i = 1, #protoRoundRecords do
		local roundReport = RoundReportData.new()
		roundReport.startTime = protoRoundRecords[i].startTime
		-- 战绩时间为结束时间
		roundReport.endTime = protoRoundRecords[i].endTime
		--roundReport.endTime = protoRoundRecords[i].startTime
		roundReport.lastCards = {}
		roundReport.spceialsCards = {}

		roundReport.isHuang = protoRoundRecords[i].isHuang
		
		roundReport.destroyerId = protoRoundRecords[i].destroyerId
		
		for j = 1, #protoRoundRecords[i].lastCards do
			local lastCards = string.byte(protoRoundRecords[i].lastCards, j)
			table.insert(roundReport.lastCards, lastCards)
		end
		
		for j = 1, #protoRoundRecords[i].spceialsCards do
			local spceialsCards = string.byte(protoRoundRecords[i].spceialsCards, j)
			table.insert(roundReport.spceialsCards, spceialsCards)
		end
		
		roundReport.playerDetailRecords = {}
		roundReport.isHuang = protoRoundRecords[i].isHuang
		-- TODO : 使用ProtocolManager解析
		local ProtobufLib = require("protobuf")
		for j = 1, #protoRoundRecords[i].playerRecords do
			if ProtobufLib.decode_all("com.kodgames.message.proto.battle.PlayerMatchResultPROTO", protoRoundRecords[i].playerRecords[j]) then
				protoRoundRecords[i].playerRecords[j] = ProtobufLib.decode_all("com.kodgames.message.proto.battle.PlayerMatchResultPROTO", protoRoundRecords[i].playerRecords[j])
				self._oldHistory = false
			else
				protoRoundRecords[i].playerRecords[j] = ProtobufLib.decode_all("com.kodgames.message.proto.battle.FixedPlayerMatchResultPROTO", protoRoundRecords[i].playerRecords[j])
				self._oldHistory = true
			end
			
			-- dump(protoRoundRecords[i].playerRecords[j])
			table.insert(roundReport.playerDetailRecords, self:_playerMRProtoToData(protoRoundRecords[i].playerRecords[j]))
		end
		
		table.sort(roundReport.playerDetailRecords, function(l, r) return playerMap[l.roleId] < playerMap[r.roleId] end)
		
		table.insert(roundReportDatas, roundReport)
	end
	
	return roundReportDatas
end

-- 将PlayerMatchResultPROTO结构转化为可存储结构
-- (供存储和单局结算用)
function HistoryRecordService:_playerMRProtoToData(playerMatchResultProto)
	local playerDetail = PlayerDetailData.new()
	playerDetail.roleId = playerMatchResultProto.roleId
	playerDetail.totalPoint = playerMatchResultProto.totalPoint
	playerDetail.pointInGame = playerMatchResultProto.pointInGame
	playerDetail.events = self:_playerEventProtoToData(playerMatchResultProto.events)
	playerDetail.handCards = {}
	playerDetail.outCards = {}
	playerDetail.status = playerMatchResultProto.status
	--- todo
	for i = 1, #playerMatchResultProto.handCards do
		local handCard = string.byte(playerMatchResultProto.handCards, i)
		table.insert(playerDetail.handCards, handCard)
	end
	
	for i = 1, #playerMatchResultProto.outCards do
		local outCards = string.byte(playerMatchResultProto.outCards, i)
		table.insert(playerDetail.outCards, outCards)
	end
	
	-- playerDetail.handCards = playerMatchResultProto.handCards
	playerDetail.operateCards = self:_operateStepProtosToData(playerMatchResultProto.operateCards)
	
	return playerDetail;
end

-- 将协议中单局的某个玩家数据转换成可存储结构
function HistoryRecordService:_playerEventProtoToData(protoEvent)
	local result = {}
	for i = 1, #protoEvent do
		local eventProto = protoEvent[i]
		local eventData = ResultEventData.new()
		eventData.addOperation = eventProto.addOperation
		eventData.score = self:_resultScoreProtoToData(eventProto.score);
		eventData.subScores = {}
		eventData.sourceCard = eventProto.sourceCard
		for j = 1, #eventProto.subScores do
			local scoreProto = eventProto.subScores[j]
			table.insert(eventData.subScores, self:_resultScoreProtoToData(scoreProto))
		end
		
		eventData.targets = eventProto.targets
		eventData.combinedTimes = eventProto.combinedTimes
		eventData.combinedPoint = eventProto.combinedPoint
		eventData.eventPoint = eventProto.eventPoint
		
		table.insert(result, eventData)
	end
	
	return result;
end

-- 将协议中的event的加分类型变成氪存储的结构 */
function HistoryRecordService:_resultScoreProtoToData(proto)
	local score = ResultScore.new();
	score.type = proto.type
	score.calcType = proto.calcType
	score.point = proto.point
	
	return score
end

--  将协议中玩家操作牌转换成可存储结构
function HistoryRecordService:_operateStepProtosToData(protoSteps)
	local result = {}
	for i = 1, #protoSteps do
		local protoStep = protoSteps[i]
		local stepData = PlayStepData.new()
		stepData.playType = protoStep.playType
		stepData.cards = CardDefines.getCards(protoStep.cards)
		table.insert(result, stepData)
	end
	
	return result;
end

-- 牌型中,各操作牌的权重
function HistoryRecordService:playTypeToSortValue(playType)
	if playType == Constants.PlayType.OPERATE_CHI_A_CARD then
		return 1
	elseif playType == Constants.PlayType.OPERATE_PENG_A_CARD then
		return 2
	elseif playType == Constants.PlayType.OPERATE_GANG_A_CARD then
		return 3
	elseif playType == Constants.PlayType.OPERATE_AN_GANG then
		return 4
	elseif playType == Constants.PlayType.OPERATE_BU_GANG_A_CARD then
		return 5
	elseif playType == Constants.PlayType.OPERATE_HU then
		return 6
	else
		return 0
	end
end

-- 请求战绩共享查看
--@param roleId: 要观看对应战绩的角色ID
--@param roomId: 观看的房间ID
--@param createTime: 房间的创建时间
function HistoryRecordService:queryShareHistory(roleId, roomId, roundNumber, createTime, clubId)
	local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
	local req = net.NetworkRequest.new(net.protocol.CRShareHistoryREQ, serverId);
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
	req:getProtocol():setData(roleId, roomId, roundNumber, createTime, clubId, areaId)
	game.util.RequestHelper.request(req);
	-- 如果当前界面正在显示，那么先关闭
	if UIManager:getInstance():getIsShowing("UIHistoryDetail") then
		-- 延时执行，否则会出现报错，这里是按钮回调执行进来的
		scheduleOnce(function()
			UIManager:getInstance():destroy("UIHistoryDetail")
		end, 0)
	end
end

-- 观看其它玩家战绩返回
function HistoryRecordService:_onShareHistoryRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.RC_SHARE_HISTORY_SUCCESS then
		-- 将club的房间记录转换
		local roomRecord = protocol.roomRecords[1]
		local roomData = RoomRecordData.new()
		roomData.roomId = roomRecord.roomId
		roomData.createTime = roomRecord.createTime
		roomData.playerRecords = self:_convert2PlayerRecord(roomRecord.playerRecords)
		roomData.roundType = roomRecord.roundType
		roomData.gameplays = clone(roomRecord.gameplays)
		roomData.roundCount = roomRecord.roundCount
		roomData.playerMaxCardCount = roomRecord.playerMaxCardCount
		roomData.enableMutilHu = roomRecord.enableMutilHu
		roomData.roundReportRecords = self:_detailRoundsProtoToData(protocol.roundReportRecords, roomData.playerRecords)
		-- 记录战绩是否已失效
		roomData.playbackExist = protocol.playbackExist
		
		-- 获取当前请求的是第几局
		local roomId = response:getRequest():getProtocol():getProtocolBuf().roomId
		-- 观看战绩的时候，是指定的观看第几局，需要将当前的局数传进
		roomData.currectRound = response:getRequest():getProtocol():getProtocolBuf().roundNumber
		-- 记录下当前分享战绩的人
		roomData.requestRoleId = response:getRequest():getProtocol():getProtocolBuf().roleId
		-- 整合数据后，送到界面中去显示
		UIManager:getInstance():show("UIHistoryDetail", roomData, HISTORY_WATCH_TYPE.SHARE)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 观看玩家回放
function HistoryRecordService:_qureyHistory(event)
	Logger.debug("HistoryRecordService:_qureyHistory")
	if event.urlType == game.service.MAGIC_WINDOW_URL_TYPE_ENUM.QUREY_RECORD then
		-- TODO : 尝试发送观看玩家回放
		local roleId = tonumber(event.param.roleId)
		local roomId = tostring(event.param.roomId)
		local round = tonumber(event.param.round)
		local createTime = tonumber(event.param.createTime)
		local clubId = tostring(event.param.clubId)
		Logger.debug(string.format("==[roleId:%d, roomId:%s, createTime:%d]==", roleId, roomId, createTime))
		if Macro.assetTrue(roleId == nil or roomId == nil or createTime == nil or clubId == nil or round == nil, "解析战绩分享失败!") then
			return false
		end
		-- local round = string.sub(roomId, 7, string.len(roomId))
		-- local realRoomId = string.byte(roomId, 1, 6)
		-- local stringToShow = string.format("是否查看房间[%s]中，第%s局战绩详情",realRoomId, round)
		-- game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定","取消"},
		-- function()
		-- local service = game.service.LocalPlayerService:getInstance():getHistoryRecordService()
		-- service:queryShareHistory(roleId, roomId, createTime)
		-- end,
		-- function()
		--     -- 取消的时候，现在不处理，先放个空吧
		-- end)
		-- 上面的是MessageBox二次确认的，现在因为断线重连的问题，MessageBox会被杀掉，无法使用，先直接进，后面参考产品意见吧
		Logger.debug("HistoryRecordService:queryShareHistory")
		self:queryShareHistory(roleId, roomId, round, createTime, clubId)
		-- 操作结果保存
		event.result = true
	end
end



-- FYD 向 Replay 请求分享房间战绩信息 参数:房间号、创建时间、局数ID
function HistoryRecordService:queryShareBattleCode(roomId, createTime, roundIndex,name,clubId)
	local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
	--包装协议数据
	local request = net.NetworkRequest.new(net.protocol.CRShareHistoryRoundForCodeREQ, serverId);
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
    request:getProtocol():setData(roomId, createTime, roundIndex, clubId, areaId)
	request.roomId = roomId
	request.roundIndex = roundIndex
	request.name = name
	--发送协议数据
	game.util.RequestHelper.request(request);
end

-- FYD Replay 向 Client 应答分享房间战绩请求（返回回放码）
function HistoryRecordService:_onShareBattleCode(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local request = response:getRequest()
	if protocol.result == net.ProtocolCode.RC_SHARE_HISTORY_FOR_CODE_SUCCESS then
		--回放码
		local playbackCode = protocol.playbackCode
		local roomId = request.roomId
		local roundIndex = request.roundIndex
		local shareType = config.SHARE_TYPE.URL_IS_PIC_PATH
		local localShare = config.LOCALSHARE.SingleRound
		
		local name = request.name
		
		local data =
		{
			enter = share.constants.ENTER.REPLAY,
			info = {
				roomId = roomId,
				playbackCode = playbackCode,
				roundIndex = roundIndex,
				name = name
			}
		}
		share.ShareWTF.getInstance():share(share.constants.ENTER.REPLAY, {data})
		
		
		--单局分享按钮点击次数
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.SingleRoundShare);
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

--FYD Client 向 Replay 请求房间战绩信息(通过回放码)
function HistoryRecordService:queryHistoryRoomByCode(playbackCode)
	local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
	--包装协议数据
	local request = net.NetworkRequest.new(net.protocol.CRHistoryRoomByCodeREQ, serverId);
	local areaId = game.service.LocalPlayerService.getInstance():getArea()
	request:getProtocol():setData(playbackCode, areaId)
	--发送协议数据
	game.util.RequestHelper.request(request);
end

--Replay 向 Client 应答房间战绩请求
function HistoryRecordService:_onHistoryRoomByCode(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local request = response:getRequest()
	if protocol.result == net.ProtocolCode.RC_HISTORY_BY_CODE_SUCCESS then
		--参数1 2确定
		local followPlayerId = protocol.queryRoleId
		
		local roomData = RoomRecordData.new()
		roomData.roomId = protocol.roomId
		roomData.createTime = protocol.createTime
		
		local roomRecord = protocol.roomRecords[1]
		roomData.playerRecords = self:_convert2PlayerRecord(roomRecord.playerRecords)
		roomData.roundType = roomRecord.roundType
		roomData.gameplays = roomRecord.gameplays
		roomData.roundCount = roomRecord.roundCount
		roomData.playerMaxCardCount = roomRecord.playerMaxCardCount
		roomData.enableMutilHu = roomRecord.enableMutilHu
		
		roomData.roundReportRecords = self:_detailRoundsProtoToData(protocol.roundReportRecord, roomData.playerRecords)
		local serverId = game.service.LocalPlayerService.getInstance():getRecordServerId()
		roomData.lookOther = true
		roomData.requestRoleId = followPlayerId
		local index = protocol.roundIndex - 1
		self:queryHistoryPlayback(serverId, protocol.createTime, protocol.roomId, index, roomData)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end
return HistoryRecordService
