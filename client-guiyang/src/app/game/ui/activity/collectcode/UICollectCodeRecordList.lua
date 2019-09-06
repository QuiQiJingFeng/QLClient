local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeRecordList.csb'
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local bindClick = UtilsFunctions.bindClick
local CodeSet = require("app.game.ui.activity.collectcode.CodeSet")
local UICollectCodeRecordList = super.buildUIClass("UICollectCodeRecordList", csbPath)
function UICollectCodeRecordList:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._listViewRecord = ReusedListViewFactory.get(seekNodeByName(self, "ListView", "ccui.ListView"),
    handler(self, self._onRecordListItemInit),
    handler(self, self._onRecordListItemSetData))
end

function UICollectCodeRecordList:onShow(buffer)
    table.sort(buffer.record, function(a, b)
        return a.startTime < b.startTime
    end)
    for idx, item in ipairs(buffer.record) do
        item.__id__ = idx
    end
    UtilsFunctions.resetListViewData(self._listViewRecord, buffer.record)
end

function UICollectCodeRecordList:_onBtnCloseClick()
    self:hideSelf()
end

function UICollectCodeRecordList:_onRecordListItemInit(listItem)
    listItem.codeSet = CodeSet.new(listItem)
    listItem.txtTitle = seekNodeByName(listItem, "Text_Title", "ccui.Text")
    listItem.btnDetail = seekNodeByName(listItem, "Button_Detail", "ccui.Button")
end

function UICollectCodeRecordList:_onRecordListItemSetData(listItem, data, index)
    bindClick(listItem.btnDetail, function()
        UIManager:getInstance():show("UICollectCodeRecordListDetail", data.playerInfo)
    end)

    listItem.codeSet:setCodes(self._service:convertToCodeArray(data.luckyCode))
    local startDate = kod.util.Time.date(data.startTime * 0.001)
    local endDate = kod.util.Time.date(data.endTime * 0.001)
    local str = string.format("第%s期 %s月%s日-%s月%s日中奖码", data.__id__, startDate.month, startDate.day, endDate.month, endDate.day)
    listItem.txtTitle:setString(str)
end

function UICollectCodeRecordList:needBlackMask() return true end

return UICollectCodeRecordList