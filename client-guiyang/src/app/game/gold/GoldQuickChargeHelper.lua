local CurrencyHelper = require("app.game.util.CurrencyHelper")
-- （1：金币不足，2：升级礼包，3：转运礼包，4：转运礼包（金币不组））
local QUICK_CHARGE_UI_MAP = {
    [1] = 'UIGoldQuickCharge_Normal',
    [2] = 'UIGoldQuickCharge_Upgrade',
    [3] = 'UIGoldQuickCharge_Luck',
    [4] = 'UIGoldQuickCharge_Luck_Downgrade',
}

local UtilsFunctions = require("app.game.util.UtilsFunctions")
local M = UtilsFunctions.singleton(class("GoldQuickChargeHelper"))

function M:ctor()
    local requestManager = net.RequestManager.getInstance()
    -- 这两个消息放这里监听，是因为他们只用来快速充值，普通的购买金币客户端不走这个逻辑
    requestManager:registerResponseHandler(net.protocol.GOCConvertGoldCoinSYN.OP_CODE, self, self._onGOCConvertGoldCoinSYN)
    requestManager:registerResponseHandler(net.protocol.GOCConvertGoldCoinRES.OP_CODE, self, self._onGOCConvertGoldCoinRES)
    requestManager:registerResponseHandler(net.protocol.GOCConvertGoldCoinResultSYN.OP_CODE, self, self._onGOCConvertGoldCoinResultSYN)

    -- 当前缓存的UI需要的参数，只会存在一个
    self._currentQuickParam = nil
    self:_resetCacheData()

    self._quickPayExtraParam = {}
end

function M:onContinueMatch()
    game.service.GoldService.getInstance():trySendCGoldMatchREQ(self:_getContinueMatchRoomGrade())
    self:_resetCacheData()
end

function M:onCancelContinue()
    local giftCache = game.service.GoldService.getInstance().giftCache
    if giftCache then
        UIManager.getInstance():show("UIGoldLeaveTip", giftCache.needRoundNextMallPoint, giftCache.rewardMallPoint)
    else
        GameFSM:getInstance():enterState("GameState_Gold")
    end
    self:_resetCacheData()
end

function M:_onGOCConvertGoldCoinSYN(response)
    local buffer = response:getProtocol():getProtocolBuf()
    local uiKey = QUICK_CHARGE_UI_MAP[buffer.type]
    self._currentQuickParam = {
        uiKey, {
            -- 是充值还是兑换  充值是用RMB去买金豆
            type = buffer.type,
            isCharge = buffer.purchaseItemId ~= "",
            goodsId = buffer.goodsId,
            cost = buffer.goldBean,
            chargeCount = buffer.goldCoin,
            extraCount = buffer.extraCoin,
            clickHandler = function()
                self:_onQuickChargeHandlerActive(buffer)
            end
        }
    }
    -- 保留快速购买的参数
    self._quickPayExtraParam = {
        type = buffer.type,
        goods_id = buffer.goodsId
    }

    if uiKey == "UIGoldQuickCharge_Normal" then
        UIManager:getInstance():show(unpack(self._currentQuickParam))
        self._currentQuickParam = nil
    end

    if uiKey == "UIGoldQuickCharge_Luck" or
    uiKey == "UIGoldQuickCharge_Luck_Downgrade"
    then
        self._cacheData.hasShowLuck = true
    else
        self._cacheData.hasShowLuck = false
    end
end

function M:_onGOCConvertGoldCoinRES(response)
    local buffer = response:getProtocol():getProtocolBuf()
    if buffer.result == net.ProtocolCode.GO_C_CONVERT_GOLD_COIN_SUCCESS then
        local request = response:getRequest()
        if request == nil then
            return
        end

        local preUIName = QUICK_CHARGE_UI_MAP[request:getProtocol():getProtocolBuf().type]
        UIManager:getInstance():show("UIGoldQuickCharge_Result", preUIName)
    end
end

function M:_onGOCConvertGoldCoinResultSYN(response)
    local buffer = response:getProtocol():getProtocolBuf()
    if buffer.result == net.ProtocolCode.GO_C_CONVERT_GOLD_COIN_SUCCESS then
        local preUIName = QUICK_CHARGE_UI_MAP[buffer.type]
        UIManager:getInstance():show("UIGoldQuickCharge_Result", preUIName)
    end
end

function M:_onQuickChargeHandlerActive(buffer)
    local tips = ''
    local btnTexts = { "确定", "取消" }
    local funcArr = {}
    if buffer.purchaseItemId == "" then
        tips = string.format("消耗%s金豆兑换%s金币", buffer.goldBean, buffer.goldCoin)
        funcArr = {
            function()
                self._cacheData.hasPay = true
                Logger.debug("===================== has pay is " .. tostring(self._cacheData.hasPay))
                self:sendCGOConvertGoldCoinREQ(buffer.goodsId, buffer.type)
            end,
            function()
                self._cacheData.hasPay = false
                Logger.debug("===================== has pay is " .. tostring(self._cacheData.hasPay))
            end
        }
    else
        -- 直接去购买
        self._cacheData.hasPay = true
        Logger.debug("===================== has pay is " .. tostring(self._cacheData.hasPay))
        game.service.PaymentService.getInstance():queryPayType(CurrencyHelper.CURRENCY_TYPE.BEAN, buffer.goldBean, {
            ["gold_convert"] = self._quickPayExtraParam,
            type =  net.protocol.PayType.GOLD_PAY,
        })
        return
    end
    game.ui.UIMessageBoxMgr.getInstance():show(tips, btnTexts, unpack(funcArr))
end

--[[0
    请求快速兑换，goodsId 不一定等于 商城的 goodId
    uiKey 是客户端用来存储发送请求的场景
]]
function M:sendCGOConvertGoldCoinREQ(goodsId, type)
    local request = net.NetworkRequest.new(net.protocol.CGOConvertGoldCoinREQ, game.service.GoldService.getInstance():getServerId())
    request:getProtocol():setData(goodsId, type)
    game.util.RequestHelper.request(request)

    -- 关闭UI
    for _, key in pairs(QUICK_CHARGE_UI_MAP) do
        UIManager:getInstance():hide(key)
    end
end

function M:onGoldRoundResultShow()
    if self._currentQuickParam then
        UIManager:getInstance():show(unpack(self._currentQuickParam))
    end
    self._currentQuickParam = nil
end

function M:_resetCacheData()
    self._cacheData = {
        -- 上次是否支付过
        hasPay = false,
        -- 上次是否显示了幸运礼包
        hasShowLuck = false,
    }
    Logger.error("===================== already reset cache data")
end

function M:_getContinueMatchRoomGrade()
    Logger.info("===================== has pay is " .. tostring(self._cacheData.hasPay))
    Logger.info("===================== has Show Luck is " .. tostring(self._cacheData.hasShowLuck))


    local grade = game.service.GoldService.getInstance():getCurrentRoomGrade()

    -- 显示了UI但是没有支付，去快速匹配
    if self._cacheData.hasShowLuck and (not self._cacheData.hasPay) then
        grade = net.protocol.CGoldMatchREQ.Enum_RoomGrade.QUICK
    end

    -- 如果缓存失败，也去快速匹配
    if grade == nil or grade == 0 then
        Logger.debug("+++++++++++++++++++ current room grade is 0, re dir to quick level")
        grade = net.protocol.CGoldMatchREQ.Enum_RoomGrade.QUICK
    end

    return grade
end

return M