local csbPath = app.UIGoldMainCsb
local super = app.UIBase
local Util = app.Util
local UIManager = app.UIManager
local UIGoldMain = class("UIGoldMain", super, function() return app.Util:loadCSBNode(csbPath) end)

function UIGoldMain:ctor()
    
end

function UIGoldMain:init()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    self._btnShop = Util:seekNodeByName(self,"btnShop","ccui.Button")
    self._btnAddBean = Util:seekNodeByName(self,"btnAddBean","ccui.Button")
    self._btnAddGold = Util:seekNodeByName(self,"btnAddGold","ccui.Button")
    self._btnHelp = Util:seekNodeByName(self,"btnHelp","ccui.Button")
    self._btnQucikMatch = Util:seekNodeByName(self,"btnQucikMatch","ccui.Button")


    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))
    Util:bindTouchEvent(self._btnQucikMatch,handler(self,self._onQucikMatchClick),0.95)

    Util:bindTouchEvent(self._btnShop,handlerFix(self,self._onBtnShopClick,1))
    Util:bindTouchEvent(self._btnAddBean,handlerFix(self,self._onBtnShopClick,2))
    Util:bindTouchEvent(self._btnAddGold,handlerFix(self,self._onBtnShopClick,3))


    self._panelMatchGame1 = Util:seekNodeByName(self,"panelMatchGame1","ccui.Layout")
    self._panelMatchGame2 = Util:seekNodeByName(self,"panelMatchGame2","ccui.Layout")
    self._panelMatchGame3 = Util:seekNodeByName(self,"panelMatchGame3","ccui.Layout")
    self._panelMatchGame4 = Util:seekNodeByName(self,"panelMatchGame4","ccui.Layout")
    Util:bindTouchEvent(self._panelMatchGame1,handlerFix(self,self._onMachGameClick,1),0.95)
    Util:bindTouchEvent(self._panelMatchGame2,handlerFix(self,self._onMachGameClick,2),0.95)
    Util:bindTouchEvent(self._panelMatchGame3,handlerFix(self,self._onMachGameClick,3),0.95)
    Util:bindTouchEvent(self._panelMatchGame4,handlerFix(self,self._onMachGameClick,4),0.95)
    
end

function UIGoldMain:_onMachGameClick(tag)

end

function UIGoldMain:_onQucikMatchClick()
    
end

function UIGoldMain:_onBtnBackClick(tag)
    UIManager:getInstance():hide("UIGoldMain")
end

function UIGoldMain:_onBtnShopClick(tag)
    UIManager:getInstance():show("UIShop",tag)
end

function UIGoldMain:getGradeLayerId()
    return 2
end

function UIGoldMain:isFullScreen()
    return true
end

function UIGoldMain:onShow()

end

function UIGoldMain:onHide()
 
end

return UIGoldMain