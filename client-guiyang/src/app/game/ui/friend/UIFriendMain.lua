local csbPath = "ui/csb/UIFriendMain.csb"
local super = require("app.game.ui.UIBase")

local UIFriendMain = class("UIFriendMain", super, function() return kod.LoadCSBNode(csbPath) end)

local FRIEND_TYPE =
{
    {name = "我的好友", ui = "UIFriendList", id = 1},
    {name = "添加好友", ui = "UIFriendAdd", id = 2},
    {name = "好友申请", ui = "UIFriendApplication", id = 3},
}

function UIFriendMain:ctor()
    self._uiElemList = {}
    self._btnCheckList= {}
    self._friendTypeId = 0
end

function UIFriendMain:init()
    self._btnQuit = seekNodeByName(self, "Button_close", "ccui.Button")
    self._listFriendItem = seekNodeByName(self, "ListView_friendType", "ccui.ListView")
    self._node = seekNodeByName(self, "Panel_friend", "ccui.Layout")
     -- 克隆item
    self._listFriendItem:setScrollBarEnabled(false)
	self._listviewItemBig = ccui.Helper:seekNodeByName(self._listFriendItem, "Panel_type")
	self._listviewItemBig:removeFromParent(false)
	self:addChild(self._listviewItemBig)
	self._listviewItemBig:setVisible(false)

    bindEventCallBack(self._btnQuit, handler(self, self._onBtnQuitClick), ccui.TouchEventType.ended)
end


function UIFriendMain:onShow()
    for _, data in ipairs(FRIEND_TYPE) do
        self:_initFriendItem(data)
    end

    game.service.friend.FriendService.getInstance():addEventListener("EVENT_FRIEND_RED_CHAGE", handler(self, self._chageFriendRed), self)
	self:_chageFriendRed()

    self:_onItemTypeClicked(FRIEND_TYPE[1])
end

function UIFriendMain:_chageFriendRed()
    for k, v in pairs(self._btnCheckList) do
        local imgRed = ccui.Helper:seekNodeByName(v, "Image_red_Friend")
        if k == FRIEND_TYPE[3].id then
            imgRed:setVisible(game.service.friend.FriendService.getInstance():isApplicant())
        else
            imgRed:setVisible(false)
        end
	end
end


function UIFriendMain:_initFriendItem(friendType)
    local node = self._listviewItemBig:clone()
    self._listFriendItem:addChild(node)
    node:setVisible(true)
    -- item名称
    local textType = ccui.Helper:seekNodeByName(node, "Text_name")
    textType:setString(friendType.name)

    local isSelected = false

    local checkBox = ccui.Helper:seekNodeByName(node, "CheckBox_type")
    checkBox:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            isSelected = checkBox:isSelected()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then	
            self:_onItemTypeClicked(friendType)
            checkBox:setSelected(true)
            game.service.DataEyeService.getInstance():onEvent(friendType.ui)
        elseif eventType == ccui.TouchEventType.canceled then
            checkBox:setSelected(isSelected)
        end
    end)
    self._btnCheckList[friendType.id] = checkBox
end

function UIFriendMain:_onItemTypeClicked(friendType)
    -- 按钮的显示与隐藏
	for k, v in pairs(self._btnCheckList) do
        if k == friendType.id then
            v:setSelected(true)
        else
            v:setSelected(false)
        end
	end

    if self._friendTypeId == friendType.id then
        return
    end

    -- 创建对应的界面
    if self._uiElemList[friendType.id] == nil then
        local clz = require("app.game.ui.friend." .. friendType.ui)
        local ui = clz.new(self)
        self._uiElemList[friendType.id] = ui
        self._node:addChild(ui)
    end

    self:_hideAllPages()
    self._uiElemList[friendType.id]:show()

    self._friendTypeId = friendType.id
end

function UIFriendMain:_hideAllPages()
    for k, v in pairs(self._uiElemList) do
        v:hide()
    end
end

function UIFriendMain:_onBtnQuitClick()
    UIManager:getInstance():destroy("UIFriendMain")
end

function UIFriendMain:onHide()
    self:_hideAllPages()
    self._uiElemList = {}
    self._btnCheckList= {}
    self._friendTypeId = 0
    game.service.friend.FriendService.getInstance():removeEventListenersByTag(self)
end

return UIFriendMain