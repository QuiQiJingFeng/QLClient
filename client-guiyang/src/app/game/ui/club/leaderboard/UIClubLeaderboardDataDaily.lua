local csbPath = "ui/csb/Club/UIClubLeaderboardDataDaily.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardDataDaily = class("UIClubLeaderboardDataDaily", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    数据日报
]]

function UIClubLeaderboardDataDaily:ctor(parent)
    self._parent = parent

    self._listData = ListFactory.get(
        seekNodeByName(self, "ListView_data", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    self._listData:setScrollBarEnabled(false)
end

function UIClubLeaderboardDataDaily:show(clubId)
    self:setVisible(true)
    self._clubId = clubId
    -- 清空列表
    self._listData:deleteAllItems()
end

function UIClubLeaderboardDataDaily:onPlayerInfo(event)
end

function UIClubLeaderboardDataDaily:onPlayerDataInfo(event)
    -- 清空列表
    self._listData:deleteAllItems()
    for k, v in ipairs(event.statisticsInfos) do
        self._listData:pushBackItem(v)
    end
end

function UIClubLeaderboardDataDaily:hied()
    self._listData:deleteAllItems()
    self:setVisible(false)
end

function UIClubLeaderboardDataDaily:_onListViewInit(listItem)
    listItem.time = seekNodeByName(listItem, "Text_time", "ccui.Text") -- 时间
    listItem.onlinePlayer = seekNodeByName(listItem, "Text_onlinePlayer", "ccui.Text") -- 上线玩家
    listItem.playPlayer = seekNodeByName(listItem, "Text_playPlayer", "ccui.Text") -- 打牌玩家
    listItem.roomCount = seekNodeByName(listItem, "Text_roomCount", "ccui.Text") -- 总房间数
    listItem.dissRoom = seekNodeByName(listItem, "Text_dissRoom", "ccui.Text") -- 解散房间
end

function UIClubLeaderboardDataDaily:_onListViewSetData(listItem, data)
    listItem.time:setString(os.date("%Y-%m-%d", data.timeStamp / 1000))
    listItem.onlinePlayer:setString(data.loginRoleCount)
    listItem.playPlayer:setString(data.playRoleCount)
    listItem.roomCount:setString(data.roomCount)
    listItem.dissRoom:setString(data.abnormalRoomCount)
end


return UIClubLeaderboardDataDaily