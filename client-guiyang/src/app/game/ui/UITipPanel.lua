local csbPath = "ui/csb/UITips.csb"
local super = require("app.game.ui.UIBase")

local UITipPanel = class("UITipPanel", super, function () return kod.LoadCSBNode(csbPath) end)

function UITipPanel:ctor()
	self._textMessageTips  = nil;
	self._strInfo = nil;
end

function UITipPanel:init()
	self._textMessageTips  = seekNodeByName(self, "Text_MessageTips",  "ccui.Text");
end

function UITipPanel:onShow(...)
	local args = {...};

	if (nil ~= args[1]) then
		self._strInfo = args[1];
	else
		self._strInfo = "";
	end

	self._textMessageTips:setString(self._strInfo);
	
	local mask = self:getChildByName("dlg_mask");
	mask:setOpacity(0);
end

function UITipPanel:needBlackMask()
	return true;
end

function UITipPanel:closeWhenClickMask()
	return true
end

return UITipPanel;
