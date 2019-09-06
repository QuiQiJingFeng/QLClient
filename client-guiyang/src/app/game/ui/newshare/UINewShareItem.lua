local csbPath = "ui/csb/Newshare/UINewShareItem.csb"

local UINewShareItem= class("UINewShareItem",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UINewShareItem:ctor()
end


function UINewShareItem:init()

	self._imageItem = seekNodeByName(self, "imgIcon", "ccui.ImageView")
	self._imageItem:ignoreContentAdaptWithSize(true)
	self._textItem = seekNodeByName(self, "Text_1", "ccui.Text")
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")	--关闭
	self._btnKnow = seekNodeByName(self, "btnClose", "ccui.Button")
	self:_registerCallBack()
end

function UINewShareItem:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnKnow, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UINewShareItem:needBlackMask()
    return true
end

function UINewShareItem:closeWhenClickMask()
	return false
end

function UINewShareItem:onShow()
	local rewardIdx = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.NEW_SHARE):getRewardIndex()
	local itemInfo = config.NewShareConfig.itemConfig[rewardIdx]
	self._imageItem:loadTexture(itemInfo[3])
	self._textItem:setString("恭喜你，领取成功！你获得了"..itemInfo[1])
end


--关闭
function UINewShareItem:_onClickClose()
	UIManager:getInstance():hide("UINewShareItem")
end

return UINewShareItem
