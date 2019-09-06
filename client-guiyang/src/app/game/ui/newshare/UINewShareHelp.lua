local super = require("app.game.ui.UITurnCardHelp")
local UINewShareHelp= class("UINewShareHelp",super)


function UINewShareHelp:ctor()
end


function UINewShareHelp:onShow()
	local str = config.NewShareConfig.rule
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
function UINewShareHelp:_onClickClose()
	UIManager:getInstance():hide("UINewShareHelp")
end

return UINewShareHelp
