local csbPath = "ui/csb/UIGxgonggao.csb"
local super = require("app.game.ui.UIBase")

local UIUpdateBS = class("UIUpdateBS", super, function () return kod.LoadCSBNode(csbPath) end)

function UIUpdateBS:ctor()
	self._notice     = nil   -- 公告内容
	self._update1    = nil   -- 更新按钮
	self._update2    = nil   -- 用于安卓手机非强更显示（左边按钮）
	self._nextUpdate = nil   -- 下次更新按钮
	self._protocol = nil
	self._onCancelCallBack = nil
	self._onOkCallBack = nil
end

function UIUpdateBS:init()
	self._notice        = seekNodeByName(self, "Text_content_gxgg",  "ccui.Text")
	self._update1       = seekNodeByName(self, "Button_1_gxgg",      "ccui.Button")
	self._update2       = seekNodeByName(self, "Button_3_gxgg",      "ccui.Button")
	self._nextUpdate    = seekNodeByName(self, "Button_2_gxgg",      "ccui.Button")

	bindEventCallBack(self._update1,    handler(self, self._onUpdate),     ccui.TouchEventType.ended)
	bindEventCallBack(self._update2,    handler(self, self._onUpdate),     ccui.TouchEventType.ended)
	bindEventCallBack(self._nextUpdate, handler(self, self._onNextUpdate), ccui.TouchEventType.ended)
end

--[[
参数列表：（args）
	公告内容
	设备(ios、android)
	立即更新回调
	下次更新回调（强更不会传）
--]] 
function UIUpdateBS:onShow(...)
	local args = {...}
	self._notice:setString(args[1])
	local _size = self._notice:getContentSize()
	self._notice:setTextAreaSize(_size)

	if #args == 3 then
		self._onCancelCallBack = args[3]
		self:_setVisible(false)
	elseif #args == 4 then
		self._onCancelCallBack = args[3]
		self._onOkCallBack = args[4]
		self:_setVisible(true)
	end

end

function UIUpdateBS:_setVisible(tf)
	self._update1:setVisible(tf)
	self._update2:setVisible(not tf)
	self._nextUpdate:setVisible(tf)
end

-- 立即更新
function UIUpdateBS:_onUpdate(sender)
	-- 只统计不强更的
	if sender:getName() == "Button_1_gxgg" then
		-- 统计立即更新的次数
		game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.the_button_of_update_now)
	end

	if nil ~= self._onCancelCallBack and "function" == type(self._onCancelCallBack) then
		if self:_onCancelCallBack() == false then
			return
		end
	end

	UIManager:getInstance():hide("UIUpdateBS");
end

-- 下次更新
function UIUpdateBS:_onNextUpdate(sender)
	-- 统计下次更新的次数
	game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.the_button_of_update_later)

	if nil ~= self._onOkCallBack and "function" == type(self._onOkCallBack) then
		if self:_onOkCallBack() == false then
			return
		end
	end

	UIManager:getInstance():hide("UIUpdateBS");
end

function UIUpdateBS:needBlackMask()
	return true
end

function UIUpdateBS:closeWhenClickMask()
	return false
end

return UIUpdateBS