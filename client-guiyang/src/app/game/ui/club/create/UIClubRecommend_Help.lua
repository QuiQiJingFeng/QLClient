local csbPath = "ui/csb/Club/UIClubRecommend_Help.csb"
local super = require("app.game.ui.UIBase")

local UIClubRecommend_Help = class("UIClubRecommend_Help", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    新手推荐界面
]]
function UIClubRecommend_Help:ctor()
end

function UIClubRecommend_Help:init()
	self._btnClose = seekNodeByName(self, "Button_Cancel", "ccui.Button")

	bindEventCallBack(self._btnClose, function()
		UIManager:getInstance():destroy("UIClubRecommend_Help")
	end, ccui.TouchEventType.ended)
end

function UIClubRecommend_Help:onShow()
end

function UIClubRecommend_Help:onHide()
end


function UIClubRecommend_Help:needBlackMask()
	return true
end

function UIClubRecommend_Help:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRecommend_Help:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRecommend_Help