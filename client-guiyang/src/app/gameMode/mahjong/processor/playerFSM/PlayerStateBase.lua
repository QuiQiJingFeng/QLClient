--[[
游戏时玩家所出的状态 base类
--]]

local super = require("app.manager.GameStateBase")
local PlayerStateBase = class("PlayerStateBase", super)

function PlayerStateBase:ctor(parent , stateMachine)
	super.ctor(self,parent)
	self._name = "PlayerStateBase"
	self._stateMachine = stateMachine
end

function PlayerStateBase:enter()
	
end

function PlayerStateBase:exit()    

end

function PlayerStateBase:getName()
	return self._name
end

function PlayerStateBase:doNotCloseTingTips()
	return false
end

return PlayerStateBase