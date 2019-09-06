--[[
玩家天听状态
--]]

local super = require("app.gameMode.mahjong.processor.playerFSM.PlayerStateBase")
local PlayerState_TianTing = class("PlayerState_TianTing",super)

function PlayerState_TianTing:ctor( parent ,stateMachine)
    super.ctor(self,parent, stateMachine)
    self._name = "PlayerState_TianTing"
end

function PlayerState_TianTing:enter()
    super.enter(self)
    game.service.RoomService.getInstance():dispatchEvent({name = "ENTER_TIANTING_STATUS"})		
end

function PlayerState_TianTing:exit()
    super.exit(self)
end

function PlayerState_TianTing:doNotCloseTingTips()
	return true
end

return PlayerState_TianTing