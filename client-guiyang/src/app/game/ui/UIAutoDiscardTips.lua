local csbPath = "ui/csb/ui_component/UIAutoDiscardTips.csb"
local super = require("app.game.ui.UIBase")

local UIAutoDiscardTips = class("UIAutoDiscardTips", super, function () return kod.LoadCSBNode(csbPath) end)

function UIAutoDiscardTips:ctor()
	self._animPanel = nil;
	self._timerTask = nil
end

function UIAutoDiscardTips:init()
    self._animPanel  = seekNodeByName(self, "Panel_AutoDiscard",  "ccui.Layout");
    
end

function UIAutoDiscardTips:onShow(...)
    local args = {...};
    -- 关闭计时器
	if self._timerTask ~= nil then
		unscheduleOnce(self._timerTask);
		self._timerTask = nil;
    end

	if self._animAction ~= nil then
		self._animAction:stop()
    end
    self._animAction = nil
    game.service.RoomService.getInstance():addEventListener("HIDE_AUTO_DISCARD_TIPS",    handler(self, self._hide), self)    

	self._animAction = cc.CSLoader:createTimeline(csbPath)
    self:runAction(self._animAction)
	self._animAction:play("animation0",false)
end

function UIAutoDiscardTips:onHide()
	-- 关闭计时器
	if self._timerTask ~= nil then
		unscheduleOnce(self._timerTask);
		self._timerTask = nil;
    end
    game.service.RoomService.getInstance():removeEventListenersByTag(self)
end

function UIAutoDiscardTips:getAnimTime(timeline)
    local speed = timeline:getTimeSpeed()
    local startFrame = timeline:getStartFrame()
    local endFrame = timeline:getEndFrame()
    local frameNum = endFrame - startFrame

    return 1.0 /(speed * 60.0) * frameNum
end

function UIAutoDiscardTips:needBlackMask()
	return false;
end

function UIAutoDiscardTips:closeWhenClickMask()
	return false
end

function UIAutoDiscardTips:_hide()
    -- self._animAction:play("animation1",false)
    -- local time = self:getAnimTime(self._animAction)

    -- self._timerTask = scheduleOnce(function ()
        UIManager:getInstance():hide("UIAutoDiscardTips")        
    -- end,time)
end
return UIAutoDiscardTips