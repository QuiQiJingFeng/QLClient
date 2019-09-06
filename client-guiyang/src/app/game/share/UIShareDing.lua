local csbPath = "ui/csb/UIShare3.csb"
local super = require("app.game.ui.UIBase")

--[[	这个ui是临时的，之后加入钉钉分享后重新弄一个动态放置按钮位置的ui
	所以注释什么的自己领悟吧
]]
local UIShareDing = class("UIShareDing", super, function() return kod.LoadCSBNode(csbPath) end)

function UIShareDing:ctor()
	self._btnClose = nil
end

function UIShareDing:init()
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btn_FRIENDS = seekNodeByName(self, "Button_Friends", "ccui.Button")
	self._btn_DINGDING = seekNodeByName(self, "Button_DINGDING", "ccui.Button")
	
	self._btn_System_help = seekNodeByName(self, "Button_System_help",	"ccui.Button")
	self._panel_System_Help = seekNodeByName(self, "Panel_System_help",	"ccui.Layout")
	self._button_Help_Close = seekNodeByName(self, "Button_System_help_close", "ccui.Button")
	
	self._btn_FRIENDS:setVisible(false)
	self._btn_DINGDING:setVisible(false)
	
	self._panel_System_Help:setVisible(false)
	self._btn_System_help:setVisible(device.platform == "ios" or device.platform == "windows") -- 只针对iOS才显示
	
	self:_changeBtnStyle()
	self:_registerCallBack()
end

local btnStyle = {
	more = "art/img/Btn_wx2.png",
	wx = "art/img/Btn_wx.png",
}

function UIShareDing:_changeBtnStyle()
	local flag = game.service.GlobalSetting.enableMoreShare
	local skin = flag and btnStyle.more or btnStyle.wx
	
	self._btn_FRIENDS:loadTextures(skin, skin, skin)
end

function UIShareDing:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_FRIENDS,	handler(self, self._onClickBtn_FRIENDS), ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_DINGDING,	handler(self, self._onClickBtn_DINGDING), ccui.TouchEventType.ended);
	
	bindEventCallBack(self._btn_System_help,	handler(self, self._onClickBtn_SystemHelp), ccui.TouchEventType.ended);
	bindEventCallBack(self._button_Help_Close, handler(self, self._onClickBtn_SystemHelpClose), ccui.TouchEventType.ended);
end

--[[	参数类型:
	1.入口
	2.行为配置
	3.分享回调
	4.最终回调
]]
function UIShareDing:onShow(...)
	local args = {...};
	self._enter = args[1]
	self._behaviors = args[2]
	self._funcs = args[3] -- 理论上跟behavior一样多
	self._finalCallback = args[4]
	
	for i, b in ipairs(self._behaviors) do
		local channel = self:getChannel(b)
		if self["_btn_" .. channel] ~= nil then
			self["_btn_" .. channel]:setVisible(true)
			self["_setCallback_" .. channel](self, self._funcs[i]);
		end
	end
end

--[[    @desc: 获取这个行为的channel
    author:{author}
    time:2018-05-24 14:02:04
    --@behavior: 行为配置
    return
]]
function UIShareDing:getChannel(behavior)
	local list = string.split(behavior, "|||")
	local channel = list[1]
	
	return channel
end

function UIShareDing:needBlackMask()
	return true;
end

function UIShareDing:closeWhenClickMask()
	return true
end

function UIShareDing:_close()
	self._friends_callback = nil
	self._DINGDING_callback = nil
	self._system_callback = nil
	self._finalCallback = nil
	UIManager:getInstance():destroy("UIShareWTF")
end

function UIShareDing:_close()
	self._friends_callback = nil
	self._MOMENTS_callback = nil
	self._system_callback = nil
	self._finalCallback = nil
	UIManager:getInstance():destroy("UIShareDing")
end

function UIShareDing:_onClose(...)
	self:_close()
end

function UIShareDing:_onClickBtn_SystemHelp()
	self._panel_System_Help:setVisible(true)
end

function UIShareDing:_onClickBtn_SystemHelpClose()
	self._panel_System_Help:setVisible(false)
end


function UIShareDing:_setCallback_FRIENDS(cb)
	self._friends_callback = cb
end

function UIShareDing:_setCallback_DINGDING(cb)
	self._DINGDING_callback = cb
end

function UIShareDing:_doFinalCallback(channel)
	if self._finalCallback ~= nil then
		self._finalCallback()
	end
	channel = channel or "SYSTEM"
	game.service.DataEyeService.getInstance():onEvent(self._enter .. "_to_" .. channel);
end

function UIShareDing:_onClickBtn_FRIENDS()
	if self._friends_callback ~= nil then
		self._friends_callback()
	end
	
	self:_doFinalCallback(share.constants.CHANNEL.FRIENDS)
	self:_close()
end

function UIShareDing:_onClickBtn_DINGDING()
	
	if self._DINGDING_callback ~= nil then
		self._DINGDING_callback()
	end
	
	self:_doFinalCallback(share.constants.CHANNEL.DINGDING)
	self:_close()
end


function UIShareDing:needBlackMask()
	return true
end

function UIShareDing:closeWhenClickMask()
	return false
end

-- 由于俱乐部自建赛要调用这个分享接口。。需要把层级提高
function UIShareDing:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIShareDing 