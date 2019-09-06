-- Event
-- { name = EVENT_JOIN_ROOM_SUCCESS, roomName = string, memberId = number}
-- { name = EVENT_MEMBER_STATUS_CHANGED, memberId = number, status = number}

local ns = namespace("game.service")

local VoiceSettingKey = "lastVoiceSetting";
local Version = require "app.kod.util.Version"

local GCloudVoiceErrno_SUCCESS = 0;
local GV_ON_JOINROOM_SUCC = 1;
local GV_ON_QUITROOM_SUCC = 6;
local GV_ON_MESSAGE_KEY_APPLIED_SUCC = 7;
local GV_ON_UPLOAD_RECORD_DONE = 11;
local GV_ON_DOWNLOAD_RECORD_DONE = 13;
local GV_ON_PLAYFILE_DONE = 21;
local JOIN_TIME_OUT_TIME_MS = 10000;
local QUIT_DELAY_TIME = 3;
local JOIN_DELAY_TIME = 0.7;

-- 用于本地存储的登录数据
local VoiceSetting = class("VoiceSetting")
function VoiceSetting:ctor()
	self.openMic = true;
	self.openSpeaker = true;
end

-- 实施语音
local RT_VoiceService = class("RT_VoiceService")
ns.RT_VoiceService = RT_VoiceService

local GCloudVoiceMode = 
{
	RealTime = 0, 		-- realtime mode for TeamRoom or NationalRoom
	Messages = 1,     	-- voice message mode
	Translation = 2,  	-- speach to text mode
	HighQuality = 4,	-- high quality realtime voice, will cost more network traffic
};

local RoomStatus = 
{
	NoRoom = 0,
	Joining = 1,
	InRoom = 2,
	WaitingQuit = 3,
	Quiting = 4,
}
ns.RT_VoiceService.RoomStatus = RoomStatus;

-------------------------
-- 单例支持
function RT_VoiceService.getInstance()
	if game.service.LocalPlayerService.getInstance() == nil then
		return nil
	end
	return manager.ServiceManager.getInstance():getRTVoiceService();
end

-------------------------
function RT_VoiceService:ctor()
	cc.bind(self, "event");
	self._initialized = false
	self._listenerEnterBackground = nil
	self._listenerEnterForeground = nil
	self._voiceSetting = VoiceSetting.new()
	self._isMicOpen = true
	self._isSpeakerOpen = true
	self._roleId = 0;

	-- {roomName, joining, waitingQuit, quiting, memberId, joiningStartTime}
	self._currentRoom = nil
	self._pendingRoomName = nil

	self._lastQuitRoomTime = 0		-- 延迟加入房间
	self._lastQuitRoomName = nil	-- 上次退出的房间名, 用于统计重新相同房间的次数

	self._delayJoinRoomTask = nil
	self._delayJoinRoomId = 0;
	
--	self._retryQuitRoomTask = nil
	self._delayQuitRoomTask = nil
	self._pollEventTask = nil

	self._recordPath = cc.FileUtils:getInstance():getWritablePath().."recording.dat"
	self._isUpload = false
	self._curVoiceId = 1
	self._hasMessageKey = false
	self._arrVoices = {}
end

function RT_VoiceService:initialize()
end

function RT_VoiceService:dispose()
	if self._delayJoinRoomTask == nil then
		self:_endDelayJoinTask()
	end

	cc.unbind(self, "event");
	
	-- 注册前后台切换事件监听
	if self._listenerEnterBackground ~= nil then
		unlistenGlobalEvent(self._listenerEnterBackground)
		self._listenerEnterBackground = nil;
	end

	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)	
		self._listenerEnterForeground = nil;
	end
end

-- 判断当前版本是否支持实时语音
function RT_VoiceService:isEnabled()
	return game.plugin.Runtime.isEnabled();
end

-- 判断当前版本是否支持实时语音
function RT_VoiceService:isSupported()
	if self:isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end

	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.0.0")
	return currentVersion:compare(supportVersion) >= 0;
end

function RT_VoiceService:getSetting()
	return self._voiceSetting;
