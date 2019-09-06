local csbPath = "ui/csb/PlayerScene.csb"
local super = require("app.game.ui.UIBase")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")

--[[
-- 牌局主界面
--]]
local UIGameScene_Mahjong = class("UIGameScene_Mahjong", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGameScene_Mahjong:ctor()
	self._roomUI = nil
	self._roomSeatUIs = {}
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIGameScene_Mahjong:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UIGameScene_Mahjong:init()

end

function UIGameScene_Mahjong:_addRoomSeat(roomSeat)
	self._roomSeatUIs[roomSeat:getChairType()] = roomSeat;
end

function UIGameScene_Mahjong:onShow(...)
	local roomService = game.service.RoomService.getInstance()
	-- 创建房间UI
	local UIRoom = require("app.gameMode.mahjong.ui.UIRoom")
	self._roomUI = UIRoom.new(self)
	self._roomUI:initialize()
	local UIRoomSeat_Watcher = nil
	local UIRoomSeat_Down = nil
	local UIRoomSeat_Right = nil
	local UIRoomSeat_Top = nil
	local UIRoomSeat_Left = nil
	if config.getIs3D() then
		UIRoomSeat_Watcher = require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher_3D")
		UIRoomSeat_Down = require("app.gameMode.mahjong.ui.UIRoomSeat_Down_3D")
		UIRoomSeat_Right = require("app.gameMode.mahjong.ui.UIRoomSeat_Right_3D")
		UIRoomSeat_Top = require("app.gameMode.mahjong.ui.UIRoomSeat_Top_3D")
		UIRoomSeat_Left = require("app.gameMode.mahjong.ui.UIRoomSeat_Left_3D")
	else
		UIRoomSeat_Watcher = require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher_2D")
		UIRoomSeat_Down = require("app.gameMode.mahjong.ui.UIRoomSeat_Down_2D")
		UIRoomSeat_Right = require("app.gameMode.mahjong.ui.UIRoomSeat_Right_2D")
		UIRoomSeat_Top = require("app.gameMode.mahjong.ui.UIRoomSeat_Top_2D")
		UIRoomSeat_Left = require("app.gameMode.mahjong.ui.UIRoomSeat_Left_2D")
	end
	-- 创建座位UI
	if game.service.LocalPlayerService:getInstance():isWatcher() then
		self:_addRoomSeat(UIRoomSeat_Watcher.new(self));
	else
		self:_addRoomSeat(UIRoomSeat_Down.new(self));
	end
	self:_addRoomSeat(UIRoomSeat_Right.new(self));
	self:_addRoomSeat(UIRoomSeat_Top.new(self));
	self:_addRoomSeat(UIRoomSeat_Left.new(self));

	for i=1,#self._roomSeatUIs do
		self._roomSeatUIs[i]:clearSeat()
	end
	
	--实时语音优化 创建和加入实时语音房间时，如果音量高于20%，则默认降低到20%。
	if roomService and roomService:isRTVoiceRoom() then
		local bgmValue = game.service.GlobalSetting.getInstance().bgmVolume
		local sfxValue = game.service.GlobalSetting.getInstance().sfxVolume

		if bgmValue > 0.2 then
			manager.AudioManager.getInstance():setMusicVolumeUser(0.2)	
		end

		if sfxValue > 0.2 then
			manager.AudioManager.getInstance():setEffectVolumeUser(0.2)	
		end
	end
	
	-- 播放比赛前需播放的动画
	game.service.CampaignService.getInstance():dispatchEvent({name = "EVENT_PLAY_CAMPAIGN_CACHE_ANIM"})
end

function UIGameScene_Mahjong:onHide()
	if self._roomUI ~= nil then
		self._roomUI:dispose();
		self._roomUI = nil;
	end

	for i=1,#self._roomSeatUIs do
		self._roomSeatUIs[i]:dispose()
	end
	self._roomSeatUIs = {}
end

function UIGameScene_Mahjong:onReset()
	-- UIRoomSeat_Watcher = require("app.gameMode.mahjong.ui.UIRoomSeat_Watcher")
	-- UIRoomSeat_Down = require("app.gameMode.mahjong.ui.UIRoomSeat_Down")
	-- UIRoomSeat_Right = require("app.gameMode.mahjong.ui.UIRoomSeat_Right")
	-- UIRoomSeat_Top = require("app.gameMode.mahjong.ui.UIRoomSeat_Top")
	-- UIRoomSeat_Left = require("app.gameMode.mahjong.ui.UIRoomSeat_Left")
	self:onHide()
	self:onShow()
end

function UIGameScene_Mahjong:getRoomUI()
	return self._roomUI;
end

function UIGameScene_Mahjong:getUIZOrder()
    return 10
end

function UIGameScene_Mahjong:getSeatUI(chairType)
	for i=1,#self._roomSeatUIs do
		if self._roomSeatUIs[i]:getChairType() == chairType then
			return self._roomSeatUIs[i];
		end
	end
	return nil
end

-- 显示操作等待指示
function UIGameScene_Mahjong:showWaitingOperationIndicator(targetSeat) 
	for i=1,#self._roomSeatUIs do
		local roomSeatUI = self._roomSeatUIs[i]
		if i == targetSeat then
			roomSeatUI:showIndicator(true)
			self:getRoomUI():doCountDown(targetSeat);
			-- 玩家头像循环播放动画
			-- this.ani7.play(0, true);
		else
			roomSeatUI:showIndicator(false)
		end
	end
end
-- 获取玩家座次
function UIGameScene_Mahjong:getPlayerSeat(playerId)
	local playerSeat = 1
	for i=1,#self._roomSeatUIs do
		local player = self._roomSeatUIs[i]._roomSeat:getPlayer()
		if player ~= nil and player.id == playerId then
			playerSeat = i
		end
	end
	return playerSeat
end

--[[
-- 回调事件
--]]
function UIGameScene_Mahjong:_onClickDestroyRoom(sender)
    game.service.RoomService.getInstance():quitRoom()
end

function UIGameScene_Mahjong:destroy()
	-- 检查是不是还有没有解除引用的card
	CardFactory:getInstance():releaseAllCards()
end

return UIGameScene_Mahjong;