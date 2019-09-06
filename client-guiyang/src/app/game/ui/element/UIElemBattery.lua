--[[
电量显示
--]]
local UIBattery = class("UIBattery")

function UIBattery:ctor(uiParent)
	--电池
	self._battery = seekNodeByName(uiParent, "Icon_Electricity0_Scene", "ccui.ImageView")
	--电量
	self._electricity = seekNodeByName(uiParent, "Icon_Electricity1_Scene", "ccui.ImageView")
	self._updateTask = nil
	
	self:_updateLevel();
	self._updateTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateLevel), 10, false)
end

function UIBattery:dispose()
	-- 关闭计时器
    if self._updateTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTask);
        self._updateTask = nil;
    end
end

function UIBattery:_updateLevel()
	local batteryLevel = game.plugin.Runtime.getBatteryLevel()
	self._electricity:setScaleX(batteryLevel/100)
	if batteryLevel > 20 then
		self._battery:setColor(cc.c3b(255,255,255))
		self._electricity:setColor(cc.c3b(255,255,255))
	elseif batteryLevel <= 20 then
		self._battery:setColor(cc.c3b(255,0,0))
		self._electricity:setColor(cc.c3b(255,0,0))
	end
end

return UIBattery