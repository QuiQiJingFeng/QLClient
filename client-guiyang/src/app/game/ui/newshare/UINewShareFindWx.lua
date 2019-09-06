local csbPath = "ui/csb/Newshare/UIShareFindWx.csb"

local UINewShareFindWx= class("UINewShareFindWx",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UINewShareFindWx:ctor()
end


function UINewShareFindWx:init()

	self._imageItem = seekNodeByName(self, "Image_1", "ccui.ImageView")
	self._imageItem:ignoreContentAdaptWithSize(true)
	self._textItem = seekNodeByName(self, "Text_1", "ccui.Text")
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")	--关闭
	self._btnLeft = seekNodeByName(self, "Button_left", "ccui.Button")
	self._btnRight = seekNodeByName(self, "Button_right", "ccui.Button")
	self:_registerCallBack()
end

function UINewShareFindWx:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnLeft, handler(self, self._onClickLeft), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRight, handler(self, self._onClickRight), ccui.TouchEventType.ended)	
end

function UINewShareFindWx:needBlackMask()
    return true
end

function UINewShareFindWx:closeWhenClickMask()
	return false
end

function UINewShareFindWx:onShow()
	self._curStep = 1
	self:_updateStep()
end

function UINewShareFindWx:_onClickLeft()
	self._curStep = self._curStep>1 and self._curStep-1 or self._curStep
	self:_updateStep()
end

function UINewShareFindWx:_onClickRight()
	self._curStep = self._curStep<3 and self._curStep+1 or self._curStep
	self:_updateStep()
end

function UINewShareFindWx:_updateStep()
	local guideInfo = config.NewShareConfig.findWxGuide[self._curStep]
	self._textItem:setString(guideInfo[1])
	self._imageItem:loadTexture(guideInfo[2])
	self._btnLeft:setVisible(self._curStep ~= 1)
	self._btnRight:setVisible(self._curStep ~= 3)
end

--关闭
function UINewShareFindWx:_onClickClose()
	UIManager:getInstance():hide("UINewShareFindWx")
end

-- 由于俱乐部自建赛要调用这个分享接口。。需要把层级提高
function UINewShareFindWx:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UINewShareFindWx
