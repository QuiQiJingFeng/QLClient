--[[
牌局状态
--]]
local UIManager = app.UIManager
local super = app.GameState_InGame
local GameState_Battle = class("GameState_Battle", super)

function GameState_Battle:ctor()
end

function GameState_Battle:isGamingState()
	return false
end

function GameState_Battle:enter(sceneName)
	self.super:enter()
	UIManager:getInstance():show(sceneName)
end

function GameState_Battle:exit()
	self.super:exit()
end

function GameState_Battle:_onUserDataRefreshed()

end

return GameState_Battle
