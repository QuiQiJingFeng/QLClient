local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherRecord.csb"

---@class UIUFOCatcherRecord:UIBase
local UIUFOCatcherRecord = super.buildUIClass("UIUFOCatcherRecord", csbPath)
function UIUFOCatcherRecord:init()
    UtilsFunctions.attachCloseButton(self, true)

    self._listView = ReusedListViewFactory.get(seekNodeByName(self, "ListView_Items"),
            handler(self, self._onListItemInit),
            handler(self, self._onListItemSetData))
    self._emptyPrompt = seekNodeByName(self, "ListView_None")
end

function UIUFOCatcherRecord:onShow(buffer)
    UtilsFunctions.resetListViewData(self._listView, buffer.records, true)
    self._emptyPrompt:setVisible(#buffer.records == 0)
    game.service.TDGameAnalyticsService.getInstance():onEvent("UFOCatcher_Record_Show")
end

function UIUFOCatcherRecord:onHide()
end

function UIUFOCatcherRecord:onDestroy()
end

function UIUFOCatcherRecord:_onListItemInit(listItem)
    listItem.date = seekNodeByName(listItem, "Date")
    listItem.desc = seekNodeByName(listItem, "Desc")
    listItem.btn = seekButton(listItem, "Button", function(sender)
        local wechat = MultiArea.getConfigByKey("activityRedpackWechat")
        game.ui.UIMessageBoxMgr.getInstance():show(("请到公众号 %s 领取"):format(wechat), { "复制" }, function()
            if game.plugin.Runtime.setClipboard(wechat) then
                game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
            end
        end)
        self:hideSelf()
    end)
end

function UIUFOCatcherRecord:_onListItemSetData(listItem, data)
    listItem.desc:setString(PropReader.generatePropTxt({ data }))
    listItem.date:setString(os.date("%m-%d %H:%M:%S", data.catchTime * 0.001))
    listItem.btn.data = data
    listItem.btn:setVisible(PropReader.getTypeById(data.itemId) == "RedPackage")
end


function UIUFOCatcherRecord:needBlackMask()
    return true
end

return UIUFOCatcherRecord