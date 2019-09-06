local csbPath = "ui/csb/Newshare/UIShareFindWx02.csb"

local UIShareFindWx= class("UIShareFindWx",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIShareFindWx:ctor()
end


function UIShareFindWx:init()

	self._imageItem = seekNodeByName(self, "Image_help", "ccui.ImageView")
	self._imageItem:ignoreContentAdaptWithSize(true)
	self._textItem = seekNodeByName(self, "Text_1", "ccui.Text")
	self._btnClose = seekNodeByName(self, "Button_x_CouponZD", "ccui.Button")	--关闭
	self._btnLeft = seekNodeByName(self, "Button_left", "ccui.Button")
	self._btnRight = seekNodeByName(self, "Button_right", "ccui.Button")
	self._btnShare = seekNodeByName(self, "Button_share", "ccui.Button")
	self._boxNoMore = seekNodeByName(self, "CheckBox_noMore", "ccui.CheckBox")
	self:_registerCallBack()
end

function UIShareFindWx:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnLeft, handler(self, self._onClickLeft), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRight, handler(self, self._onClickRight), ccui.TouchEventType.ended)	
	bindEventCallBack(self._boxNoMore, handler(self, self._onClickNoMore), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnShare, handler(self, self._onClickShare), ccui.TouchEventType.ended)
end

function UIShareFindWx:needBlackMask()
    return true
end

function UIShareFindWx:closeWhenClickMask()
	return false
end

function UIShareFindWx:onShow(shareFunc)
	self._shareFunc = shareFunc
	self._curStep = 1
	if device.platform == 'android' then
		self._guideInfo = share.constants.imgHelp.android
	else
		self._guideInfo = share.constants.imgHelp.ios
	end
	self:_updateStep()
end

function UIShareFindWx:_onClickLeft()
	self._curStep = self._curStep>1 and self._curStep-1 or self._curStep
	self:_updateStep()
end

function UIShareFindWx:_onClickRight()
	self._curStep = self._curStep<3 and self._curStep+1 or self._curStep
	self:_updateStep()
end

function UIShareFindWx:_updateStep()
	
	self._imageItem:loadTexture(self._guideInfo[self._curStep])
	self._btnLeft:setVisible(self._curStep ~= 1)
	self._btnRight:setVisible(self._curStep ~= #self._guideInfo)
end

--关闭
function UIShareFindWx:_onClickClose()
	UIManager:getInstance():hide("UIShareFindWx")
end

-- 由于俱乐部自建赛要调用这个分享接口。。需要把层级提高
function UIShareFindWx:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

function UIShareFindWx:_onClickNoMore()
	cc.UserDefault:getInstance():setBoolForKey(share.constants.HELP_KEY, not self._boxNoMore:isSelected())
	cc.UserDefault:getInstance():flush()
end
function UIShareFindWx:_onClickShare()
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Continue_Share);
	UIManager:getInstance():hide("UIShareFindWx")
	self._shareFunc()
end

function UIShareFindWx:onHide()
	if self._boxNoMore:isSelected() then
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.NoMore_Notice);
	end
end
return UIShareFindWx
