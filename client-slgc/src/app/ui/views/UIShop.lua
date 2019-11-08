local csbPath = "ui/csb/mengya/UIShop.csb"
local super = game.UIBase
local Util = game.Util
local UITableViewEx = game.UITableViewEx
local UITableView = game.UITableView
local UIManager = game.UIManager
local UIShopItem = require("app.ui.items.UIShopItem")
local UIShopLeftItem = require("app.ui.items.UIShopLeftItem")

local UIShop = class("UIShop", super, function () return Util:loadCSBNode(csbPath) end)

function UIShop:init()
    local node = Util:seekNodeByName(self,"scrollShopList","ccui.ScrollView")
    self._scrollShopList = UITableViewEx.extend(node,UIShopItem,handler(self,self._onShopItemClick))
    self._scrollShopList:perUnitNums(4)
    self._scrollShopList:setDeltUnit(11)
    self._scrollShopList:setDeltUnitFlix(11)

    self._btnBack = Util:seekNodeByName(self,"btnBack","ccui.Button")
    Util:bindTouchEvent(self._btnBack,handler(self,self._onBtnBackClick))

    local node = Util:seekNodeByName(self,"scrollLeft","ccui.ScrollView")
    self._scrollLeft = UITableView.extend(node,UIShopLeftItem,handler(self,self._onShopLeftItemClick))
    
    self._btnAddCard = Util:seekNodeByName(self,"btnAddCard","ccui.Button")
    self._btnAddBean = Util:seekNodeByName(self,"btnAddBean","ccui.Button")
    self._btnAddGold = Util:seekNodeByName(self,"btnAddGold","ccui.Button")

    Util:bindTouchEvent(self._btnAddCard,handlerFix(self,self.setSelectTabIdx,1))
    Util:bindTouchEvent(self._btnAddBean,handlerFix(self,self.setSelectTabIdx,2))
    Util:bindTouchEvent(self._btnAddGold,handlerFix(self,self.setSelectTabIdx,3))
end

function UIShop:_onBtnBackClick()
	UIManager:getInstance():hide("UIShop")
end

function UIShop:_onShopItemClick()
	
end

function UIShop:_onShopLeftItemClick(item,data,eventType)
    self._scrollShopList:updateDatas(data.goodInfos)
end

function UIShop:needBlackMask()
	return false
end

function UIShop:isFullScreen()
    return true
end

function UIShop:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIShop:setSelectTabIdx(selectIdx)
    local datas = self._scrollLeft:getDatas()
    local item = self._scrollLeft:getCellByIndex(selectIdx)
    self._scrollLeft:setCurrentSelectIndex(selectIdx)
    self:_onShopLeftItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UIShop:onShow(selectIdx)
    self._scrollLeft:updateDatas(game.UIConstant.SHOP_ITEM_CONFIG)
    self:setSelectTabIdx(selectIdx)
end


return UIShop