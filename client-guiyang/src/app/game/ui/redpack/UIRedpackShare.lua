-- local csbPath = "ui/csb/Redpack/UIRedpackShare.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackShare.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackShare= class("UIRedpackShare",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackShare:ctor()
end


function UIRedpackShare:init()
	self._textMoney = seekNodeByName(self, "Text_Money", "ccui.Text")
	self._layoutDown = seekNodeByName(self, "Panel_1", "ccui.Layout")
end

function UIRedpackShare:_registerCallBack()
	bindEventCallBack(self._layoutDown, handler(self, self._onClickShare), ccui.TouchEventType.ended)
end

function UIRedpackShare:needBlackMask()
    return true
end

function UIRedpackShare:closeWhenClickMask()
	return true
end
function UIRedpackShare:onShow(func)		
	self:_registerCallBack()
	self._shareFunc = func
	local money = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):getMoney()
	self._textMoney:setString(15 - money .. "")
end

--拆红包返回
function UIRedpackShare:_onRedPackDetail()
	UIManager:getInstance():show("UIRedpackShare")
end
--关闭
function UIRedpackShare:_onClickClose()
	UIManager:getInstance():show("UIRedpackQuit", self)
end

function UIRedpackShare:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end

function UIRedpackShare:doHide()
	UIManager:getInstance():hide("UIRedpackShare")
end
--规则
function UIRedpackShare:_onClickShare()
	UIManager:getInstance():hide("UIRedpackShare")
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):doShare(handler(self, self._onShareCompleted))
end

--分享完成
function UIRedpackShare:_onShareCompleted()
	self._shareFunc()
end


return UIRedpackShare
