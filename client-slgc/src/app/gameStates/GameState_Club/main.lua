local super = game.GameState_InGame
local GameState_Club = class("GameState_Club", super)

function GameState_Club:ctor()
end

function GameState_Club:isGamingState()
	return false
end

function GameState_Club:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UIClubMain")
end

function GameState_Club:exit()
	super.exit(self)
end

function GameState_Club:_onUserDataRefreshed()

end

return GameState_Club
