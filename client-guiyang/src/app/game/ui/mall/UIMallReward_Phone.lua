local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Mall/UIMallReward_Phone.csb"
local UIMallReward_Phone = class("UIMallReward_Phone", super, function() return kod.LoadCSBNode(csbPath) end)

local PhoneNumberRecord = class("PhoneNumberRecord")
function PhoneNumberRecord:ctor()
    self._phoneNumber = "";
end

function UIMallReward_Phone:ctor()
    super.ctor(self)
end

function UIMallReward_Phone:init()
    self._mainPanel_1 = seekNodeByName(self, "Panel_1", "ccui.Layout")
    self._mainPanel_2 = seekNodeByName(self, "Panel_2", "ccui.Layout")

    self._btnClose = seekNodeByName(self, "Button_x_CouponZD", "ccui.Button")
    self._textExchageStatus = seekNodeByName(self, "Text_Exchange_Status", "ccui.Text")
    self._textDescription = seekNodeByName(self, "Text_Description", "ccui.Text")
    self._textAward = seekNodeByName(self, "Text_Award", "ccui.Text")
    self._btnEnsure = seekNodeByName(self, "Button_Ensure", "ccui.Button")
    self._icon = seekNodeByName(self, "Image_Good_Icon", "ccui.ImageView")
    self._textAlreadyExchanged = seekNodeByName(self, "Text_Already_Exchanged", "ccui.Text")
    self._inputPhoneNumber = seekNodeByName(self, "TextField_Phone_Number", "ccui.TextField")

    --这个是没有输入手机号码的界面样式
    self._icon2 = seekNodeByName(self, "Image_Good_Icon_2", "ccui.ImageView")
    self._textExchageStatus2 = seekNodeByName(self, "Text_Exchange_Status_2", "ccui.Text")

    self:_registerCallback()
end

function UIMallReward_Phone:_registerCallback()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnEnsure, handler(self, self._onBtnEnsureClick), ccui.TouchEventType.ended)
    self._inputPhoneNumber:addEventListener(handler(self, self._onTextFieldChanged))
    require("app.game.util.UIElementUtils"):createMaskLayer(self)
end

function UIMallReward_Phone:onShow(goodInfo)
    self._mainPanel_1:setVisible(false)
    self._mainPanel_2:setVisible(false)
    self._currentShowGoodInfo = goodInfo

    if goodInfo.isNeedPhoneNumber then
        self._mainPanel_1:setVisible(true)
        local name = PropReader.getNameById(goodInfo.payType)
        self._textDescription:setString(name .. "：" .. goodInfo.goodPrice)
        self._textAward:setString("奖品：" .. goodInfo.goodName)
        self._icon:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(goodInfo.goodId))
        local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
        local phoneNumRecord = manager.LocalStorage.getUserData(roleId, "PhoneNumberRecord", PhoneNumberRecord)
        --设置上次填写的手机号、没有为空 ""
        self._inputPhoneNumber:setString(phoneNumRecord._phoneNumber)
        if goodInfo.goodInventory == -1 then
            self._textExchageStatus:setString("不限")
        else
            self._textExchageStatus:setString(string.format("库存：(%d/%d)", goodInfo.currentInventory, goodInfo.goodInventory))
        end
    else
        self._mainPanel_2:setVisible(true)
        self._icon2:loadTexture(game.service.MallService.getInstance():getGoodIconResPath(goodInfo.goodId))
        self._textExchageStatus2:setString(string.format("确定使用%d礼券兑换%s吗?", goodInfo.goodPrice, goodInfo.goodName))
    end

    --每日购买数量限制
    if goodInfo.exchangeTimes == -1 then
        self._textAlreadyExchanged:setString("不限")
    else
        self._textAlreadyExchanged:setString(string.format("(%d/%d)", goodInfo.alreadyExchanged, goodInfo.exchangeTimes))
    end
end

function UIMallReward_Phone:_onTextFieldChanged(sender, eventType)
    -- 当是插入文字的时候
    if eventType == ccui.TextFiledEventType.attach_with_ime then
        if sender:getString() == "" then
            sender:setString(" ")
        end
    end
    if eventType == ccui.TextFiledEventType.detach_with_ime then
        if sender:getString() == " " then
            sender:setString("")
        end
    end
end

function UIMallReward_Phone:_onBtnCloseClick(sender)
    self:destroySelf()
end

function UIMallReward_Phone:_onBtnEnsureClick(sender)
    local goodId, phoneNumber, address = self._currentShowGoodInfo.goodId
    if self._currentShowGoodInfo.isNeedPhoneNumber then
        local str = string.trim(self._inputPhoneNumber:getString())
        local matchResult = string.match(str, "%d+") or ""
        if #matchResult ~= 11 then -- 验证11位纯数字，其他不校验
            game.ui.UIMessageTipsMgr.getInstance():showTips("请输入正确的号码")
            return
        end
        phoneNumber = tonumber(str)
        --记录本次填写的手机号
        local roleId = game.service.LocalPlayerService.getInstance():getRoleId();
        local phoneNumRecord = manager.LocalStorage.getUserData(roleId, "PhoneNumberRecord", PhoneNumberRecord)
        phoneNumRecord._phoneNumber = phoneNumber
        manager.LocalStorage.setUserData(roleId, "PhoneNumberRecord", phoneNumRecord)
        UIManager:getInstance():show("UIMallTips", phoneNumber, self._currentShowGoodInfo.goodName, function()
            game.service.MallService.getInstance():submitOrder(goodId, phoneNumber, address)
        end)
    else
        -- game.ui.UIMessageBoxMgr.getInstance():show("确定要兑换吗?", {"确认", "取消"}, function()
        game.service.MallService.getInstance():submitOrder(goodId, phoneNumber, address)
        -- end)
    end
    self:destroySelf()
end

function UIMallReward_Phone:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return UIMallReward_Phone