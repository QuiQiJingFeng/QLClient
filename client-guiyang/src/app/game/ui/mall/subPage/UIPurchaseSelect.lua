local csbPath = "ui/csb/Prop/UIPurchaseSelect.csb"
local super = require("app.game.ui.UIBase")
local UIPurchaseSelect = class("UIPurchaseSelect", super, function () return kod.LoadCSBNode(csbPath) end)

function UIPurchaseSelect:ctor()
    self._currentSelect = 0
    self._priceDataList = {}
    self._checkboxGroup = {}
    self._data = {}
end

function UIPurchaseSelect:init()
    self._propIcon         = seekNodeByName(self,"Image_1",      "ccui.ImageView");
    self._propName         = seekNodeByName(self,"Text_12",      "ccui.Text");
    self._propPrice        = seekNodeByName(self,"Text_12_0",      "ccui.Text");
    self._priceList        = seekNodeByName(self,"ListView_8",      "ccui.ListView");
    self._listItem         = seekNodeByName(self,"CheckBox_2",      "ccui.CheckBox")

    self._btnPay           = seekNodeByName(self,"Button_17_0",      "ccui.Button");
    self._btnClose         = seekNodeByName(self,"Button_17",        "ccui.Button");

    self._listItem:setVisible(false)
    self._listItem:removeFromParent(false)
    self._listItem:retain()
    self._priceList:setScrollBarEnabled(false)
    bindEventCallBack(self._btnClose,        handler(self, self._onBtnClose),    ccui.TouchEventType.ended);
    bindEventCallBack(self._btnPay,        handler(self, self._onBtnPay),    ccui.TouchEventType.ended);

    game.service.MallService:getInstance():addEventListener("EVENT_SELECT_PURCHASE_PRICE", handler(self, self._onSelect), self)
end

function UIPurchaseSelect:onShow(data)
    self._data = data
 
    self._propName:setString(data.goodName)
    self._priceDataList = data.timePrice

    PropReader.setIconForNode(self._propIcon,game.service.MallService:getInstance():getIconRes(data.goodId))
    
    -- 价格排序
    table.sort(self._priceDataList, function (a,b)
        return a.time < b.time
    end)

    self._propPrice:setString("价格:" .. data.timePrice[1].price .. PropReader.getNameById(data.payType))
    
    self:_initPriceList()

    self:playAnimation_Scale()
end

function UIPurchaseSelect:_initPriceList()
    self._priceList:removeAllChildren()
    
    table.foreach(self._priceDataList,function (k,v)
        local item = self._listItem:clone()
        item:setName(v.time)
        item:setVisible(true)
        item:setSelected(false)
        local txt = item:getChildByName("BitmapFontLabel_1")        
        if v.time > 0 then
            txt:setString(v.time.."天")
        else
            txt:setString("永久")
        end
        self._priceList:addChild(item)
        table.insert(self._checkboxGroup, item)
        
        item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.ended then
                self:_disableAllSelect()
                item:setSelected(true)
                self._currentSelect = item:getName()
                game.service.MallService:getInstance():dispatchEvent({ name = "EVENT_SELECT_PURCHASE_PRICE", data = self:_getPrice(self._currentSelect)}); 
            end
        end)
        
        if self._checkboxGroup[1] ~= nil then
            self._checkboxGroup[1]:setSelected(true)
            self._currentSelect = self._checkboxGroup[1]:getName()
        end
    end)
end

function UIPurchaseSelect:_disableAllSelect()
    table.foreach(self._checkboxGroup,function (k,v)
        v:setSelected(false)  
    end)
end

function UIPurchaseSelect:_onSelect( event)
    self._propPrice:setString("价格:" .. event.data .. "金豆")
end

function UIPurchaseSelect:_getPrice( t)
    local result = 0
    table.foreach(self._data.timePrice,function (k,v)
        if tonumber(t) == v.time then
            result =v.price
        end        
    end)
    return result
end

function UIPurchaseSelect:_onBtnClose()
    UIManager:getInstance():destroy("UIPurchaseSelect")    
end

function UIPurchaseSelect:_onBtnPay()
    local message = string.format("消耗%s兑换%s",
    self._propPrice:getString(),
    self._data.goodName)

    game.ui.UIMessageBoxMgr.getInstance():reverseBtnShow(message, { "确定", "取消" }, function(value)
        if self._currentSelect ~= 0 then
            game.service.MallService:submitOrder(self._data.goodId, nil, nil, nil, tonumber(self._currentSelect))
        end
        UIManager:getInstance():destroy("UIPurchaseSelect")  
    end)
end

function UIPurchaseSelect:onHide()
    game.service.MallService:getInstance():removeEventListenersByTag(self)
end

function UIPurchaseSelect:dispose()
    if self._listItem ~= nil then
        self._listItem:release()
        self._listItem = nil
    end    
end

function UIPurchaseSelect:needBlackMask()
	return true;
end

function UIPurchaseSelect:closeWhenClickMask()
	return false
end

function UIPurchaseSelect:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return UIPurchaseSelect;
