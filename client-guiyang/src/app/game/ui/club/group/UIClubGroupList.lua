local csbPath = "ui/csb/Club/UIClubGroupList.csb"
local UIClubGroupList = class("UIClubGroupList", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")
--[[
    小组列表
]]

function UIClubGroupList:ctor(parent)
    self._parent = parent

    self._listGroups = ListFactory.get(
        seekNodeByName(self, "ListView_groups", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listGroups:setScrollBarEnabled(false)

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

function UIClubGroupList:_onListViewInit(listItem)
    listItem.groupName = seekNodeByName(listItem, "Text_groupName", "ccui.Text") -- 小组名称
    listItem.playerName = seekNodeByName(listItem, "Text_playerName", "ccui.Text") -- 玩家昵称
    listItem.playerId = seekNodeByName(listItem, "Text_playerId", "ccui.Text") -- 玩家id
    listItem.playerCount = seekNodeByName(listItem, "Text_playerCount", "ccui.Text") -- 玩家数量
    listItem.cardRoom = seekNodeByName(listItem, "Text_cardRoom", "ccui.Text") -- 局数
    listItem.winCount = seekNodeByName(listItem, "Text_winCount", "ccui.Text") -- 大赢家数量
    listItem.btnSetting = seekNodeByName(listItem, "Button_setting", "ccui.Button") -- 设置
    listItem.btnMember = seekNodeByName(listItem, "Button_member", "ccui.Button") -- 成员
end

function UIClubGroupList:_onListViewSetData(listItem, data)
    listItem.groupName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.groupName, 8))
    listItem.playerName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.leaderName, 8))
    listItem.playerId:setString(string.format("ID:%s", data.leaderId))
    listItem.playerCount:setString(data.memberCount)
    listItem.cardRoom:setString(data.roomCount)
    listItem.winCount:setString(string.format("%d/%d", data.bigWinCount, data.winnerCount))

    bindEventCallBack(listItem.btnSetting, function()
        local groupInfo =
        {
            groupId = data.groupId,
            leaderId = data.leaderId,
            groupName = data.groupName,
            minWinScore = data.minWinScore,
        }
        local groupType = self._parent:getGroupType()
        self._parent:updataBookMark(groupType[2], groupInfo)
        self._parent:chageItemName(groupType[2].id, "编辑搭档")
    end, ccui.TouchEventType.ended)

    bindEventCallBack(listItem.btnMember, function ()
        UIManager:getInstance():show("UIClubGroupMemberInfo", self._parent:getClubId(), data.groupId, data.groupName)
        UIManager:getInstance():hide("UIClubGroupMain")
    end, ccui.TouchEventType.ended)
end

function UIClubGroupList:show()
    self:setVisible(true)
    self._listGroups:deleteAllItems()
    
    local nowTime = math.floor(game.service.TimeService:getInstance():getCurrentTime())
    local hour = tonumber(os.date("%H", nowTime))
    local minute = tonumber(os.date("%M", nowTime))
    local startTime = nowTime - (hour * 60 * 60)
    local endTime = nowTime + (minute > 0 and 60 * 60 or 0)
    self:_updataTime(startTime, endTime)
    self:_sendClubGroupList(startTime * 1000, endTime * 1000)

    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener("EVENT_CLUB_GROUP_LIST", handler(self, self._initClubGroupList), self)
    
end

function UIClubGroupList:_initClubGroupList(event)
    self._listGroups:deleteAllItems()

    local text = string.format("总局数合计:%d\n大赢家总计:%d/%d", event.groups.totalRoomCount, event.groups.totalBigWinCount, event.groups.totalWinnerCount)

    self._textInfo:setString(text)

    if #event.groups.groupList < 1 then
        return
    end

    -- 排序按照时间先后
    table.sort(event.groups.groupList, function(a, b)
        return a.createTime < b.createTime
    end)

    for _, data in ipairs(event.groups.groupList) do
        self._listGroups:pushBackItem(data)
    end
end

function UIClubGroupList:_onClickInquire()
    local time = math.floor(game.service.TimeService:getInstance():getCurrentTime())
    local minute = tonumber(os.date("%M", time))
    local nowTime = (time + (minute > 0 and 60 * 60 or 0)) * 1000
    UIManager:getInstance():show("UIClubLeaderboardTime", nowTime - 86400000 * 6, nowTime, function(startTime, endTime)
        self:_updataTime(startTime / 1000, endTime / 1000)
        self:_sendClubGroupList(startTime, endTime)
    end)
end

-- 请求俱乐部小组列表
function UIClubGroupList:_sendClubGroupList(startTime, endTime)
    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLQueryClubGroupListREQ(self._parent:getClubId(), startTime, endTime)
end

-- 更新按钮显示时间
function UIClubGroupList:_updataTime(startTime, endTime)
    self._textStartTime:setString(os.date("%m.%d %H:00", startTime))
    self._textEndTime:setString(os.date("%m.%d %H:00", endTime))
end

function UIClubGroupList:_onClickPrompt()
    local text = "总局数:搭档所属成员参与的房间数累计\n大赢家:搭档所属成员获得的大赢家次数，以及超过预设分数额外记录的大赢家次数"
    game.ui.UIMessageBoxMgr.getInstance():show(text, {"确认"}, function() end, function() end, false, false, 0)
end

function UIClubGroupList:hide()
    self._listGroups:deleteAllItems()

    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)

    self:setVisible(false)
end

return UIClubGroupList