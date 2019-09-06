local CurrencyHelper = require("app.game.util.CurrencyHelper")
local MallService = class("MallService")
local ns = namespace("game.service")
ns.MallService = MallService

local PROP_ICON = {
    [401] = "ui/csb/Prop/propIcon/Icon_Gang.csb",
    [402] = "ui/csb/Prop/propIcon/Icon_Kaihua.csb",
    [403] = "art/prop/qipao01.png",
}

function MallService.getInstance()
    if game.service.LocalPlayerService.getInstance() ~= nil then
        return game.service.LocalPlayerService.getInstance():getMallService()
    end
    return nil
end

function MallService:ctor()
    -- 绑定事件系统
    cc.bind(self, "event");
    self._currentConvertGoldVersion = 0
    self._goodInfoCache = {}

    self._purchaseCallback = nil
end

function MallService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)

    -- 解绑事件系统
    cc.unbind(self, "event")
end

function MallService:initialize()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.GCMallRES.OP_CODE, self, self._onGCMallRES)
    requestManager:registerResponseHandler(net.protocol.GCQueryExchangeRES.OP_CODE, self, self._onGCQueryExchangeRES)
    requestManager:registerResponseHandler(net.protocol.GCMallBillRES.OP_CODE, self, self._onGCMallBillRES)
    requestManager:registerResponseHandler(net.protocol.GCRefreshGoodsSYN.OP_CODE, self, self._onGCRefreshGoodsSYN)
    requestManager:registerResponseHandler(net.protocol.GCQueryRoleTicketsRES.OP_CODE, self, self._onGCQueryRoleTicketsRES)
end

function MallService:setPurchaseCallback( callback)
    self._purchaseCallback = callback
end

function MallService:getIconRes(id)
    local result = ""
    if PROP_ICON[id] == nil or #PROP_ICON[id] == 0 then
        result = "ui/art/mall/goodIcon/good_" .. id .. ".png"
    else
        result = PROP_ICON[id]
    end
    return result
end

function MallService:queryGoldData()
    self:_internalQueryMallData()
end

function MallService:queryMatchTicketData()
    self:_internalQueryMallData()
end

function MallService:queryGiftTicketData()
    self:_internalQueryMallData()
end

function MallService:querPropsData()
    self:_internalQueryMallData()
end

function MallService:queryRoleTicket()
    local req = net.NetworkRequest.new(net.protocol.CGQueryRoleTicketsREQ, game.service.LocalPlayerService.getInstance():getGameServerId())
    game.util.RequestHelper.request(req)
end

function MallService:_onGCQueryRoleTicketsRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    self:dispatchEvent({ name = "EVENT_TICKET_MALLLIST_RECEIVE", protocol = protocol })
end

function MallService:_internalQueryMallData()
    local req = net.NetworkRequest.new(net.protocol.CGMallREQ, game.service.LocalPlayerService.getInstance():getGameServerId())
    game.util.RequestHelper.request(req)
end

--- 商品主页数据 响应
function MallService:_onGCMallRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local helper = CurrencyHelper.getInstance()
    local showType = helper:getCurrentQueryType()

    self._goodInfoCache = protocol.goodInfo

    local goodInfoArray = self:getGoodArrayByCurrencyType(showType)
    helper:showCurrencyPage(showType, goodInfoArray)

    game.service.LocalPlayerService.getInstance():setGiftTicketCount(protocol.points)
end

--- 请求账单数据
function MallService:queryBill()
    local req = net.NetworkRequest.new(net.protocol.CGMallBillREQ, game.service.LocalPlayerService.getInstance():getGameServerId())
    game.util.RequestHelper.request(req)
end

--- 账单响应
function MallService:_onGCMallBillRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.GC_MALL_BILL_RES_SUCCESS then
        self:dispatchEvent({ name = "EVENT_MALL_BILL_RES", data = protocol })
    end
end

