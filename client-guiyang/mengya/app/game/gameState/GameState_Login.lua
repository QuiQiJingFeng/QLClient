--[[
登录状态
--]]
local UIManager = app.UIManager
local super = app.GameState_InGame
local GameState_Login = class("GameState_Login", super)

function GameState_Login:ctor()
end

function GameState_Login:isGamingState()
	return false
end

function GameState_Login:enter()
	self.super:enter()
	
	UIManager:getInstance():show("UILogin")	
end

function GameState_Login:exit()
	self.super:exit()
end

function GameState_Login:_onUserDataRefreshed()
	-- -- 切换State有会造成修改Handler, 下一针在调用
	-- dispatchGlobalEvent("EVENT_BUSY_RETAIN")
	-- scheduleOnce(function()
	-- 	dispatchGlobalEvent("EVENT_BUSY_RELEASE")
	-- 	GameFSM:getInstance():enterState("GameState_Lobby");
	-- end, 0)
end

return GameState_Login
