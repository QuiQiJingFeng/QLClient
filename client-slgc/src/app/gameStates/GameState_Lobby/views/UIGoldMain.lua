local csbPath = "ui/csb/mengya/gold/UIGoldMain.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UIGoldMain = class("UIGoldMain", super, function() return Util:loadCSBNode(csbPath) end)
local UIFreeList = game.UIFreeList
local UIGoldMainItem = import("items.UIGoldMainItem")
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

    local list = {}
    for i = 1, 4 do
        local name = "panelMatchGame" .. i
        local node = Util:seekNodeByName(self,name,"ccui.Layout")
        table.insert(list,node)
    end
    self._freeList = UIFreeList.extend(list,UIGoldMainItem,handler(self,self._onMachGameClick))
    self._freeList:updateDatas(game.UIConstant.GOLD_COMPAIGN_CONFIG)
end

function UIGoldMain:_onMachGameClick(item,data)
    game.UITipManager:getInstance():show(data.name)
end

function UIGoldMain:_onQucikMatchClick()
    
end

function UIGoldMain:_onBtnBackClick()
    UIManager:getInstance():hide("views.UIGoldMain")
end

function UIGoldMain:_onBtnShopClick(tag)
    UIManager:getInstance():show("UIShop",tag)
end

function UIGoldMain:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIGoldMain:isFullScreen()
    return true
end

function UIGoldMain:onShow()

end

function UIGoldMain:onHide()
 
end

return UIGoldMain