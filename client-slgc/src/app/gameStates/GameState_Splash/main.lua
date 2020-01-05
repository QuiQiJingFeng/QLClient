local super = game.GameStateBase
local GameState_Splash = class("GameState_Splash", super)

function GameState_Splash:ctor()
end

function GameState_Splash:isGamingState()
	return false
end

function GameState_Splash:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UIDownload")
end

function GameState_Splash:exit()
	super.exit(self)
end

return GameState_Splash
