local csbPath = "ui/csb/Club/UIClubLeaderboardRoomCard.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardRoomCard = class("UIClubLeaderboardRoomCard", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    牌局统计
]]

function UIClubLeaderboardRoomCard:ctor(parent)
    self._parent = parent

    self._listRoomCard = ListFactory.get(
        seekNodeByName(self, "ListView_roomCard", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    self._listRoomCard:setScrollBarEnabled(false)
end

function UIClubLeaderboardRoomCard:show()
    self:setVisible(true)
     -- 清空列表
    self._listRoomCard:deleteAllItems()
end

function UIClubLeaderboardRoomCard:onPlayerInfo(event)
    -- 清空列表
    self._listRoomCard:deleteAllItems()

    for k, v in ipairs(event.rankInfos) do
        self._listRoomCard:pushBackItem(v)
    end
end

function UIClubLeaderboardRoomCard:onPlayerDataInfo(event)
end

function UIClubLeaderboardRoomCard:hied()
    self._listRoomCard:deleteAllItems()
    self:setVisible(false)
end

function UIClubLeaderboardRoomCard:_onListViewInit(listItem)
    listItem.name = seekNodeByName(listItem, "Text_name", "ccui.Text")
    listItem.id = seekNodeByName(listItem, "Text_id", "ccui.Text")
    listItem.roomCard = seekNodeByName(listItem, "Text_roomCard", "ccui.Text")
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView")
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView")
end

function UIClubLeaderboardRoomCard:_onListViewSetData(listItem, data)
    listItem.name:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.id:setString(data.roleId)
    listItem.roomCard:setString(data.rankDatas[1])
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
end


return UIClubLeaderboardRoomCard