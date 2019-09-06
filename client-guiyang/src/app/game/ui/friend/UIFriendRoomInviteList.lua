local csbPath = "ui/csb/UIFriendRoomInviteList.csb"
local super = require("app.game.ui.UIBase")
local UIFriendRoomInviteList = class("UIFriendRoomInviteList", super, function() return kod.LoadCSBNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    在线邀请玩家
]]

function UIFriendRoomInviteList:ctor()
end

function UIFriendRoomInviteList:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._listPlayers = ListFactory.get(
        seekNodeByName(self, "ListView_playerInfo", "ccui.ListView"),
        handler(self, self._initListItem),
        handler(self, self._setItemData)
    )
    self._listPlayers:setScrollBarEnabled(false)
    -- 清空列表
    self._listPlayers:deleteAllItems()

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
end

function UIFriendRoomInviteList:_initListItem(listItem)
    listItem._imgHead = ccui.Helper:seekNodeByName(listItem, "Image_head") -- 头像
    listItem._imgHeadBox = ccui.Helper:seekNodeByName(listItem, "Image_headBox") -- 头像框
    listItem._textPlayerName = ccui.Helper:seekNodeByName(listItem, "Text_playerName") -- 玩家名称
    listItem._textPlayerId = ccui.Helper:seekNodeByName(listItem, "Text_playerId") -- 玩家id
    listItem._imgStatus = ccui.Helper:seekNodeByName(listItem, "Image_status") -- 游戏状态

    listItem._btnInvite = ccui.Helper:seekNodeByName(listItem, "Button_invite") -- 邀请
    listItem._textInvite = ccui.Helper:seekNodeByName(listItem, "BitmapFontLabel_14")
end

function UIFriendRoomInviteList:_setItemData(listItem, value)
    listItem._textPlayerName:setString(game.service.club.ClubService.getInstance():getInterceptString(value.roleName, 16))
    listItem._textPlayerId:setString(string.format("ID:%s", value.roleId))
    game.util.PlayerHeadIconUtil.setIcon(listItem._imgHead, value.roleIcon)
    -- 在线状态
    local status = ClubConstant:getOnlineStatus()
    local statusIcon = ClubConstant:getOnlineStatusIcon("invite", value.status)
    listItem._imgStatus:loadTexture(statusIcon)
    -- 添加头像框
    listItem._imgHeadBox:setVisible(false)
	game.util.PlayerHeadIconUtil.setIconFrame(listItem._imgHead, PropReader.getIconById(value.roleHeadFrame), 0.85)
    -- 只能邀请在线玩家
    listItem._btnInvite:setVisible(value.status == status.online)
    -- 每个玩家最多被邀请2次
    local time = game.service.TimeService:getInstance():getCurrentTime()
    listItem._btnInvite:setEnabled(value.remainInvitedTimes > 0 and time > value.canInvitedTime / 1000)
    listItem._textInvite:setString(value.remainInvitedTimes > 0 and "邀请" or "已邀请")
    -- 做一个计时器更新按钮状态
    value.difference = math.floor(value.canInvitedTime / 1000 - time)
    if value.difference > 0 and value.remainInvitedTimes > 0 then
        listItem._textInvite:setString(string.format("%ds", value.difference))
        listItem.timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            value.difference = value.difference - 1
            if value.difference == 0 then
                if listItem._textInvite ~= nil then
                    listItem._textInvite:setString("邀请")
                end
                if listItem._btnInvite ~= nil then
                    listItem._btnInvite:setEnabled(true)
                end
                if listItem.timer ~= nil then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(listItem.timer)
                    listItem.timer = nil
                end
            else
                if listItem._textInvite ~= nil then
                    listItem._textInvite:setString(string.format("%ds", value.difference))
                end
            end
        end, 1, false)
    end

    -- 邀请
    bindEventCallBack(listItem._btnInvite, function()
        game.service.friend.FriendService.getInstance():sendCGSendRoomInvitationREQ(self._roomId, value.roleId)
    end, ccui.TouchEventType.ended)
end

function UIFriendRoomInviteList:onShow(roomId, friendInfos)
    self._roomId = roomId
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_ROOM_Friend_INFO_CHENGE", handler(self, self._updataFriendInfo), self)
    self:_onRoomFriendInfo(friendInfos)
end

function UIFriendRoomInviteList:_onRoomFriendInfo(friendInfos)
    -- 清空列表
    self._listPlayers:deleteAllItems()

    -- 排序
    table.sort(friendInfos, function(a, b)
        -- 在线 > 游戏中 > 离线
        if a.status < b.status then
            return true
        elseif a.status > b.status then
            return false
        end
        -- 一起游戏局数多的 > 一起游戏局数少的
        if a.playGameCount > b.playGameCount then
            return true
        elseif a.playGameCount < b.playGameCount  then
            return false
        end
        -- 好友关系建立时间
        return a.createTime < b.createTime
    end)

    for _, friendInfo in ipairs(friendInfos) do
        self._listPlayers:pushBackItem(friendInfo)
    end 
end

-- 更新玩家信息
function UIFriendRoomInviteList:_updataFriendInfo(event)
    local itemIdx, data = self:_indexOfInvitation(event.friendInfo.roleId)
    if Macro.assertFalse(itemIdx ~= false) then
        self._listPlayers:updateItem(itemIdx, event.friendInfo)
    end
end

-- 查找item
function UIFriendRoomInviteList:_indexOfInvitation(roleId)
    for idx,item in ipairs(self._listPlayers:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false
end

function UIFriendRoomInviteList:_onClickClose()
    UIManager:getInstance():destroy("UIFriendRoomInviteList")
end

function UIFriendRoomInviteList:onHide()
    -- 关闭计时器
    for idx, item in ipairs(self._listPlayers:getSpawnItems()) do
        if item.timer ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(item.timer)
            item.timer = nil
        end
    end
    -- 清空列表
    self._listPlayers:deleteAllItems()

    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
end

function UIFriendRoomInviteList:needBlackMask()
	return true
end

function UIFriendRoomInviteList:closeWhenClickMask()
	return false
end

return UIFriendRoomInviteList