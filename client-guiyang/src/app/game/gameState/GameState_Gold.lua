--[[    金币场
--]]
local super = require("app.game.gameState.GameState_InGame")

local GameState_Gold = class("GameState_Gold", super)

function GameState_Gold:ctor(parent)
	super.ctor(self, parent)
end

function GameState_Gold:prepareEnter()
	
end

function GameState_Gold:enter()
	super.enter(self)
	
	if UIManager:getInstance():needRestore() then
		UIManager:getInstance():restoreUIs("GameState_Gold")
		UIManager:getInstance():setNeedRestore(false)
	else
		UIManager:getInstance():show("UIGoldMain")
		game.service.GoldService.getInstance():sendCGOQueryGoldInfoREQ()
	end
end

function GameState_Gold:exit()
	super.exit(self)
end

return GameState_Gold
