local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Mall/UIMallReward_Address.csb"
local UIMallReward_Address = class("UIMallReward_Address", super, function() return kod.LoadCSBNode(csbPath) end)

function UIMallReward_Address:ctor()
    super.ctor(self)
end

function UIMallReward_Address:init()
    
    local layouts = seekNodeByName(self, "LayoutsNode", "ccui.Layout")
    self._layout_default = seekNodeByName(layouts, "LayoutDefault", "ccui.Layout")
    self._layout_address = seekNodeByName(layouts, "Layout_Address", "ccui.Layout")
    self._layout_phoneNumber = seekNodeByName(layouts, "Layout_Phone_Number", "ccui.Layout")
    
    self._btnClose = seekNodeByName(self, "Button_x_CouponZD", "ccui.Button")
    self._textExchageStatus = seekNodeByName(self._layout_default, "Text_Exchange_Status", "ccui.Text")
    self._textDescription = seekNodeByName(self._layout_default, "Text_Description", "ccui.Text")
    self._btnEnsure = seekNodeByName(self._layout_default, "Button_Ensure", "ccui.Button")
    self._icon = seekNodeByName(self._layout_default, "Image_Good_Icon", "ccui.ImageView")
    
    self._inputPhoneNumber = seekNodeByName(self._layout_phoneNumber, "TextField_Phone_Number", "ccui.TextField")
    self._inputAddress = seekNodeByName(self._layout_address, "TextField_Address", "ccui.TextField")
    self._inputName = seekNodeByName(self, "TextField_Phone_Number_0", "ccui.TextField")
    
    self._inputPhoneNumber:setTextColor(cc.c4b(151, 86, 31, 255))
    self._inputAddress:setTextColor(cc.c4b(151, 86, 31, 255))
    self._inputName:setTextColor(cc.c4b(151, 86, 31, 255))
    self:_registerCallback()
end

function UIMallReward_Address:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEnsure, handler(self, self._onBtnEnsureClick), ccui.TouchEventType.ended)
    require("app.game.util.UIElementUtils"):createMaskLayer(self)
end

function UIMallReward_Address:onShow(goodInfo)
    if goodInfo.exchangeTimes == -1 then
        self._textExchageStatus:setString("不限")
    else
        self._textExchageStatus:setString(string.format("已兑(%d/%d)", goodInfo.alreadyExchanged, goodInfo.exchangeTimes))
    end
    local name = PropReader.getNameById(goodInfo.payType)
    self._textDescription:setString(string.format("确定使用%d%s兑换%s吗?", goodInfo.goodPrice, name, goodInfo.goodName))
    self._icon:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(goodInfo.goodId))
    self._inputAddress:setString("")
    self._inputPhoneNumber:setString("")
    self._inputName:setString("")

    self._currentShowGoodInfo = goodInfo
end

function UIMallReward_Address:_onBtnCloseClick(sender)
    self:destroySelf()
end

function UIMallReward_Address:_onBtnEnsureClick(sender)
    local str = self._inputPhoneNumber:getString()
    local matchResult = string.match(str, "%d+") or ""
    if #matchResult ~= 11 then -- 验证11位纯数字，其他不校验
        game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的号码")
        return 
    end
    local phoneNumber = tonumber(str)

    local address = self._inputAddress:getString()
    local name = self._inputName:getString()
    local goodId = self._currentShowGoodInfo.goodId

    game.ui.UIMessageBoxMgr.getInstance():show("您确定要兑换吗?", {"确认", "取消"}, function()
        game.service.MallService.getInstance():submitOrder(goodId, phoneNumber, address, name) 
        self:destroySelf()
    end)
end

function UIMallReward_Address:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end


return UIMallReward_Address