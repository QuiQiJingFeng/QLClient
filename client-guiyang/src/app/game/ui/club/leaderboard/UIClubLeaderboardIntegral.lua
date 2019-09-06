local csbPath = "ui/csb/Club/UIClubLeaderboardIntegral.csb"
local super = require("app.game.ui.UIBase")
local UIClubLeaderboardIntegral = class("UIClubLeaderboardIntegral", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    积分累计
]]

function UIClubLeaderboardIntegral:ctor(parent)
    self._parent = parent

    self._listIntegral = ListFactory.get(
        seekNodeByName(self, "ListView_integral", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )

    self._listIntegral:setScrollBarEnabled(false)
end

function UIClubLeaderboardIntegral:show()
    self:setVisible(true)
    -- 清空列表
    self._listIntegral:deleteAllItems()
end

function UIClubLeaderboardIntegral:onPlayerInfo(event)
    -- 清空列表
    self._listIntegral:deleteAllItems()

    -- 产品要求特殊排序一下(正积分玩家 > 负积分玩家 > 0积分玩家)
    local tableNotZero = {}
    local tableZero = {}
    -- 前期做过倒序，所以现在只要把积分为0的数据拿出来即可
    for _, v in ipairs(event.rankInfos) do
        if v.rankDatas[1] == 0 then
            table.insert(tableZero, v)
        else
            table.insert(tableNotZero, v)
        end
    end
    -- 合并table
    table.insertto(tableNotZero, tableZero, #tableNotZero + 1)

    for k, v in ipairs(tableNotZero) do
        self._listIntegral:pushBackItem(v)
    end
end

function UIClubLeaderboardIntegral:onPlayerDataInfo(event)
end

function UIClubLeaderboardIntegral:hied()
    self._listIntegral:deleteAllItems()
    self:setVisible(false)
end

function UIClubLeaderboardIntegral:_onListViewInit(listItem)
    listItem.name = seekNodeByName(listItem, "Text_name", "ccui.Text")
    listItem.id = seekNodeByName(listItem, "Text_id", "ccui.Text")
    listItem.roomCard = seekNodeByName(listItem, "Text_integral", "ccui.Text")
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView")
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView")
end

function UIClubLeaderboardIntegral:_onListViewSetData(listItem, data)
    listItem.name:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.id:setString(data.roleId)
    listItem.roomCard:setString(data.rankDatas[1])
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
end


return UIClubLeaderboardIntegral