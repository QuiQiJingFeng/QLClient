local CheckBoxGroup = require("app.game.util.CheckBoxGroup")
local ONE_LINE_ITEM_COUNT = 2
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/PlayerInfo/UIWalletWithdraw.csb"

---@class UIWalletWithdraw:UIBase
local UIWalletWithdraw = super.buildUIClass("UIWalletWithdraw", csbPath)
function UIWalletWithdraw:init()
    UtilsFunctions.attachCloseButton(self, true, 'btn-close')

    seekButton(self, "btn-withdraw", handler(self, self._onBtnWithDrawClicked))

    seekButton(self, "button-makemoney", handler(self, self._onMakeMoneyClicked))

    self._listView = ReusedListViewFactory.get(seekNodeByName(self, "listview"),
            handler(self, self._onListItemInit),
            handler(self, self._onListItemSetData))

end

function UIWalletWithdraw:onShow(response, totalMoney)
    self._boxGroup = CheckBoxGroup.new({}, handler(self, self._onBoxItemClicked))
    local buffer = response:getBuffer()
    self._buffer = buffer
    UtilsFunctions.resetListViewData(self._listView, ReusedListViewFactory.splitTable(buffer.config, ONE_LINE_ITEM_COUNT))
    if #buffer.config > 0 then
        self._boxGroup:setSelectedIndexWithoutCallback(1)
    end
    self._totalMoney = totalMoney
end

function UIWalletWithdraw:onHide()
end

function UIWalletWithdraw:_onListItemInit(listItem, index)
    local items = {}
    for i = 1, ONE_LINE_ITEM_COUNT do
        local node = seekNodeByName(listItem, "item-" .. i)
        table.insert(items, {
            money = seekNodeByName(node, "money"),
            money_unit = seekNodeByName(node, "unit"),
            times = seekNodeByName(node, "times"),
            selectedBG = seekNodeByName(node, "SelectedBG"),
        })
        self._boxGroup:append(node)
    end
    listItem.items = items
end

function UIWalletWithdraw:_onListItemSetData(listItem, data)
    local items = listItem.items
    for i = 1, ONE_LINE_ITEM_COUNT do
        local item = items[i]
        item.money:setStringFormat("%s元", data[i].money * 0.01)
        item.times:setStringFormat("%s/%s", data[i].useCount, data[i].count)
        scheduleOnce(function()
            item.money_unit:setAnchorPoint(cc.p(0, 0.5))
            item.money_unit:setPositionPercent(cc.p(1, 0.4))
        end, 0)
    end
end

function UIWalletWithdraw:needBlackMask()
    return true
end

function UIWalletWithdraw:_getServerId()
    return game.service.LocalPlayerService.getInstance():getGameServerId()
end

function UIWalletWithdraw:_onBtnWithDrawClicked()
    local index = self._boxGroup:getSelectedIndex()
    if self._buffer and index then
        local data = self._buffer.config[index]
        if data then
            local money = data.money * 0.01
            if money > self._totalMoney * 0.01 then
                game.ui.UIMessageBoxMgr.getInstance():show(("亲，你的余额不足，赶快去赚取红包吧！")
                        :format(money), { "我知道了", "去赚钱" }, function()
                end, handler(self, self._onMakeMoneyClicked))
                UtilsFunctions.onEvent("WALLET_WITHDRAW_FAILED_MONEY_NOT_ENOUGH")
            elseif data.useCount >= data.count then
                game.ui.UIMessageBoxMgr.getInstance():show(("亲，你的%s元提现次数已用完，试试其他金额或者明天再来哟！")
                        :format(money), { "我知道了" })
                UtilsFunctions.onEvent("WALLET_WITHDRAW_FAILED_NO_TIMES")
            else
                game.ui.UIMessageBoxMgr.getInstance():show(("确定提现%s元?"):format(money),
                        { "提现", "取消" },
                        function()
                            local appId = config.GlobalConfig.getConfig().WECHAT_APPID
                            net.NetworkRequest.new(net.protocol.CGWalletWithdrawREQ, self:_getServerId()):setBuffer({
                                level = index - 1,
                                appId = appId,
                            }) :setExtraData({ money = money }):execute()
                            self:hideSelf()
                        end)
            end
        end
    end

    UtilsFunctions.onEvent("WALLET_WITHDRAW")
end

function UIWalletWithdraw:_onBoxItemClicked(group, index)
    if self._buffer then
        local data = self._buffer.config[index]
        if data then
            UtilsFunctions.onEvent("WALLET_WITHDRAW_SELECTED_" .. data.money)
        end
    end
end

function UIWalletWithdraw:_onMakeMoneyClicked()
    -- 跳转到比赛场
    uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    UtilsFunctions.onEvent("WALLET_MAKE_MONEY")
end

return UIWalletWithdraw