local csbPath = "views/UIReconnectTip.csb"
local super = game.UIBase

local UIReconnectTip = class("UIReconnectTip", super, function () return game.Util:loadCSBNode(csbPath) end)

function UIReconnectTip:ctor()
	super.ctor(self)
end

function UIReconnectTip:getGradeLayerId()
	return 4
end

function UIReconnectTip:init()
	self._imgRotationBg = game.Util:seekNodeByName(self,"imgRotationBg","ccui.ImageView")
	self._imgDice = game.Util:seekNodeByName(self,"imgDice","ccui.ImageView")
end

function UIReconnectTip:onShow()
	local rotate = cc.CallFunc:create(function()
		self._imgRotationBg:setVisible(true)
		self._imgDice:setVisible(true)
		local action = cc.RepeatForever:create(cc.RotateBy:create(2, 360))
		self._imgRotationBg:runAction(action)
	end)
	local delayTime = 0.5
	local queue = cc.Sequence:create(cc.DelayTime:create(delayTime), rotate)
	
	self._imgRotationBg:setVisible(false)
	self._imgDice:setVisible(false)
	self._imgRotationBg:runAction(queue)
end

function UIReconnectTip:needBlackMask()
	return false
end

function UIReconnectTip:closeWhenClickMask()
	return false
end

function UIReconnectTip:isPersistent()
	return true
end

function UIReconnectTip:onHide()
	super.onHide(self)
	self._imgRotationBg:stopAllActions()
end

return UIReconnectTip