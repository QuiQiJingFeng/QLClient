--[[
Event
{ name = EVENT_RT_VOICE_PLAYER_INFO_CHANGED }
{ name = EVENT_RT_VOICE_JOIN_ROOM_SUCCESS }
{ name = EVENT_RT_VOICE_MEMBER_STATUS_CHANGED, roleId = number, speeking = boolean }
]]

local RTVoiceComponent = class("RTVoiceComponent")

function RTVoiceComponent:ctor(roomService)
	self._isEnable = true;
	self._roomService = roomService;
	-- {roleId, memberId, status, speekingStartTime}
	self._playerInfos = {}

	-- 绑定事件系统
	cc.bind(self, "event");

	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.BCRoomPlayerInfoSYN.OP_CODE, self, self._onRoomPlayerInfoSYN);
	requestManager:registerResponseHandler(net.protocol.BCRealTimeVoiceRES.OP_CODE, self, self._onBCRealTimeVoiceRES);
	requestManager:registerResponseHandler(net.protocol.BCRealTimeVoiceSYN.OP_CODE, self, self._onBCRealTimeVoiceSYN);

	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._registerRTVoiceEvent), self)
end

function RTVoiceComponent:dispose()
	game.service.RT_VoiceService:getInstance():quitRoom(self._roomService:getRoomId())

   	cc.unbind(self, "event");
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	game.service.RT_VoiceService.getInstance():removeEventListenersByTag(self)
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
end

function RTVoiceComponent:isEnable()
	return self._isEnable;
end

function RTVoiceComponent:setEnable(tf)
	self._isEnable = tf;
end

-- 当RoomService初始化成功后，再注册相关事件
function RTVoiceComponent:_registerRTVoiceEvent()
    game.service.RT_VoiceService.getInstance():addEventListener("EVENT_JOIN_ROOM_SUCCESS", handler(self, self._onJoinVoiceRoomSuccess), self)
	game.service.RT_VoiceService.getInstance():addEventListener("EVENT_MEMBER_STATUS_CHANGED", handler(self, self._onMemberStatusChanged), self)
end

function RTVoiceComponent:isPlayerInRoom(roleId)
	Logger.dump(self._playerInfos, "self._playerInfos,"..roleId)
	Macro.assetFalse(self._playerInfos[roleId] ~= nil, tostring(roleId));
	return self._playerInfos[roleId].memberId ~= 0;
end

function RTVoiceComponent:isPlayerSpeakerOpen(roleId)
	Logger.dump(self._playerInfos, "self._playerInfos,"..roleId)
	Macro.assetFalse(self._playerInfos[roleId] ~= nil, tostring(roleId));
	return self._playerInfos[roleId].status ~= 0;
end

function RTVoiceComponent:openMic(tf)
	game.service.RT_VoiceService:getInstance():openMic(true, tf);
end

function RTVoiceComponent:openSpeaker(tf)
	game.service.RT_VoiceService:getInstance():openSpeaker(true, tf);

	-- 开启/关闭话筒需要通知其他人显示状态
	local localPlayerService = game.service.LocalPlayerService.getInstance();
	local localPlayer = self._playerInfos[localPlayerService:getRoleId()];
	if Macro.assetFalse(localPlayer ~= nil) then
		localPlayer.status = tf and 1 or 0
		self:_sendCBRealTimeVoiceREQ(localPlayer.memberId, localPlayer.status)
	end
end

-- 本地玩家加入房间
-- 掉这个方法的地方已经能保证是成功的了，所以把检查去掉
function RTVoiceComponent:onEnterRoom()
    -- 加入实时语音房间
    game.service.RT_VoiceService:getInstance():joinTeamRoom(self._roomService:getRoomId())
end

function RTVoiceComponent:_onRoomPlayerInfoSYN(response)
    local protocol = response:getProtocol():getProtocolBuf()
	local playerInfos = protocol.playerInfo

	-- 保存新的信息
	self._playerInfos = {}
	for i = 1, #playerInfos do
		local playerInfo = playerInfos[i]
		self._playerInfos[playerInfo.roleId] = {
			roleId = playerInfo.roleId,
            memberId = playerInfo.realTimeVoice.memberId,
			status = playerInfo.realTimeVoice.status,
			speekingStartTime = 0,
		}
	end

	-- 检测自己是否在房间中
	local localPlayer = self._playerInfos[game.service.LocalPlayerService.getInstance():getRoleId()];	
	local localMemberId = game.service.RT_VoiceService:getInstance():getMemberId();
	if localPlayer.memberId ~= localMemberId then
		-- 当前的memberId与实际不符, 重置
		localPlayer.memberId = localMemberId;
		localPlayer.status = game.service.RT_VoiceService:getInstance():isSpeakerOpen() and 1 or 0;
		self:_sendCBRealTimeVoiceREQ(localPlayer.memberId, localPlayer.status);
	end
	
    -- 初始化界面
    self:dispatchEvent({name = "EVENT_RT_VOICE_PLAYER_INFO_CHANGED"});
