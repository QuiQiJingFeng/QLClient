local csbPath = "ui/csb/UIUserDeclare.csb"
local GainLabelColorUtil = require("app.game.util.GainLabelColorUtil")

local UIAgreement= class("UIAgreement",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIAgreement:ctor()
	self._titleSpace = 20
	self._titleFontSize = 36
	self._otherFontSize = 24
	self._currentPosY = 0
	self._licence = {}
	self._scrollView = nil
	self._infoPanel = nil
	self._btnClose = nil
	self._scrollViewSize = nil
	self._step = 0
	self._stepScheduler = nil
end

function UIAgreement:dispose()
	self:_stopShowUpdate()
end

function UIAgreement:init()
	self._scrollView = seekNodeByName(self, "ScrollView_user", "ccui.ScrollView")
	self._scrollView:removeAllChildren(true)
	self._scrollView:setScrollBarEnabled(true)
	self._scrollViewSize = self._scrollView:getContentSize()
	self._infoPanel = ccui.Layout:create()
	self._infoPanel:setAnchorPoint(cc.p(0, 1))
	self._infoPanel:setContentSize(cc.p(self._scrollViewSize.width, 0));
	self._scrollView:addChild(self._infoPanel)
    self._btnClose= seekNodeByName(self, "Button_x_user", "ccui.Button")
	
    bindEventCallBack(self._btnClose, handler(self, self._onCloseButton), ccui.TouchEventType.ended)
	self._scrollView:setScrollBarEnabled(false)
end

function UIAgreement:needBlackMask()
    return true
end

function UIAgreement:closeWhenClickMask()
	return false
end

function UIAgreement:onShow()
	local t = cc.FileUtils:getInstance():getStringFromFile(config.GlobalConfig.getConfig().LICENCE_PATH)
	self._licence = loadstring(t)()
	self:_startShow()
end

function UIAgreement:_startShow()
	self._stepScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._showUpdate), 0, false)

	self._infoPanel:setPosition(0, self._scrollViewSize.height)
	self._scrollView:setInnerContainerSize(self._scrollViewSize)
	self._scrollView:scrollToPercentVertical(0, 0, false)
end

function UIAgreement:_showUpdate()
	self._step = self._step + 1
	if self._step > #self._licence then
		self:_stopShowUpdate()
		return
	end

		
    --读取颜色值
	local CList = GainLabelColorUtil.new(self , 3) 

	local TITLE_COLOR = cc.c4b(CList.colors[1].r,CList.colors[1].g,CList.colors[1].b,255)
	local SUBTITLE_COLOR = cc.c4b(CList.colors[2].r,CList.colors[2].g,CList.colors[2].b,255)
	local CONTENT_COLOR = cc.c4b(CList.colors[3].r,CList.colors[3].g,CList.colors[3].b,255)

	local center = false
	local space = self._titleSpace
	local config = self._licence[self._step]
	for k, v in pairs(config) do
		if k == "title" then
			self:_createLabel(v, TITLE_COLOR, self._titleFontSize, center)
		elseif k == "subTitle" then
			self:_createLabel(v, SUBTITLE_COLOR, self._otherFontSize, center)
		elseif k == "content" then
			self:_createLabel(v, CONTENT_COLOR, self._otherFontSize, center)
		elseif k == "space" then
			space = v
		elseif k == "center" then
			center = (v == "true" and true or false)
		end
	end

	self._currentPosY = self._currentPosY - space
	if -self._currentPosY > self._scrollViewSize.height then
		self._infoPanel:setPositionY(-self._currentPosY)
		self._scrollView:setInnerContainerSize(cc.size(self._scrollViewSize.width, -self._currentPosY))
	end
end

function UIAgreement:_stopShowUpdate()
	if self._stepScheduler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._stepScheduler)
		self._stepScheduler = nil
	end
end

function UIAgreement:_createLabel(text, color, fontSize, center)
	local Label = ccui.Text:create();
	Label:setString(text);
	Label:ignoreContentAdaptWithSize(false);
	Label:setTextAreaSize(cc.size(self._scrollViewSize.width,0))
	Label:setTextColor(color);
	Label:setFontSize(fontSize);
	Label:setAnchorPoint(cc.p(0,1));
	if center ~= nil and center == true then
		Label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	end
	local _size = Label:getVirtualRendererSize()
	local __size = self._scrollView:getContentSize();
	Label:setContentSize(cc.size(__size.width, _size.height));
	self._infoPanel:addChild(Label);
	Label:setPositionY(self._currentPosY);
	self._currentPosY = self._currentPosY - _size.height;
end

function UIAgreement:_onCloseButton()
	self:_stopShowUpdate()
	UIManager.getInstance():destroy("UIAgreement")
end

return UIAgreement
