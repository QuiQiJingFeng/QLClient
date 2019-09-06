local csbPath = "ui/csb/HeadFrame/UIBuyHeadSelect.csb"
local super = require("app.game.ui.UIBase")
local UIBuyHeadSelect = class("UIBuyHeadSelect", super, function () return kod.LoadCSBNode(csbPath) end)

function UIBuyHeadSelect:ctor()
    self._currentSelect = 0
    self._priceDataList = {}
    self._checkboxGroup = {}
    self._data = {}
end

function UIBuyHeadSelect:init()
    self._headIcon         = seekNodeByName(self,"Image_1",      "ccui.ImageView");
    self._headName         = seekNodeByName(self,"Text_12",      "ccui.Text");
    self._headPrice        = seekNodeByName(self,"Text_12_0",      "ccui.Text");
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

    game.service.HeadFrameService:getInstance():addEventListener("EVENT_SELECT_PRICE", handler(self, self._onSelect), self)
end

function UIBuyHeadSelect:onShow(data)
    self._headName:setString(data.name)
    self._priceDataList = data.price

    -- 
    --game.util.PlayerHeadIconUtil.setIconFrame(self._headIcon,PropReader.getIconById(data.id),0.8)
    self:setIconFrame(self._headIcon,PropReader.getIconById(data.id),0.8)
    -- 价格排序
    table.sort(self._priceDataList, function (a,b)
        return a.time < b.time
    end)

    self._headPrice:setString("价格:" .. data.price[1].price .. PropReader.getNameById(game.service.HeadFrameService:getInstance():getCurrencyType()))
    
    self:_initPriceList()
    self._data = data

    self:playAnimation_Scale()
end

function UIBuyHeadSelect:setIconFrame(imgNode, url, scale)
	-- 清空子节点
    imgNode:getParent():removeChildByName("head_frame") 

	-- 添加头像框
	local csb = cc.CSLoader:createNode(url)
	if csb == nil then
		return
	end

	local csbAnim = kod.LoadCSBNode(url)
	local action = cc.CSLoader:createTimeline(url)
	csbAnim:runAction(action)
	action:gotoFrameAndPlay(0, true)
    csbAnim:setName("csbAnim")
	imgNode:getParent():addChild(csbAnim)

	csbAnim:setPosition(imgNode:getPosition())
    csbAnim:setScale(scale or 1)
    imgNode:setVisible(false)
	return csbAnim
end 

function UIBuyHeadSelect:_initPriceList()
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
                game.service.HeadFrameService:getInstance():dispatchEvent({ name = "EVENT_SELECT_PRICE", data = self:_getPrice(self._currentSelect)}); 
            end
        end)
        
        if self._checkboxGroup[1] ~= nil then
            self._checkboxGroup[1]:setSelected(true)
            self._currentSelect = self._checkboxGroup[1]:getName()
        end
    end)
end

function UIBuyHeadSelect:_disableAllSelect()
    table.foreach(self._checkboxGroup,function (k,v)
        v:setSelected(false)  
    end)
end

function UIBuyHeadSelect:_onSelect( event)
    self._headPrice:setString("价格:" .. event.data .. config.STRING.UIBUYHEADSELECT_STRING_100)
end

function UIBuyHeadSelect:_getPrice( t)
    local result = 0
    table.foreach(self._data.price,function (k,v)
        if tonumber(t) == v.time then
            result =v.price
        end        
    end)
    return result
end

function UIBuyHeadSelect:_onBtnClose()
    UIManager:getInstance():destroy("UIBuyHeadSelect")    
end

function UIBuyHeadSelect:_onBtnPay()
    -- UIManager:getInstance():show("UIHeadConfirm", self._currentSelect, self._data, self:_getPrice(self._currentSelect))
    game.service.HeadFrameService:getInstance():queryBuyHeadframe(self._data.id,self._currentSelect)
end

function UIBuyHeadSelect:onHide()
    game.service.HeadFrameService:getInstance():removeEventListenersByTag(self)
end

function UIBuyHeadSelect:dispose()
    if self._listItem ~= nil then
        self._listItem:release()
        self._listItem = nil
    end    
end

function UIBuyHeadSelect:needBlackMask()
	return true;
end

function UIBuyHeadSelect:closeWhenClickMask()
	return false
end

return UIBuyHeadSelect;
