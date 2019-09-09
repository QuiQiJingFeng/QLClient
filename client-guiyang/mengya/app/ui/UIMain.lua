local csbPath = app.UIMainCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UITableViewEx = app.UITableViewEx
local UIMainRightListItem = app.UIMainRightListItem
local ITEM_TYPE = {
    LIANMENG = 1,
    GOLD_CAMPAIGN = 2,
    CAMPAIGN = 3,
}

local UIMain = class("UIMain", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIMain:init()
    
    local node = Util:seekNodeByName(self,"scrollMainRight","ccui.ScrollView")
    self._scrollMainRight = UITableViewEx.extend(node,UIMainRightListItem,handler(self,self._onRightListItemClick))
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

function UIMain:_onBtnSettingClick()
    UIManager:getInstance():show("UISetting")
end

function UIMain:_onBtnGamePlayHelpClick()
    UIManager:getInstance():show("UIHelp")
end

function UIMain:_onPanelPlayerInfoClick()
    UIManager:getInstance():show("UIPersonalCenter")
end

function UIMain:_onBtnMoreClick()
    local visible = not self._panelMore:isVisible()
    self._panelMore:setVisible(visible)
    self._panelMask:setVisible(visible)
	if visible then
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1), cc.ScaleTo:create(0.05, 1)))
	else
		self._panelMore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1.1), cc.ScaleTo:create(0.15, 0)))
	end
end

function UIMain:_onBtnShopClick(tag)
    UIManager:getInstance():show("UIShop",tag)
end

function UIMain:_onBtnJoinRoomClick()
 
end

function UIMain:_onBtnClubClick()
    UIManager:getInstance():show("UIClubMain")
end

function UIMain:_onBtnCreateRoomClick()
    UIManager:getInstance():show("UICreateRoom")
end

function UIMain:_onRightListItemClick(item,data,eventType)
    --克隆出来的按钮没有原来的点击放大的效果
    if eventType == ccui.TouchEventType.began then
        item:setScale(0.95)
    elseif eventType == ccui.TouchEventType.moved then
    else    -- 其他情况，恢复按钮原始状态
        item:setScale(1)
    end
    if eventType ~= ccui.TouchEventType.ended then
        return
    end

    if data.id == ITEM_TYPE.GOLD_CAMPAIGN then
        UIManager:getInstance():show("UIGoldMain")
    end
    
end

function UIMain:getGradeLayerId()
    return 2
end

function UIMain:isFullScreen()
    return true
end

function UIMain:onShow(...)
    local datas = {
        {id = ITEM_TYPE.LIANMENG, name = "大联盟",src = "art/main/Btn_lm_main.png"},
        {id = ITEM_TYPE.GOLD_CAMPAIGN,name = "金币场",src = "art/main/Btn_jbc_main.png"},
        {id = ITEM_TYPE.CAMPAIGN,name = "比赛场",src = "art/main/Btn_bsc_main.png"},
    }

    self._scrollMainRight:updateDatas(datas)
end

function UIMain:onHide()
 
end

return UIMain