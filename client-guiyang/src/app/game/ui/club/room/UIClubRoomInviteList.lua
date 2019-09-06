local csbPath = "ui/csb/Club/UIClubRoomInviteList.csb"
local super = require("app.game.ui.UIBase")
local UIClubRoomInviteList = class("UIClubRoomInviteList", super, function() return kod.LoadCSBNode(csbPath) end)

local ListFactory = require("app.game.util.ReusedListViewFactory")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local RoomSettingInfo = require("app.game.RoomSettingInfo")

--[[
    在线邀请玩家
]]

local COUNT = 2

function UIClubRoomInviteList:ctor()
    seekNodeByName(self, "BitmapFontLabel_topz_QuiteJoin", "ccui.TextBMFont"):setString(config.STRING.UICLUBROOMINVITE_STRING_102)
    seekNodeByName(self, "Text_content", "ccui.Text"):setString(config.STRING.UICLUBROOMINVITE_STRING_103)
end

function UIClubRoomInviteList:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._listPlayers = ListFactory.get(
        seekNodeByName(self, "ListView_playerInfo", "ccui.ListView"),
        handler(self, self._initListItem),
        handler(self, self._setItemData)
    )
    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button") -- 邀请
    self._panelInvite = seekNodeByName(self, "Panel_invite", "ccui.Layout")

    self._listPlayers:setScrollBarEnabled(false)
    -- 清空列表
    self._listPlayers:deleteAllItems()

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite, handler(self, self._onClickInvite), ccui.TouchEventType.ended)
end

