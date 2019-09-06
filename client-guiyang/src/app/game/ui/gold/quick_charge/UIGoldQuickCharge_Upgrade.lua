local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Gold/QuickCharge/UIGoldQuickCharge_Upgrade.csb'
local M = class("UIGoldQuickCharge_Upgrade", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor(...)
    super.ctor(self, ...)
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnCharge = seekNodeByName(self, "Button_Charge", "ccui.Button")

    self._txtCharge = seekNodeByName(self._btnCharge, "BMFont", "ccui.TextBMFont")
    self._txtChargeCost = seekNodeByName(self._btnCharge, "BMFont_Cost", "ccui.TextBMFont")
    self._txtChargeCount = seekNodeByName(self, "BMFont_Charge_Count", "ccui.TextBMFont")
end

function M:init()
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCharge, handler(self, self._onBtnChargeClick), ccui.TouchEventType.ended)
end

function M:destroy()
end

function M:onShow(argv)
    self._txtCharge:setString(argv.isCharge == false and "领取礼包" or "充值")
    self._txtChargeCost:setString(tostring(argv.cost))
    self._txtChargeCount:setString(tostring(argv.chargeCount))
    self._clickHandler = argv.clickHandler
end

function M:onHide()
end

function M:_onBtnCloseClick(sender)
    self:hideSelf()
    if game.service.GoldService.getInstance():checkIsNeedBrokeHelp() then
        UIManager:getInstance():show("UIGoldBrokeHelp")
    end
end

function M:_onBtnChargeClick(sender)
    if self._clickHandler then
        self._clickHandler()
    end
end

function M:needBlackMask() return true end

function M:getGradeLayerId() return config.UIConstants.UI_LAYER_ID.Top end

return M