local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeMyCode_Being.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local bindClick = UtilsFunctions.bindClick
local CodeSet = require("app.game.ui.activity.collectcode.CodeSet")
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local UICollectCodeMyCode_Being = super.buildUIClass("UICollectCodeMyCode_Being", csbPath)
function UICollectCodeMyCode_Being:init()
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._textRule = seekNodeByName(self, "Text_Rule", "ccui.Text")
    bindClick(self._textRule, handler(self, function()
        UIManager:getInstance():show("UICollectCodeHelp", true)
    end))
    self._textStatus = seekNodeByName(self, "Text_Code_Status", "ccui.Text")

    self._codeListView = ReusedListViewFactory.get(seekNodeByName(self, "ListView_Code", "ccui.ListView"),
    handler(self, self._onListViewItemInit),
    handler(self, self._onListItemSetData))
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
end

function UICollectCodeMyCode_Being:onShow(codes)
    UtilsFunctions.resetListViewData(self._codeListView, codes)

    local len = #codes
    self._textStatus:setString(string.format("已获得%s组幸运码 状态：未开奖", len))
end

function UICollectCodeMyCode_Being:_onBtnCloseClick()
    self:hideSelf()
end

function UICollectCodeMyCode_Being:_onListViewItemInit(listItem)
    listItem.codeSet = CodeSet.new(listItem)
end

function UICollectCodeMyCode_Being:_onListItemSetData(listItem, data)
    local codeArray = self._service:convertToCodeArray(data.code)
    listItem.codeSet:setCodes(codeArray)
end


function UICollectCodeMyCode_Being:needBlackMask() return true end

return UICollectCodeMyCode_Being