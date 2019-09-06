local csbPath = "ui/csb/GamePlays/chaoshan/UI_GAME_TYPE_SHAN_TOU.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_SHAN_TOU = class("UI_GAME_TYPE_SHAN_TOU", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_SHAN_TOU:onShow(...)
end

function UI_GAME_TYPE_SHAN_TOU:onHide()
end

function UI_GAME_TYPE_SHAN_TOU:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_SHAN_TOU