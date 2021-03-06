local csbPath = "ui/csb/mengya/headFrameShop/UIHeadFrameShop.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager
local UITableViewEx = game.UITableViewEx
local UICheckBoxGroup = game.UICheckBoxGroup
local UIHeadFrameShopItem = import("items.UIHeadFrameShopItem")
local ConfigManager = game.ConfigManager

local UIHeadFrameShop = class("UIHeadFrameShop", super, function() return game.Util:loadCSBNode(csbPath) end)

function UIHeadFrameShop:ctor()
    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    self._btnAddCard = Util:seekNodeByName(self,"btnAddCard","ccui.Button")
    Util:bindTouchEvent(self._btnAddCard,handler(self,self._onBtnAddCardClick))

    local cbxMyframe = Util:seekNodeByName(self,"cbxMyframe","ccui.CheckBox")
    local cbxBoutique = Util:seekNodeByName(self,"cbxBoutique","ccui.CheckBox")
    local cbxLimited = Util:seekNodeByName(self,"cbxLimited","ccui.CheckBox")
    local cbxAchieve = Util:seekNodeByName(self,"cbxAchieve","ccui.CheckBox")

    self._cbxGroup = UICheckBoxGroup.new({cbxMyframe,cbxBoutique,cbxLimited,cbxAchieve},handler(self,self._onCheckBoxSelected))


    local node = Util:seekNodeByName(self,"scrollListFrame","ccui.ScrollView")
    self._scrollListFrame = UITableViewEx.extend(node,UIHeadFrameShopItem,handler(self,self._onItemClick))
    self._scrollListFrame:perUnitNums(5)
    self._scrollListFrame:setDeltUnitFlix(20)
    self._scrollListFrame:setDeltUnit(20)
end

function UIHeadFrameShop:_onItemClick(item,data,eventType)
    
end

function UIHeadFrameShop:_onCheckBoxSelected(cbx,idx)
    local datas = ConfigManager:getInstance():getHeadFrameShopData()
    self._scrollListFrame:updateDatas(datas)
end

function UIHeadFrameShop:_onBtnAddCardClick()
    UIManager:getInstance():show("UIShop",1)
end

function UIHeadFrameShop:_onBtnBackClick()
    UIManager:getInstance():hide("views.UIHeadFrameShop")
end

function UIHeadFrameShop:getGradeLayerId()
    return 2
end

function UIHeadFrameShop:isFullScreen()
    return true
end

function UIHeadFrameShop:onShow()
    self._cbxGroup:setSelectIdx(1)
end

return UIHeadFrameShop