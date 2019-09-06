local csbPath = "ui/csb/Backpack/UIBagInfoGift.csb"
local super = require("app.game.ui.UIBase")

local UIBackpackGiftDetail = class("UIBackpackGiftDetail", super, function () return kod.LoadCSBNode(csbPath) end)

function UIBackpackGiftDetail:ctor()
    self.propObj = nil
end

function UIBackpackGiftDetail:init()
    self._textDetail  = seekNodeByName(self, "Text_time_1",  "ccui.Text")
    self._textTime = seekNodeByName(self, "Text_time_0", "ccui.Text")
    self._icon = seekNodeByName(self, "Image_1", "ccui.ImageView")
    self._textName = seekNodeByName(self, "Text_time", "ccui.Text")

    self._btnClose = seekNodeByName(self, "Button_close","ccui.Button")
    self._btnUse = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")
    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnUse, handler(self, self._onReceive), ccui.TouchEventType.ended)
end

function UIBackpackGiftDetail:onShow(...)
    local data = {...};
    self.propObj = data[1]
    if self.propObj:getDestoryTime() == "" then
        self._textTime:setString("永久")
    else
        self._textTime:setString("使用期限:将于".. self.propObj:getDestoryTime().. "到期")
    end

    self._icon:loadTexture("art/function/img_none.png")
    PropReader.setIconForNode(self._icon,self.propObj:getId())
    self._textName:setString(self.propObj:getName())
    self._textDetail:setString(self.propObj:getDesc())
end

function UIBackpackGiftDetail:_onReceive()
    game.service.GiftService:getInstance():queryReceiveGift(self.propObj:getId())
end

function UIBackpackGiftDetail:needBlackMask()
	return true;
end

function UIBackpackGiftDetail:closeWhenClickMask()
	return true
end

function UIBackpackGiftDetail:_onClose()
    UIManager:getInstance():destroy("UIBackpackGiftDetail")
end

return UIBackpackGiftDetail;
