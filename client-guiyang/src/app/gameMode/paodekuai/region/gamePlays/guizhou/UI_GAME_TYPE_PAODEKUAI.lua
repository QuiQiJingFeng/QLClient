local csbPath = "ui/csb/GamePlays/guizhoudiy/UI_GAME_TYPE_R_PAODEKUAI.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_PAODEKUAI = class("UI_GAME_TYPE_PAODEKUAI", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_PAODEKUAI:onShow(...)
end

function UI_GAME_TYPE_PAODEKUAI:onHide()
end

function UI_GAME_TYPE_PAODEKUAI:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_PAODEKUAI