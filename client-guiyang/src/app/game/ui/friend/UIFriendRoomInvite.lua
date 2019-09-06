local csbPath = "ui/csb/UIFriendRoomInvite.csb"
local super = require("app.game.ui.UIBase")
local UIFriendRoomInvite = class("UIFriendRoomInvite", super, function() return kod.LoadCSBNode(csbPath) end)
local RoomSettingHelper = require("app.game.ui.RoomSettingHelper").RoomSettingHelper
local CampaignUtils = require("app.game.campaign.utils.CampaignUtils")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    在线邀请玩家
]]
function UIFriendRoomInvite:ctor()
end

function UIFriendRoomInvite:init()
    self._imgHead = seekNodeByName(self, "Image_head", "ccui.ImageView") -- 头像
    self._imgHeadBox = seekNodeByName(self, "Image_headBox", "ccui.ImageView") -- 头像框
    self._textPlayerName = seekNodeByName(self, "Text_playerName", "ccui.Text") -- 玩家名称
    self._textRoomNumber = seekNodeByName(self, "Text_roomNumber", "ccui.Text") -- 房间号

    self._scrollViewRoomPlay = seekNodeByName(self, "ScrollView_roomPlay", "ccui.ScrollView")
    self._scrollViewRoomPlay:setScrollBarEnabled(false)
    self._textRoomPlay = seekNodeByName(self, "Text_roomPlay", "ccui.Text") -- 房间玩法规则

    self._btnReceive = seekNodeByName(self, "Button_receive", "ccui.Button") -- 接受
    self._btnIgnore = seekNodeByName(self, "Button_ignore", "ccui.Button") -- 忽略
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭

    self._checkBox = seekNodeByName(self, "CheckBox_1", "ccui.CheckBox") -- 今日不在接受邀请

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnIgnore, handler(self, self._onClickIgnore), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnReceive, handler(self, self._onClickReceive), ccui.TouchEventType.ended)
end

function UIFriendRoomInvite:onShow(roomInfo)
    self._roomId = roomInfo.roomId
    self._sourceType = roomInfo.sourceType
    self._textPlayerName:setString(game.service.club.ClubService.getInstance():getInterceptString(roomInfo.inviterName, 16))

    self._textRoomNumber:setString(string.format("房间号:%s", roomInfo.roomId))
    game.util.PlayerHeadIconUtil.setIcon(self._imgHead, roomInfo.inviterIcon)
    self._imgHeadBox:setVisible(false)
    game.util.PlayerHeadIconUtil.setIconFrame(self._imgHead, PropReader.getIconById(roomInfo.inviterHeadFrame))
    
    self:_initRoomPlay(roomInfo)
end

function UIFriendRoomInvite:_initRoomPlay(roomInfo)
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
function UIFriendRoomInvite:_onClickIgnore()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_Refuse)
    self:_onClickClose()
end

-- 接受邀请
function UIFriendRoomInvite:_onClickReceive()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Room_Receive)
    game.service.friend.FriendService.getInstance():clearClubRoomInviteInfo()
    -- 若已报名比赛 则无法进入房间
    if CampaignUtils.forbidenMsgWhenJoinRoom(false)  then 
        UIManager:getInstance():destroy("UIFriendRoomInvite")
        return
    end

    -- 判断加入的房间类型
    local joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.ClubRoomInvite
    if self._sourceType == ClubConstant:getRoomInviationType().FRIEND_QUICK_CREATE then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.FriendList
    elseif self._sourceType == ClubConstant:getRoomInviationType().FRIEND_INVITED then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.FriendRoomInvite
    elseif self._sourceType == ClubConstant:getRoomInviationType().ANOTHER_ROOM_INVITED then
        joinRoomStyle = game.globalConst.JOIN_ROOM_STYLE.Renewal
    end

    game.service.RoomCreatorService.getInstance():queryBattleIdReq(self._roomId, joinRoomStyle)
    UIManager:getInstance():destroy("UIFriendRoomInvite")
end

function UIFriendRoomInvite:_onClickClose()
    game.service.friend.FriendService.getInstance():getClubRoomInviteInfo("UIFriendRoomInvite")
end

function UIFriendRoomInvite:onHide()
    -- 如果点击今日不在接收邀请就在本地保存一下当前时间
    game.service.DataEyeService.getInstance():onEvent(string.format("Click_Friend_IsInvite_%s", self._checkBox:isSelected() or "true" or "false"))
    if self._checkBox:isSelected() then
        local localStorageInvitationTime = game.service.friend.FriendService.getInstance():loadLocalStorageInvitationTime()
        local newTime = game.service.TimeService:getInstance():getCurrentTimeInMSeconds()
        localStorageInvitationTime:setInvitationTime(newTime)
         game.service.friend.FriendService.getInstance():saveLocalStorageInvitationTime(localStorageInvitationTime)
    end
end

function UIFriendRoomInvite:needBlackMask()
	return true
end

function UIFriendRoomInvite:closeWhenClickMask()
	return false
end

return UIFriendRoomInvite