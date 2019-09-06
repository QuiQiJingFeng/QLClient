local super = require("app.game.gameState.GameState_InGame")
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")

local GameState_Lobby = class("GameState_Lobby",super)

function GameState_Lobby:ctor(parent)
	super.ctor(self,parent)
	-- 魔窗跟复制粘贴的共用标记，当处理一个成功后，另一个不再处理
	self._flag = nil
end

function GameState_Lobby:enter()
	super.enter(self)

    if UIManager:getInstance():needRestore() then
		UIManager:getInstance():restoreUIs("GameState_Lobby")
        UIManager:getInstance():setNeedRestore(false)
    else
		UIManager:getInstance():show("UIMain")
    end

    -- 监听加入房间或者加入亲友圈链接事件
	-- game.service.MagicWindowService.getInstance():addEventListener("MW_ON_GET_MLINK", handler(self, self._tryByLink), self)
	
	-- 加入大厅, 主动检测一次
   	self:_tryByLink()
	
	self:_joinRoomInfo()
end

function GameState_Lobby:exit()
	super.exit(self)

	-- game.service.MagicWindowService.getInstance():removeEventListenersByTag(self)
end

function GameState_Lobby:_onUserDataRefreshed()
	self._flag = false
	
	self:_joinRoomInfo()
end

function GameState_Lobby:_tryByLink(event)
	if self._flag == true then return end
	
	-- 魔窗加入房间
	-- self._flag = game.service.MagicWindowService.getInstance():parseMagicWindowLink()
end

function GameState_Lobby:_joinRoomInfo()
	if self._flag == true then return end 
	    -- 如果在比赛中/报名中则不处理
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
    		-- 若已报名比赛 则无法进入房间
    		if CampaignUtils.forbidenMsgWhenJoinRoom(false) then 
        		return false
    		end
			--	加入房间
			game.service.RoomCreatorService.getInstance():queryBattleIdReq(roomId, game.globalConst.JOIN_ROOM_STYLE.CopyRoomNumber)
		end
	end)
end

return GameState_Lobby
