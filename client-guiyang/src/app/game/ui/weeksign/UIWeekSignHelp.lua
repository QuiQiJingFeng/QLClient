local super = require("app.game.ui.UITurnCardHelp")
local UIWeekSignHelp= class("UIWeekSignHelp",super)


function UIWeekSignHelp:ctor()
end


function UIWeekSignHelp:onShow()
	local str = config.WeekSignConfig.rule
	self._textRull:setString(str)

	self._textRull:setTextAreaSize(cc.size(self._textRull:getContentSize().width, 0))

	local size = self._textRull:getVirtualRendererSize()
	self._textRull:setContentSize(size)
	if size.height < self._scroll:getContentSize().height then
		size.height = self._scroll:getContentSize().height
	end
	self._scroll:setInnerContainerSize(size)
	self._textRull:setPositionY(size.height)
end

--关闭
function UIWeekSignHelp:_onClickClose()
	UIManager:getInstance():hide("UIWeekSignHelp")
end

return UIWeekSignHelp
