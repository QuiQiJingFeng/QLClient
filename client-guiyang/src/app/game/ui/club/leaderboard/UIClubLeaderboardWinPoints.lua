local csbPath = "ui/csb/Club/UIClubLeaderboardWinPoints.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardWinPoints = class("UIClubLeaderboardWinPoints", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    赢分累计
]]

function UIClubLeaderboardWinPoints:ctor(parent)
    self._parent = parent

    self._listPoint = ListFactory.get(
        seekNodeByName(self, "ListView_point", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    self._listPoint:setScrollBarEnabled(false)
end

function UIClubLeaderboardWinPoints:show()
    self:setVisible(true)
    -- 清空列表
    self._listPoint:deleteAllItems()
end

function UIClubLeaderboardWinPoints:onPlayerInfo(event)
    -- 清空列表
    self._listPoint:deleteAllItems()

    for k, v in ipairs(event.rankInfos) do
        self._listPoint:pushBackItem(v)
    end
end

function UIClubLeaderboardWinPoints:onPlayerDataInfo(event)
end

function UIClubLeaderboardWinPoints:hied()
    self._listPoint:deleteAllItems()
    self:setVisible(false)
end

function UIClubLeaderboardWinPoints:_onListViewInit(listItem)
    listItem.name = seekNodeByName(listItem, "Text_name", "ccui.Text")
    listItem.id = seekNodeByName(listItem, "Text_id", "ccui.Text")
    listItem.roomCard = seekNodeByName(listItem, "Text_point", "ccui.Text")
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView")
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView")
end

function UIClubLeaderboardWinPoints:_onListViewSetData(listItem, data)
    listItem.name:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.id:setString(data.roleId)
    listItem.roomCard:setString(data.rankDatas[1])
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
end


return UIClubLeaderboardWinPoints