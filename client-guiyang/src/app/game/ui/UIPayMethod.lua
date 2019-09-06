local csbPath = "ui/csb/UIPayMethod.csb" --ui文件
local super = require("app.game.ui.UIBase")
local UIPayMethod = class("UIPayMethod", super, function () return kod.LoadCSBNode(csbPath) end)
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
-- 单条支付显示item
-------------------------------------------------------------------------------------
local PayTypeStatus = {
    HidenClose = 1,
    HidenOpen = 2,
    DisplayClose = 3,
    DisplayOpen = 4
}

local PayTypeConst = {
    AliPay = 1,
    WePay = 2
}

local PayTypeStringImg = {
    [PayTypeConst.AliPay] = "ui/art/img/button_aliPay.png",
    [PayTypeConst.WePay] = "ui/art/img/button_wechatPay.png"
}

local IconMap = {
    [PayTypeConst.AliPay] = {
            IconGreen = "ui/art/img/button_z.png",
            IconDark = "ui/art/img/button_z.png",
            TextGreen = "ui/art/img/icon_zfbzf.png",
            TextDark = "ui/art/img/icon_zfbzf.png",
        },
    [PayTypeConst.WePay] = {
        IconGreen = "ui/art/img/button_w.png",
        IconDark = "ui/art/img/icon_wxwh.png",
        TextGreen = "ui/art/img/icon_wxzf.png",
        TextDark = "ui/art/img/icon_wxzfwhz.png",
    }
}

local UIPayMethodCell = class("UIPayMethodItem")

function UIPayMethodCell:ctor( uiroot, data , parent)
    self:_initialize(uiroot)
    self._uiroot = uiroot
    self._data = data
    self._parent = parent
    self:setData(data)
end

function UIPayMethodCell:_initialize(uiroot)
    self._payIconGreen = seekNodeByName(uiroot, "IconGreen", "ccui.ImageView")
    self._payIconDark = seekNodeByName(uiroot, "IconDark", "ccui.ImageView")
    self._payTextGreen = seekNodeByName(uiroot, "textGreen", "ccui.ImageView")
    self._payTextDark = seekNodeByName(uiroot, "textDark", "ccui.ImageView")
    self._isSelect = seekNodeByName(uiroot, "Image_dh", "ccui.ImageView")
    self._darkCircle = seekNodeByName(uiroot, "Image_xz_1", "ccui.ImageView")
    
    self._panelGreen = seekNodeByName(uiroot, "Panel_Green", "ccui.Layout")
    self._panelDark = seekNodeByName(uiroot, "Panel_Dark", "ccui.Layout")

    bindEventCallBack(self._panelGreen, handler(self, self._onSelect), ccui.TouchEventType.ended)
end

function UIPayMethodCell:setData( info)
    if info.payType == PayTypeConst.AliPay then
        self:_loadTexture(PayTypeConst.AliPay)
    elseif info.payType == PayTypeConst.WePay then
        self:_loadTexture(PayTypeConst.WePay)
    end
    self._panelDark:setVisible(info.status ~= PayTypeStatus.DisplayOpen)
    self._panelGreen:setVisible(info.status == PayTypeStatus.DisplayOpen)
end

function UIPayMethodCell:getData()
    return self._data
end

function UIPayMethodCell:_onSelect()
    game.service.PaymentService:getInstance():dispatchEvent({name = "ON_PAY_SELECT",payType = self._data.payType})
    
    self._parent._currentMethod = self._data.payType
    self._isSelect:setVisible(true)
    self._darkCircle:setVisible(false)
end

function UIPayMethodCell:turnOffSelect()
    self._isSelect:setVisible(false)
    self._darkCircle:setVisible(true)
end

function UIPayMethodCell:turnOnSelect()
    self._isSelect:setVisible(true)
    self._darkCircle:setVisible(false)
end

