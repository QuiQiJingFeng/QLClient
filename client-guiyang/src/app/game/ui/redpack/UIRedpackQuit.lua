-- local csbPath = "ui/csb/Redpack/UIRedpackQuit.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackQuit.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackQuit= class("UIRedpackQuit",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackQuit:ctor()
end


function UIRedpackQuit:init()
	self._btnQuit = seekNodeByName(self, "Button_Quit", "ccui.Button")	--关闭
	self._btnContinue = seekNodeByName(self, "Button_Continue", "ccui.Button")	--继续

	self._imgs = {}
	for i =1,4 do
		self._imgs[i] = seekNodeByName(self, "Image_z"..i, "ccui.ImageView")
	end
end

function UIRedpackQuit:_registerCallBack()

	bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuit), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnContinue, handler(self, self._onBtnContinue), ccui.TouchEventType.ended)
end

function UIRedpackQuit:needBlackMask()
    return true
end

function UIRedpackQuit:closeWhenClickMask()
	return false
end
function UIRedpackQuit:onShow(parent)
	self._parent = parent
	self:_registerCallBack()

	local n = math.ceil(4 * math.random())
	for i = 1,4 do
		self._imgs[i]:setVisible(i == n)
	end
end

--关闭
function UIRedpackQuit:_onBtnQuit()
	UIManager:getInstance():hide("UIRedpackQuit")
	self._parent:doHide()
end

--规则
function UIRedpackQuit:_onBtnContinue()
	UIManager:getInstance():hide("UIRedpackQuit")
end

return UIRedpackQuit
