--[[
时间显示
--]]
local UIElemTime = class("UIElemTime")

function UIElemTime:ctor(uiParent)
	self._lableTime = seekNodeByName(uiParent, "Text_time_Scene", "ccui.Text");	
	self._updateTask = nil

	self:_updateTime();
	
	-- 开始显示时间	
	self._updateTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateTime), 1, false)
end

function UIElemTime:dispose()
	-- 关闭计时器
    if self._updateTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTask);
        self._updateTask = nil;
    end
end

function UIElemTime:_updateTime()
	self._lableTime:setString(os.date("%H:%M"));
end

return UIElemTime