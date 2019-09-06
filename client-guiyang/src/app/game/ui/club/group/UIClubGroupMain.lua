local csbPath = "ui/csb/Club/UIClubGroupMain.csb"
local super = require("app.game.ui.UIBase")

local UIClubGroupMain = class("UIClubGroupMain", super, function() return kod.LoadCSBNode(csbPath) end)

local GROUPTYPE_MANAGER = 
{
    {name = "我的搭档", ui = "UIClubGroupList", talkingData = "UIClubGroupList_new", id = 1},
    {name = "添加搭档", ui = "UIClubGroupCreate", talkingData = "UIClubGroupCreate_new", id = 2},
}

local GROUPTYPE_LEADER =
{
    {name = "我的成员", ui = "UIClubGroupMember", talkingData = "UIClubGroupMember_new", id = 1},
    {name = "管理成员", ui = "UIClubGroupManager", talkingData = "UIClubGroupManager_new", id = 2},
}

function UIClubGroupMain:ctor()
    self._btnCheckList = {}
    self._uiElemList = {}
    self._textList = {}
    self._showUiType = 0
end

function UIClubGroupMain:init()
    self._btnQuit = seekNodeByName(self, "Button_group", "ccui.Button")
    self._listClubGroupItem = seekNodeByName(self, "ListView_groupType", "ccui.ListView")
    self._node = seekNodeByName(self, "Panel_group", "ccui.Layout")
    self._btnHistory = seekNodeByName(self, "Button_history", "ccui.Button")

    -- 克隆item
    self._listClubGroupItem:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listClubGroupItem, "Panel_TYPE_BUTTON")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnHistory, handler(self, self._onBtnHistoryClick), ccui.TouchEventType.ended)
end

function UIClubGroupMain:onShow(clubId)
    self._clubId = clubId

    self:_initGroupList()
end

function UIClubGroupMain:getClubId()
    return self._clubId
end

function UIClubGroupMain:_initGroupList()
    -- 清空列表
    self._listClubGroupItem:removeAllChildren()
    self._btnCheckList = {}
    -- 判断自己是不是群主
    local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
    local club = game.service.club.ClubService.getInstance():getClub(self._clubId)
    local isManager = club:isManager(roleId)

    self._groupType = isManager and GROUPTYPE_MANAGER or GROUPTYPE_LEADER
    self._btnHistory:setVisible(not isManager)

    for k, v in ipairs(self._groupType) do
        self:_initGroupItem(v)
    end

    -- 默认显示第一个
    self:_onItemTypeClicked(self._groupType[1])
end

function UIClubGroupMain:_initGroupItem(groupType)
    local node = self._listviewItemBig:clone()
    self._listClubGroupItem:addChild(node)
    node:setVisible(true)
    -- item名称
    local textType = ccui.Helper:seekNodeByName(node, "Text_groupName")
    textType:setString(groupType.name)

    local isSelected = false

    local checkBox = ccui.Helper:seekNodeByName(node, "GAME_TYPE_BUTTON")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(groupType)
            checkBox:setSelected(true)
            game.service.DataEyeService.getInstance():onEvent(groupType.talkingData)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[groupType.id] = checkBox
    self._textList[groupType.id] = textType
end

function UIClubGroupMain:_onItemTypeClicked(groupType, groupInfo)
    -- 按钮的显示与隐藏
	for k,v in pairs(self._btnCheckList) do
        if self._showUiType ~= groupType.id then
            self:chageItemName(self._groupType[k].id, self._groupType[k].name)
        end
        if k == groupType.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    if self._showUiType == groupType.id then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[groupType.id] == nil then
        local clz = require("app.game.ui.club.group." .. groupType.ui)
        local ui = clz.new(self)
        self._uiElemList[groupType.id] = ui
        self._node:addChild(ui)
    end

    self._showUiType = groupType.id

    self:_hideAllPages()
    self._uiElemList[groupType.id]:show(groupInfo)
end


function UIClubGroupMain:_onBtnQuitClick()
    UIManager:getInstance():hide("UIClubGroupMain")
end

function UIClubGroupMain:_onBtnHistoryClick()
    UIManager:getInstance():show("UIClubHistoryPage", self._clubId, "UIClubGroupMain")
    self:_onBtnQuitClick()
end

function UIClubGroupMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

-- 提供子类一个切换页签的方法
function UIClubGroupMain:updataBookMark(groupType, groupInfo)
    self:_onItemTypeClicked(groupType, groupInfo)
end

-- 更改子页签的名字
function UIClubGroupMain:chageItemName(idx, name)
    self._textList[idx]:setString(name)
end

function UIClubGroupMain:getGroupType()
    return self._groupType
end

function UIClubGroupMain:onHide()
    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList= {}
    self._textList = {}
    self._showUiType = 0
end

function UIClubGroupMain:needBlackMask()
	return true
end

function UIClubGroupMain:closeWhenClickMask()
	return false
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UIClubGroupMain:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top;
end

return UIClubGroupMain
