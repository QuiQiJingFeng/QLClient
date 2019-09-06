local csbPath = "ui/csb/Activity/QiXi/UIQiXiRewardGet2.csb"
local super = require("app.game.ui.UIBase")
local UIQiXiRewardGet2 = class("UIQiXiRewardGet2", super, function() return kod.LoadCSBNode(csbPath) end)

function UIQiXiRewardGet2:ctor()
	
end

function UIQiXiRewardGet2:init()
	self._icon = seekNodeByName(self, "panelIcon", "ccui.Layout")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")

	self:_registerCallBack()
	
	PropReader.setIconForNode(self._icon, "0x03100007", 0.9)
end

function UIQiXiRewardGet2:onShow()

end

function UIQiXiRewardGet2:onHide()
	
end

function UIQiXiRewardGet2:needBlackMask()
	return true
end


function UIQiXiRewardGet2:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
end

function UIQiXiRewardGet2:_close(sender)
	UIManager.getInstance():destroy("UIQiXiRewardGet2")
end


return UIQiXiRewardGet2 