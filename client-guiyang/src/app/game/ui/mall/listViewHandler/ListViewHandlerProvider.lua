--[[0
    提供多个 ListViewHandler 的 class
]]
local AbstractListViewHandler = require("app.game.ui.mall.listViewHandler.AbstractListViewHandler")
local AgentListViewHandler = require("app.game.ui.mall.listViewHandler.AgentListViewHandler")
local BeanListViewHandler = require("app.game.ui.mall.listViewHandler.BeanListViewHandler")
local CardListViewHandler = require("app.game.ui.mall.listViewHandler.CardListViewHandler")
local GiftTickeListViewHandler = require("app.game.ui.mall.listViewHandler.GiftTickeListViewHandler")
local GoldListViewHandler = require("app.game.ui.mall.listViewHandler.GoldListViewHandler")
local MatchTicketListViewHandler = require("app.game.ui.mall.listViewHandler.MatchTicketListViewHandler")
local PropListViewHandler = require("app.game.ui.mall.listViewHandler.PropListViewHandler")

local CurrencyHelper = require("app.game.util.CurrencyHelper")

local HandlerConfig = {
    [CurrencyHelper.CURRENCY_TYPE.CARD] = CardListViewHandler,
    [CurrencyHelper.CURRENCY_TYPE.BEAN] = BeanListViewHandler,
    [CurrencyHelper.CURRENCY_TYPE.GOLD] = GoldListViewHandler,
    [CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET] = MatchTicketListViewHandler,
    [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET] = GiftTickeListViewHandler,
    [CurrencyHelper.CURRENCY_TYPE.GIFT_TICKET_HELP] = GiftTickeListViewHandler,
    ["PROPS"] = PropListViewHandler,
    ["KEY_MALL_AGENT_LIST_VIEW"] = AgentListViewHandler,
}
local ListViewHandlerProvider = {}

function ListViewHandlerProvider.getHandlerClass(type)
    local ret = HandlerConfig[type]
    if Macro.assertFalse(ret, 'unknow type to find handler class type:' .. tostring(type)) then
        return ret
    end
end

return ListViewHandlerProvider