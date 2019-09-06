--[[
牌局界面实时语音相关逻辑

1. 没有加入语音房间的时候转圈
2. 关闭听筒就关闭话筒
--]]
local csbPath = "ui/csb/Player_MicphoneSpeaker.csb"
local UIRTVoiceComponent = class("UIRTVoiceComponent", function() return kod.LoadCSBNode(csbPath) end )

function UIRTVoiceComponent:ctor(root)
    root:addChild(self);
	self:setPosition(0,0);

	self._btnMicOn = seekNodeByName(self, "Button_RT_Micphone", "ccui.Button");
	self._btnMicOff = seekNodeByName(self, "Button_RT_Micphone_0", "ccui.Button");
	self._btnSpeakerOn = seekNodeByName(self, "Button_RT_Speaker", "ccui.Button");
	self._btnSpeakerOff = seekNodeByName(self, "Button_RT_Speaker_0", "ccui.Button");
	self._imgLoadingMicphone = seekNodeByName(self, "Image_loading_Micphone", "ccui.ImageView");
	self._imgLoadingSpeaker = seekNodeByName(self, "Image_loading_Speaker", "ccui.ImageView");
	self._animAction = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._animAction)
	
	bindEventCallBack(self._btnMicOn, handler(self, self._onClickRTVoiceMicOpen), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnMicOff, handler(self, self._onClickRTVoiceMicClose), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnSpeakerOn, handler(self, self._onClickRTVoiceSpeakerOpen), ccui.TouchEventType.ended);
	bindEventCallBack(self._btnSpeakerOff, handler(self, self._onClickRTVoiceSpeakerClose), ccui.TouchEventType.ended);

	-- 加载完成之后，此时不应该显示的
	self:setVisible(false)
	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._registerRTVoiceEvent), self)
end

function UIRTVoiceComponent:dispose()
	local roomService = game.service.RoomService.getInstance();
	if roomService ~= nil and roomService:getRTVocieComponent() ~= nil then
		roomService:getRTVocieComponent():removeEventListenersByTag(self);
	end
	game.service.RT_VoiceService.getInstance():removeEventListenersByTag(self)
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
	self:removeFromParent(true)
end

-- 当RoomService初始化成功后，再注册相关事件
function UIRTVoiceComponent:_registerRTVoiceEvent()
	local rtVoiceCmp = game.service.RoomService.getInstance():getRTVocieComponent()
	if rtVoiceCmp == nil then
		-- 如果当前的平台不支持的时候，不再注册
		return
	end
	self:setVisible(true)
	rtVoiceCmp:addEventListener("EVENT_RT_VOICE_JOIN_ROOM_SUCCESS", handler(self, self._onJoinVoiceRoomSuccess), self)
	game.service.RT_VoiceService.getInstance():addEventListener("EVENT_OPEN_MIC_FAILED_DENIED", handler(self, self._onOpenMicFailed), self)
end

-- 开启/关闭, 实时语音系统
function UIRTVoiceComponent:setEnable(tf)
	self:setVisible(tf)

   	self._btnMicOn:setVisible(false)
	self._btnSpeakerOff:setVisible(false)
	self._btnSpeakerOn:setVisible(false)
	self._btnMicOff:setVisible(false)
	
	if tf then
		-- 实时语音开启
		if game.service.RT_VoiceService.getInstance():getRoomStatus() ~= game.service.RT_VoiceService.RoomStatus.InRoom then
			self:_showWaitingUI();
		else
			self:_hideWaitingUI();
		end

		self:_refreshBtnStatus();
	end
end

function UIRTVoiceComponent:_refreshBtnStatus()
	local voiceService = game.service.RT_VoiceService:getInstance();
	self:_setRTVoiceMicOpen(voiceService:isMicOpen());
	self:_setRTVoiceSpeakerOpen(voiceService:isSpeakerOpen());
end

function UIRTVoiceComponent:_setRTVoiceMicOpen(tf)
	self._btnMicOn:setVisible(tf)
	self._btnMicOff:setVisible(not tf)
end

