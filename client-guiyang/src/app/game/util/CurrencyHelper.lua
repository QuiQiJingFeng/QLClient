--[[0
    create date: 
        2018/07/23
    简介：
        1、所有货币的入口
        2、绑定了与各个 货币 service 的接口
    
]]
local CurrencyBinder = require("app.game.util.CurrencyBinder")
---@class CurrencyHelper
local CurrencyHelper = class("CurrencyHelper")
-- static
CurrencyHelper.CURRENCY_TYPE = {
    CARD = "CARD", -- 房卡，钻石
    BEAN = "BEAN", -- 金豆
    GOLD = "GOLD", -- 金币
    MATCH_TICKET = "MATCH_TICKET", -- 参赛卷
    GIFT_TICKET = "GIFT_TICKET", -- 礼卷
    GIFT_TICKET_HELP = "GIFT_TICKET_HELP", -- 礼卷
}
local ZH_NAME_CONFIG = {}
local PROP_ID_PEER_TABLE = {} -- 用来对应 PropId
local _StatMap = {
    [CurrencyHelper.CURRENCY_TYPE.CARD] = "MALL_ENTER_CARD",
    [CurrencyHelper.CURRENCY_TYPE.BEAN] = "MALL_ENTER_BEAN",
    [CurrencyHelper.CURRENCY_TYPE.GOLD] = "MALL_ENTER_GOLD",
    [CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET] = "MALL_ENTER_MATCH_TICKET",
    [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET] = "MALL_ENTER_GIFT_TICKET",
    [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET_HELP] = "MALL_ENTER_GIFT_TICKET_HELP",
}

local _instance = nil

---@return CurrencyHelper
function CurrencyHelper.getInstance()
    if _instance == nil then
        _instance = CurrencyHelper.new()
    end
    return _instance
end

function CurrencyHelper:ctor()
    -- 最近请求的类型 ，因为在Service那边，礼券商城和参赛券的响应放一个message了。。。
    self._currentQueryType = nil

    PROP_ID_PEER_TABLE = {
        [CurrencyHelper.CURRENCY_TYPE.CARD] = tonumber("0x0F000002"),
        [CurrencyHelper.CURRENCY_TYPE.BEAN] = tonumber("0x0F000001"),
        [CurrencyHelper.CURRENCY_TYPE.GOLD] = tonumber("0x0F000003"),
        [CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET] = tonumber("0x0F000007"),
        [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET] = tonumber("0x0F000005"),
        [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET_HELP] = tonumber("0x0F000005"),
    }

    for key, propId in pairs(PROP_ID_PEER_TABLE) do
        local zhName = PropReader.getNameById(propId)
        if Macro.assertFalse(zhName ~= nil and zhName ~= "", "get wrong ZH name") then
            ZH_NAME_CONFIG[key] = zhName
        end
    end
end

function CurrencyHelper:getBinder()
    return CurrencyBinder.getInstance()
end


function CurrencyHelper:checkType(currencyType)
    return CurrencyHelper.CURRENCY_TYPE[currencyType] ~= nil
end

function CurrencyHelper:getCurrentQueryType()
    return self._currentQueryType
end

-- 当关闭商场的时候调用
function CurrencyHelper:resetCurrentQueryType()
    self._currentQueryType = nil
end

function CurrencyHelper:dispose()
    game.service.LocalPlayerService:getInstance():removeEventListenersByTag(self)
end

function CurrencyHelper:_onAction(type, data)
    if CurrencyHelper.CURRENCY_TYPE.CARD == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif CurrencyHelper.CURRENCY_TYPE.BEAN == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif CurrencyHelper.CURRENCY_TYPE.GOLD == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET_HELP == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    elseif "PROPS" == type then
        UIManager:getInstance():show("UISuperMall", type, data)
    end
end


function CurrencyHelper:getCurrencyZhName(currencyType)
    if Macro.assertFalse(self:checkType(currencyType), 'unknown currencyType:' .. tostring(currencyType)) then
        return ZH_NAME_CONFIG[currencyType]
    end
