local csbPath = "ui/csb/GamePlays/guizhoudiy/UI_GAME_TYPE_R_XINGYI.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_R_XINGYI = class("UI_GAME_TYPE_R_XINGYI", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_R_XINGYI:onShow(...)
end

function UI_GAME_TYPE_R_XINGYI:onHide()
end

function UI_GAME_TYPE_R_XINGYI:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_R_XINGYI