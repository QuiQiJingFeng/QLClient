local csbPath = "ui/csb/Club/UIClubLeaderboardMain.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

local UIClubLeaderboardMain = class("UIClubLeaderboardMain", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    排行榜主界面
]]

local LEADERBOARD_TYPE =
{
    {name = "牌局数", ui = "UIClubLeaderboardRoomCard", typeId = ClubConstant:getLeaderboardType().roomCard, isVisible = true},
    {name = "大赢家次数", ui = "UIClubLeaderboardWinner", typeId = ClubConstant:getLeaderboardType().winner, isVisible = true},
    {name = "积分累积", ui = "UIClubLeaderboardIntegral", typeId = ClubConstant:getLeaderboardType().integral, isVisible = true},
    {name = "赢分累计", ui = "UIClubLeaderboardWinPoints", typeId = ClubConstant:getLeaderboardType().winPoints, isVisible = true},
    {name = "数据日报", ui = "UIClubLeaderboardDataDaily", typeId = ClubConstant:getLeaderboardType().dataDaily, isVisible = true},
}

function UIClubLeaderboardMain:ctor()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._clubId = 0
    self._leaderboardType = 0
    self._startTime = nil
    self._endtime = nil
    self._isPermissions = false
end

function UIClubLeaderboardMain:init()
    self._btnQuit = seekNodeByName(self, "Button_quit", "ccui.Button")  -- 返回
    self._node = seekNodeByName(self, "Panel_Leaderboard", "ccui.Layout")

    self._listLeaderboardItem = seekNodeByName(self, "ListView_Leaderboard", "ccui.ListView")

    self._listLeaderboardItem:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listLeaderboardItem, "Panel_TYPE_BUTTON")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    self._panelTime = seekNodeByName(self, "Panel_time", "ccui.Layout")
    self._btnStartTime = seekNodeByName(self, "Button_startTime", "ccui.Button") -- 开始时间按钮
    self._btnEndTime = seekNodeByName(self, "Button_endTime", "ccui.Button") -- 结束时间按钮
    self._btnInquire = seekNodeByName(self, "Button_inquire", "ccui.Button") -- 搜索按钮
    self._textStartTime = seekNodeByName(self, "BitmapFontLabel_startTime", "ccui.TextBMFont") -- 开始时间文字
    self._textEndTime = seekNodeByName(self, "BitmapFontLabel_endTime", "ccui.TextBMFont") -- 开始时间文字

    self._imgTips = seekNodeByName(self, "Image_No", "ccui.ImageView") -- 提示
    self._imgTips:setVisible(false)

    bindEventCallBack(self._btnStartTime, handler(self, self._onClickInquire), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEndTime, handler(self, self._onClickInquire), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInquire, handler(self, self._onClickInquire), ccui.TouchEventType.ended)

    bindEventCallBack(self._btnQuit, handler(self, self._onClickQuit), ccui.TouchEventType.ended)
end

function UIClubLeaderboardMain:onShow(clubId)
    self._clubId = clubId
    local clubService = game.service.club.ClubService.getInstance()
    self._clubLeaderboardService = clubService:getClubLeaderboardService()
    self._clubLeaderboardService:addEventListener("EVENT_CLUB_PLAYERINFO_CHANGE", handler(self, self._playerInfo), self)
    self._clubLeaderboardService:addEventListener("EVENT_CLUB_PLAYERDATAINFO_CHANGE", handler(self, self._playerDataInfo), self)

    -- 判断经理特权
    local club = clubService:getClub(self._clubId)
    local localRoleId = game.service.LocalPlayerService.getInstance():getRoleId()
    self._isPermissions = club:isPermissions(localRoleId)
    for i, data in ipairs(LEADERBOARD_TYPE) do
        if i > 2 then
            data.isVisible = self._isPermissions
        end
    end

    self:_initLeaderboardList()
end

-- 初始化list列表
function UIClubLeaderboardMain:_initLeaderboardList()
    -- 清空列表
    self._listLeaderboardItem:removeAllChildren()

    for _, data in ipairs(LEADERBOARD_TYPE) do
        -- 判断该类型是否显示
        if data.isVisible then
            self:_initActivityItem(data)
        end
    end

    self:_onItemTypeClicked(LEADERBOARD_TYPE[1])
end

function UIClubLeaderboardMain:_initActivityItem(data)
    local node = self._listviewItemBig:clone()
    self._listLeaderboardItem:addChild(node)
    node:setVisible(true)
    -- 排行榜类型名称
    local textType = ccui.Helper:seekNodeByName(node, "Text_name")
    textType:setString(data.name)

    local isSelected = false
    local checkBox = ccui.Helper:seekNodeByName(node, "GAME_TYPE_BUTTON")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(data)
            -- 统计点击排行榜页签次数
            game.service.DataEyeService.getInstance():onEvent(data.ui)
            checkBox:setSelected(true)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[data.typeId] = checkBox
end

