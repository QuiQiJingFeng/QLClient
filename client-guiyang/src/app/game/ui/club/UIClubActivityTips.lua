local csbPath = "ui/csb/Club/UIHuoDongShuoMing.csb"
local super = require("app.game.ui.UIBase")

local UIClubActivityTips = class("UIClubActivityTips", super, function () return kod.LoadCSBNode(csbPath) end)

function UIClubActivityTips:ctor()
	self._btnClose = nil
end

function UIClubActivityTips:init()
	self._btnClose		= seekNodeByName(self, "Button_x_user",			"ccui.Button")          
	bindEventCallBack(self._btnClose,		handler(self, self._onBtnTipsClick),		ccui.TouchEventType.ended)
end

function UIClubActivityTips:onShow(...)

end

function UIClubActivityTips:_onBtnTipsClick()
	UIManager:getInstance():hide("UIClubActivityTips")
end

function UIClubActivityTips:needBlackMask()
	return true;
end

function UIClubActivityTips:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubActivityTips:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end


return UIClubActivityTips;
