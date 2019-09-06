local UtilsFunctions = require("app.game.util.UtilsFunctions")
local COLORS = {
    income = UtilsFunctions.convert2CCColor("#4CB005"),
    withdraw = UtilsFunctions.convert2CCColor("#FF4444")
}
local Array = require("ds.Array")
local csbPath = "ui/csb/PlayerInfo/UIWalletBill.csb"
local super = require("app.game.ui.UIBase")
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local seekButton = UtilsFunctions.seekButton
---@class UIWalletBill:UIBase
local UIWalletBill = super.buildUIClass("UIWalletBill", csbPath)

function UIWalletBill:ctor()
    UtilsFunctions.attachCloseButton(self, true)
    self._listView = ReusedListViewFactory.get(seekNodeByName(self, "list-view", "ccui.ListView"),
            handler(self, self._onListItemInit),
            handler(self, self._onListItemSetData))

    self._btnMakeMoney = seekButton(self, "Button_MakeMoney", handler(self, self._onBtnMakeMoneyClicked))
    self._node_node = seekNodeByName(self, "none-node")
    self._text_title_desc = seekNodeByName(self, "text-title-desc")
    self._text_title_time = seekNodeByName(self, "text-title-time")

    self._txtTotalNum = seekNodeByName(self, "text-total")
    self._money_unit = seekNodeByName(self, "text-unit")
end

function UIWalletBill:onDestroy()
end

---@param response NetworkResponse
function UIWalletBill:onShow(response)
    local buffer = response:getBuffer()
    self._txtTotalNum:setStringFormat("%s元", buffer.income * 0.01)
    self._money_unit:setPositionPercent(cc.p(1, 0.4))
    UtilsFunctions.resetListViewData(self._listView, Array.new(buffer.record):reverse().innerTable)
    dump(buffer.record)
    self._node_node:setVisible(#buffer.record == 0)
    self._text_title_desc:setVisible(#buffer.record > 0)
    self._text_title_time:setVisible(#buffer.record > 0)

end

function UIWalletBill:onHide()

end

function UIWalletBill:_onBtnCloseClicked()
    self:hideSelf()
end

function UIWalletBill:_onBtnMakeMoneyClicked()
    uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    UtilsFunctions.onEvent("WALLET_MAKE_MONEY")
end

function UIWalletBill:_onListItemInit(listItem)
    listItem.date = seekNodeByName(listItem, "date")
    listItem.desc = seekNodeByName(listItem, "desc")
end

function UIWalletBill:_onListItemSetData(listItem, data)
    local date = kod.util.Time.time2Date(data.date * 0.001)
    listItem.date:setStringFormat("%d.%02d.%02d", date.year, date.month, date.day)
    local diff = data.afterMoney - data.beforeMoney
    if diff >= 0 then
        listItem.desc:setStringFormat("%s +%0.2f元", data.reason, diff * 0.01)
    else
        listItem.desc:setStringFormat("%s %0.2f元", data.reason, diff * 0.01)
    end
end

function UIWalletBill:needBlackMask()
    return true
end

return UIWalletBill