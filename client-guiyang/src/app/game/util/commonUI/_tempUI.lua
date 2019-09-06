
local _tempUI = class("tempUI", require "app.game.ui.UIBase")

function _tempUI:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

local ui = nil

function _tempUI.setUIPath(csbPath)
	_tempUI.__create = function() return kod.LoadCSBNode(csbPath) end
end

function _tempUI:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	
	self:_registerCallBack()
	
end

function _tempUI:onShow()
	
end

function _tempUI:onHide()
	
end

function _tempUI:needBlackMask()
	return true
end


function _tempUI:_registerCallBack()
	if self._btnClose then
		bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	end
end

function _tempUI:_close(sender)
	UIManager.getInstance():destroy("app.game.util.commonUI._tempUI")
end


return _tempUI 