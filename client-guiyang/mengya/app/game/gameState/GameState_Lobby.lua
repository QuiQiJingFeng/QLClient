--[[
大厅状态
--]]
local UIManager = app.UIManager
local super = app.GameState_InGame
local GameState_Lobby = class("GameState_Lobby", super)

function GameState_Lobby:ctor()
end

function GameState_Lobby:isGamingState()
	return false
end

function GameState_Lobby:enter()
	self.super:enter()
	
	UIManager:getInstance():show("UIMain")
end

function GameState_Lobby:exit()
	self.super:exit()
end

function GameState_Lobby:_onUserDataRefreshed()

end

return GameState_Lobby
