local super = require("app.game.ui.weeksign.UIWeekSignItem")
local UIGuoQingPackage = class("UIGuoQingPackage", super)

function UIGuoQingPackage:onShow()
	self._panelParent:removeChildByName("head_frame")
	
	local path1 = PropReader.getIconById(51380233)
	local pNode = cc.CSLoader:createNode(path1)
	pNode:setName("head_frame")
	pNode:setPosition(self._imageItem1:getPosition())
	self._panelParent:addChild(pNode)
	local act = cc.CSLoader:createTimeline(path1)
	act:gotoFrameAndPlay(0, true)
	pNode:runAction(act)
	self._imageItem1:setVisible(false)
	
	local path2 = "art/function/icon_fk2.png"
	self._imageItem2:loadTexture(path2)
	self._imageItem2:ignoreContentAdaptWithSize(false)
	self._imageItem2:setContentSize(self._imageItem2:getVirtualRendererSize())
	self.animAction = cc.CSLoader:createTimeline("ui/csb/UIQsqd2.csb")
	self.animAction:gotoFrameAndPlay(0, false)
	self:runAction(self.animAction)	
	
end

--关闭
function UIGuoQingPackage:_onClickClose()
	UIManager:getInstance():hide("app.game.ui.activity.guoqing.UIGuoQingPackage")
end

return UIGuoQingPackage 