function UIPayMethodCell:_loadTexture(payType)
    if IconMap[payType] == nil then 
        return 
    end
    self._payIconGreen:loadTexture(IconMap[payType].IconGreen)
    self._payIconDark:loadTexture(IconMap[payType].IconDark)
    self._payTextGreen:loadTexture(IconMap[payType].TextGreen)
    self._payTextDark:loadTexture(IconMap[payType].TextDark)
end

-------------------------------------------------------------------------------------
function UIPayMethod:ctor()
    self._textPrice = nil
    self._payMethodList = nil
    self._btnPay = nil
    self._currentMethod = 0

    self._payList = {}
end

function UIPayMethod:init()
    self._textPrice = seekNodeByName(self, "BitmapFontLabel_Price",  "ccui.TextBMFont")
    self._payMethodList = seekNodeByName(self, "ListView_payMethod",  "ccui.ListView")
    self._btnPay = seekNodeByName(self, "Button_pay",  "ccui.Button")
    self._payModel = seekNodeByName(self, "Panel_payItem", "ccui.Layout")
    self._btnClose = seekNodeByName(self, "ButtonClose", "ccui.Button")

    self._payModel:retain()

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnPay, handler(self, self._onPay), ccui.TouchEventType.ended)
    
    self._payMethodList:setScrollBarEnabled(false)    
end

function UIPayMethod:onShow( ... )
    local args = { ... }
    local payTypes = args[1]
    local order = args[2]

    game.service.PaymentService:getInstance():addEventListener("ON_PAY_SELECT", handler(self, self._onPaySelect), self)
    game.service.PaymentService:getInstance():addEventListener("CHANGE_PAY_TYPE", handler(self, self._changePayType), self)

    local orderinfo = order:getProtocol():getProtocolBuf()
    local price = orderinfo.rmb
    if price ~= nil then
        self._textPrice:setString(string.format("%0.2f",price))
    end

    if payTypes == nil or #payTypes <= 0 then return end
    self._payMethodList:removeAllItems()

    for idx,member in ipairs(payTypes) do
        local item = self._payModel:clone()
        local cell = UIPayMethodCell.new(item, member,self)
        table.insert(self._payList,cell)
        self._payMethodList:addChild(item)
    end

    if #payTypes < 1 then 
        self._btnPay:setVisible(false)
    end

    local select = self._payList[1]:getData().payType
    local combo = self._payList[1]
    local defPayType = game.service.PaymentService:getInstance():getDefaultPayType():getPayType()
    
    table.foreach(self._payList,function (k,v)        
        if v:getData().status == PayTypeStatus.DisplayOpen then
            select = v:getData().payType
            combo = v
            return
        end
    end)

    for i,v in pairs(self._payList) do
        if v:getData().status == PayTypeStatus.DisplayOpen then
            select = v:getData().payType
            combo = v
            break
        end
    end

    for i,v in pairs(self._payList) do
        if defPayType == v:getData().payType and v:getData().status == PayTypeStatus.DisplayOpen then
            select = v:getData().payType
            combo = v
            break
        end
    end

    self:_onPaySelect({payType = select})
    combo:turnOnSelect()
end

function UIPayMethod:_onPaySelect(data)
    table.foreach(self._payList,function (k,v)
        v:turnOffSelect()
    end)

    local payType = data.payType
    self._currentMethod = payType

    -- 设置按钮图片
    self._btnPay:loadTextureNormal(PayTypeStringImg[payType])
    self._btnPay:loadTexturePressed(PayTypeStringImg[payType])
end

function UIPayMethod:_onPay()
    game.service.PaymentService:getInstance():sendCachedPayOrder(self._currentMethod)
    game.service.PaymentService:getInstance():saveLocalStorage(self._currentMethod)
end

function UIPayMethod:_onClose()
    UIManager:getInstance():destroy("UIPayMethod")
end

function UIPayMethod:onHide()
    self._payList = {}
    game.service.PaymentService:getInstance():removeEventListenersByTag(self)
end

function UIPayMethod:needBlackMask()
	return true;
end

function UIPayMethod:closeWhenClickMask()
	return true
end

function UIPayMethod:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return UIPayMethod