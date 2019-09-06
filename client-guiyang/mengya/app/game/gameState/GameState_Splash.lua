--[[
闪屏状态, 游戏的第一个状态
--]]
local UIManager = app.UIManager
local super = app.GameStateBase
local GameState_Splash = class("GameState_Splash", super)

function GameState_Splash:ctor()
end

function GameState_Splash:isGamingState()
	return false
end

function GameState_Splash:enter()
	UIManager:getInstance():show("UISplash")
end

function GameState_Splash:exit()
end

return GameState_Splash