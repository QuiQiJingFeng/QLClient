local csbPath = "ui/csb/mengya/club/UIClubRoom.csb"
local super = game.UIBase
local UITableViewEx = game.UITableViewEx
local Util = game.Util
local UIClubMainItem = game.UIClubMainItem
local UIManager = game.UIManager

local UIClubMain = class("UIClubMain", super, function () return game.Util:loadCSBNode(csbPath) 
end)

function UIClubMain:ctor()
end

function UIClubMain:init()
    local node = Util:seekNodeByName(self,"scrollListRoom","ccui.ScrollView")
    self._scrollListRoom = UITableViewEx.extend(node, UIClubMainItem)
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

function UIClubMain:_onBtnAddClick()
	UIManager:getInstance():show("UIShop",1)
end

function UIClubMain:_onBtnBackClick()
	game.GameFSM:getInstance():enterState("GameState_Lobby")
end

function UIClubMain:_onBtnMoreClick()
	UIManager:getInstance():show("views.UIClubList")
end

function UIClubMain:_onBtnHistoryClick()
	UIManager:getInstance():show("views.UIClubHistoryRecord")
end

function UIClubMain:_onBtnEmailClick()
	UIManager:getInstance():show("views.UIClubMessage")
end

function UIClubMain:_onBtnDataStatisticsClick()
    UIManager:getInstance():show("views.UIClubDataStatistics")
end

function UIClubMain:_onBtnManagerClick()
    UIManager:getInstance():show("views.UIClubManager")
end

function UIClubMain:_onBtnMemberClick()
	UIManager:getInstance():show("views.UIClubMember")
end

function UIClubMain:_onBtnEditClick()
	UIManager:getInstance():show("UIClubEditNotice")
end

function UIClubMain:needBlackMask()
	return false
end

function UIClubMain:isFullScreen()
    return true
end

function UIClubMain:getGradeLayerLevel()
	return 2
end

function UIClubMain:onShow()

end

return UIClubMain