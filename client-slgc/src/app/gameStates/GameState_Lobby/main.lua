local super = game.GameStateBase
local GameState_Lobby = class("GameState_Lobby", super)

function GameState_Lobby:ctor()
end

function GameState_Lobby:isGamingState()
	return false
end

function GameState_Lobby:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UILobby")
end

function GameState_Lobby:exit()
	super.exit(self)
end

return GameState_Lobby
