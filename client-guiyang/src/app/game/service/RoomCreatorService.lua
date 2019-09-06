local ns = namespace("game.service")
local RoomSetting = config.GlobalConfig.getRoomSetting()
local room = require("app.game.ui.RoomSettingHelper")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

-- 房间声明周期相关逻辑
local RoomCreatorService = class("RoomCreatorService")
ns.RoomCreatorService = RoomCreatorService

-- 单例支持
-- @return RoomCreatorService
function RoomCreatorService:getInstance()
    return game.service.LocalPlayerService.getInstance():getRoomCreatorService();
end

-- 因为roomService的生存周期问题，现如果需要注册roomService及其子Service事件的，需要关注当前Service的RoomService的Initialize事件
function RoomCreatorService:ctor()
    cc.bind(self, "event");
    self._lastCreateRoomSettings = nil;
    
    self._roomService = game.service.RoomService.new();

    self._createType = 0
    self._isTips = false
end

function RoomCreatorService:initialize()
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.GCCreateRoomRES.OP_CODE, 	  self, self._onCreateRoomRes);
    requestManager:registerResponseHandler(net.protocol.GCQueryBattleIdRES.OP_CODE,   self, self._onQueryBattleIdRes);
    requestManager:registerResponseHandler(net.protocol.BCEnterRoomRES.OP_CODE, 	  self, self._onEnterRoomRes);
    requestManager:registerResponseHandler(net.protocol.GCInviterRoomInfoRES.OP_CODE, self, self._onGCInviterRoomInfoRES);
    requestManager:registerResponseHandler(net.protocol.CLCCreateRoomRES.OP_CODE, 	  self, self._onCreateClubRoomRes)
    
    self._roomService:initialize();

    -- game.service.MagicWindowService.getInstance():addEventListener("MW_ON_DELWITH_MLINK", handler(self, self._joinRoom), self);	
    GameFSM:getInstance():addEventListener("GAME_STATE_CHANGED", handler(self, self._onGameStateChanged), self);
end

function RoomCreatorService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self);
    -- if game.service.MagicWindowService.getInstance() ~= nil then
    --     game.service.MagicWindowService.getInstance():removeEventListenersByTag(self)
    -- end
    self:onDestoryRoom();
    cc.unbind(self, "event");
end

function RoomCreatorService:loadLocalStorage()
    -- 设置本地规则为房间规则
    local roldId = game.service.LocalPlayerService:getInstance():getRoleId();
    self._lastCreateRoomSettings = manager.LocalStorage.getUserData(roldId, "LastRoomSettings", RoomSetting.CreateRoomSettingsClass)

    local gameType = self._lastCreateRoomSettings._gameType
    
    local _, gameTypesConfig = room.RoomSettingHelper.getGameTypes()

    if gameTypesConfig[gameType] == nil then
        self._lastCreateRoomSettings = RoomSetting.CreateRoomSettingsClass.new()
    end
    
    room.RoomSettingHelper.initCreateRoomSettings(self._lastCreateRoomSettings)
end

function RoomCreatorService:saveLocalStorage()
    local roldId = game.service.LocalPlayerService:getInstance():getRoleId();
    manager.LocalStorage.setUserData(roldId, "LastRoomSettings", self._lastCreateRoomSettings)
end

function RoomCreatorService:getLastCreateRoomSettings()
    return self._lastCreateRoomSettings;
end

function RoomCreatorService:setLastCreateRoomSettings(settings)
    self._lastCreateRoomSettings._gameType = settings._gameType
    local rules = clone(settings._ruleMap[settings._gameType])
    -- 由于服务器返回的settings里包含gamePlay，所以要把gamePlay去掉，否则会报错
    for i, v in pairs(rules) do
        if v == settings._gameType then
            table.remove( rules, i )
        end
    end
    self._lastCreateRoomSettings._ruleMap[settings._gameType] = rules;
    self:saveLocalStorage();
end

function RoomCreatorService:getRoomService()
    return self._roomService;
end

function RoomCreatorService:onDestoryRoom()
    if self._roomService ~= nil then
        self._roomService:clear()
    end
end

