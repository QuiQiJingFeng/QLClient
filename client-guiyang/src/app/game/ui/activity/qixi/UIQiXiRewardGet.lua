local csbPath = "ui/csb/Activity/QiXi/UIQiXiRewardGet.csb"
local super = require("app.game.ui.UIBase")
local UIQiXiRewardGet = class("UIQiXiRewardGet", super, function() return kod.LoadCSBNode(csbPath) end)

function UIQiXiRewardGet:ctor()
	
end

function UIQiXiRewardGet:init()
	self._icon = seekNodeByName(self, "icon", "ccui.Layout")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._textContent = seekNodeByName(self, "textContent", "ccui.Text")
	self._textCount = seekNodeByName(self, "textCount", "ccui.TextBMFont")
	self:_registerCallBack()
	
	
end

function UIQiXiRewardGet:onShow(imgSource, name, count)
	PropReader.setIconForNode(self._icon, imgSource, 0.9)
	local content = "恭喜您获得" .. name
	self._textContent:setString(content)
	self._textCount:setVisible(count ~= 1)
	self._textCount:setString("X" .. count)
end

function UIQiXiRewardGet:onHide()
	
end

function UIQiXiRewardGet:needBlackMask()
	return true
end


function UIQiXiRewardGet:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
end

function UIQiXiRewardGet:_close(sender)
	UIManager.getInstance():hide("UIQiXiRewardGet")
end


return UIQiXiRewardGet 