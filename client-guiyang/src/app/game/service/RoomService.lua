local ns = namespace("game.service")
local room = require("app.game.ui.RoomSettingHelper")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local Player = require("app.gameMode.base.core.Player")
local Constants = require("app.gameMode.mahjong.core.Constants")
local SecurityChecker = require("app.gameMode.mahjong.SecurityChecker")
local RTVoiceComponent = require("app.gameMode.mahjong.RTVoiceComponent")

-- 房间声明周期相关逻辑
local RoomService = class("RoomService")
ns.RoomService = RoomService

-- 房间解散时RoomService已经清空，先把玩家数据保存下来，用来做判断解散房间的房主判断
local OldPlayerMap = {}

-- 单例支持
-- @return RoomService
function RoomService:getInstance()
	local creatorService = game.service.RoomCreatorService.getInstance();
	return creatorService and creatorService:getRoomService() or nil;
end

function RoomService:ctor()
	-- 绑定事件系统
	cc.bind(self, "event");
	self:clear()

	--房间类型
	self._roomType = game.globalConst.roomType.none
	self._lastState = nil

	self._expressioninfo = {}
end

function RoomService:clear()
	if self._securityChecker ~= nil then
		self._securityChecker:dispose();
		self._securityChecker = nil
	end
	if self._rtVocieComponent ~= nil then
		self._rtVocieComponent:dispose()
		self._rtVocieComponent = nil
	end
	
	self._roomServerId = 0
	self._roomId = 0
	self._gameCountType = 0
	self._gameCount = 0
	self._gameRules = {}
	self._roomSettings = RoomSetting.CreateRoomSettingsClass.new()
	self._maxPlayerCount = nil
	self._roomClubId = 0
	self._createTime = 0
	self._roomLeagueId = 0

	self._oldRuleOfPlayerNumber = 0 -- 对应是玩家创建房间时的初始玩法人数，提前开局之前的
	self._newRuleOfPlayerNumber = 0
	
	if self._playerMap ~= nil then
		OldPlayerMap = clone(self._playerMap)
	end
	
	self._playerMap = {}
	
	-- 是否能提前开局
	self._canEarlyBattle = false
	self._advanceStartSwitch = false
	-- 是不是极速模式
	self._isFastMode = false
	-- 是不是延时托管(模式下的60，,180, 300秒托管)
	self._delayTrustType = nil  
	-- 牌局结束时间戳(毫秒)
	self._battleEndTime = 0
	-- 牌局结束剩余时间(秒)
	self._battleRemainTime = 0
	-- 是否自动开始下一局
	self._isAutoStartNextRound = false 
end

function RoomService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.BCQuitRoomRES.OP_CODE,			self, self._onQuitRoomRes);
	requestManager:registerResponseHandler(net.protocol.BCStartVoteDestroyRES.OP_CODE,	self, self._onStartVoteDestroyRes);
	requestManager:registerResponseHandler(net.protocol.BCVoteDestroyRES.OP_CODE,		self, self._onVoteDestroyRes);
	requestManager:registerResponseHandler(net.protocol.BCVoteDestroyInfoSYN.OP_CODE,	self, self._onVoteDestroyInfoSYN);
	requestManager:registerResponseHandler(net.protocol.BCDestroyRoomSYN.OP_CODE,		self, self._onDestoryRoomSyn);
	requestManager:registerResponseHandler(net.protocol.BCRoomPlayerInfoSYN.OP_CODE,	self, self._onRoomPlayerInfoSYN);
	requestManager:registerResponseHandler(net.protocol.BCSameIpSYN.OP_CODE,			self, self._onSameIpSYN);
	requestManager:registerResponseHandler(net.protocol.BCUpdateStatusRES.OP_CODE,		self, self._onUpdateStatusRes);
	requestManager:registerResponseHandler(net.protocol.BCAdvanceInfoSYN.OP_CODE,		self, self._onBCAdvanceInfoSYN);
	-- 观战
	requestManager:registerResponseHandler(net.protocol.BCQuitWatchBattleRES.OP_CODE,	self, self._onBCQuitWatchBattleRES);
	requestManager:registerResponseHandler(net.protocol.BCIpSameRES.OP_CODE,	self, self._onBCIpSameRES);
	--
	requestManager:registerResponseHandler(net.protocol.BCQueryPlayerOPInfoRES.OP_CODE,	self, self._onBCQueryPlayerOPInfoRES);
	-- 需要保证协议监听的顺序
	self._securityChecker = SecurityChecker.new(self);
	self._securityChecker:setEnable(GameMain.getInstance():isReviewVersion() == false);
	requestManager:registerResponseHandler(net.protocol.BCStartBattleInAdvanceRES.OP_CODE, self, self._onBCStartBattleInAdvanceRES)
	requestManager:registerResponseHandler(net.protocol.BCVoteStartBattleRES.OP_CODE, self, self._onBCVoteStartBattleRES)
	requestManager:registerResponseHandler(net.protocol.BCVoteStartBattleInfoSYN.OP_CODE, self, self._onBCVoteStartBattleInfoSYN)
end

function RoomService:dispose()
	net.RequestManager.getInstance():unregisterResponseHandler(self)
end

function RoomService:loadLocalStorage()
	if self._securityChecker ~= nil then
		self._securityChecker:loadLastSecurityInfo();
	end
end

function RoomService:getRoomServerId()
	return self._roomServerId;
end

function RoomService:getRoomId()
	return self._roomId;
end

function RoomService:getRoomClubId()
	return self._roomClubId
end

function RoomService:getRoomLeagueId()
	return self._roomLeagueId
end

function RoomService:getCreateTime()
	return self._createTime
end

function RoomService:getMaxPlayerCount()
	return self._maxPlayerCount