-- @param gameCountType: number
-- @param gameCount: number
-- @param gameplays: number array
function RoomCreatorService:createRoomReq(gameCountType, gameCount, gameRules, freeActivityId, createType, inviteeIds)
    local request = net.NetworkRequest.new(net.protocol.CGCreateRoomREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(gameCountType, gameCount, gameRules, freeActivityId, createType, inviteeIds)
    self._createType = createType
    game.util.RequestHelper.request(request)
end

-- @param pb: protobuf instance
function RoomCreatorService:_onCreateRoomRes(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- 创建房间成功
    if protocol.result == net.ProtocolCode.GC_CREATE_ROOM_SUCCESS then
        -- 加入房间
        self:enterRoom(protocol.battleId, protocol.roomId, game.globalConst.JOIN_ROOM_STYLE.HallCreateRoom, nil, true);

        -- 如果当前房间是创建的，上传一下，当前房间的语音类型
        local request = response:getRequest()
        local isRTVoiceRoom = false
        local voiceOpenType = RoomSetting.GamePlay.COMMON_VOICE_OPEN
        for _, v in ipairs(request:getProtocol():getProtocolBuf().gameplays) do
            if v == voiceOpenType then
                isRTVoiceRoom = true
                break
            end
        end
        if isRTVoiceRoom then
            game.service.DataEyeService.getInstance():onEvent("GVoice_CreateRTVoiceRoom")
        else
            game.service.DataEyeService.getInstance():onEvent("GVoice_CreateYVVoiceRoom")
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

-- @param gameCountType: number
-- @param gameCount: number
-- @param gameplays: number array
function RoomCreatorService:createClubRoomReq(roomType, gameplays, roundType, clubId, managerId, isPrivate, privateRoleIds, createType, inviteeIds)
    local request = net.NetworkRequest.new(net.protocol.CCLCreateRoomREQ, game.service.club.ClubService.getInstance():getClubServiceId())
    request:getProtocol():setData(roomType, gameplays, roundType, clubId, managerId, isPrivate, privateRoleIds, createType, inviteeIds)
    self._createType = createType
    game.util.RequestHelper.request(request)
end

-- @param pb: protobuf instance
function RoomCreatorService:_onCreateClubRoomRes(response)
    local protocol = response:getProtocol():getProtocolBuf()
    -- 创建房间成功 
    if protocol.result == net.ProtocolCode.CLC_CREATE_ROOM_SUCCESS then
        self:enterRoom(protocol.battleId, protocol.roomId, game.globalConst.JOIN_ROOM_STYLE.ClubCreateRoom, nil, true);

        -- 如果当前房间是创建的，上传一下，当前房间的语音类型
        local request = response:getRequest()
        local isRTVoiceRoom = false
        local voiceOpenType = RoomSetting.GamePlay.COMMON_VOICE_OPEN
        for _, v in ipairs(request:getProtocol():getProtocolBuf().gameplays) do
            if v == voiceOpenType then
                isRTVoiceRoom = true
                break
            end
        end
        if isRTVoiceRoom then
            game.service.DataEyeService.getInstance():onEvent("GVoice_CreateRTVoiceRoom")
        else
            game.service.DataEyeService.getInstance():onEvent("GVoice_CreateYVVoiceRoom")
        end
    elseif protocol.result == net.ProtocolCode.CLC_ERROR_CODE_CLUB_OBSERVER_NO_PERMITED then
        game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.ROOMCREATORSERVICE_STRING_100, {"确认"})
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end


-- 向GameServer请求房间所在的BattleId, 返回成功之后自动加入房间
-- @param roomId: number 房间Id
-- @param JoinRoomStyle: string 统计进入房间的方式
-- @param optIsWatch 是否观战请求
function RoomCreatorService:queryBattleIdReq(roomId, JoinRoomStyle, optIsWatch)
    local request = net.NetworkRequest.new(net.protocol.CGQueryBattleIdREQ, game.service.LocalPlayerService.getInstance():getGameServerId());
    request:getProtocol():setData(roomId);
    request.JoinRoomStyle = JoinRoomStyle
    request.isWatcherReq  = optIsWatch or false;
    game.util.RequestHelper.request(request);
end

-- 请求到BattleId
-- @param pb: protobuf instance
function RoomCreatorService:_onQueryBattleIdRes(response)
    local request = response:getRequest()
    local requestProtocol = request:getProtocol():getProtocolBuf();
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_BATTLEID_SUCCESS then
        local playerService = game.service.LocalPlayerService.getInstance()
        -- 玩家是否已经玩过极速模式了
        if playerService:getHasPlayFastMode() == false and protocol.isInRoom == false then
            for _, gamePlay in ipairs(protocol.gamePlays) do
                -- 判断房间玩法中是否有极速模式
                if gamePlay == RoomSetting.GamePlay.COMMON_FAST_MODE_OPEN then
                    game.ui.UIMessageBoxMgr.getInstance():show(
                        "当前房间为极速模式，倒计时结束后自动出牌，请确保打牌期间不被干扰。是否继续加入房间？",
                        {"确认", "取消"},
                        function ()
                            self:enterRoom(protocol.battleId, requestProtocol.roomId, request.JoinRoomStyle,request.isWatcherReq)
                        end,
                        function ()
                            UIManager:getInstance():destroy("UIJoinRoom")
                        end
                    )
                    return
                end
            end
        end
        self:enterRoom(protocol.battleId, requestProtocol.roomId, request.JoinRoomStyle,request.isWatcherReq)
    else
        -- 统计输入房间号进入房间失败的事件数
        if request.JoinRoomStyle ~= nil and request.JoinRoomStyle == game.globalConst.JOIN_ROOM_STYLE.InputRoomNumber then
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.RoomID_Join_fail);
        end
        -- 统计加入房间失败的事件数
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Join_false);

        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

