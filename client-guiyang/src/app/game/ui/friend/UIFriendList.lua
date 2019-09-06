local csbPath = "ui/csb/UIFriendList.csb"
local UIFriendList = class("UIFriendList", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
--[[
    好友列表
]]

function UIFriendList:ctor(parent)
    self._parent = parent

    self._listFriend = ListFactory.get(
        seekNodeByName(self, "ListView_friend", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listFriend:setScrollBarEnabled(false)

    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
end

function UIFriendList:_onListViewInit(listItem)
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView") -- 头像
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView") -- 头像框
    listItem.playerName = seekNodeByName(listItem, "Text_playerName", "ccui.Text") -- 玩家昵称
    listItem.playerStatus = seekNodeByName(listItem, "Text_playerStatus", "ccui.Text") -- 玩家状态
    listItem.btnDelete = seekNodeByName(listItem, "Button_delete", "ccui.Button") -- 删除
    listItem.btnInvite = seekNodeByName(listItem, "Button_invite", "ccui.Button") -- 邀请组局
end

function UIFriendList:_onListViewSetData(listItem, data)
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
    listItem.playerName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.frame:setVisible(false)
    game.util.PlayerHeadIconUtil.setIconFrame(listItem.head, PropReader.getIconById(data.headFrameId), 0.6)
    listItem.playerStatus:setString(ClubConstant:getOnlineStautusName(data.status))
    -- 只要在线玩家显示邀请
    listItem.btnInvite:setVisible(data.status == ClubConstant:getOnlineStatus().online)
    -- 删除好友
    bindEventCallBack(listItem.btnDelete, function()
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend_Delete)
        game.ui.UIMessageBoxMgr.getInstance():show("是否删除该好友？", {"确定", "取消"}, function()
            game.service.friend.FriendService.getInstance():sendCGDeleteFriendInfoREQ(data.roleId)
        end)
    end, ccui.TouchEventType.ended)

    -- 邀请玩家进入牌局
    bindEventCallBack(listItem.btnInvite, function()
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend_Invite)
        game.service.friend.FriendService.getInstance():getFriendData():setFriendIds({data.roleId})
        UIManager:getInstance():show("UICreateRoom")
    end, ccui.TouchEventType.ended)
end

function UIFriendList:show()
    self:setVisible(true)
    self._listFriend:deleteAllItems()
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_LIST_INFO", handler(self, self._initFriendListInfo), self)
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_DELETE", handler(self, self._deleteFriend), self)
    game.service.friend.FriendService.getInstance():sendCGQueryFriendListREQ()
end

function UIFriendList:_initFriendListInfo(event)
    self._listFriend:deleteAllItems()
    self._textTips:setVisible(true)
    if #event.friendList < 1 then
        return
    end
    self._textTips:setVisible(false)

    -- 按时间进行排序
    table.sort(event.friendList, function(a, b)
        if a.status < b.status then
            return true
        elseif a.status > b.status then
            return false
        end

        return a.createTime < b.createTime
    end)

    for _, data in ipairs(event.friendList) do
        self._listFriend:pushBackItem(data)
    end
end

-- 删除玩家更新列表
function UIFriendList:_deleteFriend(event)
    local index, item = self:_indexOfItem(event.deleteRoleId)
    if index then
        self._listFriend:deleteItem(index)
    end
end

-- 获取item数据
function UIFriendList:_indexOfItem(roleId)
    for idx, item in ipairs(self._listFriend:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

function UIFriendList:hide()
    self._listFriend:deleteAllItems()
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIFriendList