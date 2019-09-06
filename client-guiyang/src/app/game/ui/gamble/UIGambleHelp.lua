local csbPath = "ui/csb/Gamble/UIGambleHelp.csb"
local super = require("app.game.ui.UIBase")

local UIGambleHelp = class("UIGambleHelp", super, function() return kod.LoadCSBNode(csbPath) end)

function UIGambleHelp:ctor()
	
end

function UIGambleHelp:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._scrollView = seekNodeByName(self, "ScrollView", "ccui.ScrollView")
	self._scrollView:setScrollBarEnabled(false)
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
end


function UIGambleHelp:needBlackMask()
	return true
end


function UIGambleHelp:_onClose()
	UIManager.getInstance():hide("UIGambleHelp")
end

return UIGambleHelp 