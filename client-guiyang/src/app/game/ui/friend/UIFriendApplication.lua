local csbPath = "ui/csb/UIFriendApplication.csb"
local UIFriendApplication = class("UIFriendApplication", function() return cc.CSLoader:createNode(csbPath) end)
local ListFactory = require("app.game.util.ReusedListViewFactory")

--[[
    好友申请列表
]]

function UIFriendApplication:ctor(parent)
    self._parent = parent

    self._listFriendApplication = ListFactory.get(
        seekNodeByName(self, "ListView_friendApplication", "ccui.ListView"),
        handler(self, self._onListViewInit),
        handler(self, self._onListViewSetData)
    )
    self._listFriendApplication:setScrollBarEnabled(false)

    self._textTips = seekNodeByName(self, "Text_tips", "ccui.Text")
end

function UIFriendApplication:_onListViewInit(listItem)
    listItem.head = seekNodeByName(listItem, "Image_head", "ccui.ImageView") -- 头像
    listItem.frame = seekNodeByName(listItem, "Image_frame", "ccui.ImageView") -- 头像框
    listItem.playerName = seekNodeByName(listItem, "Text_playerName", "ccui.Text") -- 玩家昵称
    listItem.time = seekNodeByName(listItem, "Text_time", "ccui.Text") -- 申请时间
    listItem.btnAgree = seekNodeByName(listItem, "Button_agree", "ccui.Button") -- 同意
    listItem.btnRefuse = seekNodeByName(listItem, "Button_refuse", "ccui.Button") -- 拒绝
end

function UIFriendApplication:_onListViewSetData(listItem, data)
    game.util.PlayerHeadIconUtil.setIcon(listItem.head, data.roleIcon)
    listItem.playerName:setString(game.service.club.ClubService.getInstance():getInterceptString(data.roleName, 8))
    listItem.time:setString(os.date("%Y-%m-%d", data.applyTime / 1000))

    -- 同意加该玩家为好友
    bindEventCallBack(listItem.btnAgree, function()
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend_Agree)
        game.service.friend.FriendService.getInstance():sendCGHandleFriendApplicantREQ(1, data.roleId)
    end, ccui.TouchEventType.ended)
    -- 忽略该玩家请求
    bindEventCallBack(listItem.btnRefuse, function()
        game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Click_Firend_Refuse)
        game.ui.UIMessageBoxMgr.getInstance():show("是否忽略该好友申请？", {"确定", "取消"}, function()
            game.service.friend.FriendService.getInstance():sendCGHandleFriendApplicantREQ(2, data.roleId)
        end)
    end, ccui.TouchEventType.ended)
end

function UIFriendApplication:show()
    self:setVisible(true)
    self._listFriendApplication:deleteAllItems()
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_APPLICANT_INFO", handler(self, self._initFriendApplicantInfo), self)
    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_APPLICANT_INFO_CHANGE", handler(self, self._updataFriendApplicantInfo), self)
    game.service.friend.FriendService.getInstance():sendCGQueryFriendApplicantListREQ()
end

function UIFriendApplication:_initFriendApplicantInfo(event)
    self._listFriendApplication:deleteAllItems()
    self._textTips:setVisible(true)
    if #event.friendApplicantList < 1 then
        return
    end

    -- 按申请时候早晚就行排序
    table.sort(event.friendApplicantList, function(a, b)
        return a.applyTime > b.applyTime
    end)

    self._textTips:setVisible(false)
    for _, data in ipairs(event.friendApplicantList) do
        self._listFriendApplication:pushBackItem(data)
    end
end

-- 更新列表
function UIFriendApplication:_updataFriendApplicantInfo(event)
    local index, item = self:_indexOfItem(event.applicantId)
    if index then
        self._listFriendApplication:deleteItem(index)
    end
end

-- 获取item数据
function UIFriendApplication:_indexOfItem(roleId)
    for idx, item in ipairs(self._listFriendApplication:getItemDatas()) do
        if item.roleId == roleId then
            return idx, item
        end
    end

    return false;
end

function UIFriendApplication:hide()
    self._listFriendApplication:deleteAllItems()
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
    self:setVisible(false)
end

return UIFriendApplication