function UIRTVoiceComponent:_setRTVoiceSpeakerOpen(tf)
	self._btnSpeakerOn:setVisible(tf)
	self._btnSpeakerOff:setVisible(not tf)
end

function UIRTVoiceComponent:_onClickRTVoiceMicOpen()
	-- 最后一把胡牌后，房间就已经解散了，这时不应该再处理事件了
	if game.service.RoomService.getInstance() == nil then
		return
	end
	game.service.RoomService.getInstance():getRTVocieComponent():openMic(false);
	self:_refreshBtnStatus();
end

function UIRTVoiceComponent:_onClickRTVoiceMicClose()
	-- 最后一把胡牌后，房间就已经解散了，这时不应该再处理事件了
	if game.service.RoomService.getInstance() == nil then
		return
	end
	game.service.RoomService.getInstance():getRTVocieComponent():openMic(true);
	self:_refreshBtnStatus();
end

function UIRTVoiceComponent:_onClickRTVoiceSpeakerOpen()
	-- 最后一把胡牌后，房间就已经解散了，这时不应该再处理事件了
	if game.service.RoomService.getInstance() == nil then
		return
	end
	game.service.RoomService.getInstance():getRTVocieComponent():openSpeaker(false);
	self:_refreshBtnStatus();
end

function UIRTVoiceComponent:_onClickRTVoiceSpeakerClose()
	-- 最后一把胡牌后，房间就已经解散了，这时不应该再处理事件了
	if game.service.RoomService.getInstance() == nil then
		return
	end
	game.service.RoomService.getInstance():getRTVocieComponent():openSpeaker(true);
	self:_refreshBtnStatus();
end

function UIRTVoiceComponent:_showWaitingUI()
	self._imgLoadingMicphone:setVisible(true)
	self._imgLoadingSpeaker:setVisible(true)

	self._btnMicOn:setEnabled(false)
	self._btnSpeakerOff:setEnabled(false)
	self._btnSpeakerOn:setEnabled(false)
	self._btnMicOff:setEnabled(false)

	self._animAction:play("animation0" , true)
end

function UIRTVoiceComponent:_hideWaitingUI()	
	self._imgLoadingMicphone:setVisible(false)
	self._imgLoadingSpeaker:setVisible(false)

	self._btnMicOn:setEnabled(true)
	self._btnSpeakerOff:setEnabled(true)
	self._btnSpeakerOn:setEnabled(true)
	self._btnMicOff:setEnabled(true)

	self._animAction:stop()
end

function UIRTVoiceComponent:_onJoinVoiceRoomSuccess(event)
	Logger.debug("UIRTVoiceComponent(EVENT_RT_VOICE_JOIN_ROOM_SUCCESS)")
	self:_hideWaitingUI()
	
	-- local roomService = game.service.RoomService.getInstance();
	-- local roomId = cc.UserDefault:getInstance():getIntegerForKey("UIRTVoiceRoomId", 0)

	-- if roomId ~= roomService:getRoomId() and roomService:isRTVoiceRoom() and game.service.ConnectionService.getInstance():getReachabilityStatus() == net.NetworkStatus.ReachableViaWWAN then
	-- 	cc.UserDefault:getInstance():setIntegerForKey("UIRTVoiceRoomId", roomService:getRoomId())
	-- 	--判断如果在4G网络下，实时语音按钮默认关闭，并弹出tips提示 
	-- 	self:_onClickRTVoiceSpeakerClose();
	-- 	UIManager:getInstance():show("UITipPanel", "开启实时语音会产生额外流\n量，建议在WIFI状态下使用")
	-- end

	-- 更新当前的按钮状态
	self:_refreshBtnStatus();
end

function UIRTVoiceComponent:_onOpenMicFailed(event)
	Logger.debug("UIRTVoiceComponent(EVENT_OPEN_MIC_FAILED_DENIED)")
	game.ui.UIMessageTipsMgr.getInstance():showTips("请在设置中允许访问麦克风")
	self:_refreshBtnStatus();
end

return UIRTVoiceComponent