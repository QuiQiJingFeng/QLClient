local csbPath = "ui/csb/GamePlays/guizhoudiy/UI_GAME_TYPE_R_ZHENFENG.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_R_ZHENFENG = class("UI_GAME_TYPE_R_ZHENFENG", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_R_ZHENFENG:onShow(...)
end

function UI_GAME_TYPE_R_ZHENFENG:onHide()
end

function UI_GAME_TYPE_R_ZHENFENG:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_R_ZHENFENG