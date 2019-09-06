local csbPath = "ui/csb/Club/UIClubMemberInfo.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    玩家信息界面
]]

local UIClubMemberInfo = class("UIClubMemberInfo", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubMemberInfo:ctor()
end

function UIClubMemberInfo:init()
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
	self._btnRecord = seekNodeByName(self, "Button_record", "ccui.Button") -- 战绩
	self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button") -- 退出亲友圈
    self._textPlayInfo = seekNodeByName(self, "Text_playerInfo", "ccui.Text") -- 玩家信息
    self._textCardCountInfo = seekNodeByName(self, "Text_cardCountInfo", "ccui.Text") -- 牌局信息
    self._imgRealName = seekNodeByName(self, "Image_11", "ccui.ImageView")
    self._btnAddFriend = seekNodeByName(self, "Button_addFriend", "ccui.Button") -- 加好友
    
    bindEventCallBack(self._btnRecord, handler(self, self._onClickRecord), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnAddFriend, handler(self, self._onClickAddFriend), ccui.TouchEventType.ended)
end

function UIClubMemberInfo:onShow(data, isPermissions)
    self._data = data
    self._btnAddFriend:setVisible(false)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_CHECK_FRIEND_SHIP", handler(self, self._isFriend), self)
    -- 如果自己看自己就不向服务器验证是否有好友关系
    -- if self._data.roleId ~= localRoleId then
    --     game.service.friend.FriendService.getInstance():sendCGCheckFriendShipREQ(self._data.roleId)
    -- end
    self._btnRecord:setVisible(isPermissions)
    self._btnQuit:setVisible(self._data.roleId == localRoleId and self._data.title ~= ClubConstant:getClubPosition().MANAFER)

    local playInfo = string.format("\n%s\n\n%d",
        game.service.club.ClubService.getInstance():getInterceptString(self._data.roleName, 8),
        self._data.roleId
    )

    local cardCountInfo = string.format("\n今日牌局数:%d\n昨日牌局数:%d\n七日牌局数:%d",
        self._data.todayRoomCount,
        self._data.yesterdayRoomCount,
        self._data.sevenDayRoomCount
    )

    if isPermissions then
        local inviterName = game.service.club.ClubService.getInstance():getInterceptString(self._data.inviterName, 8)
        local admissionMethod = self._data.title == ClubConstant:getClubPosition().MANAFER and config.STRING.UICLUBMEMBERINFO_STRING_100 or self._data.joinType == ClubConstant:getAdmissionMethod().InvitePeople and string.format("%s%s", inviterName, "邀请") or "邀请码入会"
        playInfo = string.format("%s\n%s\n%d\n%s",
            game.service.club.ClubService.getInstance():getInterceptString(self._data.roleName, 8),
            self._data.remark == "" and "无" or self._data.remark,
            self._data.roleId,
            admissionMethod
        )
        
        cardCountInfo = string.format("\n昨日/今日牌局数:%d/%d\n昨日/今日胜场数:%d/%d\n昨日/今日开房数:%d/%d",
            self._data.yesterdayRoomCount, self._data.todayRoomCount,
            self._data.yesterdayWinCount, self._data.todayWinCount,
            self._data.yesterdayCreateRoomCount, self._data.todayCreateRoomCount
        )
    end

    self._textPlayInfo:setString(playInfo)
    self._textCardCountInfo:setString(cardCountInfo)

    self._imgRealName:setVisible(self._data.isRealNameAuth or false)

    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, self._data.roleIcon)
    game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead,PropReader.getIconById(self._data.headFrameId),0.95)
end

function UIClubMemberInfo:_onClickRecord()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Club_MemberInfo_Record)
    UIManager:getInstance():show("UIClubPersonalRecord", self._data.clubId, self._data.roleId)
    UIManager:getInstance():hide("UIClubMemberInfo")
    UIManager:getInstance():hide("UIClubMemberPage")
end

-- 玩家自己退出
function UIClubMemberInfo:_onClickQuit()
	game.ui.UIMessageBoxMgr.getInstance():show(config.STRING.UICLUBMEMBERINFO_STRING_101 , {"确定","取消"}, function()
        game.service.club.ClubService.getInstance():getClubMemberService():sendCCLQuitClubREQ(self._data.clubId)
        self:_onClickCancel()
    end)
end

function UIClubMemberInfo:_onClickAddFriend()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Club_AddFriend)
    game.service.friend.FriendService.getInstance():sendCGSendFriendApplicantREQ(self._data.roleId, game.service.friend.FRIEND_APPLICANT_SOURCE.CLUB_MEMBER)
end

function UIClubMemberInfo:_onClickCancel()
    UIManager:getInstance():destroy("UIClubMember_Search")
end

function UIClubMemberInfo:_isFriend(event)
    self._btnAddFriend:setVisible(not event.isFriend)
end

function UIClubMemberInfo:onHide()
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
end

function UIClubMemberInfo:needBlackMask()
	return true
end

function UIClubMemberInfo:closeWhenClickMask()
	return true
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubMemberInfo:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubMemberInfo
