local csbPath = "ui/csb/UIFPYJ2.csb"
local UIItem = require("app.game.ui.element.UIItem")

local UITurnCardItem = class("UITurnCardItem", require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UITurnCardItem:ctor()
	self._cards = {}
end

function UITurnCardItem:dispose()
	self:_stopShowUpdate()
end

function UITurnCardItem:init()
	--确定
	self._btnConfirm = seekNodeByName(self, "Button_x_CardInfo", "ccui.Button")
	
	--分享
	self._btnShare = seekNodeByName(self, "Button_info_0_0_0", "ccui.Button")
	
	--关闭
	self._btnClose = seekNodeByName(self, "Button_info_0_0", "ccui.Button")
	
	-- 物品容器
	self._panelItem = seekNodeByName(self, "panelItem", "ccui.Layout")
	
	local effectNode = seekNodeByName(self, "Node_effect", "cc.Node")
	
	local node = cc.CSLoader:createNode("ui/csb/Effect_Glow.csb")
	local animAction = cc.CSLoader:createTimeline("ui/csb/Effect_Glow.csb")
	animAction:gotoFrameAndPlay(0, true)
	node:runAction(animAction)
	node:setTag(100001)
	-- node:setPosition(card:getContentSize().width/2, card:getContentSize().height/2)
	effectNode:addChild(node)
	
	self:_registerCallBack()
end

function UITurnCardItem:_registerCallBack()
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
end

function UITurnCardItem:needBlackMask()
	return true
end

function UITurnCardItem:closeWhenClickMask()
	return false
end

function UITurnCardItem:onShow(parent, itemId, itemCount, time)
	if not itemId then
		local item = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TURN_CARD):getPrizeItem()
		itemId = item.itemId
		itemCount = item.prizeCount
		time = item.time
	end
	if not time  then
		time = 0
	end

	self._panelItem:removeAllChildren(true)
	local UIItem = require("app.game.ui.element.UIItem")
	local item = UIItem.new(itemId, itemCount, time)
	self._panelItem:addChild(item)
	local size = self._panelItem:getContentSize()
	
	item:setPosition(size.width / 2, size.height / 2)
	
	item:setScale(1.5)
	
	item:showItemName()
	
	
	self._parent = parent
end

--关闭
function UITurnCardItem:_onClickClose()
	UIManager:getInstance():hide("UITurnCardItem")
end


--分享
function UITurnCardItem:_onClickShare()
	share.ShareWTF:getInstance():share(share.constants.ENTER.TURN_CARD_ITEM_SHARE)
end

function UITurnCardItem:onHide()
	if self._parent and self._parent._resetSelectCard then
		self._parent:_resetSelectCard()
	end
end
return UITurnCardItem