function UIClubLeaderboardMain:_onItemTypeClicked(data)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == data.typeId then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end
    
    -- 当前已显示该界面再点击无效
    if self._leaderboardType == data.typeId then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[data.typeId] == nil then
        local clz = require("app.game.ui.club.leaderboard." .. data.ui)
        local ui = clz.new(self)
        self._uiElemList[data.typeId] = ui
        self._node:addChild(ui)
    end

    -- 保存一下当前显示的界面的类型
    self._leaderboardType = data.typeId

    
    -- 排行榜数据请求
    if ClubConstant:getLeaderboardType().dataDaily ~= self._leaderboardType then
        
        if self._startTime == nil or self._endtime == nil then
            local nowTime = math.floor(game.service.TimeService:getInstance():getCurrentTime())
            local hour = tonumber(os.date("%H", nowTime))
            local minute = tonumber(os.date("%M", nowTime))
            self._startTime = nowTime - (hour * 60 * 60)
            self._endtime = nowTime + (minute > 0 and 60 * 60 or 0)
        end

        self:_updataTime(self._startTime, self._endtime)
        self:_sendClubPlayerInfo(self._startTime * 1000, self._endtime * 1000, 0)
        self._panelTime:setVisible(true)
    else
        -- 数据日报不显示时间
        self:_sendClubPlayerDataInfo()
        self._panelTime:setVisible(false)
    end

    self:_hideAllPages()
    self._uiElemList[data.typeId]:show()
end

function UIClubLeaderboardMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

-- 显示时间界面
function UIClubLeaderboardMain:_onClickInquire()
    local time = math.floor(game.service.TimeService:getInstance():getCurrentTime())
    local minute = tonumber(os.date("%M", time))
    local nowTime = (time + (minute > 0 and 60 * 60 or 0)) * 1000
    UIManager:getInstance():show("UIClubLeaderboardTime", nowTime - 86400000 * 6, nowTime, function(startTime, endTime)
        if self._leaderboardType == ClubConstant:getLeaderboardType().winner and self._isPermissions then
            UIManager:getInstance():show("UIClubLeaderboardFind", function(winnerScore)
                self:_updataTime(startTime / 1000, endTime / 1000)
                self:_sendClubPlayerInfo(startTime, endTime, winnerScore)
            end)
        else
            self:_updataTime(startTime / 1000, endTime / 1000)
            self:_sendClubPlayerInfo(startTime, endTime, 0)
        end
    end)
end

function UIClubLeaderboardMain:onClickInquire()
    self:_onClickInquire()
end

-- 更新按钮显示时间
function UIClubLeaderboardMain:_updataTime(startTime, endTime)
    self._startTime = startTime
    self._endtime = endTime
    self._textStartTime:setString(os.date("%m.%d %H:00", startTime))
    self._textEndTime:setString(os.date("%m.%d %H:00", endTime))
end

-- 请求玩家排行榜数据
function UIClubLeaderboardMain:_sendClubPlayerInfo(startTime, endTime, winnerScore)
    self._clubLeaderboardService:sendCCLQueryMemberRankInfoREQ(self._clubId, self._leaderboardType, startTime, endTime, winnerScore)
end

-- 服务器返回玩家排行榜数据（除数据日报）
function UIClubLeaderboardMain:_playerInfo(event)
    -- 如果服务器返回的类型不是客户端显示的类型就不更新数据
    if event.rankType ~= self._leaderboardType then
        return
    end

    -- 没有排行榜数据的情况
    if event.rankInfos == nil or #event.rankInfos == 0 then
        self._imgTips:setVisible(true)
    else
        -- 排序
        table.sort(event.rankInfos, function(a, b)
            if a.rankDatas[1] == b.rankDatas[1] then
                -- 数据相同的玩家id小的在前
                return a.roleId < b.roleId
            end
            -- 数据大的在前
            return a.rankDatas[1] > b.rankDatas[1]
        end)

        self._imgTips:setVisible(false)
    end

    if self._uiElemList[self._leaderboardType] ~= nil then
        -- TODO:子界面重写
        self._uiElemList[self._leaderboardType]:onPlayerInfo(event)
    end
end

-- 请求数据日报
function UIClubLeaderboardMain:_sendClubPlayerDataInfo()
    self._clubLeaderboardService:sendCCLQueryStatisticsInfoREQ(self._clubId)
end

-- 更新俱乐部数据日报
function UIClubLeaderboardMain:_playerDataInfo(event)
    if ClubConstant:getLeaderboardType().dataDaily ~= self._leaderboardType then
        return
    end

    -- 没有排行榜数据的情况
    if event.statisticsInfos == nil or #event.statisticsInfos == 0 then
        self._imgTips:setVisible(true)
    else
        -- 排序
        table.sort(event.statisticsInfos, function(a, b)
            -- 日报按时间进行排序
            return a.timeStamp > b.timeStamp
        end)

        self._imgTips:setVisible(false)
    end

    if self._uiElemList[self._leaderboardType] ~= nil then
        -- TODO:子界面重写
        self._uiElemList[self._leaderboardType]:onPlayerDataInfo(event)
    end
end

-- 关闭界面
function UIClubLeaderboardMain:_onClickQuit()
    UIManager:getInstance():show("UIClubRoom", self._clubId)
    UIManager:getInstance():hide("UIClubLeaderboardMain")
end

function UIClubLeaderboardMain:onHide()
    -- 清空列表
    self:_hideAllPages()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._clubId = 0
    self._leaderboardType = 0
    self._startTime = nil
    self._endtime = nil
    self._listLeaderboardItem:removeAllChildren()

    self._clubLeaderboardService:removeEventListenersByTag(self)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubLeaderboardMain:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubLeaderboardMain