local csbPath = "ui/csb/UIShare.csb"
local super = require("app.game.ui.UIBase")

--[[	这个ui是临时的，之后加入钉钉分享后重新弄一个动态放置按钮位置的ui
	所以注释什么的自己领悟吧
]]
local UIShareWTF = class("UIShareWTF", super, function() return kod.LoadCSBNode(csbPath) end)

function UIShareWTF:ctor()
	self._btnClose = nil
end

function UIShareWTF:init()
	self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
	self._btn_FRIENDS = seekNodeByName(self, "Button_Friends", "ccui.Button")
	self._btn_MOMENTS = seekNodeByName(self, "Button_Circle", "ccui.Button")
	self._btn_DINGFING = seekNodeByName(self, "Button_Ding", "ccui.Button")
	
	self._btn_DINGFING:setVisible(false)
	self._btn_FRIENDS:setVisible(false)
	self._btn_MOMENTS:setVisible(false)
	
	self._btnMap = {
		SYSTEM = self._btn_FRIENDS,
		DINGDING = self._btn_DINGFING,
		FRIENDS = self._btn_FRIENDS,
		MOMENTS = self._btn_MOMENTS,
	}
	
	self._callBacks = {}
	self:_registerCallBack()
end

function UIShareWTF:_registerCallBack()
	bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_FRIENDS,	handler(self, self._onClickBtn), ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_MOMENTS,	handler(self, self._onClickBtn), ccui.TouchEventType.ended);
	bindEventCallBack(self._btn_DINGFING,	handler(self, self._onClickBtn), ccui.TouchEventType.ended);
	
end

--[[	参数类型:
	1.入口
	2.行为配置
	3.分享回调(目前只有两个,默认右边是朋友圈或者钉钉)
	4.最终回调
]]
function UIShareWTF:onShow(...)
	local args = {...};
	self._enter = args[1]
	self._behaviors = args[2]
	self._funcs = args[3] -- 理论上跟behavior一样多
	self._finalCallback = args[4]
	self._callBacks = {}
	for i, b in ipairs(self._behaviors) do
		local channel = self:getChannel(b)
		self._btnMap[channel]:setVisible(true)
		self._callBacks[self._btnMap[channel]] = self._funcs[i]
	end

	self:playAnimation_Scale()
end

--[[    @desc: 获取这个行为的channel
    author:{author}
    time:2018-05-24 14:02:04
    --@behavior: 行为配置
    return
]]
function UIShareWTF:getChannel(behavior)
	local list = string.split(behavior, "|||")
	local channel = list[1]
	
	return channel
end

function UIShareWTF:needBlackMask()
	return true;
end

function UIShareWTF:closeWhenClickMask()
	return true
end

function UIShareWTF:_close()
	self._finalCallback = nil
	UIManager:getInstance():destroy("UIShareWTF")
end

function UIShareWTF:_onClose(...)
	self:_close()
end


function UIShareWTF:_doFinalCallback()
	if self._finalCallback ~= nil then
		self._finalCallback()
	end
end

function UIShareWTF:_onClickBtn(sender)
	if self._callBacks[sender] ~= nil then
		self._callBacks[sender]()
	end
	
	self:_doFinalCallback()
	self:_close()
end

function UIShareWTF:needBlackMask()
	return true
end

function UIShareWTF:closeWhenClickMask()
	return false
end

-- 由于俱乐部自建赛要调用这个分享接口。。需要把层级提高
function UIShareWTF:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIShareWTF 