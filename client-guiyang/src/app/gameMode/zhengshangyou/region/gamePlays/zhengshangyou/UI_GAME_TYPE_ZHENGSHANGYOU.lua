local csbPath = "ui/csb/GamePlays/zhengshangyou/UI_GAME_TYPE_R_ZHENGSHANGYOU.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_ZHENGSHANGYOU = class("UI_GAME_TYPE_ZHENGSHANGYOU", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_ZHENGSHANGYOU:onShow(...)
end

function UI_GAME_TYPE_ZHENGSHANGYOU:onHide()
end

function UI_GAME_TYPE_ZHENGSHANGYOU:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_ZHENGSHANGYOU