
local csbPath = "ui/csb/GamePlays/chaoshan/UI_GAME_TYPE_HUI_LAI.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_HUI_LAI = class("UI_GAME_TYPE_HUI_LAI", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_HUI_LAI:onShow(...)
end

function UI_GAME_TYPE_HUI_LAI:onHide()
end

function UI_GAME_TYPE_HUI_LAI:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_HUI_LAI