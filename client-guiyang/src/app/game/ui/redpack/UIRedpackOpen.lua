-- local csbPath = "ui/csb/Redpack/UIRedpackOpen.csb"
local csbPath = "ui/csb/RedPackNew/UIRedpackOpen.csb"
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local UIRedpackOpen= class("UIRedpackOpen",  require("app.game.ui.UIBase"), function()
	return kod.LoadCSBNode(csbPath)
end)


function UIRedpackOpen:ctor()
end


function UIRedpackOpen:init()

	self._btnRule = seekNodeByName(self, "Button_rule", "ccui.Button")	--关闭
	self._btnMyPackage = seekNodeByName(self, "Button_MyPackage", "ccui.Button")	--关闭
	self._btnClose = seekNodeByName(self, "Button_X", "ccui.Button")	--关闭
	self._btnOpen = seekNodeByName(self, "Button_Open", "ccui.Button")	--开启红包

	self._imageNums = seekNodeByName(self, "Image_2", "ccui.ImageView")
	self._imageNums:setVisible(false)

	self._layoutMarquee = seekNodeByName(self, "Panel_Marquee", "ccui.Layout")
	self._layoutSingleMarquee = seekNodeByName(self, "Panel_SingleMarquee", "ccui.Layout")
	self:_updateMarquee()
end

function UIRedpackOpen:_registerCallBack()

	bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnMyPackage, handler(self, self._onClickMyPackage), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnRule, handler(self, self._onClickRule), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnOpen, handler(self, self._onClickOpen), ccui.TouchEventType.ended)
end

function UIRedpackOpen:needBlackMask()
    return true
end

function UIRedpackOpen:closeWhenClickMask()
	return false
end
function UIRedpackOpen:onShow()	
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):addEventListener("EVENT_OPEN_REDPACKAGE", handler(self, self._onRedPackDetail), self)

	self:_registerCallBack()
	
end
function UIRedpackOpen:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):removeEventListenersByTag(self)
end

function UIRedpackOpen:doHide()
	UIManager:getInstance():hide("UIRedpackOpen")
end
--拆红包返回
function UIRedpackOpen:_onRedPackDetail()
	UIManager:getInstance():hide("UIRedpackOpen")
	UIManager:getInstance():show("UIRedpackDetail")
end
--关闭
function UIRedpackOpen:_onClickClose()
	UIManager:getInstance():show("UIRedpackQuit", self)
end

--开启
function UIRedpackOpen:_onClickOpen()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.RED_PACK):queryOpenRedPackage(1)
end

function UIRedpackOpen:_onClickRule()
	UIManager:getInstance():show("UIRedpackHelp")
end

function UIRedpackOpen:_onClickMyPackage()
	UIManager:getInstance():show("UIRedpackMine")
end

function UIRedpackOpen:_updateMarquee()
	local function createOneLED(parent)
		local text2 = seekNodeByName(self, "Text_Marquee2", "ccui.Text")
		local text3 = seekNodeByName(self, "Text_Marquee3", "ccui.Text")
		local textName = parent:getChildByName("Text_MarqueeName")
		textName:setString(config.TurnCardConfig.getOneName())
		local textMoney = parent:getChildByName("Text_MarqueeMoney")
		local money = 15 + 3 * math.random()
		textMoney:setString(string.format("%.2f", money))

		text2:setPositionX(textName:getPositionX() + textName:getVirtualRendererSize().width + 10)
		textMoney:setPositionX(text2:getPositionX() + text2:getVirtualRendererSize().width + 10)
		text3:setPositionX(textMoney:getPositionX() + textMoney:getVirtualRendererSize().width + 10)
	end


	self._layoutMarquee:setClippingEnabled(true)
	local act1 = cc.CallFunc:create(function()
		-- self._textLED:setString(game.service.TurnCardService:getInstance():getPrizeStr() or config.TurnCardConfig.getPrizeStr())
		createOneLED(self._layoutSingleMarquee)
		self._layoutSingleMarquee:setPositionX(self._layoutMarquee:getContentSize().width)
		end
		)
	local act2 = cc.MoveBy:create(10.0, cc.p(-self._layoutMarquee:getContentSize().width * 1.5 , 0))

	local act3 = cc.Sequence:create(act1, act2)
	self._layoutSingleMarquee:runAction(cc.RepeatForever:create(act3))

end

return UIRedpackOpen
