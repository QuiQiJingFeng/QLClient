local csbPath = "ui/csb/UIMonth3.csb"
local UIMonthSignTips= class("UIMonthSignTips",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)



function UIMonthSignTips:ctor()

end


function UIMonthSignTips:init()
	--关闭
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btnConfirm = seekNodeByName(self, "Button_Confirm", "ccui.Button")
	self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
	self._text = seekNodeByName(self, "Text_2", "ccui.Text")
	--
	self._checkBoxNoMore = seekNodeByName(self, "CheckBox_NoMore", "ccui.CheckBox")
	self._checkBoxNoMore:setSelected(false)

	self:_registerCallBack()
end

function UIMonthSignTips:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._checkBoxNoMore, handler(self, self._onClickNoMore), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickConfirm), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnCancel, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIMonthSignTips:needBlackMask()
    return true
end

function UIMonthSignTips:closeWhenClickMask()
	return false
end

function UIMonthSignTips:onShow()
	self._text:setString("是否花费"..game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getResignCost().. "张房卡进行补签")
end

function UIMonthSignTips:_onClickNoMore(sender)
	local selected = sender:isSelected()

	local key =  game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getTodayKey()
	cc.UserDefault:getInstance():setBoolForKey(key, not selected)
end

--关闭
function UIMonthSignTips:_onClickClose()
	UIManager:getInstance():hide("UIMonthSignTips")
end

function UIMonthSignTips:_onClickConfirm(sender)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):querySignInfo(2)
	UIManager:getInstance():hide("UIMonthSignTips")
end

return UIMonthSignTips
