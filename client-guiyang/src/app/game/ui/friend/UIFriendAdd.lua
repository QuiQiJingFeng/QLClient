local csbPath = "ui/csb/UIFriendAdd.csb"
local UIFriendAdd = class("UIFriendAdd", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    推荐好友列表
]]

local COUNT = 3

local TEXT = 
{
    "大厅一起打过牌",
    "亲友圈一起打过牌",
    "",
}

function UIFriendAdd:ctor(parent)
    self._parent = parent
    -- 记录一下是否为搜索
    self._isSearch = false

    self._listRecommend = ListFactory.get(
        seekNodeByName(self, "ListView_players", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listRecommend:setScrollBarEnabled(false)

    self._textTips = seekNodeByName(self, "Image_tips", "ccui.ImageView")
    self._inputPlayerId = seekNodeByName(self, "TextField_playerId", "ccui.TextField")
    self._btnClear = seekNodeByName(self, "Button_clear", "ccui.Button")
    self._btnSearch = seekNodeByName(self, "Button_search", "ccui.Button")

    self._inputPlayerId:addEventListener(handler(self, self._onChangedNumber))
    self._inputPlayerId:setTextColor(cc.c4b(151, 86, 31, 255))

    bindEventCallBack(self._btnClear, handler(self, self._onClickClear), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSearch, handler(self, self._onClickSearch), ccui.TouchEventType.ended)
end

function UIFriendAdd:_onListViewInit(listItem)
    listItem.players = {}
    for i = 1, 3 do
        local panelName = string.format("Panel_player_%d", i)
        local playerInfo = {}
        playerInfo.player = seekNodeByName(listItem, panelName, "ccui.Layout")
        playerInfo.head = seekNodeByName(playerInfo.player, "Image_head", "ccui.ImageView")
        playerInfo.frame = seekNodeByName(playerInfo.player, "Image_frame", "ccui.ImageView")
        playerInfo.playerName = seekNodeByName(playerInfo.player, "Text_name", "ccui.Text")
        playerInfo.playerId = seekNodeByName(playerInfo.player, "Text_id", "ccui.Text")
        playerInfo.introduction = seekNodeByName(playerInfo.player, "Text_introduction", "ccui.Text")
        playerInfo.btnAdd = seekNodeByName(playerInfo.player, "Button_add", "ccui.Button")
        table.insert(listItem.players, playerInfo)
    end
end

function UIFriendAdd:_onListViewSetData(listItem, data)
    for i = 1, COUNT do
        if data[i] == nil then
            -- 多余的item隐藏
            listItem.players[i].player:setVisible(false)
        else
            listItem.players[i].player:setVisible(true)
            game.util.PlayerHeadIconUtil.setIcon(listItem.players[i].head, data[i].roleIcon)
            listItem.players[i].frame:setVisible(false)
            listItem.players[i].playerName:setString(game.service.club.ClubService.getInstance():getInterceptString(data[i].roleName, 8))
            listItem.players[i].playerId:setString(string.format("ID:%s", data[i].roleId))
            listItem.players[i].introduction:setString(TEXT[data[i].recommendReason])
            bindEventCallBack(listItem.players[i].btnAdd, function()
                game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Recommend_AddFriend)
                local type = self._isSearch and game.service.friend.FRIEND_APPLICANT_SOURCE.SEARCH or game.service.friend.FRIEND_APPLICANT_SOURCE.RECOMMEND
                game.service.friend.FriendService.getInstance():sendCGSendFriendApplicantREQ(data[i].roleId, type)
            end, ccui.TouchEventType.ended)
        end

    end
end

function UIFriendAdd:show()
    self:setVisible(true)
    self._listRecommend:deleteAllItems()
    self:_onClickClear()

    -- 推荐玩家列表的返回
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_RECOMMEND_LIST_INFO", function(event)
        self:_initRecommendList(event.friendRecommendList, false)
    end, self)
    -- 更新列表推送
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_RECOMMEND_LIST_INFO_CHANGE", handler(self, self._updataRecommendList), self)
    -- 搜索推送
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_RECOMMEND_SEARCH", function(event)
        self:_initRecommendList(event.playerInfo, true)
    end, self)
    
    game.service.friend.FriendService.getInstance():sendCGQueryFriendRecommendListREQ()
end

-- 初始化列表
function UIFriendAdd:_initRecommendList(friendRecommendList, isSearch)
    self._listRecommend:deleteAllItems()
    self._textTips:setVisible(true)
    if #friendRecommendList < 1 then
        return
    end

    self._isSearch = isSearch

    -- 按玩家id排序
    table.sort(friendRecommendList, function(a, b)
        return a.roleId < b.roleId
    end)

    self._textTips:setVisible(false)

    local player = {}
    for _, data in ipairs(friendRecommendList) do
        table.insert(player, data)
        if #player == COUNT then
             self._listRecommend:pushBackItem(player)
             player = {}
        end
    end

    if #player > 0 then
        self._listRecommend:pushBackItem(player)
        player = {}
    end
end

-- 更新推荐列表
function UIFriendAdd:_updataRecommendList(event)
    -- 如果是搜索更新，目前只有一个，根据产品需求把列表清空
    if self._isSearch then
        self:_initRecommendList({})
        return
    end
    -- 如果玩家没有在列表里面就不在进行更新列表操作
    if event.isDelete == false then
        return
    end
    -- 用本地缓存进行更新列表
    local friendData = game.service.friend.FriendService.getInstance():getFriendData()
    self:_initRecommendList(friendData.friendRecommendList)
end

-- 限制只能输入数字
function UIFriendAdd:_onChangedNumber(sender, eventType)
    if eventType== 2 or eventType==3 then
        local str = sender:getString()
        str=string.trim(str)
        local sTable = kod.util.String.stringToTable(str)
        local number = ""
        for i=1,#sTable do
            if tonumber(sTable[i]) ~= nil then
                number = number .. sTable[i]
            else
            	game.ui.UIMessageTipsMgr.getInstance():showTips('只能输入数字')
            end
        end
        sender:setString(number)
    end
end

-- 清空玩家输入的id
function UIFriendAdd:_onClickClear()
    self._inputPlayerId:setString("")
    -- 只有搜索成功点击清除才会更新列表
    if self._isSearch then
        local friendData = game.service.friend.FriendService.getInstance():getFriendData()
        self:_initRecommendList(friendData.friendRecommendList)
    end
end

-- 搜索玩家
function UIFriendAdd:_onClickSearch()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend_Search)
    if tonumber(self._inputPlayerId:getString()) ~= nil then
        game.service.friend.FriendService.getInstance():sendCGSearchRoleInfoREQ(tonumber(self._inputPlayerId:getString()))
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的玩家Id")
    end
end

function UIFriendAdd:hide()
    self._listRecommend:deleteAllItems()
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIFriendAdd