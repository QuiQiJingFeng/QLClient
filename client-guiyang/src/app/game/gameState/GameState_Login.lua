--[[
登录状态
--]]
local super = require("app.game.gameState.GameState_InGame")
local GameState_Login = class("GameState_Login", super)

function GameState_Login:ctor(parent)
	super.ctor(self, parent)
end

function GameState_Login:isGamingState()
	return false
end

function GameState_Login:enter()
	super.enter(self)
	
	UIManager:getInstance():show("UILogin")	
end

function GameState_Login:exit()
	super.exit(self)
end

function GameState_Login:_onUserDataRefreshed()
	-- 切换State有会造成修改Handler, 下一针在调用
	dispatchGlobalEvent("EVENT_BUSY_RETAIN")
	scheduleOnce(function()
		dispatchGlobalEvent("EVENT_BUSY_RELEASE")
		GameFSM:getInstance():enterState("GameState_Lobby");
	end, 0)
end

return GameState_Login
