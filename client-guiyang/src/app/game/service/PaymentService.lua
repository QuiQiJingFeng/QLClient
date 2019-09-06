local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ShopCostConfig = require("app.config.ShopCostConfig")
local ns = namespace("game.service")

local PaymentService = class("PaymentService")
ns.PaymentService = PaymentService

local payType = {
    alipay = 1,
    h5 = 2,
    ios = 3
}

local PayMethodRecord = class("PayMethodRecord")
function PayMethodRecord:ctor()
    self._payType = 0;
end

function PayMethodRecord:setPaytype(type)
    self._payType = type
end

function PayMethodRecord:getPayType()
    return self._payType
end

--[[	这里要注意一点，如果支付成功后，没有向服务器发送，这里的支付会不生效的！
	当客户端支付完成后，会做一次本地保存，当确认结果后，再删除，做一下保护
	！！！这里对应的服务器需要保存一下票据，如果已经加过房卡后，下次客户端再次请求的时候，不应该再加！！！

	现在看来，当前不需要事件
]]
-- local PaymentData = class("PaymentData")
-- function PaymentData:ctor()
-- 	self.data = {}
-- end
-- 单例支持
-- @return LoginService
function PaymentService:getInstance()
    return game.service.LocalPlayerService.getInstance():getPaymentService();
end

-- 构造
function PaymentService:ctor()
    -- cc.bind(self, "event")
    -- self._paymentData = nil
    -- 如果支付 验证失败的时候，再次验证尝试的次数
    self._retryTimes = 1
    -- 请求订单的时候，先生成订单，在选择完支付方式后再发送
    self._payRequestCache = nil
    self._defalutPayType = PayMethodRecord.new()

    cc.bind(self, "event");
end

function PaymentService:clear()
    self._retryTimes = 1
end

-- 初始化
function PaymentService:initialize()
    local requestManager = net.RequestManager.getInstance();
    requestManager:registerResponseHandler(net.protocol.GCPayOrderRES.OP_CODE, self, self._onGCPayOrderRES);
    requestManager:registerResponseHandler(net.protocol.GCPayVerifyRES.OP_CODE, self, self._onGCPayVerifyRES);
    requestManager:registerResponseHandler(net.protocol.GCQueryPayTypesRES.OP_CODE, self, self._onGCQueryPayTypesRES);
    local IAPService = game.service.IAPService.getInstance()
    IAPService:addEventListener("EVENT_ONRESULTAPPCALLBACK", handler(self, self._payCallback), self)

    -- 未完成初始化的时候，初始化一下
    if not game.service.IAPService.getInstance():isInitialized() then
        game.service.IAPService.getInstance():initialize()
    end
end

function PaymentService:recheckPayment()
    -- 检查是否有未完成的定单
    -- self:_loadPayment()
    self:_recheck()
    -- 重置尝试次数
    self._retryTimes = 1
end

-- 重新检查，当前没有校验过的支付
function PaymentService:_recheck()
    -- for i=1,#self._paymentData.data do
    -- 	local data = self._paymentData.data[i]
    -- 	self:_reqPaymentResult(data.orderid, data.transcationId, data.receiptString)
    -- end
    local _json = game.service.IAPService.getInstance():queryOrder()
    if _json and _json ~= "" then
        -- 现确认上一单未完成的话，是无法开始下一单的
        local succ, param = pcall(json.decode, _json)
        -- 如果解析失败，上传一下当前的URL
        if Macro.assetTrue(not succ, "PaymentService queryOrder json Parse failed") then
            Logger.debug("PaymentService queryOrder json =>" .. tostring(_json))
            return
        end
        self:_reqPaymentResult(param.orderid, param.roleId, param.transcationId, param.receiptString)
    end
end

-- 销毁前的清除
function PaymentService:dispose()
    -- cc.unbind(self, "event")
    game.service.IAPService.getInstance():removeEventListenersByTag(self)
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
    net.RequestManager.getInstance():unregisterResponseHandler(self);
    -- 解绑事件系统
    cc.unbind(self, "event");