-- 加入具体的游戏房间
-- @param roomServerId: number, 房间所在服务器ID
-- @param roomId: number, 房间Id
-- @param isWatcherReq 是否观战请求，断线重连传false
function RoomCreatorService:enterRoom(roomServerId, roomId, JoinRoomStyle, isWatcherReq, isCreator)
    -- 用于服务器做BI数据统计
    if JoinRoomStyle ~= nil then
        -- 客户端打点统计进入房间方式（暂时先不删除）
        game.service.DataEyeService.getInstance():onEvent(JoinRoomStyle)
    else
        -- 防止没有传加入房间方式(比如:断线重连加入房间)
        JoinRoomStyle = ""
    end
    local clubId = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo():getClubId()
    local playerService = game.service.LocalPlayerService.getInstance()
    local location = game.service.LocalPlayerService:getInstance():getGpsLocationInfo()
    if location then
        location = clone(location)
        location.expireTime = nil
    end
    Logger.debug("FYD========location===="..json.encode(location))
    local request = net.NetworkRequest.new(net.protocol.CBEnterRoomREQ, roomServerId);
    request:getProtocol():setData(
        playerService._roleId,
        roomId,
        playerService._name,
        playerService._iconUrl,
        playerService._gender,
        isWatcherReq or false,
        game.service.LocalPlayerService.getInstance():getCertificationService():getCertificationStatus(),
        game.service.LocalPlayerService.getInstance():getHeadFrameId(),
        JoinRoomStyle,
        playerService:getSpecialEffectArray(),
        clubId,
        location
    )

    if isCreator then
        request.creator = playerService._roleId
    end
    
    game.util.RequestHelper.request(request)
end

function RoomCreatorService:_onGameStateChanged(event)
    local name = event.current
    if name == "GameState_Mahjong" or 
        name == "GameState_MahjongReplay" or
        name == "GameState_Paodekuai" or
        name == "GameState_PaodekuaiReplay"
     then
        -- 因为现在有可能是排队后进桌，而不是直接进，所以roomservice的初始化事件应该是进入了场景才算
        self:dispatchEvent({name = "EVENT_ROOMSERVICE_INITIALIZED"})
    end
end