end

function RT_VoiceService:isMicOpen()
	return self._isMicOpen;
end

function RT_VoiceService:isSpeakerOpen()
	return self._isSpeakerOpen;
end

function RT_VoiceService:getRoomStatus()
	if self._currentRoom == nil then
		return RoomStatus.NoRoom
	elseif self._currentRoom.joining == true then
		return RoomStatus.Joining
	elseif self._currentRoom.waitingQuit == true then
		return RoomStatus.WaitingQuit
	elseif self._currentRoom.quiting == true then
		return RoomStatus.Quiting
	else
		return RoomStatus.InRoom
	end
end

function RT_VoiceService:getMemberId()
	if self:getRoomStatus() ~= RoomStatus.InRoom then
		return 0;
	end

	return self._currentRoom.memberId;
end

-- 加载保存设置
function RT_VoiceService:_loadSetting()
	self._voiceSetting = manager.LocalStorage.getUserData(self._roleId, VoiceSettingKey, VoiceSetting);
end

-- 保存设置
function RT_VoiceService:_saveSetting()
	manager.LocalStorage.setUserData(self._roleId, VoiceSettingKey, self._voiceSetting);
end

-- 设置业务信息
function RT_VoiceService:setAppInfo(appId, appKey, roleId)
	Logger.debug("[Gvoice] setAppInfo,%s,%s,%s", appId, appKey, tostring(roleId))
	if not self:isEnabled() then return end

	local ret = Gvoice.setAppInfo(appId, appKey, tostring(roleId))
	Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] setAppInfo failed:"..ret)

	if self._initialized == false then
		-- 第一次设置, 初始化sdk
		local ret = Gvoice.initGvoice();
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] initGvoice failed:"..ret)

		-- 设置模式
		if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.0.6.0")) >= 0 then
			-- 4.0.6版本开始支持1.1.8sdk, 支持高品质音质
			ret = Gvoice.setMode(GCloudVoiceMode.HighQuality)
		else
			ret = Gvoice.setMode(GCloudVoiceMode.RealTime)
		end
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] setMode failed:"..ret)

		-- 设置回调
		Gvoice.setCallbackOnJoinRoom(handler(self,self._joinCallback))
		Gvoice.setCallbackOnQuitRoom(handler(self,self._quitCallback))
		Gvoice.setCallbackOnMemberVoice(handler(self,self._memberVoiceCallback))
		Gvoice.setCallbackOnUploadFile(handler(self, self._onUploadFile))
		Gvoice.setCallbackOnDownloadFile(handler(self, self._onDownloadFile))
		Gvoice.setCallbackOnPlayRecordedFile(handler(self, self._onPlayRecordedFile))
		Gvoice.setCallbackOnApplyMessageKey(handler(self,self._onApplyMessageKey))

		-- 注册前后台切换事件监听
		self._listenerEnterBackground = listenGlobalEvent("EVENT_APP_DID_ENTER_BACKGROUND", handler(self, self._onEnterBackground))	
		self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))	

		self._initialized = true;
		Logger.debug("[Gvoice] initialized")
	end

	self._roleId = roleId;

	-- 加载本地数据
	self:_loadSetting(roleId)
end

function RT_VoiceService:_onEnterBackground()
	Logger.debug("[Gvoice] _onEnterBackground")
	-- 主动断开链接
	self:pause();
end

function RT_VoiceService:_onEnterForeground()
	Logger.debug("[Gvoice] _onEnterForeground")
	self:resume();
end

-- 系统发生Pause
function RT_VoiceService:pause()
	Logger.debug("[Gvoice] pause")
	if not self:isEnabled() then return end
	
	local ret = Gvoice.pause()
	Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] pause failed:"..ret)
end

-- 系统发生Resume
function RT_VoiceService:resume()
	Logger.debug("[Gvoice] resume")
	if not self:isEnabled() then return end
	
	local ret = Gvoice.resume()
	Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] resume failed:"..ret)
end

