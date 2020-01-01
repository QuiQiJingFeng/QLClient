local super = game.GameStateBase
local scene = import("scenes.WordScene")
local GameState_Physics = class("GameState_Physics", super)

function GameState_Physics:ctor()
end

function GameState_Physics:isGamingState()
	return false
end

function GameState_Physics:enter()
    super.enter(self)

    game.UIManager:destroyInstance()
    display.runScene(scene.new())
end

function GameState_Physics:exit()
	super.exit(self)
end

return GameState_Physics