-- @param pb: protobuf instance
function RoomCreatorService:_onEnterRoomRes(response)
    local request = response:getRequest():getProtocol():getProtocolBuf();
    local protocol = response:getProtocol():getProtocolBuf();
    
    if protocol.result == net.ProtocolCode.BC_ENTER_ROOM_SUCCESS then
        -- 联盟房间强行删除实时语音
        if protocol.leagueId ~= 0 and protocol.gameplays ~= nil and #protocol.gameplays > 0 then
            local voiceOpenType = RoomSetting.GamePlay.COMMON_VOICE_OPEN
            for i, rule in ipairs(protocol.gameplays) do
                if rule == voiceOpenType then
                    table.remove(protocol.gameplays, i)
                    break
                end
            end
        end


        -- 加入房间成功
        -- TODO:现在roomService不会主动销毁
        -- Macro.assetFalse(self._roomService == nil)
        -- 再来一局房主加入房间给个提示
        if protocol.isHaveBeginFirstGame then self._isTips = false end -- 开局重置提示状态
        if not self._isTips and self._createType == ClubConstant:getCreateRoomType().ANOTHER_ROOM_CREATE and
            protocol.creatorInfo.roleId == game.service.LocalPlayerService.getInstance():getRoleId() and
            not protocol.isHaveBeginFirstGame then
            self._isTips = true
            game.ui.UIMessageTipsMgr.getInstance():showTips("已自动向上局玩家发送邀请")
        end

        if self._roomService ~= nil then
            self._roomService:clear()
        end

        -- 断线重连重新给联盟赋值
        if roomClubId == 0 then
            game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setLeagueId(protocol.leagueId)
            game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():setClubId(protocol.clubId)
        end

        self._roomService:onEnterRoomRes(response)
        self:dispatchEvent({name = "EVENT_ENTER_ROOM"})

    elseif protocol.result == net.ProtocolCode.BC_CLC_ENTER_ROOM_FAILED_IS_WATCHER then -- 是处于观战状态
        
    elseif protocol.result == net.ProtocolCode.BC_ENTER_GPS_ROOM_FAILED_DISTANCE_TOO_LITTLE then
        local result = "对不起，系统检测到您和房间内玩家距离过近\n赶快进入一个新房间玩耍吧！"
        game.ui.UIMessageTipsMgr.getInstance():showTips(result,1.5)
    else -- 服务器处理失败
        -- TODO：如果是断线重连，在加入房间失败后，全部返回到主界面
        -- 如果没有断线重连，在加入房间失败后，返回所在界面
        local state = GameFSM.getInstance():getCurrentState().class.__cname
        if state ~= nil and state ~= "GameState_Mahjong" then
            GameFSM.getInstance():enterState(state);
        else
            GameFSM.getInstance():enterState("GameState_Lobby");
        end

        -- 显示错误信息
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
end

-- 通过RoomId加入房间, 
function RoomCreatorService:queryInviterRoomInfo(roomId)
    Logger.debug("queryInviterRoomInfo," .. roomId);
    local request = net.NetworkRequest.new(
        net.protocol.CGInviterRoomInfoREQ,
        game.service.LocalPlayerService.getInstance():getGameServerId())
    request:getProtocol():setData(roomId)
    game.util.RequestHelper.request(request)
end

function RoomCreatorService:_onGCInviterRoomInfoRES(response)
    local protocolBuf = response:getProtocol():getProtocolBuf()
    if protocolBuf.result == net.ProtocolCode.GC_INVITER_ROOMINFO_SUCCEE then
        local info = protocolBuf.info
        local roomID = info.roomId
        local gamePlays = info.gamePlays
        local creator = info.creatorId
        local nickname = info.nickname
        local headImageUrl = info.headImageUrl
        UIManager:getInstance():show("UIQuickJoin", roomID, gamePlays, creator, nickname, headImageUrl)
    end
end

-- 加入房间
function RoomCreatorService:_joinRoom(event)
    Logger.debug("RoomCreatorService:_joinRoom")
    if event.urlType == game.service.MAGIC_WINDOW_URL_TYPE_ENUM.JOIN_ROOM then
        local roomId = tonumber(event.param.roomId)
        -- TODO : 尝试加入房间
        if Macro.assetTrue(roomId == nil, "解析加入房间失败!") then
            return false
        end
        Logger.debug(string.format("_joinRoom, %d", roomId));
        -- TODO：直接加入房间，不再请求房间信息
        Logger.debug("RoomCreatorService:queryBattleIdReq")
        self:queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.MagicWindow)
        -- 操作结果保存
        event.result = true
    end
end