--- @param goodId 商品id
--- @param phoneNumber 商品有需要则11位数字，否则为“0”
--- 购买请求
function MallService:submitOrder(goodId, phoneNumberStrm, address, name , time)
    local req = net.NetworkRequest.new(net.protocol.CGQueryExchangeREQ, game.service.LocalPlayerService.getInstance():getGameServerId())
    req:getProtocol():setData(goodId, phoneNumberStrm, address, name, time)
    game.util.RequestHelper.request(req)
end

--- 购买响应，无论成功失败，重新请求数据
function MallService:_onGCQueryExchangeRES(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local goodId = response:getRequest():getProtocol():getProtocolBuf().goodId
    local price = protocol.price

    if protocol.result ~= net.ProtocolCode.GC_QUERY_EXCHANGE_RES_SUCCESS then
        if protocol.result == net.ProtocolCode.GC_QUERY_EXCHANGE_RES_FAILED_GOLDBEAN then
            UIManager:getInstance():show("UIMallQuickCharge",price, goodId)
        else
            if self._purchaseCallback ~= nil then
                self._purchaseCallback()
                self._purchaseCallback = nil
            end
            game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(protocol.result), { "确定" }, function() end)
        end

        return        
    end

    local info = self:getGoodInfoById(goodId)
    local tipStr = nil
    if info then
        if self:getCurrencyTypeByGoodTab(info.tab) == CurrencyHelper.CURRENCY_TYPE.GOLD then
            -- 如果是金币的话特殊处理
            local service = game.service.GoldService.getInstance()
            if service then
                service:playComingGoldEffect(info.goodPrice)
            end
        elseif info.tab == 4 then
            tipStr = string.format("恭喜您获得牌桌特效%s，请前往背包查收，祝您游戏愉快", info.goodName)
        else
            tipStr = string.format("恭喜您获得%s，奖励已经发放到您的账户，祝您游戏愉快", info.goodName)
        end
    else
        tipStr = string.format("恭喜您，奖励已经发放到您的账户，祝您游戏愉快")
    end
    if tipStr then
        game.ui.UIMessageBoxMgr.getInstance():show(tipStr, { "确定" }, function()
            CurrencyHelper.getInstance():reQueryCurrentCurrency()
        end)
    end

    self:dispatchEvent({ name = "EVENT_MALLPAY_SUCCESS", data = protocol })
end

--- 服务器 同步信息, 当UI不存在时不处理
function MallService:_onGCRefreshGoodsSYN()
    local superMall = UIManager:getInstance():getUI("UISuperMall")
    if superMall and superMall:isVisible() then
        CurrencyHelper.getInstance():reQueryCurrentCurrency()
    end
end

function MallService:getGoodInfoById(goodId)
    if goodId == nil then
        return nil
    end
    for _, info in ipairs(self._goodInfoCache or {}) do
        if goodId == info.goodId then
            return info
        end
    end
    return nil
end

function MallService:getCurrencyTypeByGoodTab(tabKey)
    -- 1：礼券，2：参赛券，3：金币。
    if tabKey == 1 then
        return CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET
    elseif tabKey == 2 then
        return CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET
    elseif tabKey == 3 then
        return CurrencyHelper.CURRENCY_TYPE.GOLD
    end
end

function MallService:getGoodArrayByCurrencyType(currencyType)
    -- 1：礼券，2：参赛券，3：金币，4：购买道具。
    local tabKey = nil
    if CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET == currencyType then
        tabKey = 1
    elseif CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET == currencyType then
        tabKey = 2
    elseif CurrencyHelper.CURRENCY_TYPE.GOLD == currencyType then
        tabKey = 3
    elseif "PROPS" == currencyType then
        tabKey = 4
    else
        return {}
    end

    local ret = {}
    for _, goodInfo in ipairs(self._goodInfoCache or {}) do
        if goodInfo.tab == tabKey then
            table.insert(ret, goodInfo)
        end
    end
    return ret
end

function MallService:getGoodIconResPath(goodId)
    if goodId == nil then
        return ""
    end
    return string.format("mall/goodIcon/good_%d.png", goodId)
end

return MallService