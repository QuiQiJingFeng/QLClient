local csbPath = "ui/csb/UIQsqd2.csb"
local UIItem = require("app.game.ui.element.UIItem")
local UIWeekSignItem= class("UIWeekSignItem",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIWeekSignItem:ctor()
end


function UIWeekSignItem:init()

	self._imageItem1 = seekNodeByName(self, "Image_Item_1", "ccui.ImageView")
	self._imageItem2 = seekNodeByName(self, "Image_Item_2", "ccui.ImageView")

	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭
	self._btnConfirm = seekNodeByName(self, "Button_1", "ccui.Button")
	self._panelParent = seekNodeByName(self, "Panel_2", "ccui.Layout")

	
	self:_registerCallBack()
end

function UIWeekSignItem:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIWeekSignItem:needBlackMask()
    return true
end

function UIWeekSignItem:closeWhenClickMask()
	return false
end

function UIWeekSignItem:onShow()
	self._panelParent:removeChildByName("head_frame")

	local dayInfo, dayInfo2 = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.WEEK_SIGN):getItemByDay(7)


	local pPanel1 = seekNodeByName(self, "Panel_2", "ccui.Button")
	local image1 = pPanel1:getChildByName("Image_Item_1")
	image1:setVisible(false)
	pPanel1:removeChildByName("csbHeadNode1")
	local pItem1 = UIItem.new(dayInfo.rewardId, dayInfo.count , 0)
	pItem1:setName("csbHeadNode1")
	pItem1:setScale(1.3)
	pItem1:setPosition(image1:getPosition())
	pPanel1:addChild(pItem1)


	local image2 = pPanel1:getChildByName("Image_Item_2")
	image2:setVisible(false)
	pPanel1:removeChildByName("csbHeadNode2")
	local pItem2 = UIItem.new(dayInfo2.rewardId, dayInfo2.count , 0)
	pItem2:setName("csbHeadNode1")
	pItem2:setScale(1.3)
	pItem2:setPosition(image2:getPosition())
	pPanel1:addChild(pItem2)



	self.animAction = cc.CSLoader:createTimeline(csbPath)
	self.animAction:gotoFrameAndPlay(0, false)
	self:runAction(self.animAction)	

end

--关闭
function UIWeekSignItem:_onClickClose()
	UIManager:getInstance():hide("UIWeekSignItem")
end

return UIWeekSignItem
