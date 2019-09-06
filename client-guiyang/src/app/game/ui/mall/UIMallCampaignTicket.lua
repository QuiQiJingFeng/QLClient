local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Mall/UIMallCampaignTicket.csb"

local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local CurrencyHelper = require("app.game.util.CurrencyHelper")

local UIMallCampaignTicket = class("UIMallCampaignTicket", super, function() return kod.LoadCSBNode(csbPath) end)
-- 单条奖励显示item
-------------------------------------------------------------------------------------
local UIMallCampaignTicketItem = class("UIMallCampaignTicketItem")

function UIMallCampaignTicketItem:ctor( uiroot , data)
    self._uiroot = uiroot

    self:_initialize()
    self:setData(data)
end

function UIMallCampaignTicketItem:_initialize()
    self._goodIcon = nil
    self._textNum = nil
    self._btnPanel = nil
    self._textDesc = nil

    self._goodIcon = seekNodeByName(self._uiroot, "Image_img1_1_shop", "ccui.ImageView")
    self._textNum = seekNodeByName(self._uiroot, "BitmapFontLabel_1_0", "ccui.TextBMFont")
    self._btnPanel = seekNodeByName(self._uiroot, "Panel_2", "ccui.Layout")
    self._textDesc = seekNodeByName(self._uiroot, "BitmapFontLabel_2", "ccui.TextBMFont")
    self._transportBg = seekNodeByName(self._uiroot, "transportBg", "ccui.TextBMFont")
    self._btnBuy = seekNodeByName(self._uiroot, "Button_btn1_1_shop","ccui.Button")
    self._content = seekNodeByName(self._uiroot, "context", "ccui.Layout")

    self._btnBuy:setSwallowTouches(true)
    self._btnPanel:setSwallowTouches(true)
end

function UIMallCampaignTicketItem:getData()
    return self._data
end

function UIMallCampaignTicketItem:setData( applicationInfo )
    self._data = applicationInfo
    self._transportBg:setVisible(false)
    self._content:setVisible(true)
    if applicationInfo.id == "unknow" then
        self._transportBg:setVisible(true)
        self._content:setVisible(false)
        return
    end
    local iconPath = PropReader.getIconById(applicationInfo.id) or ""
    local name = PropReader.getNameById(applicationInfo.id) or ""
    self._goodIcon:loadTexture(iconPath)
    self._textNum:setString(applicationInfo.count .. "张")
    self._textDesc:setString(name)

    bindEventCallBack(self._btnPanel, handler(self, self._onClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnBuy, handler(self, self._onClicnBtnBuy), ccui.TouchEventType.ended)
end

function UIMallCampaignTicketItem:_onClick()
    game.service.DataEyeService.getInstance():onEvent("EVENT_CAMPAIGN_TICKET_BUY_" .. PropReader.getNameById(self._data.id) or "")
    if self._data.count > 0 then 
        UIManager.getInstance():show("UIBackpackDetail", PropFactory:createProp(self._data.id))
        return 
    end
    game.ui.UIMessageBoxMgr.getInstance():show("你的门票用完啦！赶快去商城购买吧！", {"立即购买", "我再想想"},
        function ()
            CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET)
        end,
        function()
            return
        end,
    true)
end

function UIMallCampaignTicketItem:_onClicnBtnBuy()
    CurrencyHelper.getInstance():queryCurrency(CurrencyHelper.CURRENCY_TYPE.MATCH_TICKET)
end

----------------------------------------------------------------------------------------
function UIMallCampaignTicket:ctor()
    super.ctor(self)
    self._btnBack = nil
    self._beanLayout = nil
    self._shopList = nil

    self._reusedShopList = seekNodeByName(self, "ListView_goods", "ccui.ListView")
end

function UIMallCampaignTicket:init()
    self._btnBack = seekNodeByName(self, "Button_back", "ccui.Button")
    self._beanLayout = seekNodeByName(self, "Panel_Bean", "ccui.Layout")
    self._shopList = seekNodeByName(self, "ListView_goods", "ccui.ListView")
    self._panelModel = seekNodeByName(self, "item", "ccui.Layout")

    self._panelModel:retain()
    self._panelModel:setVisible(false)
    self._shopList:removeAllItems()

    self:_registerCallback()
end

function UIMallCampaignTicket:_registerCallback()    
    bindEventCallBack(self._btnBack, handler(self, self._onClose), ccui.TouchEventType.ended)
end

function UIMallCampaignTicket:onShow()
    game.service.MallService:getInstance():addEventListener("EVENT_MALLPAY_SUCCESS", handler(self, self._reFreshTickets), self)
    game.service.MallService:getInstance():addEventListener("EVENT_TICKET_MALLLIST_RECEIVE", handler(self, self._onReceiveList), self)    

    self._bindKey = CurrencyHelper.getInstance():getBinder():bind(CurrencyHelper.CURRENCY_TYPE.BEAN, self._beanLayout)
end

function UIMallCampaignTicket:_onReceiveList( data )
    local consumes = data.protocol.item
    self._shopList:removeAllItems()

    if #consumes < 3 then
        local num = 3 - #consumes
        for i = 1,num do
            table.insert(consumes,{id = "unknow"})
        end
    end

    for idx,member in ipairs(consumes) do
        local item = self._panelModel:clone()
        item:setVisible(true)
        local cell = UIMallCampaignTicketItem.new(item,member)
        self._shopList:addChild(item)
    end
end

function UIMallCampaignTicket:onHide()
    CurrencyHelper.getInstance():getBinder():unbind(self._bindKey)
    game.service.MallService:getInstance():removeEventListenersByTag(self)
end

function UIMallCampaignTicket:_reFreshTickets()
    game.service.MallService:getInstance():queryRoleTicket()
end

function UIMallCampaignTicket:needBlackMask()
	return true;
end

function UIMallCampaignTicket:closeWhenClickMask()
	return false
end

function UIMallCampaignTicket:_onClose()
    UIManager:getInstance():destroy("UIMallCampaignTicket")
end

function UIMallCampaignTicket:dispose()
    self._panelModel:release()
    self._panelModel = nil
end

return UIMallCampaignTicket