end

-- -- 本地数据保存，当异常断线后，或者crash后，能保证还能找到对应数据
-- -- 保存以及加载，要以玩家ID为基准
-- function PaymentService:_savePayment()
-- 	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
-- 	self._paymentData = self._paymentData and clone(self._paymentData) or PaymentData.new();
-- 	manager.LocalStorage.setUserData(roleId, "PaymentRecord", self._paymentData);
-- 	Logger.dump(self._paymentData, "self._paymentData[save] => ", 3)
-- end
-- -- 本地数据加载，当service初始化后，就加载，用来加载上次没有处理完的票据校验
-- -- 保存以及加载，要以玩家ID为基准
-- function PaymentService:_loadPayment()
-- 	local roleId = game.service.LocalPlayerService:getInstance():getRoleId()
-- 	self._paymentData = manager.LocalStorage.getUserData(roleId, "PaymentRecord", PaymentData);
-- 	Logger.dump(self._paymentData, "self._paymentData[load] => ", 3)
-- end
--[[	当客户端点击相应购买按钮事件后调用，
	先向服务器请求productID，这里需要先定几个参数，用来确定要请求的数据
]]
function PaymentService:reqProductId(payType, osType, rmb, goodId, itemId, activityId)
    local request = net.NetworkRequest.new(net.protocol.CGPayOrderREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    local custom = {}
    -- if device.platform == "android" then
    -- 	custom = {
    -- 		wx_type = 1,
    -- 		ip = game.service.LocalPlayerService.getInstance():getIp()
    -- 	}
    -- end
    custom = {
        wx_type = 1,
        ip = game.service.LocalPlayerService.getInstance():getIp()
    }

    if activityId then
        custom.activityId = activityId
    end

    request:getProtocol():setData(
    game.service.LocalPlayerService.getInstance():getRoleId(),
    payType,
    osType,
    rmb,
    goodId,
    0,
    game.plugin.Runtime.getChannelId(),
    0,
    json.encode(custom),
    itemId
    );

    game.util.RequestHelper.request(request)
    if device.platform == "ios" then
        Macro.assetTrue(true, "PaymentService Log reqProductId")
    end
end

--[[	当返回成功后，去调用支付相关内容
]]
function PaymentService:_onGCPayOrderRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local request = response:getRequest()
    Logger.debug("PaymentService:_onGCPayOrderRES:result", protocol.result)
    if protocol.result == net.ProtocolCode.GC_PAY_ORDER_SUCCESS then
        if protocol.payType == payType.h5 or protocol.payType == payType.alipay then
            local url = ""
            if protocol.domain ~= nil and protocol.domain ~= "" then
                url = protocol.domain
            else
                url = config.GlobalConfig.getConfig().WECHAT_PAY_URL .. kod.util.String.encodeURI(protocol.payUrl)
            end
            self:_wechatPay(url)
            
        elseif protocol.orderId ~= "" and protocol.payType == payType.ios then
            self:_toPay(request:getProtocol():getProtocolBuf().goodId, protocol.orderId)
        end
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

--[[	当服务器返回后，由webview拉起微信支付，
]]
function PaymentService:_wechatPay(payUrl)
    game.service.WebViewService.getInstance():openWebView(payUrl)
end

--[[	当服务器返回后，本地的支付调用，
	现在有个安全隐患，如果在这步支付完成后，如果没有向服务器请求，那么本次支付就不会加相应数据的，
	现在当支付成功的时候，做了次本地保存，
	但是如果支付成功，但是在客户端仍没有拿到成功数据的时候，会怎么样？这里不清楚
	当一切成功后，发往服务器校验
]]
function PaymentService:_toPay(productId, orderId)
    Logger.info("PaymentService:_toPay productId=%s, orderId=%s", productId, orderId)
    game.service.IAPService.getInstance():setPayParams(productId, orderId, game.service.LocalPlayerService.getInstance():getRoleId())
end

-- sdk支付回调
function PaymentService:_payCallback(event)
    Logger.debug("PaymentService:_payCallback")
    -- table.insert(self._paymentData.data, {orderid = event.orderid, transcationId = event.transcationId, receiptString = event.receiptString})
    -- self:_savePayment()
    self:_reqPaymentResult(event.orderid, event.roleId, event.transcationId, event.receiptString)
    -- 重置尝试次数
    self._retryTimes = 1
end

-- 请求服务器校验
function PaymentService:_reqPaymentResult(orderId, roleId, transactionId, receipt)
    Logger.debug("PaymentService:_reqPaymentResult", orderId, transactionId, receipt)
    local request = net.NetworkRequest.new(net.protocol.CGPayVerifyREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    request:getProtocol():setData(
    orderId,
    roleId,
    transactionId,
    receipt);
    game.util.RequestHelper.request(request)
    -- 更改消息超时时间，因为这条消息验证时间可能会很长
    request:setTimeoutTime(kod.util.Time.now() + 60)

    if device.platform == "ios" then
        Macro.assetTrue(true, "PaymentService Log reqPaymentResult")
    end
end

--[[	服务器反回productID后，并且支付已经成功，用成功后返回的票据去服务器校验
	当收到返回后，不论成功还是失败，都会将本地对应数据删除
]]
function PaymentService:_onGCPayVerifyRES(response)
    Logger.debug("PaymentService:_onGCPayVerifyRES")
    local payResult = false
    local protocol = response:getProtocol():getProtocolBuf()
    local retryPayVerify = function()
        local request = response:getRequest()
        -- 如果断线重连后，收到此消息，reqest都是nil，未确定是否是如此，但确实有log输出出现过
        if request then
            local protocol = request:getProtocol():getProtocolBuf()
            self:_reqPaymentResult(protocol.orderId, protocol.roleId, protocol.transactionId, protocol.receipt)
        else
            -- 如果是断线重连的话，那么重连后，会发送
            -- self:_recheck()
        end
     end
    if protocol.result == net.ProtocolCode.GC_PAY_VERIFY_SUCCESS then
        -- 充值成功的提示
        game.ui.UIMessageTipsMgr.getInstance():showTips("充值成功！")
        Logger.debug("GC_PAY_VERIFY_SUCCESS")
        payResult = true
    elseif protocol.result == net.ProtocolCode.MG_PAY_VERIFY_FAILED_TIMEOUT then
        game.ui.UIMessageBoxMgr.getInstance():show("服务器校验超时，请重试！", { "确定" }, function()
            retryPayVerify()
            return
        end, nil, nil, nil, 0)
        return
    elseif protocol.result == net.ProtocolCode.GC_PAY_VERIFY_DONE then
        -- 支付未完成时杀进程等特殊操作的时候，错误不提示
        Logger.debug("GC_PAY_VERIFY_DONE")
        payResult = true
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
        Logger.debug("GC_PAY_VERIFY_FAILED")
        payResult = false
        if self._retryTimes > 0 then
            retryPayVerify()
            self._retryTimes = self._retryTimes - 1
            return
        end
    end

    if device.platform == "ios" then
        Macro.assetTrue(true, "PaymentService Log onGCPayVerifyRES")
    end

    -- table.remove(self._paymentData.data, idx)
    -- self:_savePayment()
    -- 通知SDK完成支付
    Logger.debug("GC_PAY_VERIFY_notifyResult")
    game.service.IAPService.getInstance():notifyResult(payResult)
end

local TypeKeyConfig = {
    [CurrencyHelper.CURRENCY_TYPE.BEAN] = "GameMoney",
    [CurrencyHelper.CURRENCY_TYPE.CARD] = "NormalCard",
}

-- 生成请求订单的request
function PaymentService:genPayRequest(currencyType, chargeCount, extraCustomTable)
    if CurrencyHelper.CURRENCY_TYPE.BEAN ~= currencyType and
    CurrencyHelper.CURRENCY_TYPE.CARD ~= currencyType then
        return Macro.assert(false, 'quick pay only implement on bean or card.')
    end

    local channelId = 0
    if game.plugin.Runtime.isEnabled() then
        channelId = checknumber(game.plugin.Runtime.getChannelId())
    else
        channelId = 100000
    end

    local cfg = ShopCostConfig.getConfig(channelId)
    local selectedItem = nil
    if Macro.assertFalse(cfg, 'shop cost config is a nil value, channel id is ', tostring(game.plugin.Runtime.getChannelId())) then
        local items = ShopCostConfig.filterItemsByCurrencyType(currencyType, cfg.items)
        items = ShopCostConfig.filterItemsByChargeCount(chargeCount, items)
        if #items == 0 then
            return Macro.assertFalse(false, 'items size is 0')
        end
        selectedItem = items[1]
    end

    if not Macro.assertFalse(selectedItem, "quick pay selectedItem  is a nil value") then
        return false
    end

    local custom = {
        wx_type = 1,
        type = 0,
        ip = game.service.LocalPlayerService.getInstance():getIp()
    }
    for k, v in pairs(extraCustomTable or {}) do
        if Macro.assertFalse(custom[v] == nil, 'key ' .. tostring(v) .. ', is a illegal key') then
            custom[k] = v
        end
    end

    local request = net.NetworkRequest.new(net.protocol.CGPayOrderREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    local buffer = request:getProtocol():getProtocolBuf()
    buffer.roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    buffer.payType = cfg.payType
    buffer.osType = cfg.osType
    buffer.rmb = selectedItem.cost
    buffer.goodId = selectedItem.productId
    buffer.deviceType = 0
    buffer.channelId = game.plugin.Runtime.getChannelId()
    buffer.subChannelId = 0
    buffer.custom = json.encode(custom)
    buffer.itemId = PropReader.getIdByType(TypeKeyConfig[currencyType])

    return request
end

function PaymentService:quickPay(currencyType, chargeCount, extraCustomTable)
    local request = self:genPayRequest(currencyType,chargeCount,extraCustomTable)
    game.util.RequestHelper.request(request)
    if device.platform == "ios" then
        Macro.assetTrue(true, "PaymentService Log reqProductId")
    end

    Logger.debug("quick pay custom json : " .. buffer.custom)
    return true
end

-- 请求支付方式,此处先生成订单request
function PaymentService:queryPayType(currencyType, chargeCount, extraCustomTable)
    local request = net.NetworkRequest.new(net.protocol.CGQueryPayTypesREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
    local osType = 0
    self._payRequestCache = self:genPayRequest(currencyType, chargeCount, extraCustomTable)
    if device.platform == "ios" then
        osType = 3
    end
    request:getProtocol():setData(osType);
    game.util.RequestHelper.request(request);
end

function PaymentService:_onGCQueryPayTypesRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_QUERY_PAY_TYPES_SUCCESS then
        -- 如果是只有一个且是苹果就拉起苹果
        if #protocol.payType == 1 and protocol.payType[1].payType == 3 then
            local request = self._payRequestCache
            if request == nil then return end
            local buf = request:getProtocol():getProtocolBuf()
            buf.payType = 3
            game.util.RequestHelper.request(request);
        else
            UIManager:getInstance():show("UIPayMethod",protocol.payType, self._payRequestCache)
        end
    end
end

function PaymentService:sendCachedPayOrder(payType)
    local request = self._payRequestCache
    if request == nil then return end
    local buf = request:getProtocol():getProtocolBuf()
    buf.payType = payType
    game.util.RequestHelper.request(request);
end

function PaymentService:getDefaultPayType()
    return self._defalutPayType
end

function PaymentService:loadLocalStorage()
    self._defalutPayType = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "PayMethodRecord", PayMethodRecord);
end

-- 保存上一次使用的支付方式
function PaymentService:saveLocalStorage(payType)
    self._defalutPayType:setPaytype(payType)
    manager.LocalStorage.setUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "PayMethodRecord", self._defalutPayType)
end

return PaymentService