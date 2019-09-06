local csbPath = "ui/csb/BigLeague/UIBigLeagueMemberManager.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueMemberManager:UIBase
local UIBigLeagueMemberManager = super.buildUIClass("UIBigLeagueMemberManager", csbPath)

local MemberType =
{
    {id = 1, name = "成员", ui = "UIBigLeagueMember_Member"},
    {id = 2, name = "搭档", ui = "UIBigLeagueMember_Partner"}
}

function UIBigLeagueMemberManager:ctor()

end

function UIBigLeagueMemberManager:init()
    self._listMemberItem = seekNodeByName(self, "ListView_MemberType", "ccui.ListView")
    self._listMemberItem:setScrollBarEnabled(false)
    self._listviewItemBig = ccui.Helper:seekNodeByName(self._listMemberItem, "Panel_Node")
    self._listviewItemBig:removeFromParent(false)
    self:addChild(self._listviewItemBig)
    self._listviewItemBig:setVisible(false)

    self._textPeoples = seekNodeByName(self, "TextBMFont_Peoples", "ccui.TextBMFont")
    self._textPeoples:setVisible(false)
    self._node = seekNodeByName(self, "Panel_Member", "ccui.Layout")

    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button") -- 关闭
    self._btnSearch = seekNodeByName(self, "Button_search", "ccui.Button")
    self._btnInvite = seekNodeByName(self, "Button_invite", "ccui.Button")
    self._btnSetting = seekNodeByName(self, "Button_Setting", "ccui.Button")
    self._btnInvite:setVisible(false)

    self._panelTime = seekNodeByName(self, "Panel_Time", "ccui.Layout")
    self._btnAll = seekNodeByName(self, "CheckBox_All", "ccui.CheckBox")
    self._btnToday = seekNodeByName(self, "CheckBox_Today", "ccui.CheckBox")
    self._btnThreeDays = seekNodeByName(self, "CheckBox_ThreeDays", "ccui.CheckBox")
    self._btnSevenDays = seekNodeByName(self, "CheckBox_SevenDays", "ccui.CheckBox")

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSearch, handler(self, self._onClickSearch), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnInvite, handler(self, self._onClickInvite), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnSetting, handler(self, self._onClickSetting), ccui.TouchEventType.ended)

    local tbChkBox = {self._btnAll, self._btnToday, self._btnThreeDays, self._btnSevenDays}

    local isSelected = false
    local pFunc = function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = sender:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if sender:getName() == "CheckBox_Today" then
                self._isSort = true
                self:_sendCCLQueryMembersREQ(1)
            elseif sender:getName() == "CheckBox_ThreeDays" then
                self._isSort = true
                self:_sendCCLQueryMembersREQ(3)
            elseif sender:getName() == "CheckBox_SevenDays" then
                self._isSort = true
                self:_sendCCLQueryMembersREQ(7)
            elseif sender:getName() == "CheckBox_All" then
                self._isSort = false
                self:_sendCCLQueryMembersREQ(0)
            end

            for _,btn in ipairs(tbChkBox) do
                btn:setSelected(sender == btn)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            sender:setSelected(isSelected)
        end
    end

    self._btnAll:addTouchEventListener(pFunc)
    self._btnToday:addTouchEventListener(pFunc)
    self._btnThreeDays:addTouchEventListener(pFunc)
    self._btnSevenDays:addTouchEventListener(pFunc)
end

function UIBigLeagueMemberManager:_sendCCLQueryMembersREQ(days)
    self._bigLeagueService:sendCCLQueryMembersREQ(
            self._bigLeagueService:getLeagueData():getLeagueId(),
            self._bigLeagueService:getLeagueData():getClubId(),
            days,
            self._showUiType == MemberType[1].id and self._bigLeagueService:getLeagueData():getMemberType().MEMBER or self._bigLeagueService:getLeagueData():getMemberType().PARTNER,
            self._bigLeagueService:getLeagueData():getTitle(),
            0
    )
end

function UIBigLeagueMemberManager:_onClickClose()
    self:hideSelf()
end

function UIBigLeagueMemberManager:_onClickSearch()
    UIManager:getInstance():show("UIBigLeagueMemberFind", function (playerInfo)
        if playerInfo == "" then
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入成员昵称或Id")
            return
        end

        local searchMembers = {}
        for _, data in ipairs(self._bigLeagueService:getLeagueData():getMemberInfo()) do
            if string.find(data.nickname, playerInfo) ~= nil or string.find(data.roleId, playerInfo) then
                table.insert(searchMembers, data)
            end
        end
        if #searchMembers == 0 then
            game.ui.UIMessageTipsMgr.getInstance():showTips("未找到该玩家")
            return
        end

        if self._uiElemList[self._showUiType] then
            self._uiElemList[self._showUiType]:upadtaListViewInfo(searchMembers)
        end
        UIManager:getInstance():destroy("UIBigLeagueMemberFind")
    end)
