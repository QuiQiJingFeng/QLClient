local super = require("app.game.ui.luckydraw.UILuckyDrawItem")
local csbPath = "ui/csb/UIMonth2.csb"
local UIMonthSignItem= class("UIMonthSignItem",  super)


function UIMonthSignItem:onShow(index, count)
	local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.MONTH_SIGN):getRewardItemByIndex(index)

	self._bmTitle:setString(item.signCount.."天礼包")

	self._panelParent:removeChildByName("head_frame");
	local  icon = PropReader.getIconByIdAndCount(item.itemId, item.count)

	if string.sub(icon, string.len( icon )-3) ~= ".csb" then
		self._textItem:setString("恭喜您获得"..PropReader.getNameById(item.itemId).."X"..item.count)		
		if PropReader.getTypeById(item.itemId) == "RedPackage" then
			self._textItem:setString(string.format( "恭喜您获得%d元红包×1", count ))
		end
		local icon = PropReader.getIconByIdAndCount(item.itemId, item.count)
		self._imageItem:loadTexture(icon)
		self._imageItem:setVisible(true)
	else
		local icon = PropReader.getIconById(item.itemId)
		self._textItem:setString("恭喜您获得"..PropReader.getNameById(item.itemId))
		local pNode = cc.CSLoader:createNode(icon)
		pNode:setName("head_frame")
		pNode:setPosition(self._imageItem:getPosition())
		self._panelParent:addChild(pNode)
		self._imageItem:setVisible(false)
	end
	self:stopAllActions()
	self.animAction = cc.CSLoader:createTimeline(csbPath)
	self.animAction:gotoFrameAndPlay(0, false)
	self:runAction(self.animAction)	

end

--关闭
function UIMonthSignItem:_onClickClose()
	UIManager:getInstance():hide("UIMonthSignItem")
end

return UIMonthSignItem
