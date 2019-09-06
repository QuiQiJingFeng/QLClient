local csbPath = "ui/csb/UIReconnectTips.csb"
local super = require("app.game.ui.UIBase")

local UIReconnectTips = class("UIReconnectTips", super, function () return kod.LoadCSBNode(csbPath) end)

function UIReconnectTips:ctor()
	super.ctor(self);
	self._imgConnect = nil
	self._imgIcon = nil
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIReconnectTips:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

function UIReconnectTips:init()
	self._imgConnect    = seekNodeByName(self,"Image_Connect", "ccui.ImageView")
	self._imgIcon		= seekNodeByName(self,"Image_Icon", "ccui.ImageView")
end

-- 不能直接设置self的visible, 否则会造成UIManager错误
function UIReconnectTips:setChildrenVisible(visible)
	local children = self:getChildren()
    for _, child in ipairs(children) do	
		child:setVisible(visible)
	end
end

function UIReconnectTips:onShow(...)
	local args = {...}
		
	local _rotate = cc.CallFunc:create(function()
		self._imgConnect:setVisible(true);
		self._imgIcon:setVisible(true);
		local _repeat = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
		self._imgConnect:runAction(_repeat)
	end)
	local delayTime = 0.5
	local _queue = cc.Sequence:create(cc.DelayTime:create(delayTime), _rotate)	
	
	self._imgConnect:setVisible(false);
	self._imgIcon:setVisible(false);
	self._imgConnect:runAction(_queue)
end

function UIReconnectTips:getUIZOrder()
	return config.UIConstants.UIZorder + 5
end

function UIReconnectTips:needBlackMask()
	return false
end

function UIReconnectTips:closeWhenClickMask()
	return false
end

function UIReconnectTips:isPersistent()
	return true;
end

function UIReconnectTips:onHide()
	self._imgConnect:stopAllActions()
end

return UIReconnectTips;