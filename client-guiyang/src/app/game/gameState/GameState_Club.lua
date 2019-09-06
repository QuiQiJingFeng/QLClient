--[[
亲友圈状态
--]]
local super = require("app.game.gameState.GameState_InGame")

local GameState_Club = class("GameState_Club",super)

function GameState_Club:ctor(parent)
	super.ctor(self, parent)
	-- 魔窗跟复制粘贴的共用标记，当处理一个成功后，另一个不再处理
	self._flag = nil
end

function GameState_Club:enter()
	super.enter(self)

	local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
	-- 显示亲友圈主界面，我的参数。。。没法传了。。
	if UIManager:getInstance():needRestore() then
		-- 处理一下该玩家不在此亲友圈中就直接显示亲友圈不主界面（比如在回放中被群主踢出）
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and
				game.service.club.ClubService.getInstance():getClub(localStorageClubInfo:getClubId()) ~= nil then

			UIManager:getInstance():restoreUIs("GameState_Club")
			UIManager:getInstance():setNeedRestore(false)
		else
			GameFSM.getInstance():enterState("GameState_Lobby")
		end
	else
		if localStorageClubInfo:getClubId() ~= nil and localStorageClubInfo:getClubId() ~= 0 and
				game.service.club.ClubService.getInstance():getClub(localStorageClubInfo:getClubId()) ~= nil then

			UIManager:getInstance():show("UIClubRoom", localStorageClubInfo:getClubId())
		else
			GameFSM.getInstance():enterState("GameState_Lobby")
		end
	end

	-- 监听加入房间或者加入亲友圈链接事件
	-- game.service.MagicWindowService.getInstance():addEventListener("MW_ON_GET_MLINK", handler(self, self._tryByLink), self)
	-- 监听亲友圈是否把自己设置为管理
	game.service.club.ClubService.getInstance():getClubMemberService():addEventListener("EVENT_CLUB_PERMISSIONS_CHANGED", handler(self, self._onPermissions), self)

	-- 加入亲友圈大厅, 主动检测一次
	self:_tryByLink()

	self:_joinRoomInfo()
end

function GameState_Club:_onPermissions(event)
	local localStorageClubInfo = game.service.club.ClubService.getInstance():loadLocalStorageClubInfo()
	if localStorageClubInfo:getClubId() ~= event.clubId then
		return
	end

	game.ui.UIMessageBoxMgr.getInstance():show("您的权限发生变动" , {"确定"}, function ()
		GameFSM.getInstance():enterState("GameState_Club")
	end, function()end, true)
end

function GameState_Club:exit()
	super.exit(self)

	-- 隐藏亲友圈主界面
	-- 如果主动隐藏了，是无法恢复的
	-- UIManager:getInstance():hide("UIClubMain")
	-- game.service.MagicWindowService.getInstance():removeEventListenersByTag(self)
	game.service.club.ClubService.getInstance():getClubMemberService():removeEventListenersByTag(self)
end

function GameState_Club:_onUserDataRefreshed()
	self._flag = false
	self:_joinRoomInfo()
end

function GameState_Club:_tryByLink(event)
	if self._flag == true then return end
	-- 魔窗加入房间
	-- self._flag = game.service.MagicWindowService.getInstance():parseMagicWindowLink()
end

function GameState_Club:_joinRoomInfo()
	if self._flag == true then return end
	game.plugin.Runtime.getClipboard(function(msg)
		local roomId = 0
		for s in string.gfind(msg, "%[.-%]") do
			if roomId == 0 then
				roomId = tonumber(string.sub(s, 2, -2))
			end
		end

		if roomId ~= nil and roomId > 0 then
			self._flag = true
			game.plugin.Runtime.setClipboard("")
			-- 加入房间
			game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.CopyRoomNumber)
		end
	end)
end

return GameState_Club