local csbPath = "ui/csb/GamePlays/guizhoudiy/UI_GAME_TYPE_R_BIJIE.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_R_BIJIE = class("UI_GAME_TYPE_R_BIJIE", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_R_BIJIE:onShow(...)
end

function UI_GAME_TYPE_R_BIJIE:onHide()
end

function UI_GAME_TYPE_R_BIJIE:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_R_BIJIE