-- 打开/关闭麦克风
function RT_VoiceService:openMic(setSetting, tf)
	Logger.debug("[Gvoice] openMic,%s,%s", tostring(setSetting), tostring(tf))
	if not self:isEnabled() then return end
	
	if self._isSpeakerOpen == false and tf == true then
		-- 不能听的时候, 不能设置可说
		return
	end

	if tf then
		local ret = Gvoice.openMic()
		if tonumber(ret) == 12291 then
			-- 没有权限打开mic
			self._isMicOpen = false
			self:dispatchEvent({name = "EVENT_OPEN_MIC_FAILED_DENIED"})
			return
		end
		-- 设置成功后再保存
		if ret == GCloudVoiceErrno_SUCCESS then
			self._isMicOpen = tf
			if setSetting == true then
				self._voiceSetting.openMic = tf;
				self:_saveSetting();
			end
		end
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] openMic failed:"..ret)
	else
		local ret = Gvoice.closeMic()
		if tonumber(ret) == 12291 then
			-- 没有权限打开mic，理论来说不会进入到这里，没有权限打开，就不存在关闭，如果中间切换过权限开关，游戏会重启
			self._isMicOpen = true
			self:dispatchEvent({name = "EVENT_OPEN_MIC_FAILED_DENIED"})
			return
		end
		-- 设置成功后再保存
		if ret == GCloudVoiceErrno_SUCCESS then
			self._isMicOpen = tf
			if setSetting == true then
				self._voiceSetting.openMic = tf;
				self:_saveSetting();
			end
		end
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] closeMic failed:"..ret)
	end
end

-- 打开/关闭扬声器
function RT_VoiceService:openSpeaker(setSetting, tf)
	Logger.debug("[Gvoice] openSpeaker,%s,%s", tostring(setSetting), tostring(tf))
	if not self:isEnabled() then return end
	
	if setSetting == true then
		self._voiceSetting.openSpeaker = tf;
		self:_saveSetting();
	end

	self._isSpeakerOpen = tf

	if tf then
		local ret = Gvoice.openSpeaker()
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] openSpeaker failed:"..ret)

		-- 能听才有可能说话
		self:openMic(false, self._voiceSetting.openMic)
	else
		local ret = Gvoice.closeSpeaker()
		Macro.assertFalse(ret == GCloudVoiceErrno_SUCCESS, "[Gvoice] closeSpeaker failed:"..ret)

		-- 不能听就不能说话
		self:openMic(false, false)
	end
end

-- 开始事件回调更新
function RT_VoiceService:_startPollEvent()
	Logger.debug("[Gvoice] _startPollEvent")
	if self._pollEventTask == nil then
		self._pollEventTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() Gvoice.poll() end, 1, false)
	end
end

-- 关闭事件回调更新
function RT_VoiceService:_endPollEvent()
	Logger.debug("[Gvoice] _endPollEvent")
	if self._pollEventTask ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pollEventTask)
		self._pollEventTask = nil
	end
end

