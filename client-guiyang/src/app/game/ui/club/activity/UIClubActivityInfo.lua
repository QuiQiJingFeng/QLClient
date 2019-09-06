local csbPath = "ui/csb/Club/UIClubActivityInfo.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    活动信息界面（未开始、开始、已结束）
]]

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")

local UIElemActivityInfoItem = class("UIElemActivityInfoItem")

function UIElemActivityInfoItem.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UIElemActivityInfoItem)
    self:_initialize()
    return self
end

function UIElemActivityInfoItem:_initialize()
    self._textRank = seekNodeByName(self, "BitmapFontLabel_Rank", "ccui.TextBMFont") -- 玩家排名
    self._textPlayName = seekNodeByName(self, "Text_Play_Name", "ccui.Text") -- 玩家名称
    self._textPlayId = seekNodeByName(self, "Text_Play_Id", "ccui.Text") -- 玩家Id
    self._textPlayData = seekNodeByName(self, "Text_Play_Data", "ccui.Text") -- 玩家数据
end

-- 整体设置数据
function UIElemActivityInfoItem:setData(val)
    self._textRank:setString(val.rank)
    self._textPlayName:setString(val.roleName)
    self._textPlayId:setString(val.roleId)
    self._textPlayData:setString(val.data)
end

local UIClubActivityInfo = class("UIClubActivityInfo", super, function() return cc.CSLoader:createNode(csbPath) end)

function UIClubActivityInfo:ctor(parent)
    self._parent = parent

    self._reusedListActivity = UIItemReusedListView.extend(seekNodeByName(self, "ListView_Paiming", "ccui.ListView"), UIElemActivityInfoItem)
     -- 不显示滚动条, 无法在编辑器设置
    self._reusedListActivity:setScrollBarEnabled(false)

    self._textActivityName = seekNodeByName(self, "Text_Activity_Name", "ccui.Text") -- 活动名称
    self._textActivityType = seekNodeByName(self, "Text_Activity_Type", "ccui.Text") -- 活动类型
    self._textActivityTime = seekNodeByName(self, "Text_Activity_Time", "ccui.Text") -- 活动时间

    self._textActivityDesc = seekNodeByName(self, "Text_Activity_Jushu", "ccui.Text") -- 活动头描述

    self._btnActivityDelete = seekNodeByName(self, "Button_Activity_Delete", "ccui.Button") -- 删除活动
    self._btnActivityStop = seekNodeByName(self, "Button_Activity_Stop", "ccui.Button") -- 停止活动
    self._btnActivityCancel = seekNodeByName(self, "Button_Activity_Cancel", "ccui.Button") -- 取消活动

    self._roleId = seekNodeByName(self, "Text_Play_RoleId", "ccui.Text")
    self._roleName = seekNodeByName(self, "Text_Play_RoleName", "ccui.Text")
    self._roleDtat = seekNodeByName(self, "Text_Play_RoleData", "ccui.Text")
    self._roleRank = seekNodeByName(self, "BitmapFontLabel_RoleRank", "ccui.TextBMFont")

    self._btnInvite = seekNodeByName(self, "Button_yqhd_Info", "ccui.Button")
    self._btnInvite:setVisible(false)

    -- 删除活动
    bindEventCallBack(self._btnActivityDelete, function()
        local text = "删除活动,会删除活动并同时删除数据，确认删除活动?"
        self:_onActivitiesOperatingClick(ClubConstant:getActivityOperationType().delete, text)
    end, ccui.TouchEventType.ended)
    -- 中止活动
    bindEventCallBack(self._btnActivityStop, function()
        local text = "终止活动,会使排行榜数据不再更新,但是会保留数据,确认终止活动?"
        self:_onActivitiesOperatingClick(ClubConstant:getActivityOperationType().stop, text)
    end, ccui.TouchEventType.ended)
    -- 取消活动
    bindEventCallBack(self._btnActivityCancel, function()
        local text = "取消活动,会删除本活动设置,确认取消活动?"
        self:_onActivitiesOperatingClick(ClubConstant:getActivityOperationType().cancel, text)
    end, ccui.TouchEventType.ended)
    
end


function UIClubActivityInfo:show(clubId, data)
    self:setVisible(true)
    
    self._clubId = clubId

    self._activityInfo = data

    self._textActivityName:setString(data.title)
    
    local activityType, index = ClubConstant:getClubActivityType()
    local textType = ""
    if data.type == activityType.CardCount then
        textType = "局数累计"
        self._textActivityDesc:setString("局数统计")
    elseif data.type == activityType.Winner then
        textType = "大赢家活动"
        self._textActivityDesc:setString("胜利局数")
    elseif data.type == activityType.HighestScore then
        textType = "单局最高分"
        self._textActivityDesc:setString("最高得分")
    elseif data.type == activityType.InvitePlayers then
        textType = "邀请玩家"
        self._textActivityDesc:setString("完成局数新玩家")
    end
    self._textActivityType:setString(textType)
    self._textActivityTime:setString(string.format("%s 至 %s",os.date("%m-%d %H:%M", data.startTime/1000), os.date("%m-%d %H:%M", data.endTime/1000)))

    self._roleId:setString(data.selfRank.roleId)
    self._roleName:setString(data.selfRank.roleName)
    self._roleDtat:setString(data.selfRank.data)
    self._roleRank:setString(data.selfRank.rank == -1 and "-" or data.selfRank.rank)

    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local isManager = club:isManager(roleId)

    self._btnActivityCancel:setVisible(isManager and data.status == ClubConstant:getActivityStatus().start)
    self._btnActivityStop:setVisible(isManager and data.status == ClubConstant:getActivityStatus().processing)
    self._btnActivityDelete:setVisible(isManager and data.status == ClubConstant:getActivityStatus().status_end)

    if (data.type == activityType.InvitePlayers and data.status == ClubConstant:getActivityStatus().processing) then
        self._btnInvite:setVisible(true)
        --邀请人员
        bindEventCallBack(self._btnInvite, function()
            UIManager:getInstance():show("UIClubWeChatInvited", club, true)
        end, ccui.TouchEventType.ended)
    else
        self._btnInvite:setVisible(false)
    end

    self:_initActivityList()
end

function UIClubActivityInfo:_initActivityList()
     -- 清空列表
    self._reusedListActivity:deleteAllItems()

    for _, playerInfo in ipairs(self._activityInfo.rankList) do
        self._reusedListActivity:pushBackItem(playerInfo)
    end
end

function UIClubActivityInfo:_onActivitiesOperatingClick(activityOperationType, text)
    game.ui.UIMessageBoxMgr.getInstance():show(text, {"确定", "取消"}, function()
        game.service.club.ClubService.getInstance():getClubActivityService():sendCCLCloseManagerActivityREQ(self._clubId, activityOperationType, self._activityInfo.id)
    end)
end

function UIClubActivityInfo:hide()
    -- 清空列表
    self._reusedListActivity:deleteAllItems()

    self:setVisible(false)
end


return UIClubActivityInfo