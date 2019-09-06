local csbPath = "ui/csb/Choujiang/UIYaoJiang.csb"
local super = require("app.game.ui.UITurnCardHelp")
local UILuckyDrawHelp= class("UILuckyDrawHelp",super)


function UILuckyDrawHelp:ctor()
end


function UILuckyDrawHelp:onShow()
	local str = config.LuckyDrawConfig.rule
	self._textRull:setString(str)

	self._textRull:setTextAreaSize(cc.size(self._textRull:getContentSize().width, 0))

	local size = self._textRull:getVirtualRendererSize()
	self._textRull:setContentSize(size)
	if size.height < self._scroll:getContentSize().height then
		size.height = self._scroll:getContentSize().height
	end
	self._scroll:setInnerContainerSize(size)
	self._textRull:setPositionY(size.height)

	self._textTitle:setString("玩法说明")
end

--关闭
function UILuckyDrawHelp:_onClickClose()
	UIManager:getInstance():hide("UILuckyDrawHelp")
end

return UILuckyDrawHelp
