--[[
俱乐部状态
--]]
local UIManager = app.UIManager
local super = app.GameState_InGame
local GameState_Club = class("GameState_Club", super)

function GameState_Club:ctor()
end

function GameState_Club:isGamingState()
	return false
end

function GameState_Club:enter()
	self.super:enter()
	
	UIManager:getInstance():show("UIClubRoom")
end

function GameState_Club:exit()
	self.super:exit()
end

function GameState_Club:_onUserDataRefreshed()

end

return GameState_Club
