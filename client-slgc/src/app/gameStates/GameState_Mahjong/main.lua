local super = game.GameStateBase
local GameState_Mahjong = class("GameState_Mahjong", super)

function GameState_Mahjong:ctor()
end

function GameState_Mahjong:isGamingState()
	return false
end

function GameState_Mahjong:enter()
	super.enter(self)
	game.UIManager:getInstance():show("views.UIBattle")
end

function GameState_Mahjong:exit()
	super.exit(self)
end

return GameState_Mahjong
