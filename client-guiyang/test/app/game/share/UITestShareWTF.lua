local csbPath = "ui/csb/UIShare1.csb"
local super = require("app.game.ui.UIBase")

--[[
	这个ui是临时的，之后加入钉钉分享后重新弄一个动态放置按钮位置的ui
	所以注释什么的自己领悟吧
]]
local UITestShareWTF = class("UITestShareWTF", super, function () return kod.LoadCSBNode(csbPath) end)

function UITestShareWTF:ctor()
	self._btnClose = nil
end

function UITestShareWTF:init()
	self._btnClose   = seekNodeByName(self,"Button_Close",   "ccui.Button")
	self._btn_1 = seekNodeByName(self,"Button_Friends", "ccui.Button")
	self._btn_2  = seekNodeByName(self,"Button_Circle",  "ccui.Button")
	self._btn_3  = seekNodeByName(self,"Button_Sys", 	 "ccui.Button")
	self._btn_System_help  = seekNodeByName(self,"Button_System_help", 	 "ccui.Button")
	self._btn_System_help_close  = seekNodeByName(self,"Button_System_help_close", 	 "ccui.Button")

	self._panel_System_help = seekNodeByName(self,"Panel_System_help", 	 "ccui.Layout")

	self._btn_1:setVisible(false)
	self._btn_2:setVisible(false)
	self._btn_3:setVisible(false)

	self._panel_System_help:setVisible(false)

	self:_registerCallBack()
end

function UITestShareWTF:_registerCallBack()
	bindEventCallBack(self._btnClose,   handler(self, self._onClose),ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_1,       handler(self, self._onClickBtn_1),ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_2,       handler(self, self._onClickBtn_2),ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_3,       handler(self, self._onClickBtn_3),ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_System_help,       handler(self, self._onClickBtn_SystemHelp),ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_System_help_close,       handler(self, self._onClickBtn_SystemHelpClose),ccui.TouchEventType.ended);
end

--[[
	参数类型:
	1.入口
	2.行为配置
	3.分享回调
	4.最终回调
]]
function UITestShareWTF:onShow(...)
	local args = {...};
	self._enter = args[1]
	self._behaviors = args[2]
	self._funcs = args[3] -- 理论上跟behavior一样多
	self._finalCallback = args[4]

	for i, b in ipairs(self._behaviors) do
		local channel = self:getChannel(b)
		self["_btn_"..i]:setVisible(true)
		self["_setCallback_"..i](self, self._funcs[i]);
	end
end

--[[
    @desc: 获取这个行为的channel
    author:{author}
    time:2018-05-24 14:02:04
    --@behavior: 行为配置
    return
]]
function UITestShareWTF:getChannel( behavior )
    local list = string.split(behavior, "|||")
	local channel = list[1]
	
	return channel
end

function UITestShareWTF:needBlackMask()
	return true;
end

function UITestShareWTF:closeWhenClickMask()
	return true
end

function UITestShareWTF:_onClose(...)
	self._firends_callback = nil
	self._MOMENTS_callback = nil
	self._system_callback = nil
	self._finalCallback = nil
	UIManager:getInstance():destroy("UITestShareWTF")
end

function UITestShareWTF:_onClickBtn_SystemHelp()
	self._panel_System_help:setVisible(true)
end

function UITestShareWTF:_onClickBtn_SystemHelpClose()
	self._panel_System_help:setVisible(false)
end

function UITestShareWTF:_setCallback_1( cb )
	self._firends_callback = cb
end

function UITestShareWTF:_setCallback_2( cb )
	self._MOMENTS_callback = cb
end

function UITestShareWTF:_setCallback_3( cb )
	self._system_callback = cb
end

function UITestShareWTF:_doFinalCallback(  )
	if self._finalCallback ~= nil then
		self._finalCallback()
	end
end

function UITestShareWTF:_onClickBtn_1()
	if self._firends_callback ~= nil then
		self._firends_callback()
	end

	self:_doFinalCallback()
end

function UITestShareWTF:_onClickBtn_2()
	if self._MOMENTS_callback ~= nil then
		self._MOMENTS_callback()
	end

	self:_doFinalCallback()
end

function UITestShareWTF:_onClickBtn_3()
	if self._system_callback ~= nil then
		self._system_callback()
	end

	self:_doFinalCallback()
end

return UITestShareWTF