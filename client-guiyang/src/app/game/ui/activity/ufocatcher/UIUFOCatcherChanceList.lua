local BuyHook = 0xFF
local TaskTitleFormat = {
    [5] = "好友局 %s 局",
    [7] = "比赛场 %s 局",
    [8] = "金币场 %s 局",
    [BuyHook] = "购买金爪子",
}
local TaskClickCallbacks = {
    [5] = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.club)
    end,
    [7] = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.campaign)
    end,
    [8] = function()
        uiSkip.UISkipTool.skipTo(uiSkip.SkipType.gold)
    end,
}
local CurrencyHelper = require("app.game.util.CurrencyHelper")
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local bindClick = UtilsFunctions.bindClick
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherChanceList.csb"

---@class UIUFOCatcherChanceList:UIBase
local UIUFOCatcherChanceList = super.buildUIClass("UIUFOCatcherChanceList", csbPath)
function UIUFOCatcherChanceList:init()
    ---@type UFOCatcherActivityService
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.UFO_CATCHER)
    -- close button
    UtilsFunctions.attachCloseButton(self, true)

    UtilsFunctions.attachCloseButton(self, true, "Button_Ensure")

    -- reused list
    self._listView = ReusedListViewFactory.get(seekNodeByName(self, "ListView"),
            function(listItem)
                listItem.title = seekNodeByName(listItem, "Text_Title")
                listItem.btn = seekNodeByName(listItem, "Button")
                listItem.btnText = seekNodeByName(listItem, "Text_Button")
                bindClick(listItem.btn, handler(self, self._onTaskItemClicked))
            end,
            function(listItem, data)
                listItem.btn.data = data
                if data.taskType == BuyHook then
                    listItem.title:setString(TaskTitleFormat[data.taskType])
                    listItem.btnText:setStringFormat("%s%s", data.price,
                            CurrencyHelper.getInstance():getCurrencyZhName(CurrencyHelper.CURRENCY_TYPE.CARD))
                else
                    listItem.title:setStringFormat(TaskTitleFormat[data.taskType], data.allCount)
                    listItem.btnText:setStringFormat("%s/%s", data.finishCount, data.allCount)
                end
            end)
end

---@private
function UIUFOCatcherChanceList:_onTaskItemClicked(sender)
    local taskData = sender.data
    if taskData.taskType == BuyHook then
        local helper = CurrencyHelper.getInstance()
        local currencyType = CurrencyHelper.CURRENCY_TYPE.CARD
        local currencyName = helper:getCurrencyZhName(currencyType)
        local msg
        local btnNames
        local callback1
        local callback2
        if helper:getCurrencyCount(currencyType) < taskData.price then
            msg = ("您的%s不足，是否前往商城购买"):format(currencyName)
            btnNames = { "确定", "前往商城" }
            callback1 = function()
            end
            callback2 = function()
                helper:queryCurrency(currencyType)
            end
        else
            msg = ("是否使用%s%s购买1个金爪子，\n金爪子更牢固，抓奖更容易哦!"):format(taskData.price, currencyName)
            btnNames = { "确定", "取消" }
            callback2 = function()
            end
            callback1 = function()
                self._service:sendCACBuyCatchDollREQ()
            end
        end
        game.ui.UIMessageBoxMgr.getInstance():show(msg, btnNames, callback1, callback2)
    else
        local func = TaskClickCallbacks[taskData.taskType]
        if func then
            func()
        end
    end
    self:hideSelf()
end

function UIUFOCatcherChanceList:onShow(buffer)
    -- 加入直接买爪子的
    table.insert(buffer.tasks, {
        taskType = BuyHook,
        price = buffer.countPrice,
    })
    UtilsFunctions.resetListViewData(self._listView, buffer.tasks)
    game.service.TDGameAnalyticsService.getInstance():onEvent("UFOCatcher_ChanceListShow")
end

function UIUFOCatcherChanceList:needBlackMask()
    return true
end

return UIUFOCatcherChanceList