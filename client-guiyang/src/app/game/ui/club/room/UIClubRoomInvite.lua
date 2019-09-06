local csbPath = "ui/csb/Club/UIClubRoomInvite.csb"
local super = require("app.game.ui.UIBase")
local UIClubRoomInvite = class("UIClubRoomInvite", super, function() return kod.LoadCSBNode(csbPath) end)
local RoomSettingHelper = require("app.game.ui.RoomSettingHelper").RoomSettingHelper
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
--[[
    在线邀请玩家
]]
function UIClubRoomInvite:ctor()
end

function UIClubRoomInvite:init()
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
    self._imgHeadBox = seekNodeByName(self, "Image_headBox", "ccui.ImageView") -- 头像框
    self._textPlayerName = seekNodeByName(self, "Text_playerName", "ccui.Text") -- 玩家名称
    self._textClubName = seekNodeByName(self, "Text_clubName", "ccui.Text") -- 俱乐部名称
    self._textRoomNumber = seekNodeByName(self, "Text_roomNumber", "ccui.Text") -- 房间号

    self._scrollViewRoomPlay = seekNodeByName(self, "ScrollView_roomPlay", "ccui.ScrollView")
    self._scrollViewRoomPlay:setScrollBarEnabled(false)
    self._textRoomPlay = seekNodeByName(self, "Text_roomPlay", "ccui.Text") -- 房间玩法规则

    self._btnReceive = seekNodeByName(self, "Button_receive", "ccui.Button") -- 接受
    self._btnIgnore = seekNodeByName(self, "Button_ignore", "ccui.Button") -- 忽略
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭

    self._checkBox = seekNodeByName(self, "CheckBox_1", "ccui.CheckBox") -- 今日不在接受邀请

    seekNodeByName(self, "Text_clubName_0", "ccui.Text"):setString(config.STRING.UICLUBROOMINVITE_STRING_101)

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnIgnore, handler(self, self._onClickIgnore), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReceive, handler(self, self._onClickReceive), ccui.TouchEventType.ended)
end

function UIClubRoomInvite:onShow(roomInfo)
    self._roomInfo = roomInfo
    self._textPlayerName:setString(game.service.club.ClubService.getInstance():getInterceptString(roomInfo.inviterName, 16))

    self._textClubName:setString(string.format(config.STRING.UICLUBROOMINVITE_STRING_100, game.service.club.ClubService.getInstance():getInterceptString(roomInfo.clubName, 16)))
    self._textRoomNumber:setString(string.format("房间号:%s", roomInfo.roomId))
    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, roomInfo.inviterIcon)
    self._imgHeadBox:setVisible(false)
    game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, PropReader.getIconById(roomInfo.inviterHeadFrame))
    
    self:_initRoomPlay(roomInfo)
end

function UIClubRoomInvite:_initRoomPlay(roomInfo)
    local gameTypes = RoomSettingHelper.convert2ClientGameOptions(false, roomInfo.roundType, roomInfo.gamePlays)
    -- 玩法
    local gamePlay = {}
    for indx, optionType in ipairs(gameTypes) do
        local play = game.service.club.ClubService.getInstance():_getGameTypeName(optionType)
        if play ~= "" then
            table.insert(gamePlay, play)
        end
    end
    self._textRoomPlay:setString(table.concat(gamePlay, "、"))
    -- 由于潮汕地区玩法多，特地做一个玩法可以滑动
    self._textRoomPlay:setTextAreaSize(cc.size(self._textRoomPlay:getContentSize().width, 0))
	local size = self._textRoomPlay:getVirtualRendererSize()
    local scrollViewSize = self._scrollViewRoomPlay:getContentSize()
	self._textRoomPlay:setContentSize(size)
	self._scrollViewRoomPlay:setInnerContainerSize(size)
	self._textRoomPlay:setPositionY(scrollViewSize.height > size.height and scrollViewSize.height or size.height)
end

-- 忽略
function UIClubRoomInvite:_onClickIgnore()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Online_Ignore)
    self:_onClickClose()
end

-- 接受邀请
function UIClubRoomInvite:_onClickReceive()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Online_Receive)

    game.service.club.ClubService.getInstance():getClubRoomService():sendCCLSendRoomInvitedResultREQ(
        self._roomInfo.clubId,
        self._roomInfo.roomId,
        1,
        game.service.LocalPlayerService.getInstance():getArea(),
        self._roomInfo.inviterId
    )

    game.service.friend.FriendService.getInstance():clearClubRoomInviteInfo()
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false)  then 
        UIManager:getInstance():destroy("UIClubRoomInvite")
        return
    end

    local joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.ClubRoomInvite
    if self._roomInfo.sourceType == ClubConstant:getRoomInviationType().FRIEND_QUICK_CREATE then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.FriendList
    elseif self._roomInfo.sourceType == ClubConstant:getRoomInviationType().FRIEND_INVITED then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.FriendRoomInvite
    elseif self._roomInfo.sourceType == ClubConstant:getRoomInviationType().ANOTHER_ROOM_INVITED then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.Renewal
    end

    game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._roomInfo.roomId, joinRoomStyle)
    UIManager:getInstance():destroy("UIClubRoomInvite")
end

function UIClubRoomInvite:_onClickClose()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Club_Online_Close)

    game.service.club.ClubService.getInstance():getClubRoomService():sendCCLSendRoomInvitedResultREQ(
        self._roomInfo.clubId,
        self._roomInfo.roomId,
        2,
        game.service.LocalPlayerService.getInstance():getArea(),
        self._roomInfo.inviterId
    )

    game.service.friend.FriendService.getInstance():getClubRoomInviteInfo("UIClubRoomInvite")
end

function UIClubRoomInvite:onHide()
   -- 如果点击今日不在接收邀请就在本地保存一下当前时间
    game.service.DataEyeService.getInstance():onEvent(string.format("Click_Friend_IsInvite_%s", self._checkBox:isSelected() or "true" or "false"))
    if self._checkBox:isSelected() then
        local localStorageInvitationTime = game.service.friend.FriendService.getInstance():loadLocalStorageInvitationTime()
        local newTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
        localStorageInvitationTime:setInvitationTime(newTime)
         game.service.friend.FriendService.getInstance():saveLocalStorageInvitationTime(localStorageInvitationTime)
    end
end

function UIClubRoomInvite:needBlackMask()
	return true
end

function UIClubRoomInvite:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRoomInvite:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRoomInvite