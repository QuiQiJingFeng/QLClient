local csbPath = "ui/csb/Club/UILeaderboardActivityToday.csb"
local M = class("UILeaderboardActivityToday", function() return cc.CSLoader:createNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    俱乐部排行榜信息
]]

--颜色配置
local color = 
{
    -- list
    cc.c3b(185, 87, 69), -- 第一
    cc.c3b(78, 104, 143), -- 第二
    cc.c3b(60, 150, 117), -- 第三
    cc.c3b(163, 113, 70), -- 其他
}

function M:ctor(parent)
    self._parent = parent

    self._listActivityData = ListFactory.get(
        seekNodeByName(self, "ListView_activityInfo", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listActivityData:setScrollBarEnabled(false)
    self._myId = seekNodeByName(self, "BitmapFontLabel_rank", "ccui.TextBMFont")
    self._myClubName = seekNodeByName(self, "Text_myClubName", "ccui.Text") -- 我俱乐部的名称
    self._myTodayIntegral = seekNodeByName(self, "Text_myTodayIntegral", "ccui.Text") -- 我今天积分
    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text") -- 提示
    self._btnJump = seekNodeByName(self, "Button_jump", "ccui.Button") -- 跳转
    -- self._imgBg = seekNodeByName(self, "Image_bg", "ccui.ImageView")
    self._imgTop = seekNodeByName(self, "Image_Top", "ccui.ImageView")

    bindEventCallBack(self._btnJump, handler(self, self._onBtnJumpClick), ccui.TouchEventType.ended)
end

function M:_onBtnJumpClick()
    local count = #self._listActivityData:getItemDatas()
    local rank = self._rank
    if rank > (count / 2) then
        rank = (rank + 1) > 100 and 100 or (rank + 1)
    elseif rank < (count / 2) then
        rank = (rank - 1) < 0 and 0 or (rank - 1)
    end
    self._listActivityData:jumpToPercentVertical(rank / count * 100)
end

function M:_onListViewInit(listItem)
    listItem.textId = seekNodeByName(listItem, "BitmapFontLabel_id", "ccui.TextBMFont") -- 排名
    listItem.textClubName = seekNodeByName(listItem, "Text_clubName", "ccui.Text") -- 俱乐部名称
    listItem.TextTodayIntegral = seekNodeByName(listItem, "Text_todayIntegral", "ccui.Text") -- 今日积分
    listItem.textReward_Manager = seekNodeByName(listItem, "Text_Reward_Manager", "ccui.Text") -- 经理奖励
    listItem.textReward_Member = seekNodeByName(listItem, "Text_Reward_Member", "ccui.Text") -- 成员奖励
    listItem.imgIcon = seekNodeByName(listItem, "Image_icon", "ccui.ImageView") -- 前三名的icon
end

function M:_onListViewSetData(listItem, data)
    -- 改变前三名字体颜色
    if data.rank > 0 and data.rank < 4 then
        listItem.textId:setVisible(false)
        listItem.imgIcon:setVisible(true)
        listItem.imgIcon:loadTexture(string.format("art/activity/phs/img_phs_icon_%d.png", data.rank))
        listItem.textClubName:setColor(color[data.rank])
        listItem.TextTodayIntegral:setColor(color[data.rank])
        listItem.textReward_Manager:setColor(color[data.rank])
        listItem.textReward_Member:setColor(color[data.rank])
    else
        listItem.imgIcon:setVisible(false)
        listItem.textId:setVisible(true)
        listItem.textClubName:setColor(color[4])
        listItem.TextTodayIntegral:setColor(color[4])
        listItem.textReward_Manager:setColor(color[4])
        listItem.textReward_Member:setColor(color[4])
    end

    if self._rank > 0 and self._rewardRank ~= 0 and self._rank <= self._rewardRank and self._rank == data.rank then
        listItem:setBackGroundImage("art/activity/phs/img_phs_list-1.png")
    else
        listItem:setBackGroundImage("art/activity/phs/img_phs_list-0.png")
    end
    
    listItem.textId:setString(data.rank)
    listItem.textClubName:setString(game.service.club.ClubService.getInstance():getShieldString(data.clubName))
    listItem.TextTodayIntegral:setString(data.score)
    listItem.textReward_Manager:setString(data.managerReward)
    listItem.textReward_Member:setString(data.memberReward)

    bindEventCallBack(listItem, function()
        game.service.club.ClubService.getInstance():getClubActivityService():sendCCLQueryClubRankInfoREQ(data.clubId, data.rankType, data.clubName, data.clubIcon)
    end, ccui.TouchEventType.ended)
end

function M:show(id)
    self:setVisible(true)
    self._btnJump:setVisible(false)
    self._textTips:setVisible(false)
    self._myClubName:setVisible(false)
    self._myTodayIntegral:setVisible(false)
    self._myId:setString("")
    self._imgTop:loadTexture(id == 1 and "art/activity/phs/img_phs_qzjl.png" or "art/activity/phs/img_phs_qzjl2.png")

    self._listActivityData:deleteAllItems()
    self._rank = 0
    self._rewardRank = 0

    game.service.club.ClubService.getInstance():getClubActivityService():addEventListener(
        "EVENT_CLUB_RANK_LIST",
        handler(self, self._onEventClubRankInfo),
        self)

    game.service.club.ClubService.getInstance():getClubActivityService():sendCCLQueryClubRankListREQ(id)
end

function M:_onEventClubRankInfo(event)
    self._myId:setString("未上榜")
    self._myId:setScale(0.4, 0.4)
    if event.data.selfRankInfo ~= nil then
        self._myClubName:setVisible(true)
        self._myTodayIntegral:setVisible(true)
        self._rank = event.data.selfRankInfo.rank
        self._rewardRank = event.data.rewardRank
        self._myClubName:setString(event.data.selfRankInfo.clubName)
        self._myTodayIntegral:setString(event.data.selfRankInfo.score)
        self._textTips:setVisible(event.data.rewardRank < event.data.selfRankInfo.rank and event.data.selfRankInfo.rank <= event.data.maxRank and event.data.selfRankInfo.rank ~= 0)
        self._btnJump:setVisible(event.data.selfRankInfo.rank <= event.data.rewardRank and event.data.selfRankInfo.rank ~= 0)
        if event.data.selfRankInfo.rank ~= 0 and event.data.selfRankInfo.rank <= event.data.maxRank then
            self._myId:setString(event.data.selfRankInfo.rank)
            self._myId:setScale(0.6, 0.6)
        end
    end
    
    self._listActivityData:deleteAllItems()
    for _, rankInfo in ipairs(event.data.rankInfos) do
        self._listActivityData:pushBackItem(rankInfo)
    end
end

function M:hide()
    game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)
    self._listActivityData:deleteAllItems()
    self:setVisible(false)
end

return M