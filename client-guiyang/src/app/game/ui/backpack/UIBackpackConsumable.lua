local csbPath = "ui/csb/Backpack/UIBagInfoGift.csb"
local super = require("app.game.ui.UIBase")

local UIBackpackConsumable = class("UIBackpackConsumable", super, function () return kod.LoadCSBNode(csbPath) end)

local FORBIDDEN_USE_PROP = {

}
function UIBackpackConsumable:ctor()
    self.propObj = nil
end

function UIBackpackConsumable:init()
    self._textDetail  = seekNodeByName(self, "Text_time_1",  "ccui.Text")
    self._textTime = seekNodeByName(self, "Text_time_0", "ccui.Text")
    self._icon = seekNodeByName(self, "Image_1", "ccui.ImageView")
    self._textName = seekNodeByName(self, "Text_time", "ccui.Text")
    self._textButton = seekNodeByName(self, "BitmapFontLabel_ts_0", "ccui.TextBMFont")

    self._btnClose = seekNodeByName(self, "Button_close","ccui.Button")
    self._btnUse = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnUse, handler(self, self._onUse), ccui.TouchEventType.ended)
end

function UIBackpackConsumable:onShow(...)
    local data = {...};
    self.propObj = data[1]
    self._external = data[2]
    local destroyTime = self.propObj:getExternal().destroyTime

    local existTime = destroyTime/1000 - game.service.TimeService:getInstance():getCurrentTime()
    if existTime < 0 then
        existTime = 0
    end
    
    if destroyTime == 0 or destroyTime == nil then
        self._textTime:setString("永久")
    elseif math.floor( existTime/86400 ) == 0 then
        self._textTime:setString("将于".. math.floor( existTime/3600 ) .. "小时后到期")
    else
        self._textTime:setString("将于".. math.floor( existTime/86400 ) .. "天后到期")
    end

    local hide = false
    table.foreach(FORBIDDEN_USE_PROP,function (k,v)
        if self.propObj:getId() == v then
            hide = true
        end
    end)
    self._btnUse:setVisible(not hide)
    self._status = self.propObj:getExternal().status or false 

    if self._status == true then
        self._textButton:setString("停用")
    else
        self._textButton:setString("使用")
    end

    self._icon:loadTexture("art/function/img_none.png")
    PropReader.setIconForNode(self._icon,self.propObj:getId())
    self._textName:setString(self.propObj:getName())
    self._textDetail:setString(self.propObj:getDesc())
end

function UIBackpackConsumable:_onUse()
    if self._status == true then
        game.service.BackpackService:getInstance():useSpecialEffect(self.propObj:getId(),2)
        game.service.DataEyeService.getInstance():onEvent("USING_PROP_" .. self.propObj:getId())
    else
        game.service.BackpackService:getInstance():useSpecialEffect(self.propObj:getId(),1)
        game.service.DataEyeService.getInstance():onEvent("STOP_USING_PROP_" .. self.propObj:getId())
    end
end

function UIBackpackConsumable:needBlackMask()
	return true;
end

function UIBackpackConsumable:closeWhenClickMask()
	return true
end

function UIBackpackConsumable:_onClose()
    UIManager:getInstance():destroy("UIBackpackConsumable")
end

return UIBackpackConsumable;