end

function UIBigLeagueMemberManager:_onClickInvite()
    local clubId = self._bigLeagueService:getLeagueData():getClubId()
    local club = game.service.club.ClubService.getInstance():getClub(clubId)

    UIManager:getInstance():show("UIBigLeagueMemberInvite",club)
end

function UIBigLeagueMemberManager:_onClickSetting()
    -- 活跃值设置
    UIManager:getInstance():show("UIBigLeagueFireGive",self._bigLeagueService:getLeagueData():getClubId())
end

function UIBigLeagueMemberManager:getisSort()
    return self._isSort
end

function UIBigLeagueMemberManager:onShow(uiId)
    self._uiElemList = {}
    self._btnCheckList= {}
    self._showUiType = 0
    self._isSort = false
    self._uiId = uiId or 1

    self._bigLeagueService = game.service.bigLeague.BigLeagueService:getInstance()
    -- 当在该界面把搭档取消后没有搭档了，就变成原来的界面
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_INFO_SYN", function ()
        if self._bigLeagueService:getLeagueData():getPartnerNumber() <= 0 then
            UIManager:getInstance():show("UIBigLeagueMember", 0, self._bigLeagueService:getLeagueData():getMemberType().MEMBER)
            self:hideSelf()
        end
    end, self)
    self._bigLeagueService:addEventListener("EVENT_LEAGUE_MEMBER", handler(self, self._upadtaListView), self)
    self._bigLeagueService:addEventListener("EVENT_UPDATA_MEMBER_INFO", function ()
        self:_sendCCLQueryMembersREQ(0)
    end , self)
    event.EventCenter:addEventListener("EVENT_CLUB_INVITE_SUC", function ()
        self:_sendCCLQueryMembersREQ(0)
    end)

    self:_initMemberList()
end

function UIBigLeagueMemberManager:_upadtaListView(event)
    if self._uiElemList[self._showUiType] then
        self._uiElemList[self._showUiType]:updataMemberInfo(event.roleId)
    end
end

function UIBigLeagueMemberManager:_initMemberList()
    self._listMemberItem:removeAllChildren()
    for _, v in ipairs(MemberType) do
        self:_initMemberItem(v)
    end

    self:_onItemTypeClicked(MemberType[self._uiId])
end

function UIBigLeagueMemberManager:_initMemberItem(data)
    local node = self._listviewItemBig:clone()
    self._listMemberItem:addChild(node)
    node:setVisible(true)
    -- item名称
    local textType = ccui.Helper:seekNodeByName(node, "BitmapFontLabel_Name")
    textType:setString(data.name)

    local isSelected = false

    local checkBox = ccui.Helper:seekNodeByName(node, "CheckBox")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self:_onItemTypeClicked(data)
            checkBox:setSelected(true)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)

    self._btnCheckList[data.id] = checkBox
end

function UIBigLeagueMemberManager:_onItemTypeClicked(data)
    for k,v in pairs(self._btnCheckList) do
        if k == data.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
    end

    if self._showUiType == data.id then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[data.id] == nil then
        local clz = require("app.game.ui.bigLeague.member." .. data.ui)
        local ui = clz.new(self)
        self._uiElemList[data.id] = ui
        self._node:addChild(ui)
    end

    self._showUiType = data.id

    self:_hideAllPages()
    self._uiElemList[data.id]:show()


    self:_sendCCLQueryMembersREQ(0)
    local tbChkBox = {self._btnAll, self._btnToday, self._btnThreeDays, self._btnSevenDays}
    for _,btn in ipairs(tbChkBox) do
        btn:setSelected(btn == self._btnAll)
    end

    self._panelTime:setVisible(data.id == MemberType[1].id)
    self._btnSetting:setVisible(data.id == MemberType[2].id)
end

function UIBigLeagueMemberManager:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIBigLeagueMemberManager:onHide()
    self._uiElemList = {}
    self._btnCheckList= {}
    self._showUiType = 0
    self:_hideAllPages()
    game.service.bigLeague.BigLeagueService:getInstance():removeEventListenersByTag(self)
    event.EventCenter:removeEventListenersByTag(self)
end

return UIBigLeagueMemberManager