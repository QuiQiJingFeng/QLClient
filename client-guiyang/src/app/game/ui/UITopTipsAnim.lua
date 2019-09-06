local csbPath = "ui/csb/Campaign/UITopTipsAnim.csb"
local super = require("app.game.ui.UIBase")

local UITopTipsAnim = class("UITopTipsAnim", super, function () return kod.LoadCSBNode(csbPath) end)

function UITopTipsAnim:ctor()
	self._textMessageTips = nil;
	self._timerTask = nil
end

function UITopTipsAnim:init()
	self._textMessageTips  = seekNodeByName(self, "Text_1",  "ccui.Text");
end

function UITopTipsAnim:onShow(...)
	local args = {...};

	if args[1] ~= nil then
		self._textMessageTips:setString(args[1]);
	end
	
	if self._animAction ~= nil then
		self._animAction:stop()
	end
	self._animAction = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._animAction)
	self._animAction:play("animation0",false)
	
	-- 先解除注册
    if self._timerTask ~= nil then
        unscheduleOnce(self._timerTask);
        self._timerTask = nil;
	end
	self._timerTask = scheduleOnce(function() self:hide() end, 6)
end

function UITopTipsAnim:onHide()
	-- 关闭计时器
	if self._timerTask ~= nil then
		unscheduleOnce(self._timerTask);
		self._timerTask = nil;
	end
end

function UITopTipsAnim:needBlackMask()
	return false;
end

function UITopTipsAnim:closeWhenClickMask()
	return false
end

function UITopTipsAnim:_hide()
	UIManager:getInstance():hide("UITopTipsAnim")
end
return UITopTipsAnim