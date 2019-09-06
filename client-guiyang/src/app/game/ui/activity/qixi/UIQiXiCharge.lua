local csbPath = "ui/csb/Activity/QiXi/UIQiXiCharge.csb"
local super = require("app.game.ui.UIBase")
local UIQiXiCharge = class("UIQiXiCharge", super, function() return kod.LoadCSBNode(csbPath) end)
local ShopCostConfig = require("app.config.ShopCostConfig")
local CurrencyHelper = require("app.game.util.CurrencyHelper")

--记录是否点击过充值按钮
local isCharge = false

function UIQiXiCharge:ctor()
	
end

function UIQiXiCharge:init()
	self._btnBuy = seekNodeByName(self, "btnBuy", "ccui.Button")
	self._btnClose = seekNodeByName(self, "btnClose", "ccui.Button")
	self._panelIcon = seekNodeByName(self, "panelIcon", "ccui.Layout")
	-- 购买领取的奖励信息
	self._rewardList = {}
	
	PropReader.setIconForNode(self._panelIcon, "csb/HeadFrame/frames/frame_Qx.csb", 0.7)
	
	self:_registerCallBack()
end

function UIQiXiCharge:_registerCallBack()
	bindEventCallBack(self._btnBuy, handler(self, self._onBtnBuy), ccui.TouchEventType.ended)
	bindEventCallBack(self._btnClose, function(...)
		UIManager.getInstance():hide("UIQiXiCharge")
	end, ccui.TouchEventType.ended)
end

function UIQiXiCharge:onShow()
	local activityService = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA)
	-- 监听七夕充值活动
	activityService:addEventListener("EVENT_QTXI_CHARGEINFO", handler(self, self._setAndCheckData), self)
	-- 监听断线重连回来后的事件(支付完也会触发来检查是否充值完成)
	game.service.LocalPlayerService.getInstance():addEventListener("EVENT_GAME_DATA_RETRIVED", function(...)
		activityService:sendCACMagpieRechargeActivityREQ()
	end, self)
	
	activityService:addEventListener("EVENT_QIXI_CHARGE_SUCCESS", handler(self, self._buySuccess), self)
	
	activityService:sendCACMagpieRechargeActivityREQ()
end

function UIQiXiCharge:onHide()
	game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.TANA_BATA):removeEventListenersByTag(self)
	game.service.LocalPlayerService.getInstance():removeEventListenersByTag(self)
end

function UIQiXiCharge:needBlackMask()
	return true
end

function UIQiXiCharge:_setAndCheckData(event)
	if isCharge and event.protocol.hasBought then
		self:_buySuccess()
		return
	end
	
	self._btnBuy:setVisible(not event.protocol.hasBought)
end

function UIQiXiCharge:_buySuccess()
	isCharge = false
	UIManager.getInstance():show("UIQiXiRewardGet2")
	self:_close()
end


function UIQiXiCharge:_onBtnBuy()
	isCharge = true
	local channelId = game.plugin.Runtime.getChannelId() ~= 0 and tonumber(game.plugin.Runtime.getChannelId()) or 100000
	local SHOP_TYPE_COST = ShopCostConfig.getConfig(channelId)
	local shopData = SHOP_TYPE_COST.items[6]
	game.service.PaymentService:getInstance():queryPayType( CurrencyHelper.CURRENCY_TYPE.BEAN, shopData.count, {activityId = net.protocol.activityType.QIXI_CHARGE})
end

function UIQiXiCharge:_close(...)
	UIManager.getInstance():hide("UIQiXiCharge")
end


return UIQiXiCharge 