end

function RoomService:getRoomSettings()
	return self._roomSettings;
end

-- 获取创建房间玩家id
function RoomService:getCreatorId()
	return self._creatorInfo.id
end

-- 俱乐部经理Id
function RoomService:getClubManagerId()
	return self._clubManagerId
end

function RoomService:getRoomRules()
	if self._roomSettings == nil then
		return {}
	end
	
	return self._roomSettings._ruleMap[self._roomSettings._gameType] or {}
end

function RoomService:getCanEarlyBattle()
	return self._canEarlyBattle
end

function RoomService:getAdvanceStartSwitch()
	return self._advanceStartSwitch
end

function RoomService:getOriginPlayerNumText()
	return self._oldRuleOfPlayerNumber
end

function RoomService:getRuleTextIfAdvance()
	local text = ""
	if self._newRuleOfPlayerNumber ~= "" then
		text = room.RoomSettingHelper.getChineseString(self._newRuleOfPlayerNumber)
	end
	return text
end

function RoomService:getNewRuleOfPlayerNumber()
	return self._newRuleOfPlayerNumber
end

function RoomService:isRTVoiceRoom()
	-- 如果是观战模式，那么语音模块不需要开启
	if game.service.LocalPlayerService:getInstance():isWatcher() then
		return false
	end

	-- 如果是大联盟房间，语音模块不需要开启
	if self:getRoomLeagueId() ~= 0 then
		return false
	end
	
	-- 如果是回放，那么语音模块不需要开启
	local state = GameFSM.getInstance():getCurrentState().class.__cname
	if state == "GameState_MahjongReplay" then
		return false
	end
	
	for _, v in ipairs(self:getRoomRules()) do
		if v == "GAME_PLAY_COMMON_VOICE_OPEN" then
			return true
		end
	end
	return false
end

-- 返回是否已经开始第一局
function RoomService:isHaveBeginFirstGame()
	return self._isHaveBeginFirstGame
end

function RoomService:setHaveBeginFirstGame(tf)
	self._isHaveBeginFirstGame = tf;
end

function RoomService:isFastMode()
	return self._isFastMode
end

function RoomService:getTrustType()
	return self._delayTrustType 
end 

function RoomService:getIsTrustDismiss()
	return self._isTrustDismiss
end 

function RoomService:setIsTrustDismiss(tb)
	self._isTrustDismiss = tb or false 
end 

function RoomService:getScoreRatio()
	return self._scoreRatio
end

function RoomService:getHostPlayer()
	for _, player in pairs(self._playerMap) do
		if player:isHost() then
			return player
		end
	end

	-- 如果是代开房是有可能没有房主的情况,返回创建者信息
	return self._creatorInfo
end

function RoomService:getPlayerMap()
	return self._playerMap;
end

function RoomService:getPlayerNum()
	local count = 0
	for i,v in pairs(self._playerMap) do
		count = count + 1
	end
	return count
end

function RoomService:getPlayerById(playerId)
	return self._playerMap[playerId]
end

function RoomService:getSecurityChecker()
	return self._securityChecker;
end

function RoomService:getRTVocieComponent()
	return self._rtVocieComponent;
end

function RoomService:getGamePlays()
	return self._gamePlays
end

-- @param pb: protobuf instance
function RoomService:onEnterRoomRes(response)
	Logger.debug("RoomService:onEnterRoomRes")
	local request = response:getRequest():getProtocol():getProtocolBuf();
	local protocol = response:getProtocol():getProtocolBuf();
	local creator = response:getRequest().creator
	
	Macro.assertFalse(protocol.result == net.ProtocolCode.BC_ENTER_ROOM_SUCCESS)
	
	-- 创建房间成功
	self._roomServerId = response:getRequest():getProtocol():getServerId();
	self._roomId = request.roomId;	
	self._roomClubId = protocol.roomClubId;
	self._roomLeagueId = protocol.leagueId
	self._roomType = protocol.roomType;
	self._roundCount = protocol.roundCount;
	self._gamePlays = protocol.gameplays;
	self._isHaveBeginFirstGame = protocol.isHaveBeginFirstGame;
	self._maxPlayerCount = protocol.maxPlayerCount
	self._canEarlyBattle = protocol.canEarlyBattle
	self._creatorInfo = Player.new(protocol.creatorInfo)
	self._clubManagerId = protocol.clubManagerId
	self._createTime = protocol.createTime
	self._scoreRatio = protocol.scoreRatio
	-- 此变量应该赋值一次之后，不受断线重连的影响
	
	game.service.LocalPlayerService:getInstance():setIsWatcher(protocol.isWatcher)
	-- 构造房间规则
	local localGamePlays = room.RoomSettingHelper.convert2ClientGameOptions(false, self._roundCount, self._gamePlays);
	self._roomSettings._gameType = room.RoomSettingHelper.getGameTypeFromOptions(localGamePlays);
	self._roomSettings._ruleMap[self._roomSettings._gameType] = localGamePlays;
	
	-- 再来一局功能保存一下当前玩法规则(目前只有俱乐部才有此功能)
	if self._roomClubId ~= 0 or self._roomLeagueId ~= 0 then
		game.service.club.ClubService:getInstance():getClubRoomService():setRoomRule(self._roundCount, self._gamePlays)
	end

	-- 判断是否有极速模式玩法
	self._isFastMode = false
	for _, gamePlay in ipairs(self._gamePlays) do
		if gamePlay == RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN then
			self._isFastMode =  true
			break
		end
	end

	-- 判定是否有延时托管
	self._delayTrustType = nil 
	for _, _type in ipairs(self._gamePlays) do
		if _type == RoomSetting.GamePlay.COMMON_TRUSTEESHIP_60 or 
		_type == RoomSetting.GamePlay.COMMON_TRUSTEESHIP_180 or 
		_type == RoomSetting.GamePlay.COMMON_TRUSTEESHIP_300 then 
			self._delayTrustType = _type
			break 
		end 	
	end 

	-- 保存上次房间规则
	if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() ~= true
	and	self._roomType ~= game.globalConst.roomType.gold
	and creator == game.service.LocalPlayerService:getInstance():getRoleId() then
		game.service.RoomCreatorService.getInstance():setLastCreateRoomSettings(self._roomSettings);
	end
	-- TODO : 这是什么了逻辑, 当前房间信息保存到constants，结算的时候，需要对应的gameType
	Constants.SpecialEvents.setGameType(self._roomSettings._gameType)
	
	self:initRoomComp(response)
	
	-- 观战模式禁用聊天功能
	game.service.ChatService.getInstance():setEnabled(not game.service.LocalPlayerService:getInstance():isWatcher())
	if GameFSM.getInstance():getCurrentState().class.__cname ~= "GameState_Mahjong" then
		self._lastState = GameFSM.getInstance():getCurrentState().class.__cname 
	end
	if protocol.isWaiting == false then
		UIManager:getInstance():destroy("UICreateRoom");
		UIManager:getInstance():destroy("UIMain");
		self:enterGameState()
		if self._rtVocieComponent then
			self._rtVocieComponent:onEnterRoom()
		end
	else
		-- 断线重连重新进入以前的状态
		if self._lastState ~= nil and(self._lastState == "GameState_Lobby" or self._lastState == "GameState_Club" or self._lastState == "GameState_Gold" or self._lastState == "GameState_League") then
		else
			if self._roomClubId ~= 0 then
				-- 如果是从亲友圈进入游戏的，那么返回亲友圈
				GameFSM:getInstance():enterState("GameState_Club");
			elseif self._roomLeagueId ~= 0 then
				GameFSM:getInstance():enterState("GameState_League");
			else
				GameFSM:getInstance():enterState("GameState_Lobby");
			end
		end
    end
    
end

function RoomService:initRoomComp(response)
	-- 检测器
	self._securityChecker = SecurityChecker.new(self);
	self._securityChecker:setEnable(GameMain.getInstance():isReviewVersion() == false);
	
	-- 加载本地数据
	self:loadLocalStorage();
	
	-- 初始化安全检测器
	self._securityChecker:onEnterRoomRes(response);
	
	-- 初始化实时语音
	if self:isRTVoiceRoom() then
		-- 开启实时语音
		self._rtVocieComponent = RTVoiceComponent.new(self);
	end
end

function RoomService:enterGameState()
	Macro.assertFalse(MultiArea.checkAreaId(game.service.LocalPlayerService:getInstance():getArea()))
	local areaId = game.service.LocalPlayerService:getInstance():getArea()
	local gamePlay = self:getRoomSettings()._gameType
	local state = MultiArea.getGameUI(areaId, gamePlay, Constants.GameUIType['UI_GAME_SCENE'])
	state = state or "GameState_Mahjong"
	GameFSM:getInstance():enterState(state)
end

-- 牌局开始前, 退出当前房间
function RoomService:quitRoom(isDestroyRoom)
	isDestroyRoom = isDestroyRoom == nil and true or isDestroyRoom
	Macro.assertFalse(self._roomServerId ~= nil and self._roomServerId ~= 0)
	local request = net.NetworkRequest.new(net.protocol.CBQuitRoomREQ, self._roomServerId)
	request:getProtocol():setData(isDestroyRoom)
	game.util.RequestHelper.request(request)
end

-- 战斗开始前退出房间，操作成功，给发起人的回复
-- @param response: protobuf instance
function RoomService:_onQuitRoomRes(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local quit = false
	local result = protocol.result
	if result == net.ProtocolCode.BC_QUIT_ROOM_SUCCESS then
		-- 等待_onDestoryRoomSyn处理
		self:enterNextGameState()
		game.service.RoomCreatorService.getInstance():onDestoryRoom();
	elseif result == net.ProtocolCode.BC_QUIT_WATCH_BATTLE_SUCCESS then
		-- 退出成功, 或者房间已经解散
		self:enterNextGameState()
		
		-- 清空数据, 注意, 放在enterState为了在前面的清理过程中还可以获得当前房间数据
		game.service.RoomCreatorService.getInstance():onDestoryRoom();
	else
		-- 出错提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(result));
	end
end

function RoomService:enterNextGameState()
	-- 不判断的话，断线重连会进登陆 
	if self._lastState ~= nil and(self._lastState == "GameState_Lobby" or self._lastState == "GameState_Club" or self._lastState == "GameState_Gold" or self._lastState == "GameState_League") then
		GameFSM:getInstance():enterState(self._lastState);
		return
	end
	if self._roomClubId ~= 0 then
		-- 如果是从亲友圈进入游戏的，那么返回亲友圈
		GameFSM:getInstance():enterState("GameState_Club");
	elseif self._roomLeagueId ~= 0 then
		GameFSM:getInstance():enterState("GameState_League");
	else
		GameFSM:getInstance():enterState("GameState_Lobby");
	end

end

-- 开始投票解散房间
function RoomService:startVoteDestroy()
	if self._roomClubId ~= 0 or self._roomLeagueId ~= 0 then
		UIManager:getInstance():show("UIClubDissmisRoomReasonForm")
	else
		self:sendCBStartVoteDestroyREQ("", {})
	end
end

function RoomService:sendCBStartVoteDestroyREQ(phoneNumber, reasons)
	local req = net.NetworkRequest.new(net.protocol.CBStartVoteDestroyREQ, self._roomServerId);
	req:getProtocol():setData(phoneNumber, reasons)
	game.util.RequestHelper.request(req);
end

-- 请求解散房间, 收到回复
function RoomService:_onStartVoteDestroyRes(response)
	Logger.dump(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result ~= net.ProtocolCode.BC_START_VOTE_SUCCESS then
		-- 显示错误信息
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 投票解散房间
-- @param agree: boolean
function RoomService:_voteDestory(agree)
	local request = net.NetworkRequest.new(net.protocol.CBVoteDestroyREQ, self._roomServerId)
	request:getProtocol():setData(agree)
	game.util.RequestHelper.request(request)
end

-- @param pb: protobuf instance
function RoomService:_onVoteDestroyRes(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result ~= net.ProtocolCode.BC_VOTE_DESTROY_SUCCESS then
		-- 显示错误提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 投票解散房间状态有变化时, 服务器的推送消息
function RoomService:_onVoteDestroyInfoSYN(response)
	Logger.dump(response)
	local protocolBuf = response:getProtocol():getProtocolBuf()
	-- close setting panel
	if UIManager:getInstance():getIsShowing("UISetting") then
		UIManager:getInstance():destroy("UISetting")
	end
	
	-- collect local players
	local localPlayers = {}
	for _, player in pairs(self._playerMap) do
		localPlayers[#localPlayers + 1] = player
	end
	
	-- 如果没人拒绝则显示所有人状态
	-- TODO:如果两个人同时点击会出现protocolBuf.applicant = 0的情况，如果不处理会出错
	if #protocolBuf.disagreePlayers == 0 and protocolBuf.applicant ~= 0 then
		local applicant = self._playerMap[protocolBuf.applicant]
		local agreePlayers = {}
		local waitPlayers = {}
		local agreePlayersId = protocolBuf.agreePlayers
		for i = 1, #agreePlayersId do
			agreePlayers[#agreePlayers + 1] = self._playerMap[agreePlayersId[i]]
		end
		
		-- 未解散时显示界面
		local tempPlayerIds = {}
		for i = 1, #agreePlayers do
			tempPlayerIds[#tempPlayerIds + 1] = agreePlayers[i].id
		end
		
		tempPlayerIds[#tempPlayerIds + 1] = applicant.id
		
		-- 帮助函数, 判断talbe中是否已经包含一个值
		local function isInTalbe(t, value)
			for i = 1, #t do
				if t[i] == value then return true end
			end
			
			return false
		end
		
		for i = 1, #localPlayers do
			if isInTalbe(tempPlayerIds, localPlayers[i].id) == false then
				waitPlayers[#waitPlayers + 1] = localPlayers[i]
			end
		end
		
		-- 检查是否已经投票
		local playerId = game.service.LocalPlayerService:getInstance():getRoleId()
		local isVoted = false
		for i = 1, #agreePlayers do
			if agreePlayers[i].id == playerId then
				isVoted = true
				break
			end
		end
		
		UIManager:getInstance():hide("UIApplyVote")
		UIManager:getInstance():show("UIApplyVote",
		self:_buildVoteMessage(applicant, agreePlayers, waitPlayers, "解散房间"),
		isVoted,
		protocolBuf.remainTime / 1000,
		game.service.LocalPlayerService:getInstance():isWatcher(),
		"解散房间",
		function()
			self:_voteDestory(true)
		end,
		function()
			self:_voteDestory(false)
		end
		)
	else
		-- 有人拒绝则关闭投票UI
		local disagreePlayers = {}
		local disagreePlayersId = protocolBuf.disagreePlayers
		for i = 1, #disagreePlayersId do
			disagreePlayers[#disagreePlayers + 1] = self._playerMap[disagreePlayersId[i]]
		end
		
		UIManager:getInstance():destroy("UIApplyVote")
		
		-- //显示提示框谁拒绝了解散房间
		local msg = "玩家"
		for i = 1, #disagreePlayers do
			if #disagreePlayers[i].name > 4 then
				msg = msg .. "“" .. kod.util.String.getMaxLenString(disagreePlayers[i].name, 8) .. "”"
			else
				print("msg::::::", msg)
				msg = msg .. "“" .. kod.util.String.getMaxLenString(disagreePlayers[i].name, 8) .. "”"
			end
			
		end
		
		msg = msg .. "拒绝解散房间\n\n解散房间失败"
		
		game.ui.UIMessageBoxMgr.getInstance():show(msg, {"确定"})
	end
end

-- 构建投票信息
--@param applicant: 发起者
--@param agreePlayers: 同意解散房间玩家列表
--@param waitPlayers: 等待回应玩家列表
--@return 玩家投票信息
function RoomService:_buildVoteMessage(applicant, agreePlayers, waitPlayers, title)
	local msg = ""
	local localPlayers = {}
	for _, player in pairs(self._playerMap) do
		localPlayers[#localPlayers + 1] = player
	end
	
	for i = 1, #agreePlayers do
		msg = msg .. "[" .. kod.util.String.getMaxLenString(agreePlayers[i].name, 8) .. "]" .. "选择同意\n"
	end
	
	for i = 1, #waitPlayers do
		msg = msg .. "[" .. kod.util.String.getMaxLenString(waitPlayers[i].name, 8) .. "]" .. "等待选择\n"
	end
	
	return "玩家" .. "[" .. kod.util.String.getMaxLenString(applicant.name, 8) .. "]" .. "申请" .. title .. ", 请等待其他玩家确认, " .. "超过时间未选择, 视为同意。\n\n" .. msg
end

-- 判断玩家是否房主(只在牌局未开始房主解散房间时调用)
function RoomService:_isHost()
	local playerService = game.service.LocalPlayerService.getInstance();
	local roleId = playerService:getRoleId()
	local player = OldPlayerMap[roleId]
	if player ~= nil then
		return player:isHost()
	end
	
	return false
end

function RoomService:_onDestoryRoomSyn(response)
	local protocol = response:getProtocol():getProtocolBuf()
	--	this.roomId = INVALID_BATTLE_ROOM_ID;
	local processors = {}
	local gameService = nil
	if gameMode.mahjong.Context.getInstance() then
		gameService = gameMode.mahjong.Context.getInstance():getGameService()
	end
	if gameService then
		local idx = 1
		for _, player in pairs(self._playerMap) do
			processors[idx] = {}
			processors[idx].player = gameService:getPlayerProcessorByPlayerId(player.id)
			idx = idx + 1
		end
	end
	
	if UIManager:getInstance():getIsShowing("UIApplyVote") then
		UIManager:getInstance():destroy("UIApplyVote")
	end
	if protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.CREATOR then
		-- 显示解散信息
		self:enterNextGameState()
		if self:_isHost() == false then
			game.ui.UIMessageBoxMgr.getInstance():show("房主解散房间", {"确定"}, function()
				self:enterNextGameState() end)
		end
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.GAMEOVER then
		-- 正常结束如果是比赛过程中destory则弹出等待中页面
		game.service.CampaignService.getInstance():dispatchEvent({name = "CAMPAIGN_SHOW_WAIT"})
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.GMT then
		-- 切换状态
		self:enterNextGameState()

		-- 判定是否显示中途解散广告页面
		local _callBack = function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
		end 

		local isShow = self:_IsShowAdvert(gameService)
		if isShow then 
			UIManager:getInstance():show("UIDissmissAdvert", _callBack, "GMT")
		else 
			-- 管理解散房间, 需要根据游戏结果显示相应界面
			game.ui.UIMessageBoxMgr.getInstance():show("您的房间已被管理解散。", {"确定"}, function()
				_callBack()
				return true
			end)
		end 
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.EXCEPTION then
		-- 异常终止
		-- todo 需要根据游戏结果显示相应界面
		self:enterNextGameState()
		local result = {}
		game.ui.UIMessageBoxMgr.getInstance():show("数据异常，房间解散。", {"确定"}, function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
			return true
		end)
		
		-- 埋点
		game.service.DataEyeService.getInstance():reportError("roomExceptionQuit");
		
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.VOTE then
		-- 投票解散
		local msg = "\n"
		for _, player in pairs(self._playerMap) do
			msg = msg .. "[" .. string.sub(player.name, 1, 6) .. "]\n"
		end
		-- 切换状态
		self:enterNextGameState()
		-- 判定是否显示中途解散广告页面
		local _callBack = function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
		end

		local isShow = self:_IsShowAdvert(gameService)
		if isShow then 
			UIManager:getInstance():show("UIDissmissAdvert", _callBack, "VOTE")
		else 
			game.ui.UIMessageBoxMgr.getInstance():show("成功解散房间", {"确定"}, function()
				_callBack()
				return true
			end)
		end 		
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.CLUB_MANAGER_DESTROY then
		-- 现在有很多报房间卡死，群主解散房间，所以在群主解散的时候，打印一下当前玩家的状态
		local status = {}
		local gameService = gameMode.mahjong.Context.getInstance():getGameService()
		for _, player in pairs(self._playerMap) do
			local name = player.name
			status[name] = {}
			-- 当前状态
			status[name].isHost = player:isHost()
			status[name].isBanker = player:isBanker()
			status[name].isOnline = player:isOnline()
			-- 出牌情况
			local processor = gameService:getPlayerProcessorByPlayerId(player.id)
			if processor then
				-- 只有本地玩家才有这个操作
				if processor._discardCardOperation then
					status[name].canDiscard = tostring(processor._discardCardOperation)
				end
				if processor._cardList then
					status[name].cards = processor._cardList:toStrings()
				end
				-- 按钮的显示状态，只有本地玩家都这个状态
				local seat = processor:getSeatUI()
				if seat._operationBtns then
					status[name].opBtn = {}
					for k, v in pairs(seat._operationBtns) do
						status[name].opBtn[tostring(k)] = v:isVisible()
					end
				end
			else
				-- 这里是观战，不知道现在是不是观战引起的？
			end
		end
		local reportDdata = {
			roomid = self._roomId,
			maxplayer = gameService:getMaxPlayerCount(),
			status = status
		}
		
		self:enterNextGameState()
		if game.service.LocalPlayerService:getInstance():isWatcher() then
			return
		end
		game.ui.UIMessageBoxMgr.getInstance():show("您的房间已被群主或管理解散。", {"确定"}, function()
			local state = GameFSM.getInstance():getCurrentState().class.__cname
			if state ~= nil and state == "GameState_Mahjong" then
				if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
					UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
				end
			end
			return true
		end)
	--超级盟主解散房间
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.LEAGUE_LEADER_DESTROY then
		self:enterNextGameState()
		if game.service.LocalPlayerService:getInstance():isWatcher() then
			return
		end
		game.ui.UIMessageBoxMgr.getInstance():show("您的房间已被盟主解散。", {"确定"}, function()
			local state = GameFSM.getInstance():getCurrentState().class.__cname
			if state ~= nil and state == "GameState_Mahjong" then
				if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
					UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
				end
			end
			return true
		end)
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.CAMPAIGN_STOP_DESTORY then
		-- 比赛晋级停赛
		self:enterNextGameState()
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.ACTING_ROOM_TIME_OUT then
		-- 俱乐部代开房间超时自动解散
		game.ui.UIMessageBoxMgr.getInstance():show("代开房房间超时解散", {"确定"})
		self:enterNextGameState()
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.LEAGUE_DESTROY or protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.LEAGUE_LOW_MEN_KAN_DESTROY  then
		self:enterNextGameState()
		local str = "赛事房间因为某个玩家分数不足而解散"
		local isWatcher = game.service.LocalPlayerService:getInstance():isWatcher()

		if protocol.result == net.ProtocolCode.BC_DESTROY_LEAGUE_LOSER and not isWatcher then
			str = "您的赛事分过低，房间已被解散，请联系队长申请赛事分！"
		elseif protocol.result == net.ProtocolCode.BC_DESTROY_LEAGUE_HAVE_LOSER and not isWatcher then
			str = "您的对手赛事分过低，房间已被解散！"
		end
		game.ui.UIMessageBoxMgr.getInstance():show(str, {"确定"}, function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
			return true
		end)
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.LEAGUE_SCORE_LESS_DESTROY then 
		self:enterNextGameState()

		local info  = {}
		if string.len(protocol.description) > 0 then 
			local losers = json.decode(protocol.description).losers
			if losers ~= nil then 
				for nIdx,roleId in ipairs(losers) do 
					local name = self:getPlayerById(roleId).name
					table.insert(info, {ID = roleId,name = name})
				end
			end 
		end 
		
		UIManager.getInstance():show("UIBigLeagueScoreTips", info , function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
		end)	
	elseif protocol.reason == net.protocol.BCDestroyRoomSYN.ReasonForDestoryRoom.TRUSTEESHIP_DESTROY then 
		self:setIsTrustDismiss(true)
	else
		self:enterNextGameState()
		-- 其他情况
		-- todo 需要根据游戏结果显示相应界面
		local result = {}
		game.ui.UIMessageBoxMgr.getInstance():show("不可预料的情况发生了。", {"确定"}, function()
			if gameService ~= nil and gameService:getFinishMachResult() ~= nil then
				UIManager:getInstance():show("UIFinalReport", processors, gameService:getFinishMachResult())
			end
			return true
		end)
	end
	
	-- 解散房间后，需要删除定缺界面
	UIManager:getInstance():destroy("UILack")
	game.service.RoomCreatorService.getInstance():onDestoryRoom();
	
	-- 房间销毁后，将观战状态置为false
	game.service.LocalPlayerService:getInstance():setIsWatcher(false)

	-- 房间销毁后，魔法表情数据清空
	self._expressioninfo = {}
end

-- 检测是否显示中途解散广告图,返回true表示显示
-- UIDissmissWinTip
function RoomService:_IsShowAdvert(gameService)
	-- 屏蔽解散弹窗商务入口
	do return false end 

	if gameService == nil then 
		return false 
	end 
	-- 判定是否不为俱乐部
	if self._clubManagerId == nil or self._clubManagerId == 0 then 
		return false 
	end 

	-- 判定是否胡
	local isHu = gameService:IsOnHuStatus()
	if isHu then 
		return false 
	end 
	
	-- 判定是否不为第一局
	local curCount = gameService:getCurrentRoundCount()
	if curCount ~= 1 then 
		return false 
	end 

	-- 判定当前玩家ID的尾号是否不为0,1
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local str = string.sub(tostring(roleId), -1)
	if str ~= "0" and str ~= "1" then 
		return false 
	end 
	return true 
end 

function RoomService:getExpressioninfo()
	return self._expressioninfo
end

-- 替换规则
function RoomService:replaceRule(old,new)
	for i,v in pairs(self._gamePlays) do
		if v == old then
			self._gamePlays[i] = new
		end
	end
	-- 重新构造房间规则
	local localGamePlays = room.RoomSettingHelper.convert2ClientGameOptions(false, self._roundCount, self._gamePlays);
	self._roomSettings._gameType = room.RoomSettingHelper.getGameTypeFromOptions(localGamePlays);
	self._roomSettings._ruleMap[self._roomSettings._gameType] = localGamePlays;
end

function RoomService:_onBCAdvanceInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	self._oldRuleOfPlayerNumber = protocol.oldRuleOfPlayerNumber
	self._newRuleOfPlayerNumber = protocol.newRuleOfPlayerNumber
	self._advanceStartSwitch = protocol.switch

	if self._oldRuleOfPlayerNumber > 0 and self._newRuleOfPlayerNumber >0 then
		self:replaceRule(self._oldRuleOfPlayerNumber,self._newRuleOfPlayerNumber)
	end
	game.service.RoomCreatorService.getInstance():dispatchEvent({name = "EVENT_REFRESH_ADVANCE_INFO"})
end

-- 服务器推送，同步房间内玩家数据:玩家加入或离开房间
function RoomService:_onRoomPlayerInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
    local playerInfos = protocol.playerInfo
    if gameMode.mahjong.Context.getInstance() == nil then
        return
    end

	local gameService = gameMode.mahjong.Context.getInstance():getGameService();	
	
	-- 判断自己是不是等待中
	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
	local isWaiting = false
	
	-- 构造玩家数据
	self._playerMap = {}
	for i = 1, #playerInfos do
		local playerInfo = playerInfos[i]
		
		local player = Player.new(playerInfo)
		-- GameService_Mahjong里面进行排座
		-- player.seat = CardDefines.CHAIR_MAP[(playerInfo.position - localPlayer.position + 4) % 4];
		self._playerMap[player.id] = player;
		
		if roleId == playerInfo.roleId then
			isWaiting = bit.band(playerInfo.status, Constants.PlayerStatus.WAITING) ~= 0
		end
	end
	
	-- 如果自己是等待状态就不用做牌局界面处理
	if isWaiting == false then
		-- 如果等待的玩家没有进入战斗状态就切换状态
		local state = GameFSM.getInstance():getCurrentState().class.__cname
		if state ~= nil and(state == "GameState_Lobby" or state == "GameState_Club" or state == "GameState_Gold") then
			self:enterGameState()
			if self._rtVocieComponent then
				self._rtVocieComponent:onEnterRoom()
			end
		end
		
		-- 等待的玩家后进入，如果component也是监听方法的话，ui就收不到事件了，等待进入mahjongstate后再响应
		-- if self._securityChecker ~= nil then
		-- 	self._securityChecker:_onRoomPlayerInfoSYN(response)
		-- end
		-- if self._rtVocieComponent ~= nil then
		-- 	self._rtVocieComponent:_onRoomPlayerInfoSYN(response)
		-- end
		-- 设置数据
		gameService:setRoomPlayers(table.values(self._playerMap))
		gameService:setCurrentRoundCount(protocol.nowRoundCount)
		gameService:setMaxRoundCount(protocol.totalRoundCount)
		gameService:setCurrentRoundCount(protocol.nowRoundCount)
		
		-- 设置比赛信息
		local campaignService = game.service.CampaignService.getInstance()
		local me = self:getPlayerById(game.service.LocalPlayerService:getInstance():getRoleId())
		if me ~= nil and campaignService:getCampaignData():getRank() == 0 then
			campaignService:getCampaignData():setRank(me.rank)
		end
		campaignService:getCampaignData():setMultiple(protocol.multiple)		
		campaignService:dispatchEvent({name = "EVENT_CAMPAIGN_RANK_CHANGED"})
	else
		if UIManager:getInstance():getIsShowing("UIWaiting") then
			UIManager:getInstance():hide("UIWaiting")
		end
		UIManager:getInstance():show("UIWaiting", playerInfos)
	end
end

-- 设置牌局结束时间戳，是否自动开始下一局
function RoomService:setBattleEndData(endTime, isAutoStart)
	self._battleEndTime = endTime or 0
	self._isAutoStartNextRound = isAutoStart or false 
end 

-- 获取牌局结束时间
function RoomService:getBattleEndRetainTime()
	if self._battleEndTime <= 0 then 
		return 0
	end 

	-- 获取当前毫秒时间
	local nowtime = math.floor(game.service.TimeService.getInstance():getCurrentTimeInMSeconds()) 
	local _tempTime = (self._battleEndTime - nowtime)/1000 + 20
	self._battleRemainTime = math.max(_tempTime, 0)

	return self._battleRemainTime
end

function RoomService:isAutoStartNextRound()
	return self._isAutoStartNextRound
end 

-- 判断是否有相同IP
function RoomService:_onSameIpSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
end

function RoomService:updatePlayerStatus()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService();
	gameService:setRoomPlayers(table.values(self._playerMap))
end

-- 通知服务器改变本地玩家状态
-- param status: number
function RoomService:updateStatus(status)
	-- 如果此时roomServerId为0则不发送
	if self._roomServerId == 0 then
		return
	end
	local req = net.NetworkRequest.new(net.protocol.CBUpdateStatusREQ, self._roomServerId);
	req:setWaitForResponse(false)
	req:getProtocol():setData(status);
	game.util.RequestHelper.request(req);
end

-- 服务器推送，同步房间内玩家数据:玩家加入或离开房间
function RoomService:_onUpdateStatusRes(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result ~= net.ProtocolCode.BC_UPDATE_PLAYERSTATUS_SUCCESS then
		-- 显示错误提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
	end
end

-- 请求离开观战
function RoomService:quitWatchBattleREQ(roomId)
	local req = net.NetworkRequest.new(net.protocol.CBQuitWatchBattleREQ, self._roomServerId);
	req:getProtocol():setData(roomId);
	game.util.RequestHelper.request(req);
end

-- 请求离开观战回应
function RoomService:_onBCQuitWatchBattleRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local quit = false
	local result = protocol.result
	if result == net.ProtocolCode.BC_QUIT_WATCH_BATTLE_SUCCESS then
		-- 等待_onDestoryRoomSyn处理
		self:enterNextGameState()
		game.service.RoomCreatorService.getInstance():onDestoryRoom();
	elseif result == net.ProtocolCode.BC_QUIT_WATCH_BATTLE_FAILED_NO_ROOM then
		-- 退出成功, 或者房间已经解散
		self:enterNextGameState()
		
		-- 清空数据, 注意, 放在enterState为了在前面的清理过程中还可以获得当前房间数据
		game.service.RoomCreatorService.getInstance():onDestoryRoom();
	else
		-- 出错提示
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(result));
	end
	-- GameFSM:getInstance():enterState("GameState_Club");
end

--同ip免房卡活动消息
function RoomService:CBIpSameREQ(ipSameCount, gpsConflictCount)
	local req = net.NetworkRequest.new(net.protocol.CBIpSameREQ, self._roomServerId);
	req:getProtocol():setData(ipSameCount, gpsConflictCount)
	req:setWaitForResponse(false)
	game.util.RequestHelper.request(req);
end

function RoomService:_onBCIpSameRES()
end

function RoomService:queryPlayerOPInfoREQ()
	local req = net.NetworkRequest.new(net.protocol.CBQueryPlayerOPInfoREQ, self._roomServerId);
	game.util.RequestHelper.request(req);
end

function RoomService:_onBCQueryPlayerOPInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	local quit = false
	local result = protocol.result
	if result == net.ProtocolCode.BC_QUERY_PLAYER_OP_INFO_SUCCESS then
		UIManager:getInstance():show("UITimeDelay", "battle", protocol.playerOPInfos)
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(result));
	end
end

-- 提前开局
function RoomService:sendCBStartBattleInAdvanceREQ(roomId)
	local request = net.NetworkRequest.new(net.protocol.CBStartBattleInAdvanceREQ, self._roomServerId);
	request:getProtocol():setData(roomId)
	game.util.RequestHelper.request(request)
end

function RoomService:_onBCStartBattleInAdvanceRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.BC_START_BATTLE_IN_ADVANCE_SUCCESS then
		
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

-- 请求提前开局投票
function RoomService:_sendCBVoteStartBattleREQ(type)
	local request = net.NetworkRequest.new(net.protocol.CBVoteStartBattleREQ, self._roomServerId);
	request:getProtocol():setData(type)
	game.util.RequestHelper.request(request)
end

function RoomService:_onBCVoteStartBattleRES(response)
	local protocol = response:getProtocol():getProtocolBuf()
	if protocol.result == net.ProtocolCode.BC_VOTE_START_BATTLE_SUCCESS then
		
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
	end
end

function RoomService:_onBCVoteStartBattleInfoSYN(response)
	local protocolBuf = response:getProtocol():getProtocolBuf()
	
	-- 清除投票
	if protocolBuf.isStart then
		if UIManager:getInstance():getIsShowing("UIEarlyStartVote") then
			UIManager:getInstance():destroy("UIEarlyStartVote")
			self._maxPlayerCount = #protocolBuf.agreePlayers
			game.service.LoginService:getInstance():dispatchEvent({name = "BC_VOTE_START_BATTLEINFO_SYN"})
			game.ui.UIMessageTipsMgr.getInstance():showTips("提前开局成功")
		end
		return
	elseif protocolBuf.clearVoteTask then
		if UIManager:getInstance():getIsShowing("UIEarlyStartVote") then
			UIManager:getInstance():destroy("UIEarlyStartVote")
		end
		return		
	end
	
	local localPlayers = {}
	for _, player in pairs(self._playerMap) do
		localPlayers[#localPlayers + 1] = player
	end
	
	-- 如果没人拒绝则显示所有人状态
	-- TODO:如果两个人同时点击会出现protocolBuf.applicant = 0的情况，如果不处理会出错
	if #protocolBuf.disagreePlayers == 0 and protocolBuf.applicant ~= 0 then
		UIManager:getInstance():destroy("UIEarlyStartVote")
		UIManager:getInstance():show("UIEarlyStartVote", localPlayers, protocolBuf,function()
			self:_sendCBVoteStartBattleREQ(true)
		end,
		function()
			self:_sendCBVoteStartBattleREQ(false)
		end)	
	else
		-- 有人拒绝则关闭投票UI
		local disagreePlayers = {}
		local disagreePlayersId = protocolBuf.disagreePlayers
		for i = 1, #disagreePlayersId do
			disagreePlayers[#disagreePlayers + 1] = self._playerMap[disagreePlayersId[i]]
		end
		
		if UIManager:getInstance():getIsShowing("UIEarlyStartVote") then
			UIManager:getInstance():destroy("UIEarlyStartVote")
		end
		
		-- //显示提示框谁拒绝了提前开局
		local msg = "玩家"
		for i = 1, #disagreePlayers do
			if #disagreePlayers[i].name > 4 then
				msg = msg .. "【" .. kod.util.String.getMaxLenString(disagreePlayers[i].name, 8) .. "】"
			else
				print("msg::::::", msg)
				msg = msg .. "【" .. kod.util.String.getMaxLenString(disagreePlayers[i].name, 8) .. "】"
			end
			
		end

		msg = msg .. "建议再等等其他小伙伴再开局"
		game.ui.UIMessageBoxMgr.getInstance():show(msg, {"确定"})
	end
end

-- 这里获取的是上一次的房间类型，可能当前并不在房间内
function RoomService:getRoomType()
    return self:_internal_getRoomType(self._roomType)
end

-- 由于除了金币场其他的场景没有实现 roomType，所以客户端自行抽象一层做一个
function RoomService:_internal_getRoomType(default_value)
    local currentStateName = GameFSM.getInstance():getCurrentState().class.__cname
    local isReplay = string.match(string.lower(currentStateName), "replay") == 'replay'
    if isReplay then
        return game.globalConst.roomType.replay
    end
    if currentStateName ~= "GameState_Mahjong" and currentStateName ~= "GameState_Paodekuai" then
        return default_value
    end

    -- club battle
    local roomClubId = self:getRoomClubId()
    if roomClubId and roomClubId ~= 0 then
        return game.globalConst.roomType.club
    end

	local roomLeagueId = self:getRoomLeagueId()
	if roomLeagueId and roomLeagueId ~= 0 then
		return game.globalConst.roomType.league
	end

    -- gold battle
    if self._roomType and self._roomType ~= 0 then
        return self._roomType
    end

    -- campaign battle
    if campaign.CampaignFSM.getInstance():getCurrentState():getIsInCampaign() then
        return game.globalConst.roomType.campaign
    end

    -- default battle
    return game.globalConst.roomType.normal
end

-- 检测玩家是否在大联盟牌局结算中且不为最后一局
function RoomService:isBigLeagueReport()
	local gameService = gameMode.mahjong.Context.getInstance():getGameService()
	if not gameService then 
		return false 
	end 

    -- 是否为观战者
    local isWatcher = game.service.LocalPlayerService:getInstance():isWatcher()
    if isWatcher then 
        return false 
    end 

    -- 判定是否为大联盟牌局中
    local leagueId = self:getRoomLeagueId()
    if leagueId == 0 then 
        return false 
    end 

    -- 判定是否为最后一局结束
    local finishResult = gameService:getFinishMachResult()
    if finishResult ~= nil then
        return false 
    end 

    -- 是否自动开始下一局
    if not self:isAutoStartNextRound() then
        return false 
	end 

    return true 
end 

return RoomService
