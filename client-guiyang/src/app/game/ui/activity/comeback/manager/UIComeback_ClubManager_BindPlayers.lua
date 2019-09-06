local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local ReusedListViewFactory = require("app.game.util.ReusedListViewFactory")
local csbPath = 'ui/csb/Activity/Comeback/UIComeback_ClubManager_BindPlayers.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIComeback_ClubManager_BindPlayers", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    self._listView = ReusedListViewFactory.get(
    seekNodeByName(self, "ListView", "ccui.ListView"),
    handler(self, self._onListItemInit),
    handler(self, self._onListItemSetData),
    "BindPlayerList"
    )
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnClose))
    UtilsFunctions.createListViewEmptyText(self._listView, config.STRING.ACTIVITY_COMEBACK_NO_BINDER, 24, cc.c3b(255, 255, 255))
end

function M:onDestroy()
    UtilsFunctions.destroyListViewEmptyText(self._listView)
end

function M:onShow(args)
    self._increaseNum = args.increaseCard or 1
    self._listView:deleteAllItems()
    local names = args.names or {}
    self._listView.emptyText:setVisible(#names == 0)
    for idx, name in ipairs(names) do
        self._listView:pushBackItem({ idx, name })
    end
end

function M:onHide()
end

function M:_onListItemInit(listItem)
    listItem.textName = seekNodeByName(listItem, "Text_Name", "ccui.Text")
    listItem.textPosition = seekNodeByName(listItem, "Text_Position", "ccui.Text")
    listItem.textReward = seekNodeByName(listItem, "Text_Reward", "ccui.Text")
end

function M:_onListItemSetData(listItem, data)
    local idx = data[1] or 0
    -- 回流玩家只能点亮从第二盏灯开始，所以 + 1
    idx = idx + 1
    local name = data[2] or ""
    local count = idx * self._increaseNum

    listItem.textName:setString(name)
    listItem.textPosition:setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_POSITION_FORMAT, idx))
    listItem.textReward:setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_REWARD_FORMAT, count))
end

function M:_onBtnClose(sender)
    self:hideSelf()
end

function M:needBlackMask() return true end

return M