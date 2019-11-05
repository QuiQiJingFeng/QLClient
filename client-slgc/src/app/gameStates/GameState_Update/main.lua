local super = game.GameStateBase
local GameState_Update = class("GameState_Update", super)

function GameState_Update:ctor()
end

function GameState_Update:isGamingState()
	return false
end

function GameState_Update:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UILaunch")
end

function GameState_Update:exit()
	super.exit(self)
end

return GameState_Update
