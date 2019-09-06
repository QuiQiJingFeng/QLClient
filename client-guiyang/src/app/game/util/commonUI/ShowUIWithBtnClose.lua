local ns = namespace("commonUI")

local ShowUIWithBtnClose = class("ShowUIWithBtnClose")
local tempUI = require "app.game.util.commonUI._tempUI"


function ShowUIWithBtnClose.showUI(csbPath)
	tempUI.setUIPath(csbPath)
	return UIManager.getInstance():show("app.game.util.commonUI._tempUI")
end

ns.ShowUIWithBtnClose = ShowUIWithBtnClose

return ShowUIWithBtnClose 