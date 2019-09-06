--[[
头像上实时语音聊天标记

显示规则:
1. 没有加入房间的时候不显示
2. 离线不显示
3. 本地玩家不显示
4. 关闭喇叭的时候不显示

动画规则:
5. 说话的时候播放动画
--]]
local csbPath = "ui/csb/Player_talking.csb"
local UIRTVoiceIconComponent = class("UIRTVoiceIconComponent", function() return kod.LoadCSBNode(csbPath) end )

function UIRTVoiceIconComponent:ctor(parent, uiRoot)
    self._parent = parent;
    uiRoot:addChild(self);
	self:setPosition(0,0);

    self._action = cc.CSLoader:createTimeline(csbPath);
    self:runAction(self._action);

	game.service.RoomCreatorService.getInstance():addEventListener("EVENT_ROOMSERVICE_INITIALIZED", handler(self, self._registerRTVoiceEvent), self)
    self:showRTVoiceUI(false);
end

function UIRTVoiceIconComponent:dispose()
	if game.service.LocalPlayerService.getInstance() ~= nil then
		-- TODO：析构顺序需要整理
		local roomService = game.service.RoomService.getInstance() 
		if roomService ~= nil and roomService:getRTVocieComponent() ~= nil then
			roomService:getRTVocieComponent():removeEventListenersByTag(self);
		end
	end
	game.service.RoomCreatorService.getInstance():removeEventListenersByTag(self)
end

-- 当RoomService初始化成功后，再注册相关事件
function UIRTVoiceIconComponent:_registerRTVoiceEvent()
	local rtVoiceCmp = game.service.RoomService.getInstance():getRTVocieComponent();
	if rtVoiceCmp == nil then
		-- 如果当前的平台不支持的时候，不再注册
		return
	end
    rtVoiceCmp:addEventListener("EVENT_RT_VOICE_PLAYER_INFO_CHANGED", handler(self, self._onRTPlayerInfoChanged), self)
    rtVoiceCmp:addEventListener("EVENT_RT_VOICE_MEMBER_STATUS_CHANGED", handler(self, self._onRTVoiceStatusChanged), self)
end

function UIRTVoiceIconComponent:showRTVoiceUI(tf)
	if tf == true then
		local id = self._parent:getSeatUI():getRoomSeat():getPlayer().id
		if id == game.service.LocalPlayerService.getInstance():getRoleId() then 
			-- 本地玩家不显示实时语音图标
			tf = false;
		end
	end
	
	-- Logger.debug("UIRTVoiceIconComponent:showRTVoiceUI,"..tostring(tf))
	self:setVisible(tf);

	if tf == false then
		-- 隐藏的时候关闭动画
		self._action:stop();
	end
end

function UIRTVoiceIconComponent:_onRTPlayerInfoChanged(event)
	Logger.debug("UIRTVoiceIconComponent:_onRTPlayerInfoChanged")
	if self._parent:getSeatUI():getRoomSeat():hasPlayer() == false then
		return
	end

	local rtVoiceCmp = game.service.RoomService.getInstance():getRTVocieComponent();
	local player = self._parent:getSeatUI():getRoomSeat():getPlayer();
	-- Logger.debug("UIRTVoiceIconComponent:showRTVoiceUI,%s,%s,%s", tostring(rtVoiceCmp:isPlayerInRoom(player.id)), tostring(rtVoiceCmp:isPlayerSpeakerOpen(player.id)), tostring(player:isOnline()))
	-- 不在房间,不能收听的人,不在线的人,不显示状态图标
	if rtVoiceCmp:isPlayerInRoom(player.id) == true 
		and rtVoiceCmp:isPlayerSpeakerOpen(player.id) == true
		and player:isOnline() == true then
		self:showRTVoiceUI(true);
	else
		self:showRTVoiceUI(false);
	end
end

function UIRTVoiceIconComponent:_onRTVoiceStatusChanged(event)
	-- Logger.debug("UIRTVoiceIconComponent:_onRTVoiceStatusChanged,%s,%s",tostring(event.roleId),tostring(event.speeking))
	if self._parent:getSeatUI():getRoomSeat():hasPlayer() == false then
		return
	end
	
	if self._parent:getSeatUI():getRoomSeat():getPlayer().id ~= event.roleId then
		return
	end

	-- 显示/隐藏语音UI
	if event.speeking then
		self._action:play("animation0", true)
	else
		self._action:stop();
	end
end

return UIRTVoiceIconComponent