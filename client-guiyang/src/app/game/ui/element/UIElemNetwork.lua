--[[
����״̬��ʾ
--]]
local UIElemNetwork = class("UIElemNetwork")

function UIElemNetwork:ctor(uiParent)
	self._noPanel = seekNodeByName(uiParent, "Panel_NO", "ccui.ImageView")
	self._4GPanel = seekNodeByName(uiParent, "Panel_4G", "ccui.ImageView")
	self._wifiPanel = seekNodeByName(uiParent, "Panel_wiff", "ccui.Layout")
	-- self._wifiFlag = {}
	-- table.insert(self._wifiFlag, seekNodeByName(uiParent, "Image_wiff1", "ccui.ImageView"))
	-- table.insert(self._wifiFlag, seekNodeByName(uiParent, "Image_wiff2", "ccui.ImageView"))
	-- table.insert(self._wifiFlag, seekNodeByName(uiParent, "Image_wiff3", "ccui.ImageView"))
	self._updateTask = nil
	
	self:_updateWifi();
	self._updateTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self._updateWifi), 1, false)
end

function UIElemNetwork:dispose()
	-- 关闭计时器
    if self._updateTask ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTask);
        self._updateTask = nil;
    end
end

function UIElemNetwork:_updateWifi()
	self._noPanel:setVisible(false)
	if  game.service.ConnectionService.getInstance():getReachabilityStatus()== net.NetworkStatus.NotReachable then
		self._noPanel:setVisible(true)
	elseif game.service.ConnectionService.getInstance():getReachabilityStatus() == net.NetworkStatus.ReachableViaWiFi then
		self._wifiPanel:setVisible(true)
		self._4GPanel:setVisible(false)
	elseif game.service.ConnectionService.getInstance():getReachabilityStatus() == net.NetworkStatus.ReachableViaWWAN then
		self._wifiPanel:setVisible(false)
		self._4GPanel:setVisible(true)
	end
end

return UIElemNetwork
