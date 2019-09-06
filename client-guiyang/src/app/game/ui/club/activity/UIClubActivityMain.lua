local csbPath = "ui/csb/Club/UIClubActivityMain.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local UIClubActivityMain = class("UIClubActivityMain", super, function() return kod.LoadCSBNode(csbPath) end)

--[[
    亲友圈活动主界面
    显示内容：
        1.创建活动页签
        2.活动页签（开始、未开始、已结束）
        3.显示子界面
]]

local ACTIVITY_TYPE =
{
    {"创建活动", "UIClubActivityCreate"},
    {"活动信息", "UIClubActivityInfo"},
    {config.STRING.UICLUBACTIVITYMAIN_STRING_101, "UIClubActivityCampaign"},
}

function UIClubActivityMain:ctor()
    self._listActivityItem = nil -- 亲友圈主界面功能
    self._btnQuit = nil -- 返回
    self._btnCheckList = {}
    self._uiElemList = {}
    self._node = nil
    
    self._saveTime = {}

    self._imgTips = nil -- 提示
end

function UIClubActivityMain:init()
    self._btnQuit = seekNodeByName(self, "Button_x_Activity", "ccui.Button")
    self._listActivityItem = seekNodeByName(self, "ListView_activity_type", "ccui.ListView")
    self._node = seekNodeByName(self, "Panel_Activity", "ccui.Layout")
    self._imgTips = seekNodeByName(self, "Image_No", "ccui.ImageView")

    self._btnRewards = seekNodeByName(self, "Button_record",   "ccui.Button")      -- 参赛记录
    self._btnHelp    = seekNodeByName(self, "Button_help", "ccui.Button")  -- 赛事介绍  

    self._cardPanel = seekNodeByName(self, "Image_roomCard", "ccui.ImageView")

    self._imgTips:setVisible(false)

    -- 克隆item
    self._listActivityItem:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listActivityItem, "Panel_TYPE_BUTTON")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIClubActivityMain:onShow(clubId)
    self._clubId = clubId

    local clubService = game.service.club.ClubService.getInstance()

    local clubActivityService = clubService:getClubActivityService()
    -- 请求亲友圈活动列表
    clubActivityService:sendCCLQueryManagerActivityListREQ(self._clubId)

    clubActivityService:addEventListener("EVENT_CLUB_ACTIVITY_LIST_SUCCESS", handler(self, self._initActivityList), self)

    -- 不显示自建赛里的内容
    self._btnRewards:setVisible(false)
    self._btnHelp:setVisible(false)
    self._cardPanel:setVisible(false)
    self._bindKey = CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.CARD, self._cardPanel)
end

function UIClubActivityMain:_initActivityList(event)
    -- 清空列表
    self._listActivityItem:removeAllChildren()

    self._btnCheckList = {}

    if event.clubId ~= self._clubId then
        return
    end

    -- 判断自己是不是群主
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local isManager = club:isManager(roleId)

    if isManager then
        local data =
        {
            title = "创建活动",
            status = 0,
            id = ""
        }
        self:_initActivityItem(data, ACTIVITY_TYPE[1])
    end

    -- eventList内添加自建赛
    local selfMatch = {
        title = config.STRING.UICLUBACTIVITYMAIN_STRING_101,
        status = 0,
        id = "match"
    }
    self:_initActivityItem(selfMatch, ACTIVITY_TYPE[3])

    -- 赛事常驻显示
    self._imgTips:setVisible(false)
    if not isManager and #event.acitivtyList <= 0 then
        self._imgTips:setVisible(false)
        self:_onItemTypeClicked("match", ACTIVITY_TYPE[3], selfMatch)
        return
    end

     -- 活动页签的排序方式：进行中的（结束时间早的靠前）>即将开始的（开始时间早的靠前）>已经结束的（结束时间早的靠前）
     if #event.acitivtyList > 1 then
        table.sort(event.acitivtyList, function(a, b)
            if a.status == b.status then
                if a.status == ClubConstant:getActivityStatus().start then
                    return a.startTime < b.startTime
                else
                    return a.endTime < b.endTime
                end
            end

            return a.status < b.status
        end)
    end

    for _, data in ipairs(event.acitivtyList) do
        if data.id == "match" then
            self:_initActivityItem(data, ACTIVITY_TYPE[3])
        else
            self:_initActivityItem(data, ACTIVITY_TYPE[2])
        end
    end

    self:_onItemTypeClicked(
        isManager and "" or event.acitivtyList[1].id,
        ACTIVITY_TYPE[isManager and 1 or 2],
        isManager and {} or event.acitivtyList[1]
    )
end

function UIClubActivityMain:_initActivityItem(data, activityType)
    local node = self._listviewItemBig:clone()
    self._listActivityItem:addChild(node)
    node:setVisible(true)
    --活动名字
    local textType = ccui.Helper:seekNodeByName(node, "Text_activity_name")
    -- 活动状态的Icon
    local imgStart = ccui.Helper:seekNodeByName(node, "Image_start")
    local imgProcessing = ccui.Helper:seekNodeByName(node, "Image_processing")
    local imgEnd = ccui.Helper:seekNodeByName(node, "Image_end")
    ccui.Helper:seekNodeByName(node, "Image_jjks"):setVisible(false)

    imgStart:setVisible(data.status == ClubConstant:getActivityStatus().start)
    imgProcessing:setVisible(data.status == ClubConstant:getActivityStatus().processing)
    imgEnd:setVisible(data.status == ClubConstant:getActivityStatus().status_end)

    textType:setString(game.service.club.ClubService.getInstance():getInterceptString(data.title, 10))

    local isSelected = false

    local checkBox = ccui.Helper:seekNodeByName(node, "GAME_TYPE_BUTTON")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(data.id, activityType, data)
            checkBox:setSelected(true)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[data.id] = checkBox
end

--[[
    activityId:活动页签按照活动Id保存
    type:显示的UI类型
    data:活动数据
]]
function UIClubActivityMain:_onItemTypeClicked(activityId, type, data)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == activityId then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    -- 创建对应的活动界面
    if self._uiElemList[type[2]] == nil then
        local clz = require("app.game.ui.club.activity." .. type[2])
        local ui = clz.new(self)
        self._uiElemList[type[2]] = ui
        self._node:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[type[2]]:show(self._clubId, data)
end


function UIClubActivityMain:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubActivityMain")
end

function UIClubActivityMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIClubActivityMain:onHide()
    game.service.club.ClubService.getInstance():getClubActivityService():removeEventListenersByTag(self)

    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList= {}
    self._saveTime = {}
    if self._bindKey then
        CurrencyHelper.getInstance():getBinder():unbind(self._bindKey)
    end
    self._bindKey = nil
end

function UIClubActivityMain:needBlackMask()
	return true
end

function UIClubActivityMain:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubActivityMain:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubActivityMain
