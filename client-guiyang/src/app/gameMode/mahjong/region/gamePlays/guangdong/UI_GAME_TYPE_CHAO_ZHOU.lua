-- 门清玩法
local csbPath = "ui/csb/GamePlays/chaoshan/UI_GAME_TYPE_CHAO_ZHOU.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_CHAO_ZHOU = class("UI_GAME_TYPE_CHAO_ZHOU", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_CHAO_ZHOU:onShow(...)
end

function UI_GAME_TYPE_CHAO_ZHOU:onHide()
end

function UI_GAME_TYPE_CHAO_ZHOU:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_CHAO_ZHOU