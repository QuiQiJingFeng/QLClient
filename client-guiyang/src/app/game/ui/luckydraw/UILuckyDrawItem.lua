local csbPath = "ui/csb/UIMonth2.csb"

local UILuckyDrawItem= class("UILuckyDrawItem",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UILuckyDrawItem:ctor()
end


function UILuckyDrawItem:init()

	self._imageItem = seekNodeByName(self, "Image_Item", "ccui.ImageView")
	self._imageItem:ignoreContentAdaptWithSize(true)
	self._textItem = seekNodeByName(self, "Text_1", "ccui.Text")
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭
	self._panelParent = seekNodeByName(self, "Panel_2", "ccui.Layout")
	self._bmTitle = seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")
	self._bmTitle:setString("恭喜中将")

	self._btnConfirm = seekNodeByName(self, "Button_1", "ccui.Button")
	self:_registerCallBack()
end

function UILuckyDrawItem:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UILuckyDrawItem:needBlackMask()
    return true
end

function UILuckyDrawItem:closeWhenClickMask()
	return false
end

function UILuckyDrawItem:onShow(parent)
	self._panelParent:removeChildByName("head_frame")

	self._parent = parent
	local prizeItems = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getPrizeItems()
	local item = prizeItems[1]
	-- if item.type < 0x03000001 or item.type > 0x03100005 then
	if item.type < 0 or PropReader.getTypeById(item.type) ~= "HeadFrame" then
		self._textItem:setString("客官，恭喜你抽中"..item.name.."!")		
		local icon = config.LuckyDrawConfig.getImagePath(item.name)
		self._imageItem:loadTexture(icon)
		self._imageItem:setVisible(true)
	else
		local info = config.LuckyDrawConfig.getItemById(item.type)
		self._textItem:setString("客官，恭喜你抽中"..info.name)
		local pNode = cc.CSLoader:createNode(info.icon)
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



function UILuckyDrawItem:onHide()
	-- game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):removeEventListenersByTag(self)
	if self._parent and self._parent._showFirstDraw then
		self._parent:_showFirstDraw()
	end
end

--关闭
function UILuckyDrawItem:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawItem")
end

return UILuckyDrawItem
