local csbPath = "ui/csb/GamePlays/chaoshan/UI_GAME_TYPE_PU_NING.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_PU_NING = class("UI_GAME_TYPE_PU_NING", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_PU_NING:onShow(...)
end

function UI_GAME_TYPE_PU_NING:onHide()
end

function UI_GAME_TYPE_PU_NING:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_PU_NING