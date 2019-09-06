--[[
闪屏状态, 游戏的第一个状态
--]]
local super = require("app.manager.GameStateBase")
local GameState_Splash = class("GameState_Splash", super)

function GameState_Splash:ctor(parent)
	super.ctor(self,parent)
end

function GameState_Splash:isGamingState()
	return false
end

function GameState_Splash:getDependentResource() end

function GameState_Splash:enter()
	UIManager:getInstance():show("UISplash")
end

function GameState_Splash:exit()
end

return GameState_Splash