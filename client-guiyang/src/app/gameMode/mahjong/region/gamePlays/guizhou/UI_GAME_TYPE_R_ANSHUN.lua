local csbPath = "ui/csb/GamePlays/guizhoudiy/UI_GAME_TYPE_R_ANSHUN.csb"
local super   = require("app.game.ui.UIBase")

local UI_GAME_TYPE_R_ANSHUN = class("UI_GAME_TYPE_R_ANSHUN", super, function ()return kod.LoadCSBNode(csbPath) end)

function UI_GAME_TYPE_R_ANSHUN:ctor()
	self.roomCard_x1 = nil
	self.roomCard_x2 = nil
end

function UI_GAME_TYPE_R_ANSHUN:init()
	self.roomCard_x1 = seekNodeByName(self, "Text_1_0_2", 				"ccui.Text")
	self.roomCard_x2 = seekNodeByName(self, "Text_1_0_2_0", 			"ccui.Text")
end

function UI_GAME_TYPE_R_ANSHUN:onShow(...)
	-- android提审（应用宝）
	if device.platform == "android" and GameMain.getInstance():isReviewVersion() then
		self.roomCard_x1:setVisible(false)
		self.roomCard_x2:setVisible(false)
	else
		self.roomCard_x1:setVisible(true)
		self.roomCard_x2:setVisible(true)
	end
end

function UI_GAME_TYPE_R_ANSHUN:onHide()
end

function UI_GAME_TYPE_R_ANSHUN:getUIZOrder()
	return config.UIConstants.UIZorder
end

return UI_GAME_TYPE_R_ANSHUN