end

function CurrencyHelper:getCurrencyCount(currencyType)
    if Macro.assertFalse(self:checkType(currencyType), 'unknown currencyType:' .. tostring(currencyType)) then
        local count = 0
        if CurrencyHelper.CURRENCY_TYPE.CARD == currencyType then
            count = game.service.LocalPlayerService.getInstance():getCardCount()
        elseif CurrencyHelper.CURRENCY_TYPE.BEAN == currencyType then
            count = game.service.LocalPlayerService.getInstance():getBeanAmount()
        elseif CurrencyHelper.CURRENCY_TYPE.GOLD == currencyType then
            count = game.service.LocalPlayerService.getInstance():getGoldAmount()
        elseif CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET == currencyType then
            count = game.service.LocalPlayerService.getInstance():getCompVoucherCount()
        elseif CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET == currencyType then
            count = game.service.LocalPlayerService.getInstance():getGiftTicketCount()
        else
            Macro.assertFalse(false, 'unknown currencyType:' .. tostring(currencyType))
        end
        return count
    end
end

function CurrencyHelper:getCurrencyPropId(currencyType)
    if Macro.assertFalse(self:checkType(currencyType), 'unknown currencyType:' .. tostring(currencyType)) then
        return PROP_ID_PEER_TABLE[currencyType]
    end
end

function CurrencyHelper:getCurrencyTypeByPropId(propId)
    if not Macro.assertFalse(type(propId) == 'number', 'prop ID must a number value') then
        return nil
    end

    local currencyType = nil
    for type, id in pairs(PROP_ID_PEER_TABLE) do
        if propId == id then
            currencyType = type
            break
        end
    end
    return currencyType
end

-- 显示货币数据，需要货币源数据
function CurrencyHelper:showCurrencyPage(currencyType, data)
    self:_onAction(currencyType, data)
end

-- 请求某种货币的数据
function CurrencyHelper:queryCurrency(currencyType)

    self:_stat(currencyType)
    local _type = self:getCurrentQueryType()
    if _type == currencyType then
        -- 不重复请求了
        return
    end

        local TypeEnum = CurrencyHelper.CURRENCY_TYPE
        if TypeEnum.BEAN == currencyType then
            -- 不需要服务器，直接返回
            self:showCurrencyPage(currencyType, nil)
        elseif TypeEnum.CARD == currencyType then
            self:showCurrencyPage(currencyType, nil)
        elseif TypeEnum.GOLD == currencyType then
            game.service.MallService.getInstance():queryGoldData()
        elseif TypeEnum.GIFT_TICKET == currencyType then
            game.service.MallService.getInstance():queryGiftTicketData()
        elseif TypeEnum.MATCH_TICKET == currencyType then
            game.service.MallService.getInstance():queryMatchTicketData()
        elseif "PROPS" == currencyType then
            game.service.MallService.getInstance():querPropsData()
        else
            Macro.assertTrue(true,'unknown currency type:' .. tostring(currencyType))
            return
        end

        self._currentQueryType = currencyType
end

function CurrencyHelper:reQueryCurrentCurrency()
    local _type = self:getCurrentQueryType()
    self:resetCurrentQueryType()
    self:queryCurrency(_type)
end

function CurrencyHelper:_stat(currencyType)
    if currencyType then
        local eventKey = _StatMap[currencyType]
        game.service.TDGameAnalyticsService.getInstance():onEvent("MALL_ENTER")
        game.service.TDGameAnalyticsService.getInstance():onEvent(eventKey)
    end
end

function CurrencyHelper:requestCharge(currentType)
    local name = self:getCurrencyZhName(currentType)
    if name then
        local str = ("您的%s不足，请购买后重试"):format(name)
        game.ui.UIMessageBoxMgr.getInstance():show(str, { "取消", "确认" },
                function()
                end,
                function()
                    self:queryCurrency(currentType)
                end)
    end
end

return CurrencyHelper