local csbPath = app.UIShopCsb
local super = app.UIBase
local Util = app.Util
local UITableViewEx = app.UITableViewEx
local UITableView = app.UITableView
local UIManager = app.UIManager
local UIShopItem = app.UIShopItem
local UIShopLeftItem = app.UIShopLeftItem

local UIShop = class("UIShop", super, function () return app.Util:loadCSBNode(csbPath) end)

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

function UIShop:getGradeLayerLevel()
	return 2
end

function UIShop:setSelectTabIdx(selectIdx)
    local datas = self._scrollLeft:getDatas()
    local item = self._scrollLeft:getCellByIndex(selectIdx)
    self:_onShopLeftItemClick(item,datas[selectIdx],ccui.TouchEventType.ended)
end

function UIShop:onShow(selectIdx)
    local datas = { 
    [2] = {
            name = "金豆商城",
            goodInfos = {
                {title = "10金豆", icon = "art/mall/goodIcon/icon_bean1_mall.png",cost = "1元"},
                {title = "60金豆", icon = "art/mall/goodIcon/icon_bean2_mall.png",cost = "6元"},
                {title = "120金豆", icon = "art/mall/goodIcon/icon_bean3_mall.png",cost = "12元"},
                {title = "300金豆", icon = "art/mall/goodIcon/icon_bean4_mall.png",cost = "30元"},
                {title = "600金豆", icon = "art/mall/goodIcon/icon_bean5_mall.png",cost = "60元"},
                {title = "1280金豆", icon = "art/mall/goodIcon/icon_bean6_mall.png",cost = "128元"},
                {title = "3280金豆", icon = "art/mall/goodIcon/icon_bean7_mall.png",cost = "328元"},
                {title = "6480金豆", icon = "art/mall/goodIcon/icon_bean8_mall.png",cost = "648元"},
            }
        },
    [3] = {
            name = "金币商城",
            goodInfos = {
                {title = "10000金币", icon = "art/mall/goodIcon/icon_gold1_mall.png",cost = "10金豆"},
                {title = "20000金币", icon = "art/mall/goodIcon/icon_gold2_mall.png",cost = "20金豆"},
                {title = "50000金币", icon = "art/mall/goodIcon/icon_gold3_mall.png",cost = "50金豆"},
                {title = "110000金币", icon = "art/mall/goodIcon/icon_gold4_mall.png",cost = "100金豆"},
                {title = "220000金币", icon = "art/mall/goodIcon/icon_gold5_mall.png",cost = "200金豆"},
                {title = "50000金币", icon = "art/mall/goodIcon/icon_gold6_mall.png",cost = "400金豆"},
                {title = "100000金币", icon = "art/mall/goodIcon/icon_gold7_mall.png",cost = "800金豆"},
                {title = "300000金币", icon = "art/mall/goodIcon/icon_gold8_mall.png",cost = "2000金豆"},
            }
        },
    [1] = {
            name = "房卡商城",
            goodInfos = {
                {title = "1房卡", icon = "art/mall/goodIcon/icon_fk1_mall.png",cost = "3元"},
                {title = "3房卡", icon = "art/mall/goodIcon/icon_fk2_mall.png",cost = "8元"},
                {title = "36房卡", icon = "art/mall/goodIcon/icon_fk3_mall.png",cost = "88元"},
                {title = "88房卡", icon = "art/mall/goodIcon/icon_fk4_mall.png",cost = "188元"},
            }
        }
    }
    self._scrollLeft:updateDatas(datas)

    self:setSelectTabIdx(selectIdx)
end


return UIShop