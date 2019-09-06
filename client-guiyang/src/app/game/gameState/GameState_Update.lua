--[[
更新状态, 用于处理游戏的更新逻辑
--]]
local super = require("app.manager.GameStateBase")
local GameState_Update = class("GameState_Update",super)

function GameState_Update:ctor(parent)
	super.ctor(self,parent)
	self.geteeayServerUrl = "http://10.23.1.178:3700/client"
	self.cachedUserName = ""
end

function GameState_Update:isGamingState()
	return false
end

function GameState_Update:isUpdateState()
	return true
end

function GameState_Update:getDependentResource() end

function GameState_Update:enter()
	UIManager:getInstance():show("UILaunch")
end

function GameState_Update:exit()
end

return GameState_Update