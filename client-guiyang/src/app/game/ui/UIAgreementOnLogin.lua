local csbPath = "ui/csb/UIUserDeclare_1.csb"

local UIAgreementOnLogin= class("UIAgreementOnLogin",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)

local TITLE_COLOR = cc.c4b(36,79,4,255)
local SUBTITLE_COLOR = cc.c4b(94,122,191,255)
local CONTENT_COLOR = cc.c4b(124,44,0,255)

function UIAgreementOnLogin:ctor()
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

function UIAgreementOnLogin:dispose()
	self:_stopShowUpdate()
end

function UIAgreementOnLogin:init()
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

	-- self._node = ccui.Layout:create()
	-- self:addChild(self._node)
	-- self._node:setContentSize(cc.size(400,400))
	-- self._node:setAnchorPoint(cc.p(0.5, 0.5))
	-- self._node:setPosition(cc.p(1136/2, 640/2))
	-- self._node:setClippingEnabled(true)

	-- self._text = ccui.Text:create()
	-- self._text:setString("江宇是个大SB！")
	-- self._text:setAnchorPoint(cc.p(0, 0))
	-- self._text:setFontSize(32)
	-- self._text:setTextColor(cc.c3b(0, 0, 0))
	-- self:addChild(self._text)

	-- self._textSeq = {}
	-- local num = math.floor(self._node:getContentSize().height / self._text:getContentSize().height) + 2
	-- local height = self._text:getContentSize().height
	-- for i=1,num do
	-- 	local item = self._text:clone()
	-- 	self._node:addChild(item)
	-- 	self._text:setPosition(cc.p(0, -(height+5)*i))
	-- 	table.insert(self._textSeq, item)
	-- end
	-- self:scheduleUpdateWithPriorityLua(function(dt)
	-- 	self:_update(dt)
	-- end, 0)

	-- self._last = 0

	-- 添加的两个新按钮
	self._btnYes = seekNodeByName(self, "Button_userdeclare_yes", "ccui.Button")
	self._btnNo = seekNodeByName(self, "Button_userdeclare_no", "ccui.Button")

	bindEventCallBack(self._btnYes, handler(self, self._onBtnYes), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnNo, handler(self, self._onBtnNo), ccui.TouchEventType.ended)
end

-- function UIAgreementOnLogin:_update(dt)
-- 	self._last = self._last + dt
-- 	if self._last > 0.05 then
-- 		self._last = 0
-- 		local height = self._text:getContentSize().height
-- 		local maxHeight = self._node:getContentSize().height
-- 		local maxNum = #self._textSeq

-- 		local perMove = 1
-- 		local y = 0
-- 		-- 向上移动
-- 		for i,v in ipairs(self._textSeq) do
-- 			y = v:getPositionY()
-- 			y = y + perMove
-- 			if y > maxHeight then
-- 				y = y -(height+5)*maxNum
-- 			end
-- 			v:setPositionY(y)
-- 		end
-- 	end
-- end

function UIAgreementOnLogin:needBlackMask()
    return true
end

function UIAgreementOnLogin:closeWhenClickMask()
	return false
end

function UIAgreementOnLogin:onShow()
	local t = cc.FileUtils:getInstance():getStringFromFile(config.GlobalConfig.getConfig().LICENCE_PATH)
	self._licence = loadstring(t)()
	self:_startShow()
end

function UIAgreementOnLogin:onHide()
	self:dispose()
end

function UIAgreementOnLogin:_startShow()
	self._stepScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._showUpdate), 0, false)

	self._infoPanel:setPosition(0, self._scrollViewSize.height)
	self._scrollView:setInnerContainerSize(self._scrollViewSize)
	self._scrollView:scrollToPercentVertical(0, 0, false)
end

function UIAgreementOnLogin:_showUpdate()
	self._step = self._step + 1
	if self._step > #self._licence then
		self:_stopShowUpdate()
		return
	end

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

function UIAgreementOnLogin:_stopShowUpdate()
	if self._stepScheduler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._stepScheduler)
		self._stepScheduler = nil
	end
end

function UIAgreementOnLogin:_createLabel(text, color, fontSize, center)
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

function UIAgreementOnLogin:_onCloseButton()
	self:_onAgreementChanged(false)
end

function UIAgreementOnLogin:_onBtnYes()
	self:_onAgreementChanged(true)
end

function UIAgreementOnLogin:_onBtnNo()
	self:_onAgreementChanged(false)
end

function UIAgreementOnLogin:_onAgreementChanged(is)
	self:_stopShowUpdate()
	game.service.LoginService:getInstance():saveAcceptAgreement(is)
	game.service.LoginService.getInstance():dispatchEvent({ name = "EVENT_AGREEMENT_CHANGED", agreement = is});
	UIManager.getInstance():destroy("UIAgreementOnLogin")
end

return UIAgreementOnLogin
