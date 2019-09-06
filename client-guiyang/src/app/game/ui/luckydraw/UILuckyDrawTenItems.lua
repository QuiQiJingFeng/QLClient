local csbPath = "ui/csb/Choujiang/UIYaojiang5.csb"

local UILuckyDrawTenItems= class("UILuckyDrawTenItems",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UILuckyDrawTenItems:ctor()
end


function UILuckyDrawTenItems:init()


	self._imageItems = {}
	self._panelItems = {}
	for i = 1,10 do
		self._imageItems[i] = seekNodeByName(self, "Image_Item_"..i, "ccui.ImageView")
		self._imageItems[i]:ignoreContentAdaptWithSize(true)
	end
	self._btnClose = seekNodeByName(self, "Button_x_NoticeTips", "ccui.Button")	--关闭

	self:_registerCallBack()
end

function UILuckyDrawTenItems:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UILuckyDrawTenItems:needBlackMask()
    return true
end

function UILuckyDrawTenItems:closeWhenClickMask()
	return false
end

function UILuckyDrawTenItems:onShow()
	local prizeItems = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.LUCKY_DRAW):getPrizeItems()
	for i = 1, 10 do
		local item = prizeItems[i]
		self._imageItems[i]:getParent():removeChildByName("head_frame")
		-- if item.type < 0x03000001 or item.type > 0x03100005 then
		if item.type < 0 or PropReader.getTypeById(item.type) ~= "HeadFrame" then
			self._imageItems[i]:setVisible(true)			
			self._imageItems[i]:loadTexture(config.LuckyDrawConfig.getImagePath(item.name))
		else
			local info = config.LuckyDrawConfig.getItemById(item.type)
			local pNode = cc.CSLoader:createNode(info.icon)
			pNode:setName("head_frame")
			pNode:setPosition(self._imageItems[i]:getPosition())
			pNode:setScale(0.6)
			self._imageItems[i]:getParent():addChild(pNode)
			self._imageItems[i]:setVisible(false)
		end
	end

	self:stopAllActions()
	self.animAction = cc.CSLoader:createTimeline(csbPath)
	self.animAction:gotoFrameAndPlay(0, false)
	self:runAction(self.animAction)	
end

--关闭
function UILuckyDrawTenItems:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawTenItems")
end

return UILuckyDrawTenItems
