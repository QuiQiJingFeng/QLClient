local super = game.GameState_InGame
local GameState_Login = class("GameState_Login", super)

function GameState_Login:ctor()
end

function GameState_Login:isGamingState()
	return false
end

function GameState_Login:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UILogin")
end

function GameState_Login:exit()
	super.exit(self)
end

function GameState_Login:_onUserDataRefreshed()
	GameFSM:getInstance():enterState("GameState_Lobby")
end

return GameState_Login
