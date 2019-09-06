local csbPath = "ui/csb/UIFPyj4.csb"

local UITurnCardHelp= class("UITurnCardHelp",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UITurnCardHelp:ctor()
	self._cards = {}
end

function UITurnCardHelp:dispose()
	self:_stopShowUpdate()
end

function UITurnCardHelp:init()
	self._textRull = seekNodeByName(self, "Text_9", "ccui.Text")

	--确定
	self._btnConfirm = seekNodeByName(self, "Button_qd2_messagebox", "ccui.Button")

	--关闭
	self._btnClose = seekNodeByName(self, "Button_1", "ccui.Button")

	self._scroll = seekNodeByName(self, "ScrollView_1", "ccui.ScrollView")
	self._scroll:setScrollBarEnabled(false)

	self._textTitle = seekNodeByName(self, "BitmapFontLabel_ts", "ccui.TextBMFont")

	self:_registerCallBack()
end

function UITurnCardHelp:_registerCallBack()
	bindEventCallBack(self._btnConfirm, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UITurnCardHelp:needBlackMask()
    return true
end

function UITurnCardHelp:closeWhenClickMask()
	return true
end

function UITurnCardHelp:onShow(str)
	self._textRull:setString(str)

	self._textRull:setTextAreaSize(cc.size(self._textRull:getContentSize().width, 0))

	local size = self._textRull:getVirtualRendererSize()
	if size.height < self._scroll:getContentSize().height then
		size.height = self._scroll:getContentSize().height
	end
	self._textRull:setContentSize(size)
	self._scroll:setInnerContainerSize(size)
	self._textRull:setPositionY(size.height)
end

--关闭
function UITurnCardHelp:_onClickClose()
	UIManager:getInstance():hide("UITurnCardHelp")
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UITurnCardHelp:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UITurnCardHelp
