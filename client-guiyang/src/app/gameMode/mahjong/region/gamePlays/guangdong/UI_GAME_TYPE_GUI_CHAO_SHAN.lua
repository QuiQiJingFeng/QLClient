local csbPath = "ui/csb/GamePlays/chaoshan/UI_GAME_TYPE_GUI_CHAO_SHAN.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_GUI_CHAO_SHAN = class("UI_GAME_TYPE_GUI_CHAO_SHAN", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_GUI_CHAO_SHAN:onShow(...)
end

function UI_GAME_TYPE_GUI_CHAO_SHAN:onHide()
end

function UI_GAME_TYPE_GUI_CHAO_SHAN:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_GUI_CHAO_SHAN