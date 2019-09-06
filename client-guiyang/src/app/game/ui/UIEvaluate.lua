local csbPath = "ui/csb/UIPingJia.csb"
local super = require("app.game.ui.UIBase")

local UIEvaluate = class("UIEvaluate", super, function () return kod.LoadCSBNode(csbPath) end)

function UIEvaluate:ctor()

	self._btnAccess = nil;
	self._btnClose = nil;
	self._btnMeiQia = nil;

end

function UIEvaluate:init()

	self._btnAccess			= seekNodeByName(self, "Button_PingJia_1"			, "ccui.Button");
	self._btnClose			= seekNodeByName(self, "Button_PingJia_2"			, "ccui.Button");
	self._btnMeiQia			= seekNodeByName(self, "Button_PingJia_3"			, "ccui.Button");

	self:_registerCallBack()
end	

function UIEvaluate:_registerCallBack()

	bindEventCallBack(self._btnAccess, handler(self, self.onBtnAccessClick),    ccui.TouchEventType.ended);
	bindEventCallBack(self._btnClose,  handler(self, self.onBtnCloseClick),   ccui.TouchEventType.ended);
	bindEventCallBack(self._btnMeiQia, handler(self, self.onBtnMeiQiaClick), ccui.TouchEventType.ended);

end

function UIEvaluate:onShow(...)
	local args = {...};
end

function UIEvaluate:onBtnAccessClick()
	game.plugin.Runtime.sendCommentToApple()
	UIManager:getInstance():destroy("UIEvaluate")
end

function UIEvaluate:onBtnCloseClick()
	UIManager:getInstance():destroy("UIEvaluate")
end

function UIEvaluate:onBtnMeiQiaClick()
	game.service.MeiQiaService:getInstance():openMeiQia()
	UIManager:getInstance():destroy("UIEvaluate")
end

function UIEvaluate:needBlackMask()

	return true;

end

return UIEvaluate;




