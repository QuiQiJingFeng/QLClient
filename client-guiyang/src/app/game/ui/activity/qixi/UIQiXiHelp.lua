local csbPath = "ui/csb/Activity/QiXi/UIQiXiHelp.csb"
local super = require("app.game.ui.UIBase")
local UIQiXiHelp = class("UIQiXiHelp", super, function() return kod.LoadCSBNode(csbPath) end)
local ScrollText = require("app.game.util.ScrollText")

function UIQiXiHelp:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

function UIQiXiHelp:ctor()
	
end

function UIQiXiHelp:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")

	self:_registerCallBack()
	
end

function UIQiXiHelp:onShow()

end

function UIQiXiHelp:onHide()
	
end

function UIQiXiHelp:needBlackMask()
	return true
end


function UIQiXiHelp:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
end

function UIQiXiHelp:_close(sender)
	UIManager.getInstance():hide("UIQiXiHelp")
end


return UIQiXiHelp 