function UIClubRoomInviteList:_initListItem(listItem)
    for i = 1, COUNT do
        listItem[string.format("_imgHead_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Image_head_%d", i)) -- 头像
        listItem[string.format("_imgHeadBox_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Image_headBox_%d", i)) -- 头像框
        listItem[string.format("_textPlayerName_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Text_playerName_%d", i)) -- 玩家名称
        -- listItem[string.format("_textPlayerId_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Text_playerId_%d", i)) -- 玩家id
        listItem[string.format("_imgStatus_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Image_status_%d", i)) -- 游戏状态
        listItem[string.format("_btnInvite_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Button_invite_%d", i)) -- 邀请
        listItem[string.format("_textInvite_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("BitmapFontLabel_btnName_%d", i)) -- 按钮文字
        listItem[string.format("_panelPlayer_%d", i)] = ccui.Helper:seekNodeByName(listItem, string.format("Panel_playerInfo_%d", i))
    end
end

function UIClubRoomInviteList:_setItemData(listItem, data)
    for i = 1, COUNT do
        if #data < i then
            listItem[string.format("_panelPlayer_%d", i)]:setVisible(false)
            break
        else
            listItem[string.format("_panelPlayer_%d", i)]:setVisible(true)
        end
        local value = data[i]
        listItem[string.format("_textPlayerName_%d", i)]:setString(game.service.club.ClubService.getInstance():getInterceptString(value.roleName, 16))
        -- listItem[string.format("_textPlayerId_%d", i)]:setString(string.format("ID:%s", value.roleId))
        game.util.PlayerHeadIconUtil.setIcon(listItem[string.format("_imgHead_%d", i)], value.roleIcon)
        -- 在线状态
        local status = ClubConstant:getOnlineStatus()
        local statusIcon = ClubConstant:getOnlineStatusIcon("roomInvite", value.status)
        listItem[string.format("_imgStatus_%d", i)]:loadTexture(statusIcon)
        -- 添加头像框
        listItem[string.format("_imgHeadBox_%d", i)]:setVisible(false)
        game.util.PlayerHeadIconUtil.setIconFrame(listItem[string.format("_imgHead_%d", i)], PropReader.getIconById(value.roleHeadFrame), 0.85)
        -- 只能邀请在线玩家
        listItem[string.format("_btnInvite_%d", i)]:setVisible(value.canBeInvited)
        -- 每个玩家最多被邀请2次
        local time = game.service.TimeService:getInstance():getCurrentTime()
        listItem[string.format("_btnInvite_%d", i)]:setEnabled(value.remainInvitedTimes > 0 and time > value.canInvitedTime / 1000)
        listItem[string.format("_textInvite_%d", i)]:setString(value.remainInvitedTimes > 0 and "邀请" or "已邀请")
        -- 做一个计时器更新按钮状态
        value.difference = math.floor(value.canInvitedTime / 1000 - time)
        if value.difference > 0 and value.remainInvitedTimes > 0 and listItem[string.format("timer_%d", i)] == nil then
            listItem[string.format("_textInvite_%d", i)]:setString(string.format("%ds", value.difference))
            listItem[string.format("timer_%d", i)] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                value.difference = value.difference - 1
                if value.difference == 0 then
                    if listItem[string.format("_textInvite_%d", i)] ~= nil then
                        listItem[string.format("_textInvite_%d", i)]:setString("邀请")
                    end
                    if listItem[string.format("_btnInvite_%d", i)] ~= nil then
                        listItem[string.format("_btnInvite_%d", i)]:setEnabled(true)
                    end
                else
                    if listItem[string.format("_textInvite_%d", i)] ~= nil then
                        listItem[string.format("_textInvite_%d", i)]:setString(string.format("%ds", value.difference))
                    end
                end
                if value.difference <= 0 then
                    if listItem[string.format("timer_%d", i)] ~= nil then
                        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(listItem[string.format("timer_%d", i)])
                        listItem[string.format("timer_%d", i)] = nil
                    end
                end
            end, 1, false)
        end

        -- 邀请
        bindEventCallBack(listItem[string.format("_btnInvite_%d", i)], function()
            local text = string.format("%s_status_%s",game.globalConst.StatisticNames.Club_Online_Invite, value.status)
            game.service.DataEyeService.getInstance():onEvent(text)
            local roundCount, gamePlays = game.service.club.ClubService.getInstance():getClubRoomService():getRoomRule()
            local roomSettingInfo = RoomSettingInfo.new(gamePlays, roundCount)
            local newZHTable = roomSettingInfo:getZHArray()
            local gamePlaysDesc = table.concat(newZHTable, "、", 1)
            game.service.club.ClubService.getInstance():getClubRoomService():sendCCLSendRoomInvitationREQ(self._clubId, self._roomId, value.roleId, gamePlaysDesc)
        end, ccui.TouchEventType.ended)
    end
end

function UIClubRoomInviteList:onShow(clubId, roomId)
    self._clubId = clubId
    self._roomId = roomId
    local clubRoomService = game.service.club.ClubService.getInstance():getClubRoomService()
    clubRoomService:addEventListener("EVENT_CLUB_ROOM_MEMBER_INFO", handler(self, self._onRoomMemberInfo), self)
    clubRoomService:addEventListener("EVENT_CLUB_ROOM_MEMBER_INFO_CHENGE", handler(self, self._updataMemberInfo), self)

    clubRoomService:sendCCLQueryRoomInvitedMembersREQ(self._clubId, self._roomId)
end

function UIClubRoomInviteList:_onRoomMemberInfo(event)
    if event.memberInfos == nil or #event.memberInfos == 0 then
        self._panelInvite:setVisible(true)
        self._listPlayers:setVisible(false)
        return
    end

    self._panelInvite:setVisible(false)
    self._listPlayers:setVisible(true)
    -- 清空列表
    self._listPlayers:deleteAllItems()

    -- 排序
    table.sort(event.memberInfos, function(a, b)
        -- 在线 > 游戏中 > 离线
        if a.status < b.status then
            return true
        elseif a.status > b.status then
            return false
        end
        -- 可被邀请的>不可被邀请的
        local isInvited_a = a.canBeInvited and 1 or 0
        local isInvited_b = b.canBeInvited and 1 or 0
        if isInvited_a > isInvited_b then
            return true
        end
        if isInvited_a < isInvited_b then
            return false
        end
        -- -- 按邀请次数排序
        -- if a.remainInvitedTimes > b.remainInvitedTimes then
        --     return true
        -- end
        -- if a.remainInvitedTimes < b.remainInvitedTimes then
        --     return false
        -- end
        -- 群主 > 管理 > 成员
        if a.right > b.right then
            return true
        elseif a.right < b.right then
            return false
        end
        -- 一起游戏局数多的 > 一起游戏局数少的
        if a.playGameCount > b.playGameCount then
            return true
        elseif a.playGameCount < b.playGameCount  then
            return false
        end
        -- 早入会的 > 晚入会的
        return a.joinTime < b.joinTime
    end)

    local members = {}
    for _, memberInfo in ipairs(event.memberInfos) do
        if #members == COUNT then
            self._listPlayers:pushBackItem(members)
            members = {}
        end
        
        table.insert(members, memberInfo)
    end

    if #members > 0 then
        self._listPlayers:pushBackItem(members)
        members = {}
    end
end

-- 更新玩家信息
function UIClubRoomInviteList:_updataMemberInfo(event)
    if event.clubId ~= self._clubId then
        return
    end

    local itemIdx, data = self:_indexOfInvitation(event.inviteeMemberInfo.roleId)
    if Macro.assertFalse(itemIdx ~= false) then
        local dataInfo = {}
        for _, info in ipairs(data) do
            if info.roleId == event.inviteeMemberInfo.roleId then
                table.insert(dataInfo, event.inviteeMemberInfo)
            else
                table.insert(dataInfo, info)
            end
        end
        self._listPlayers:updateItem(itemIdx, dataInfo)
    end
end

-- 查找item
function UIClubRoomInviteList:_indexOfInvitation(roleId)
    for idx,item in ipairs(self._listPlayers:getItemDatas()) do
        for _, data in ipairs(item) do
            if data.roleId == roleId then
                return idx, item
            end
        end
    end

    return false
end

function UIClubRoomInviteList:_onClickClose()
    UIManager:getInstance():destroy("UIClubRoomInviteList")
end

-- 邀请界面
function UIClubRoomInviteList:_onClickInvite()
    local clubList = game.service.club.ClubService.getInstance():getClubList()
    local idx = clubList:indexOfClub(self._clubId)
    UIManager:getInstance():show("UIClubWeChatInvited", clubList.clubs[idx], true)    
end

function UIClubRoomInviteList:onHide()
    -- 关闭计时器
    for idx, item in ipairs(self._listPlayers:getSpawnItems()) do
        for i = 1, COUNT do
            local timer = item[string.format("timer_%d", i)]
            if timer ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
                timer = nil
            end
        end
    end
    -- 清空列表
    self._listPlayers:deleteAllItems()

    game.service.club.ClubService.getInstance():getClubRoomService():removeEventListenersByTag(self)
end

function UIClubRoomInviteList:needBlackMask()
	return true
end

function UIClubRoomInviteList:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubRoomInviteList:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubRoomInviteList