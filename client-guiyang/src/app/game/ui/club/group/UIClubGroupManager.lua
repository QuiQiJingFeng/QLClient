local csbPath = "ui/csb/Club/UIClubGroupManager.csb"
local UIClubGroupManager = class("UIClubGroupManager", function() return cc.CSLoader:createNode(csbPath) end)

--[[
    组长管理小组界面
]]

function UIClubGroupManager:ctor(parent)
    self._parent = parent

    self._textInfo = seekNodeByName(self, "Text_info", "ccui.Text")
    self._btnImport = seekNodeByName(self, "Button_import", "ccui.Button")
    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button")

    bindEventCallBack(self._btnImport, handler(self, self._onClickImport), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite, handler(self, self._onClickInvite), ccui.TouchEventType.ended)
end

function UIClubGroupManager:show()
    self:setVisible(true)
    -- 邀请暂时不做
    -- self._btnInvite:setVisible(false)
    -- self._btnImport:setPositionPercent(cc.p(0.5, 0.3))
    self._textInfo:setString("")

    game.service.club.ClubService.getInstance():getClubGroupService():sendCCLQueryGroupInfoREQ(
        self._parent:getClubId(),
        game.service.club.ClubService.getInstance():getGroupId(self._parent:getClubId())    
    )

    game.service.club.ClubService.getInstance():getClubGroupService():addEventListener("EVENT_CLUB_GROUP_MANAGER_INFO", handler(self, self._initGroupInfo), self)
end

function UIClubGroupManager:_initGroupInfo(event)
    local text = string.format(
        "搭档:%s\n\n我的成员:%s\n\n大赢家分数超%s分额外记录\n\n创建时间:%s",
        event.groupInfo.leaderName,
        event.groupInfo.memberCount,
        event.groupInfo.minWinnerScore,
        os.date("%Y-%m-%d", event.groupInfo.createTime / 1000)
    )
    self._textInfo:setString(text)
end

function UIClubGroupManager:_onClickImport()
    UIManager:getInstance():show("UIClubGroupImportList", self._parent:getClubId())
end

function UIClubGroupManager:_onClickInvite()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Group_Invite)
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    local idx = clubList:indexOfClub(self._parent:getClubId())
    UIManager:getInstance():show("UIClubWeChatInvited", clubList.clubs[idx], false)
end

function UIClubGroupManager:hide()
    game.service.club.ClubService.getInstance():getClubGroupService():removeEventListenersByTag(self)

    self:setVisible(false)
end

return UIClubGroupManager