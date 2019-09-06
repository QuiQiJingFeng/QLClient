local csbPath = app.UIClubRoomCsb
local super = app.UIBase
local UITableViewEx = app.UITableViewEx
local Util = app.Util
local UIClubRoomItem = app.UIClubRoomItem
local UIManager = app.UIManager

local UIClubRoom = class("UIClubRoom", super, function () return app.Util:loadCSBNode(csbPath) 
end)

function UIClubRoom:ctor()
end

function UIClubRoom:init()
    local node = Util:seekNodeByName(self,"scrollListRoom","ccui.ScrollView")
    self._scrollListRoom = UITableViewEx.extend(node, UIClubRoomItem)
    self._scrollListRoom:perUnitNums(3)
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")

    --俱乐部公告
    self._panelNotice = Util:seekNodeByName(self,"panelNotice","ccui.Layout")
    self._btnEdit = Util:seekNodeByName(self,"btnEdit","ccui.Button")
    self._txtClubNotice = Util:seekNodeByName(self,"txtClubNotice","ccui.Text")


    self._imgClubIcon = Util:seekNodeByName(self,"imgClubIcon","ccui.ImageView")
    self._txtClubName = Util:seekNodeByName(self,"txtClubName","ccui.Text")
    self._txtInviteCode = Util:seekNodeByName(self,"txtInviteCode","ccui.Text")
    
    self._btnMore = Util:seekNodeByName(self,"btnMore","ccui.Button")

    self._txtBmfCardValue = Util:seekNodeByName(self,"txtBmfCardValue","ccui.Text")
    self._btnAdd = Util:seekNodeByName(self,"btnAdd","ccui.Button")

    
    self._btnManager = Util:seekNodeByName(self,"btnManager","ccui.Button")
    self._btnDataStatistics = Util:seekNodeByName(self,"btnDataStatistics","ccui.Button")
    self._btnEmail = Util:seekNodeByName(self,"btnEmail","ccui.Button")
    self._btnHistory = Util:seekNodeByName(self,"btnHistory","ccui.Button")
    self._btnMember = Util:seekNodeByName(self,"btnMember","ccui.Button")
    
    Util:bindTouchEvent(self._btnAdd,handler(self,self._onBtnAddClick))
    Util:bindTouchEvent(self._btnEdit,handler(self,self._onBtnEditClick))
    Util:bindTouchEvent(self._btnMember,handler(self,self._onBtnMemberClick))

    Util:bindTouchEvent(self._btnHistory,handler(self,self._onBtnHistoryClick))
    Util:bindTouchEvent(self._btnEmail,handler(self,self._onBtnEmailClick))
    Util:bindTouchEvent(self._btnDataStatistics,handler(self,self._onBtnDataStatisticsClick))
    Util:bindTouchEvent(self._btnManager,handler(self,self._onBtnManagerClick))
    Util:bindTouchEvent(self._btnMore,handler(self,self._onBtnMoreClick))

    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    
end

function UIClubRoom:_onBtnAddClick()
	UIManager:getInstance():show("UIShop",1)
end

function UIClubRoom:_onBtnBackClick()
	app.GameFSM:getInstance():enterState("GameState_Lobby")
end

function UIClubRoom:_onBtnMoreClick()
	UIManager:getInstance():show("UIClubList")
end

function UIClubRoom:_onBtnHistoryClick()
	UIManager:getInstance():show("UIClubHistoryRecord")
end

function UIClubRoom:_onBtnEmailClick()
	UIManager:getInstance():show("UIClubMessage")
end

function UIClubRoom:_onBtnDataStatisticsClick()
    UIManager:getInstance():show("UIClubDataStatistics")
end

function UIClubRoom:_onBtnManagerClick()
    UIManager:getInstance():show("UIClubManager")
end

function UIClubRoom:_onBtnMemberClick()
	UIManager:getInstance():show("UIClubMember")
end

function UIClubRoom:_onBtnEditClick()
	UIManager:getInstance():show("UIClubEditNotice")
end

function UIClubRoom:needBlackMask()
	return false
end

function UIClubRoom:isFullScreen()
    return true
end

function UIClubRoom:getGradeLayerLevel()
	return 2
end

function UIClubRoom:onShow()

end

return UIClubRoom