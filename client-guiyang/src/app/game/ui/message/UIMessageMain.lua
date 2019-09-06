local csbPath = "ui/csb/Mail/UIMessageMain.csb"
local super = require("app.game.ui.UIBase")
local ClubConstant = require("app.game.service.club.data.ClubConstant")

--[[
    俱乐部消息
        公告
        邮件
        亲友圈动态
        亲友圈申请
]]

local MESSAGE_TYPE =
{
    {name = "动态", ui = "UIOperationRecord", isVisible = false, id = 1, sortId = 1},
    {name = "动态", ui = "UIOperationRecord2", isVisible = false, id = 3, sortId = 2},
    {name = "审批", ui = "UIApplicationPage", isVisible = false, id = 2, sortId = 3},
    {name = "审批", ui = "UIApplicationPage2", isVisible = false, id = 4, sortId = 4},
    {name = "公告", ui = "UINotice", isVisible = true, id = 5, sortId = 6},
    {name = "邮件", ui = "UIMailMain", isVisible = true, id = 6, sortId = 5},
}

local UIMessageMain = class("UIMessageMain", super, function() return kod.LoadCSBNode(csbPath) end)

function UIMessageMain:ctor()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._imgRedDot = {}
    self._showUiType = 0
    self._clubId = 0
end

function UIMessageMain:init()
    self._listMessage = seekNodeByName(self, "ListView_messageType", "ccui.ListView")
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listMessage, "Panel_tiem")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    self._node = seekNodeByName(self, "Panel_node", "ccui.Layout")

    self._btnQuit = seekNodeByName(self, "btnClose", "ccui.Button")
    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end

function UIMessageMain:_onBtnQuitClick()
    UIManager:getInstance():destroy("UIMessageMain")
end


function UIMessageMain:onShow(clubId, isSuperLeague)
    self._clubId = clubId
    local isSuperLeague = isSuperLeague or false
    -- 判断页签是否要显示
    if self._clubId ~= 0 then
        local clubService = game.service.club.ClubService.getInstance()
        local club = clubService:getClub(self._clubId)
        local isLeague = false
        if game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId() ~= 0 then
            isLeague =true
        end
        local isPermissions = club:isPermissions(game.service.LocalPlayerService:getInstance():getRoleId())
        MESSAGE_TYPE[1].isVisible = club.playerInfo.title ~= ClubConstant:getClubPosition().OBSERVER and not isLeague
        MESSAGE_TYPE[3].isVisible = isPermissions
        MESSAGE_TYPE[2].isVisible = isLeague
        MESSAGE_TYPE[4].isVisible = false
    else
        MESSAGE_TYPE[1].isVisible = false
        MESSAGE_TYPE[3].isVisible = false
        MESSAGE_TYPE[2].isVisible = isSuperLeague
        MESSAGE_TYPE[4].isVisible = isSuperLeague
    end
    self:_initMessageList()
    self:_onRedDotChanged()
    if self._clubId ~= 0 then
        self:_showTabBadge()
        game.service.club.ClubService.getInstance():addEventListener("EVENT_CLUB_REDDOT_CHANGED", handler(self, self._showTabBadge), self)
    elseif game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getLeagueId() ~= 0 then
        self:_updateLeagueInfo()
        game.service.bigLeague.BigLeagueService:getInstance():addEventListener("EVENT_LEAGUE_INFO_SYN", handler(self, self._updateLeagueInfo), self)
    end
    self:_onShowItem()
    game.service.NoticeMailService:getInstance():addEventListener("EVENT_REDDOT_CHANGED", handler(self, self._onRedDotChanged), self)
end

function UIMessageMain:_updateLeagueInfo()
    if self._imgRedDot[4] ~= nil then
        self._imgRedDot[4]:setVisible(game.service.bigLeague.BigLeagueService:getInstance():getLeagueData():getHaveApproval())
    end
end

-- 红点状态改变
function UIMessageMain:_onRedDotChanged()
    local noticeService = game.service.NoticeMailService.getInstance()
    if self._imgRedDot[5] ~= nil then
        self._imgRedDot[5]:setVisible(noticeService:isNoticeDotShow())
    end
    if self._imgRedDot[6] ~= nil then
        self._imgRedDot[6]:setVisible(noticeService:isMailDotShow())
    end
end

function UIMessageMain:_showTabBadge()
    if self._clubId == 0 then
        return
    end
    local service = game.service.club.ClubService.getInstance()
    local club = service:getClub(self._clubId)
    if self._imgRedDot[2] then
        self._imgRedDot[2]:setVisible(club:hasApplicationBadges())
    end
end

function UIMessageMain:getClubId()
    return self._clubId
end

function UIMessageMain:_initMessageList()
    -- 清空列表
    self._listMessage:removeAllChildren()
    self._btnCheckList = {}

    for k, v in ipairs(MESSAGE_TYPE) do
        if v.isVisible then
            self:_initMessageItem(v)
        end
    end
end

function UIMessageMain:_onShowItem()
    -- 先按红点的优先级排序:审批>邮件>公告
    local messageList = clone(MESSAGE_TYPE)
    table.sort(messageList, function (a, b)
        return a.sortId < b.sortId
    end)
    local itemInfo = nil
    for k, v in ipairs(messageList) do
        if v.isVisible then
            -- 保存一下第一个为true的界面
            if itemInfo == nil then
                itemInfo = v
            end
            -- 默认显示有红点的item
            if self._imgRedDot[v.id]:isVisible() then
                self:_onItemTypeClicked(v)
                return
            end
            -- 没有红点默认显示第一个为true的界面
            if k == #MESSAGE_TYPE then
                self:_onItemTypeClicked(itemInfo)
            end
        end
    end
end

function UIMessageMain:_initMessageItem(itemInfo)
    local node = self._listviewItemBig:clone()
    self._listMessage:addChild(node)
    node:setVisible(true)
    -- item名称
    local textType = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_messageName")
    textType:setString(itemInfo.name)
    -- 小红点
    local imgRedDot = ccui.Helper:seekNodeByName(node, "Image_red_Notice")
    self._imgRedDot[itemInfo.id] = imgRedDot
    imgRedDot:setVisible(false)

    local isSelected = false

    local checkBox = ccui.Helper:seekNodeByName(node, "CheckBox_item")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(itemInfo)
            checkBox:setSelected(true)
            game.service.DataEyeService.getInstance():onEvent(itemInfo.ui)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[itemInfo.id] = checkBox
end

function UIMessageMain:_onItemTypeClicked(itemInfo)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if k == itemInfo.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    if self._showUiType == itemInfo.id then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[itemInfo.id] == nil then
        local clz = require("app.game.ui.message." .. itemInfo.ui)
        local ui = clz.new(self)
        self._uiElemList[itemInfo.id] = ui
        self._node:addChild(ui)
    end

    self._showUiType = itemInfo.id

    self:_hideAllPages()
    self._uiElemList[itemInfo.id]:show()
end

function UIMessageMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIMessageMain:onHide()
    self:_hideAllPages()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._imgRedDot = {}
    self._showUiType = 0

    game.service.club.ClubService.getInstance():removeEventListenersByTag(self)
    game.service.NoticeMailService:getInstance():removeEventListenersByTag(self)
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
end

function UIMessageMain:onDestroy()
    self:onHide()
end

return UIMessageMain