-- 加入小队语音
function RT_VoiceService:joinTeamRoom(roomId)
	Logger.debug("[Gvoice] joinTeamRoom,%s", tostring(roomId))
	if not self:isEnabled() then return end

	Macro.assertFalse(self._delayJoinRoomTask == nil)
	if kod.util.Time.now() - self._lastQuitRoomTime < JOIN_DELAY_TIME then
		-- 刚退出房间, 需要延迟0.5秒才能重新加入房间, 否则会加入失败
		self:_startDelayJoinTask(roomId, kod.util.Time.now() + JOIN_DELAY_TIME - self._lastQuitRoomTime)
		return;
	end
	
	local roomName = tostring(roomId);
	if self._currentRoom ~= nil then
		-- 当前房间没有准备退出的时候, 不应该加入新的房间
		Macro.assertFalse(self._currentRoom.waitingQuit == true or self._currentRoom.quiting == true)
		-- 不可能同时为True
		Macro.assertTrue(self._currentRoom.waitingQuit == true and self._currentRoom.quiting == true)
		
		if self._currentRoom.roomName == roomName then
			-- 同一个房间尝试不用重新加入		
			if self._currentRoom.waitingQuit == true then
				Logger.debug("[Gvoice] joinTeamRoom, cancel waitingQuit")
				
				-- 正在等待退出, 暂时不用退出了
				self:_cancelDelayQuitTask()
			elseif Macro.assertFalse(self._currentRoom.quiting == true) then
				Logger.debug("[Gvoice] joinTeamRoom, wait quiting")
				-- 当前房间正在退出, 等待退出之后重新加入
				self._pendingRoomName = roomName;
			end
		else
			Logger.debug("[Gvoice] joinTeamRoom, pending")
			-- 其他房间正在等待退出, 设置为Pending
			self._pendingRoomName = roomName;
		end
		
		return
	end

	-- 加入房间
	if self._lastQuitRoomName == roomName then
		game.service.DataEyeService.getInstance():onEvent("Govice_rejoinRoom")
	end

	local ret = Gvoice.joinTeamRoom(roomName, JOIN_TIME_OUT_TIME_MS)
	-- 统计加入房间成功次数
	game.service.DataEyeService.getInstance():onEvent("Gvoice_JoinRoomStart")

	if Macro.assertTrue(ret ~= GCloudVoiceErrno_SUCCESS, "[Gvoice] Gvoice joinRoom failed:"..ret) then
		--统计加入房间错误
		game.service.DataEyeService.getInstance():onEvent("Gvoice_JoinRoomError")
		return;
	end

	-- 加入调用成功, 开启事件监测
	self._currentRoom = {
		roomName = roomName, 
		joining = true, 
		waitingQuit = false, 
		quiting = false,
		joiningStartTime = kod.util.Time.now(),
		quitingStartTime = 0,
	}
	self:_startPollEvent();

	-- 统计加入房间
	game.service.TDGameAnalyticsService.getInstance():onBegin("Gvoice_JoinRoom")
end

-- 加入房间的回调
function RT_VoiceService:_joinCallback(code, roomName, memberId)
	Logger.debug("[Gvoice] _joinCallback,%s,%s,%s", tostring(code), roomName, tostring(memberId))
	
	Macro.assertFalse(self._currentRoom ~= nil)
	Macro.assertFalse(self._currentRoom.joining == true)

	if code ~= GV_ON_JOINROOM_SUCC then
		-- 加入失败检测pending操作
		Logger.error("[Gvoice] _joinCallback failed:"..code)

		-- 统计加入房间失败次数
		game.service.DataEyeService.getInstance():reportError("Gvoice_JoinRoomFailed", code)
		game.service.DataEyeService.getInstance():onEvent("Gvoice_JoinRoomFailed")
		
		Macro.assertFalse(self._currentRoom.quiting == false);
		if self._currentRoom.waitingQuit == false then
			Logger.debug("[Gvoice] _joinCallback, retry")
			-- 没有等待退出, 再尝试加入
			local roomName = self._currentRoom.roomName
			self._currentRoom = nil;
			self:joinTeamRoom(tonumber(roomName))
		else
			-- 没有加入成功还在等待退出, 直接尝试Pending
			self._currentRoom = nil;
			if self._pendingRoomName ~= nil then
				Logger.debug("[Gvoice] _joinCallback, join pending")
				local pendingRoomName = self._pendingRoomName;
				self._pendingRoomName = nil
				self:joinTeamRoom(tonumber(pendingRoomName))
			end
		end
		return
	end

	-- 加入房间成功
	Macro.assertFalse(self._currentRoom.roomName == roomName)
	self._currentRoom.joining = false
	self._currentRoom.memberId = memberId

	-- 统计加入房间成功
	game.service.DataEyeService.getInstance():onEvent("Gvoice_JoinRoomSuccess", kod.util.Time.now() - self._currentRoom.joiningStartTime)
	game.service.TDGameAnalyticsService.getInstance():onCompleted("Gvoice_JoinRoom")

	if self._currentRoom.waitingQuit then
		Logger.debug("[Gvoice] _joinCallback, _startDelayQuitTask")
		-- 等待退出, 发起退出
		self:_startDelayQuitTask();
		return;
	end

	-- 设置话筒和喇叭
	self:openMic(false, self._voiceSetting.openMic)
	self:openSpeaker(false, self._voiceSetting.openSpeaker)
	self:dispatchEvent({name = "EVENT_JOIN_ROOM_SUCCESS", roomName = roomName, memberId = memberId});
end

-- 退出实时语音
function RT_VoiceService:quitRoom(roomId)
	Logger.debug("[Gvoice] quitRoom,%s", tostring(roomId))
	if not self:isEnabled() then return end

	if self._delayJoinRoomTask ~= nil then
		Logger.debug("[Gvoice] quitRoom, clear delay join")
		if Macro.assertFalse(self._delayJoinRoomId == roomId) then
			-- 要退出的房间正在延迟加入, 直接终止延迟加入任务就可以
			self:_endDelayJoinTask();
			return;
		else
			-- 正常逻辑不应该进入这里, 防止出错, 处理下
			self:_endDelayJoinTask();
		end
	end

	local roomName = tostring(roomId);
	if self._pendingRoomName == roomName then
		Logger.debug("[Gvoice] quitRoom, clear pending")
		-- 退出pending房间, 直接清空pending不用加入了
		self._pendingRoomName = nil
		return
	end
	
	-- TODO : 线上有这个assert, 可能是由于前面的处理出错造成的, 先加上判断, 如果没问题再移除
	if Macro.assertTrue(self._currentRoom == nil) then return end
	if Macro.assertTrue(self._currentRoom.roomName ~= roomName) then return end
	
	-- 标记将要退出
	self._currentRoom.waitingQuit = true;
	
	if self._currentRoom.joining == true then
		Logger.debug("[Gvoice] quitRoom, waiting joining")
		-- 正在加入, 等待加入结果之后再操作
		return;
	end
	
	-- 退出房间
	self:_startDelayQuitTask();
end

function RT_VoiceService:_doQuitRoom()
	Logger.debug("[Gvoice] _doQuitRoom")
	
	Macro.assertFalse(self._currentRoom ~= nil)
	Macro.assertFalse(self._currentRoom.waitingQuit == true)
	Macro.assertFalse(self._currentRoom.quiting == false)
	
	-- 退出房间
	local ret = Gvoice.quitRoom(self._currentRoom.roomName, JOIN_TIME_OUT_TIME_MS)
	-- 统计退出房间发起次数
	game.service.DataEyeService.getInstance():onEvent("Gvoice_QuitRoomStart")
	if Macro.assertTrue(ret ~= GCloudVoiceErrno_SUCCESS, "[Gvoice] quitRoom failed:"..ret) then
		-- 统计退出房间出错次数
		game.service.DataEyeService.getInstance():onEvent("Gvoice_QuitRoomError")
		return;
	end
	
	self._currentRoom.waitingQuit = false;
	self._currentRoom.quiting = true;
	self._currentRoom.quitingStartTime = kod.util.Time.now();

	-- 统计退出房间
	game.service.TDGameAnalyticsService.getInstance():onBegin("Gvoice_QuitRoom")
end

function RT_VoiceService:_quitCallback(code, roomName)
	Logger.debug("[Gvoice] _quitCallback,%s,%s",tostring(code),roomName)

	if Macro.assertTrue(code ~= GV_ON_QUITROOM_SUCC, "[Gvoice] _quitCallback failed:"..code) then
		-- 统计退出房间失败次数
		game.service.DataEyeService.getInstance():onEvent("Gvoice_QuitRoomFailed")
		game.service.TDGameAnalyticsService.getInstance():onFailed("Gvoice_QuitRoom", tostring(code))
		return;
	end

	-- 统计加入房间成功
	game.service.DataEyeService.getInstance():onEvent("Gvoice_QuitRoomSuccess", self._currentRoom.quitingStartTime - kod.util.Time.now())
	game.service.TDGameAnalyticsService.getInstance():onCompleted("Gvoice_QuitRoom")

	-- 退出成功, 直接尝试Pending
	self._lastQuitRoomTime = kod.util.Time.now();
	self._lastQuitRoomName = self._currentRoom.roomName
	self._currentRoom = nil;
	self:_endPollEvent();

	if self._pendingRoomName ~= nil then
		Logger.debug("[Gvoice] _quitCallback, join pending")
		local pendingRoomName = self._pendingRoomName;
		self._pendingRoomName = nil
		self:joinTeamRoom(tonumber(pendingRoomName))
	end
end

-- 延迟退出房间, 防止频发加入退出
function RT_VoiceService:_startDelayQuitTask()
	Logger.debug("[Gvoice] _startDelayQuitTask")
		
	if Macro.assertTrue(self._delayQuitRoomTask ~= nil) then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._delayQuitRoomTask)
		self._delayQuitRoomTask = nil
	end
	
	-- 延迟退出, 先禁用话筒和喇叭
	self:openMic(false, false)
	self:openSpeaker(false, false)

	-- 发起延迟任务
	self._delayQuitRoomTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
		Logger.debug("[Gvoice] do DelayQuitTask")
		
		-- 终止当前Task
		if Macro.assertFalse(self._delayQuitRoomTask ~= nil) then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._delayQuitRoomTask)
			self._delayQuitRoomTask = nil
		end
		self:_doQuitRoom();
	end, QUIT_DELAY_TIME, false)
end

function RT_VoiceService:_cancelDelayQuitTask()
	Logger.debug("[Gvoice] _cancelDelayQuitTask")
	
	Macro.assertFalse(self._currentRoom ~= nil)
	Macro.assertFalse(self._currentRoom.waitingQuit == true)
	Macro.assertFalse(self._currentRoom.quiting == false)

	self._currentRoom.waitingQuit = false;
	
	if self._delayQuitRoomTask ~= nil then 
		-- 已经开始延迟退出, 恢复话筒和喇叭
		self:openMic(false, self._voiceSetting.openMic)
		self:openSpeaker(false, self._voiceSetting.openSpeaker)

		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._delayQuitRoomTask)
		self._delayQuitRoomTask = nil
	end
end

