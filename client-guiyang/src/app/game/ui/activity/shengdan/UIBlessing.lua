local csbPath = "ui/csb/Activity/Christmas/UIBlessing.csb"
local super = require("app.game.ui.UIBase")
local UIBlessing = class("UIBlessing", super, function() return kod.LoadCSBNode(csbPath) end)

local buttonType = {
	card = 251658242,
	gold = 251658243,
	ticket = 251658247,
}
local blessDesc = {
	[buttonType.card] = {text = "房卡", img = "art/activity/Christmas/img_lydhg_jl_fk.png"},
	[buttonType.gold] = {text = "金币", img = "art/activity/Christmas/img_gold_christmas.png"},
	[buttonType.ticket] = {text = "参赛券", img = "art/mall/ticket8.png"},
}

function UIBlessing:ctor()
	
end

function UIBlessing:init()
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._btnClose1 = seekNodeByName(self, "btnClose1", "ccui.Button")
	self._btnGold = seekNodeByName(self, "btnGold", "ccui.Button")
	--参赛卷
	self._btnTicket = seekNodeByName(self, "btnTicket", "ccui.Button")
	self._btnCard = seekNodeByName(self, "btnCard", "ccui.Button")
	
	self._btnReelect = seekNodeByName(self, "btnReelect", "ccui.Button")
	
	self._panelSelcet = seekNodeByName(self, "panelSelcet", "ccui.Layout")
	self._panelBless = seekNodeByName(self, "panelBless", "ccui.Layout")
	
	self._textDesc = seekNodeByName(self, "textDesc", "ccui.Text")
	self._imgBlessed = seekNodeByName(self, "imgBlessed", "ccui.ImageView")
	self:_registerCallBack()
	self._action = cc.CSLoader:createTimeline(csbPath)
	self:runAction(self._action)
	self._action:gotoFrameAndPlay(0, true)
end

function UIBlessing:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._close), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose1, handler(self, self._close), ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnGold, function()
		self:_selectBless(buttonType.gold)
	end, ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnTicket, function()
		self:_selectBless(buttonType.ticket)
	end, ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnCard, function()
		self:_selectBless(buttonType.card)
	end, ccui.TouchEventType.ended)
	
	bindEventCallBack(self._btnReelect, function()
		self:_selectBless(0)
	end, ccui.TouchEventType.ended)
end

function UIBlessing:onShow()
	event.EventCenter:addEventListener("EVENT_BLESSING_INFO_RECEIVE", handler(self, self._changeState), self)
	event.EventCenter:addEventListener("EVENT_BLESS_SUCCESS", function(...)
		self:_changeState()
		if blessDesc[game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getBlessId()] then
			commonUI.ShowUIWithBtnClose.showUI("ui/csb/Activity/Christmas/UIBlessSuccess.csb")
		end
	end, self)
	
	self:_changeState()
end

function UIBlessing:onHide()
	event.EventCenter:removeEventListenersByTag(self)
	
end

function UIBlessing:needBlackMask()
	return true
end

function UIBlessing:_close(sender)
	UIManager.getInstance():hide("UIBlessing")
end

function UIBlessing:_selectBless(itemId)
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACPrayREQ(itemId)
end

function UIBlessing:_showSelect()
	self._panelSelcet:setVisible(true)
	self._panelBless:setVisible(false)
end

function UIBlessing:_showBless(currentId)
	local string = blessDesc[currentId].text
	local img = blessDesc[currentId].img
	self._panelSelcet:setVisible(false)
	self._panelBless:setVisible(true)
	
	self._textDesc:setString(string)
	self._imgBlessed:loadTexture(img)
end

function UIBlessing:_changeState()
	local currentId = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):getBlessId()
	if not currentId then
		game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.CHRISTMAS):CACPrayInfoREQ()
		self._panelSelcet:setVisible(false)
		self._panelBless:setVisible(false)
	elseif not blessDesc[currentId] then
		self:_showSelect()
	else
		self:_showBless(currentId)
	end
end



return UIBlessing 