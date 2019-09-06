local HELP_STR = [[
1、赚钱途径
亲，比赛场和各种限时活动都可以赚取大量的红包，每日签到也可以哟！

2、提现介绍
亲、点击我的钱包中的提现按钮，选择想要提现的金额，点击下方提现按钮，红包一秒就到微信零钱！

3、钱包介绍
目前游戏内大部分图形获得的红包均直接进入钱包余额，只有一些活动的红包发放采用特殊途径（具体见相关活动介绍）。提现成功直接发放到微信零钱里，提现失败也不用慌张，你提现的金额会退还到余额里。]]
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local csbPath = "csb/PlayerInfo/UIWallet.csb"

---@class UIWallet
local UIWallet = class("UIWallet", function()
    return cc.CSLoader:createNode(csbPath)
end)

function UIWallet:ctor()
    seekButton(self, "button-bill", function()
        self:_sendCGWalletWithdrawRecordREQ()
    end)

    self._btn_withdraw = seekButton(self, "button-withdraw", function()
        self:_sendCGWalletConfigREQ()
        UtilsFunctions.onEvent("WALLET_WITHDRAW_SHOW")
    end)

    seekButton(self, "button-help", function()
        UIManager:getInstance():show("UICommonHelp", HELP_STR, "说明")
    end)

    seekButton(self, "button-makemoney", handler(self, self._onMakeMoneyClicked))

    self._none_node = seekNodeByName(self, "node_empty")

    ---@type ListView
    local lv = seekNodeByName(self, "list-view")
    self._list_view = ReusedListViewFactory.get(lv,
            handler(self, self._on_list_item_init),
            handler(self, self._on_list_item_set_data))

    lv:setScrollBarEnabled(false)
    lv:setClippingEnabled(true)

    self._totalMoney = seekNodeByName(self, "text-total-money")
    self._moneyUnit = seekNodeByName(self, "text-unit")
end

---@private
function UIWallet:_registerResponseHandler()
    local requestManager = net.RequestManager.getInstance()
    requestManager:registerResponseHandler(net.protocol.GCWalletInfoRES.OP_CODE, self, self._onGCWalletInfoRES)
    requestManager:registerResponseHandler(net.protocol.GCWalletWithdrawRES.OP_CODE, self, self._onGCWalletWithdrawRES)
    requestManager:registerResponseHandler(net.protocol.GCWalletWithdrawRecordRES.OP_CODE, self, self._onGCWalletWithdrawRecordRES)
    requestManager:registerResponseHandler(net.protocol.GCWalletConfigRES.OP_CODE, self, self._onGCWalletConfigRES)

    -- 监听后立马请求
    self:_sendCGWalletInfoREQ()
end

function UIWallet:show()
    UtilsFunctions.onEvent("WALLET_SHOW")
    self:_registerResponseHandler()
    self:setVisible(true)
    self:_showGuide()
end

function UIWallet:hide()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    self:setVisible(false)
end

function UIWallet:onDestroy()
end

function UIWallet:_on_list_item_init(list_item)
    list_item.desc = seekNodeByName(list_item, "desc")
    list_item.money = seekNodeByName(list_item, "money")
end

function UIWallet:_on_list_item_set_data(list_item, data)
    list_item.desc:setString(data.reason)
    local money = data.afterMoney - data.beforeMoney
    if money >= 0 then
        list_item.money:setStringFormat("+%.02f元", money * 0.01)
    else
        list_item.money:setStringFormat("%.02f元", money * 0.01)
    end
end

function UIWallet:_onMakeMoneyClicked(sender)
    -- 跳转到比赛场
    uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    UtilsFunctions.onEvent("WALLET_MAKE_MONEY")
end

---@private
function UIWallet:_sendCGWalletInfoREQ()
    net.NetworkRequest.new(net.protocol.CGWalletInfoREQ, self:_getServerId()):execute()
end

---@private
function UIWallet:_sendCGWalletWithdrawRecordREQ()
    net.NetworkRequest.new(net.protocol.CGWalletWithdrawRecordREQ, self:_getServerId()):execute()
end

function UIWallet:_sendCGWalletConfigREQ()
    net.NetworkRequest.new(net.protocol.CGWalletConfigREQ, self:_getServerId()):execute()
end

---@private
---@param response NetworkResponse
function UIWallet:_onGCWalletInfoRES(response)
    if response:checkIsSuccessful() then
        self._walletInfo = response:getBuffer()
        self:refreshData()
    end
end

---@private
---@param response NetworkResponse
function UIWallet:_onGCWalletWithdrawRES(response)
    -- 体现成功后，所有数据重新请求一边
    if response:checkIsSuccessful() then
        game.ui.UIMessageBoxMgr.getInstance():show(("成功提现%s元，已发到微信零钱"):format(response:getRequest():getExtraData().money or 1))
    else
        UtilsFunctions.onEvent("WALLET_WITHDRAW_FAILED")
    end
    self:_sendCGWalletInfoREQ()
end

---@private
---@param response NetworkResponse
function UIWallet:_onGCWalletWithdrawRecordRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIWalletBill", response)
        UtilsFunctions.onEvent("WALLET_SHOW_BILL")
    end
end

---@private
---@param response NetworkResponse
function UIWallet:_onGCWalletConfigRES(response)
    if response:checkIsSuccessful() then
        UIManager:getInstance():show("UIWalletWithdraw", response, self._walletInfo.money)
    end
end

function UIWallet:refreshData()
    local money = 0
    local record = {}
    if self._walletInfo then
        money = self._walletInfo.money
        record = self._walletInfo.record
    end
    self._totalMoney:setStringFormat("%.02f", money * 0.01)
    self._moneyUnit:setAnchorPoint(cc.p(0, 0.5))
    self._moneyUnit:setPositionPercent(cc.p(1, 0.4))
    self._none_node:setVisible(#record == 0)
    UtilsFunctions.resetListViewData(self._list_view, record)
end

---@private
function UIWallet:_getServerId()
    return game.service.LocalPlayerService.getInstance():getGameServerId()
end

---@private
function UIWallet:_showGuide()
    local key = "UIGuide_UIWallet_2"
    if require("app.game.ui.guides.GuideHelper").isNeedGuide(key, 1) then
        ---@type GuideBase
        local ui = UIManager.getInstance():show(key)
        ui:guide(self._btn_withdraw, UtilsFunctions.sizeMul(self._btn_withdraw:getContentSize(), 1.3))
        ui:guide(self._totalMoney, UtilsFunctions.sizeMul(self._totalMoney:getVirtualRendererSize(), 1.3))
    end
end

return UIWallet