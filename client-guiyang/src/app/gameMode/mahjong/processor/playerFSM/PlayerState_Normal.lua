--[[
玩家正常打牌状态
--]]

local super = require("app.gameMode.mahjong.processor.playerFSM.PlayerStateBase")
local PlayerState_Normal = class("PlayerState_Normal",super)

function PlayerState_Normal:ctor( parent ,stateMachine)
    super.ctor(self,parent, stateMachine)
    self._name = "PlayerState_Normal"
end

function PlayerState_Normal:enter()
    super.enter(self)
end

function PlayerState_Normal:exit()
    super.exit(self)
end
return PlayerState_Normal