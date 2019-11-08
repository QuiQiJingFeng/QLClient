local csbPath = "ui/csb/mengya/UIMain.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableViewEx = game.UITableViewEx
local UILobbyRightItem = import("items.UILobbyRightItem")
local UILobby = class("UILobby", super, function() return Util:loadCSBNode(csbPath) end)
local ITEM_TYPE = game.UIConstant.LOBBY_RIGHT_ITEM_TYPE
function UILobby:init()
    
    local node = Util:seekNodeByName(self,"scrollMainRight","ccui.ScrollView")
    self._scrollMainRight = UITableViewEx.extend(node,UILobbyRightItem,handler(self,self._onRightListItemClick))
    self._scrollMainRight:perUnitNums(2)

    self._btnClub = Util:seekNodeByName(self,"btnClub","ccui.Button")
    Util:bindTouchEvent(self._btnClub,handler(self,self._onBtnClubClick),0.95)

    self._btnCreateRoom = Util:seekNodeByName(self,"btnCreateRoom","ccui.Button")
    Util:bindTouchEvent(self._btnCreateRoom,handler(self,self._onBtnCreateRoomClick),0.95)

    self._btnJoinRoom = Util:seekNodeByName(self,"btnJoinRoom","ccui.Button")
    Util:bindTouchEvent(self._btnJoinRoom,handler(self,self._onBtnJoinRoomClick),0.95)

    --商店模块
    self._btnAddCard = Util:seekNodeByName(self,"btnAddCard","ccui.Button")
    self._btnAddBean = Util:seekNodeByName(self,"btnAddBean","ccui.Button")
    self._btnAddGold = Util:seekNodeByName(self,"btnAddGold","ccui.Button")
    self._btnShop = Util:seekNodeByName(self,"btnShop","ccui.Button")
    
    Util:bindTouchEvent(self._btnShop,handlerFix(self,self._onBtnShopClick,1))
    Util:bindTouchEvent(self._btnAddCard,handlerFix(self,self._onBtnShopClick,1))
    Util:bindTouchEvent(self._btnAddBean,handlerFix(self,self._onBtnShopClick,2))
    Util:bindTouchEvent(self._btnAddGold,handlerFix(self,self._onBtnShopClick,3))

    self._panelMore = Util:seekNodeByName(self,"panelMore","ccui.Layout")
    self._panelMask = Util:seekNodeByName(self,"panelMask","ccui.Layout")
    self._btnMore = Util:seekNodeByName(self,"btnMore","ccui.Button")
    Util:bindTouchEvent(self._btnMore,handler(self,self._onBtnMoreClick))
    Util:bindTouchEvent(self._panelMask,handler(self,self._onBtnMoreClick))
    Util:hide(self._panelMask,self._panelMore)

    self._panelPlayerInfo = Util:seekNodeByName(self,"panelPlayerInfo","ccui.Layout")
    Util:bindTouchEvent(self._panelPlayerInfo,handler(self,self._onPanelPlayerInfoClick))

    self._btnGamePlayHelp = Util:seekNodeByName(self,"btnGamePlayHelp","ccui.Button")
    Util:bindTouchEvent(self._btnGamePlayHelp,handler(self,self._onBtnGamePlayHelpClick))

    self._btnSetting = Util:seekNodeByName(self,"btnSetting","ccui.Button")
    Util:bindTouchEvent(self._btnSetting,handler(self,self._onBtnSettingClick))

    
end

function UILobby:_onBtnSettingClick()
    UIManager:getInstance():show("UISetting")
end

function UILobby:_onBtnGamePlayHelpClick()
    UIManager:getInstance():show("UIHelp")
end

function UILobby:_onPanelPlayerInfoClick()
    UIManager:getInstance():show("UIPersonalCenter")
end

function UILobby:_onBtnMoreClick()
    local visible = not self._panelMore:isVisible()
    self._panelMore:setVisible(visible)
    self._panelMask:setVisible(visible)
	if visible then
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1), cc.ScaleTo:create(0.05, 1)))
	else
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.1), cc.ScaleTo:create(0.15, 0)))
	end
end

function UILobby:_onBtnShopClick(tag)
    UIManager:getInstance():show("UIShop",tag)
end

function UILobby:_onBtnJoinRoomClick()

end

function UILobby:_onBtnClubClick()
    UIManager:getInstance():show("UIClubMain")
end

function UILobby:_onBtnCreateRoomClick()
    UIManager:getInstance():show("UICreateRoom")
end

function UILobby:_onRightListItemClick(item,data)
    if data.id == ITEM_TYPE.GOLD_CAMPAIGN then
        UIManager:getInstance():show("views.UIGoldMain")
    elseif data.id == ITEM_TYPE.LEAGUE then
        
    elseif data.id == ITEM_TYPE.CAMPAIGN then
    
    end
    
end

function UILobby:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UILobby:isFullScreen()
    return true
end

function UILobby:onShow(...)
    self._scrollMainRight:updateDatas(game.UIConstant.LOBBY_RIGHT_LIST_CONFIG)
end

function UILobby:onHide()
 
end

return UILobby