-- 玩家说话回调
function RT_VoiceService:_memberVoiceCallback(members)
	Logger.debug("[Gvoice] _memberVoiceCallback," .. #members)
	Logger.dump(members, "_memberVoiceCallback", 3)
	for _,data in ipairs(members) do
		self:dispatchEvent({name = "EVENT_MEMBER_STATUS_CHANGED", memberId = data[1], status = data[2]});
	end
end

-- 延迟加入房间
function RT_VoiceService:_startDelayJoinTask(roomId, delayTime)
	Logger.debug("[Gvoice] delay joinRoom,%s,%s", tostring(roomId), tostring(delayTime));
	if Macro.assertFalse(self._delayJoinRoomTask == nil) then
		self._delayJoinRoomId = roomId;
		self._delayJoinRoomTask = scheduleOnce(function() 
			Logger.debug("[Gvoice] do delay joinRoom,%s", tostring(roomId));
			self._delayJoinRoomTask = nil
			self._delayJoinRoomId = 0
			self:joinTeamRoom(roomId);
		end, delayTime)
	end
end

function RT_VoiceService:_endDelayJoinTask()
	if Macro.assertFalse(self._delayJoinRoomTask ~= nil) then 
		unscheduleOnce(self._delayJoinRoomTask)
		self._delayJoinRoomTask = nil
		self._delayJoinRoomId = 0
	end
end

--是否可以录音
function RT_VoiceService:canRecord()
	return not self._isUpload
end
--准备消息通话
function RT_VoiceService:prepareForMessage(bRealTime)
	Logger.debug("prepareForMessage~~~~~~~~~~~")
	if not self:isEnabled() then return end
	if bRealTime then
		local ret = Gvoice.setMode(GCloudVoiceMode.RealTime)
		Logger.debug("setMode RealTime~~~~~~~~~~~~"..ret)
	else
		local ret = Gvoice.setMode(GCloudVoiceMode.Messages)
		Logger.debug("setMode Messages~~~~~~~~~~~~"..ret)
		ret = Gvoice.applyMessageKey(6000)
		Logger.debug("ApplyMessageKey~~~~~~"..ret)
		
	end
	self:_startPollEvent()
end
--
function RT_VoiceService:_onApplyMessageKey(code)	
	if code == GV_ON_MESSAGE_KEY_APPLIED_SUCC then
		Logger.debug("get Apply MessageKey succeed")
		self._hasMessageKey = true
	else
		Logger.error("get Apply MessageKey failed"..code)
		local ret = Gvoice.applyMessageKey(6000)
		Logger.debug("applyMessageKey~~~",ret)
	end		
end
--录音
function RT_VoiceService:startRecording()	
	if not self:isEnabled() then return end
	
	Logger.debug("startRecording~~~~~~~~~~~~~~"..self._recordPath)
	local ret = Gvoice.startRecording(self._recordPath, false)
	Logger.debug("startRecording~~~",ret)	
end

--录音完成
function RT_VoiceService:stopRecording(doUpload)
	if not self:isEnabled() then return end
	local code = Gvoice.stopRecording(false)
	if code == GCloudVoiceErrno_SUCCESS and doUpload then
		Logger.debug("record succeed, start upload")
		local ret = Gvoice.uploadRecordedFile(self._recordPath, 6000)
		Logger.debug("upload recorded file~~".. ret)
	elseif code ~= GCloudVoiceErrno_SUCCESS then
		Logger.error("record failed".. code)
	end
end
--上传录音
function RT_VoiceService:_onUploadFile(code, filePath, fileID)
	if code == GV_ON_UPLOAD_RECORD_DONE then
		Logger.debug("upload voice file succeed".. fileID)
		self:dispatchEvent({name = "EVENT_UPLOAD_FINISNED", url = fileID});
		-- self:downloadRecordFile(fileID)
	else
		Logger.error("uploadfile failed~~~~~~~~~~~~~~~~~~~~~~".. code)
	end
end
--下载录音
function RT_VoiceService:downloadRecordFile(fileID, roleId)
	if not self:isEnabled() then return end
	local downloadFilePath = cc.FileUtils:getInstance():getWritablePath().."voice"..self._curVoiceId..".data"
	self._curVoiceId = self._curVoiceId + 1
	local ret = Gvoice.downloadRecordedFile(fileID, downloadFilePath, 6000);
	self._arrVoices[downloadFilePath] = roleId
	Logger.dump(self._arrVoices)
	Logger.debug("downloadRecordedFile~~~~~~", ret)
end

--下载完成
function RT_VoiceService:_onDownloadFile(code, filePath, fileID)
	if code == GV_ON_DOWNLOAD_RECORD_DONE then
		Logger.debug("download file succeed"..fileID)
		local ret = Gvoice.playRecordedFile(filePath)
		Logger.debug("playRecordedFile~~~~~~", ret)
		self:dispatchEvent({name = "EVENT_PLAY_STARTED", roleId = self._arrVoices[filePath]});
	else
		Logger.error("download file failed"..code)
	end
end
-- 播放完成
function RT_VoiceService:_onPlayRecordedFile(code, filePath)
	if code == GV_ON_PLAYFILE_DONE then
		Logger.debug("play file succeed"..filePath)
		cc.FileUtils:getInstance():removeFile(filePath)
		self:dispatchEvent({name = "EVENT_PLAY_FINISNED", roleId = self._arrVoices[filePath]});
		-- table.remove(self._arrVoices, filePath)
		self._arrVoices[filePath] = nil
	else
		Logger.error("play file failed".. filePath)
	end
end

--[[-- 上一次没有加入函数失败, 延迟重新尝试
function RT_VoiceService:_startRetryQuitTask(roomId)
	if self._retryQuitRoomTask == nil then
		self._retryQuitRoomTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
			Logger.debug("[Gvoice] retry quit");
			self:_doQuitRoom();
		end, RETRY_DELAY_TIME, false)
	end
end

function RT_VoiceService:_endRetryQuitTask()
	if self._retryQuitRoomTask ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._retryQuitRoomTask)
		self._retryQuitRoomTask = nil
	end
end
--]]