end

function RTVoiceComponent:_sendCBRealTimeVoiceREQ(memberId, status)
	local request = net.NetworkRequest.new(net.protocol.CBRealTimeVoiceREQ, self._roomService:getRoomServerId())
	request:getProtocol():setData(memberId, status)
	request:setWaitForResponse(false)
	game.util.RequestHelper.request(request)
end

function RTVoiceComponent:_onBCRealTimeVoiceRES(response)
end

function RTVoiceComponent:_onBCRealTimeVoiceSYN(response)
	Logger.debug("RTVoiceComponent:_onBCRealTimeVoiceSYN")
	local protocol = response:getProtocol():getProtocolBuf()
	
    local localPlayerService = game.service.LocalPlayerService.getInstance();
    if protocol.roleId == localPlayerService:getRoleId() then
        -- 本地玩家已经修改过, 不用更新本地数据
        return
    end

    -- 保存新的信息
    self._playerInfos[protocol.roleId] = {
        roleId = protocol.roleId,
        memberId = protocol.rtvInfo.memberId,
		status = protocol.rtvInfo.status,
		speekingStartTime = 0,
    }

	-- 通知玩家说话状态变更
	self:dispatchEvent({name = "EVENT_RT_VOICE_PLAYER_INFO_CHANGED"});
end

function RTVoiceComponent:_onJoinVoiceRoomSuccess(event)
    Logger.debug("RTVoiceComponent _onJoinVoiceRoomSuccess,%s,%s", tostring(event.roomName), tostring(event.memberId))
    if tonumber(event.roomName) ~= self._roomService:getRoomId() then
        -- 判断退出的是同一个房间
        return;
    end

    local localPlayerService = game.service.LocalPlayerService.getInstance();

    -- 保存新的信息
    self._playerInfos[localPlayerService:getRoleId()] = {
        roleId = localPlayerService:getRoleId(),
        memberId = event.memberId,
		status = game.service.RT_VoiceService:getInstance():isSpeakerOpen() and 1 or 0,
		speekingStartTime = 0,
    }

    -- 通知服务器状态改变
    self:_sendCBRealTimeVoiceREQ(event.memberId, self._playerInfos[localPlayerService:getRoleId()].status)

	-- 通知界面
	self:dispatchEvent({name = "EVENT_RT_VOICE_JOIN_ROOM_SUCCESS"});
end

function RTVoiceComponent:_onMemberStatusChanged(event)
    Logger.debug("RTVoiceComponent _onMemberStatusChanged,%s,%s", tostring(event.memberId), tostring(event.status))
    -- 通知界面

	-- 获取开启喇叭玩家的数量, 用于统计
	local listeningPlayerCount = 0;
	if game.service.LocalPlayerService.getInstance() ~= nil then
		for _,info in pairs(self._playerInfos) do
			if info.roleId ~= game.service.LocalPlayerService.getInstance():getRoleId() and info.status == 1 then
				listeningPlayerCount = listeningPlayerCount + 1
			end
		end
	end

	for _,info in pairs(self._playerInfos) do
		if info.memberId == event.memberId then
			self:dispatchEvent({name = "EVENT_RT_VOICE_MEMBER_STATUS_CHANGED", roleId = info.roleId, speeking = event.status ~= 0});

			-- 统计说话时长
			if event.status ~= 0 then
				info.speekingStartTime = info.speekingStartTime ~= 0 and info.speekingStartTime or kod.util.Time.now();
			elseif info.speekingStartTime ~= 0 then
				-- 获取有效玩家数量
				local roomPlayerCount = 0;
				if game.service.LocalPlayerService.getInstance() ~= nil then
					local roomService = game.service.RoomService.getInstance()
					for roleId,player in pairs(roomService:getPlayerMap()) do
						if roleId ~= game.service.LocalPlayerService.getInstance():getRoleId() and player:isOnline() then
							roomPlayerCount = roomPlayerCount + 1;
						end
					end
				end

				local playerCount = math.min(roomPlayerCount, listeningPlayerCount);
				Logger.debug("GVoice_Talking,%d,%d", roomPlayerCount, listeningPlayerCount);
				if playerCount ~= 0 then
					game.service.DataEyeService.getInstance():onEvent("GVoice_Talking", (kod.util.Time.now() - info.speekingStartTime) / playerCount)
				end

				info.speekingStartTime = 0;
			end		
			
			return;
		end		
	end
end

return RTVoiceComponent