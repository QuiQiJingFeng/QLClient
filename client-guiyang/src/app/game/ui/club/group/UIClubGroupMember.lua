local csbPath = "ui/csb/Club/UIClubGroupMember.csb"
local UIClubGroupMember = class("UIClubGroupMember", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")
--[[
    小组成员列表
]]

function UIClubGroupMember:ctor(parent)
    self._parent = parent

    self._listPlayers = ListFactory.get(
        seekNodeByName(self, "ListView_playerInfo", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listPlayers:setScrollBarEnabled(false)

    self._textInfo = seekNodeByName(self, "Text_info", "ccui.Text")
    self._btnStartTime = seekNodeByName(self, "Button_startTime", "ccui.Button") -- 开始时间按钮
    self._btnEndTime = seekNodeByName(self, "Button_endTime", "ccui.Button") -- 结束时间按钮
    self._btnInquire = seekNodeByName(self, "Button_inquire", "ccui.Button") -- 搜索按钮
    self._textStartTime = seekNodeByName(self, "BitmapFontLabel_startTime", "ccui.TextBMFont") -- 开始时间文字
    self._textEndTime = seekNodeByName(self, "BitmapFontLabel_endTime", "ccui.TextBMFont") -- 开始时间文字
    self._btnPrompt = seekNodeByName(self, "Button_prompt", "ccui.Button") -- 提示按钮

    bindEventCallBack(self._btnStartTime, handler(self, self._onClickInquire), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEndTime, handler(self, self._onClickInquire), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInquire, handler(self, self._onClickInquire), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPrompt, handler(self, self._onClickPrompt), ccui.TouchEventType.ended)
end

function UIClubGroupMember:_onListViewInit(listItem)
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView") -- 头像
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView") -- 头像框
    listItem.playerName = seekNodeByName(listItem, "Text_playerName", "ccui.Text") -- 玩家昵称
    listItem.playerId = seekNodeByName(listItem, "Text_playerId", "ccui.Text") -- 玩家id
    listItem.cardRoom = seekNodeByName(listItem, "Text_cardRoom", "ccui.Text") -- 局数
    listItem.winCount = seekNodeByName(listItem, "Text_winCount", "ccui.Text") -- 大赢家数量
    listItem.btnOut = seekNodeByName(listItem, "Button_out", "ccui.Button") -- 踢出
end

function UIClubGroupMember:_onListViewSetData(listItem, data)
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
    listItem.playerName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.playerId:setString(data.roleId)
    listItem.cardRoom:setString(data.roomCount)
    listItem.winCount:setString(string.format("%d/%d", data.bigWinCount, data.winCount))

    listItem.btnOut:setVisible(data.roleId ~= game.service.LocalPlayerService:getInstance():getRoleId())

    bindEventCallBack(listItem.btnOut, function()
        self:_onClickOut(data)
    end, ccui.TouchEventType.ended)
end

function UIClubGroupMember:_onClickOut(data)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Group_Out)

    game.ui.UIMessageBoxMgr.getInstance():show(
        "踢出玩家后，玩家会与该搭档解除绑定，是否确认踢出？",
        {"确认", "取消"},
        function()
            game.service.club.ClubService.getInstance():getClubGroupService():sendCCLModifyGroupMemberREQ(self._parent:getClubId(), 2, data.roleId, game.service.club.ClubService.getInstance():getGroupId(self._parent:getClubId()))
        end,
        function()
        end
    )
end

function UIClubGroupMember:show()
    self:setVisible(true)
    self._listPlayers:deleteAllItems()

    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener("EVENT_CLUB_GROUP_PLAYER_INFO_CHAGE", handler(self, self._initPlayerInfo), self)
    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener("EVENT_CLUB_GROUP_MEMBER_INFO_CHANGE", handler(self, self._updataPlayerInfo), self)

    local nowTime = math.floor(game.service.TimeService:getInstance():getCurrentTime())
    local hour = tonumber(os.date("%H", nowTime))
    local minute = tonumber(os.date("%M", nowTime))
    local startTime = nowTime - (hour * 60 * 60)
    local endTime = nowTime + (minute > 0 and 60 * 60 or 0)
    self:_updataTime(startTime, endTime)
    self:_sendClubGroupPlayerList(startTime * 1000, endTime * 1000)

end

-- 请求玩家信息
function UIClubGroupMember:_sendClubGroupPlayerList(startTime, endTime)
   game.service.club.ClubService.getInstance():getClubGroupService():sendCCLQueryGroupMembersREQ(
       self._parent:getClubId(),
       game.service.club.ClubService.getInstance():getGroupId(self._parent:getClubId()),
       startTime,
       endTime
    )
end

-- 初始化玩家列表
function UIClubGroupMember:_initPlayerInfo(event)
    self._listPlayers:deleteAllItems()

    self._textInfo:setString(
        string.format(
            "总局数合计:%d\n大赢家合计:%d/%d",
            event.playerInfo.totalRoomCount,
            event.playerInfo.totalBigWinCount,
            event.playerInfo.totalWinCount
        )
    )

    if #event.playerInfo.memberInfos < 1 then
        return
    end

    -- 玩家排序
    table.sort(event.playerInfo.memberInfos, function(a, b)
        if a.roomCount == b.roomCount then
            return a.roleId < b.roleId
        end

        return a.roomCount < b.roomCount
    end)


    for _, data in ipairs(event.playerInfo.memberInfos) do
        self._listPlayers:pushBackItem(data)
    end
end

-- 玩家被踢出更新玩家列表
function UIClubGroupMember:_updataPlayerInfo(event)
    local index, item = self:_indexOfItem(event.roleId)
    if index then
        self._listPlayers:deleteItem(index)
    end
end

-- 获取item数据
function UIClubGroupMember:_indexOfItem(roleId)
    for idx, item in ipairs(self._listPlayers:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

-- 显示时间滚轮
function UIClubGroupMember:_onClickInquire()
    local time = math.floor(game.service.TimeService:getInstance():getCurrentTime())
    local minute = tonumber(os.date("%M", time))
    local nowTime = (time + (minute > 0 and 60 * 60 or 0)) * 1000
    UIManager:getInstance():show("UIClubLeaderboardTime", nowTime - 86400000 * 6, nowTime, function(startTime, endTime)
        self:_updataTime(startTime / 1000, endTime / 1000)
        self:_sendClubGroupPlayerList(startTime, endTime)
    end)
end

function UIClubGroupMember:_onClickPrompt()
    local text = "总局数:搭档所属成员参与的房间数累计\n大赢家:搭档所属成员获得的大赢家次数，以及超过预设分数额外记录的大赢家次数"
    game.ui.UIMessageBoxMgr.getInstance():show(text, {"确认"}, function() end, function() end, false, false, 0)
end


-- 更新按钮显示时间
function UIClubGroupMember:_updataTime(startTime, endTime)
    self._textStartTime:setString(os.date("%m.%d %H:00", startTime))
    self._textEndTime:setString(os.date("%m.%d %H:00", endTime))
end

function UIClubGroupMember:hide()
    self._listPlayers:deleteAllItems()
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)

    self:setVisible(false)
end

return UIClubGroupMember