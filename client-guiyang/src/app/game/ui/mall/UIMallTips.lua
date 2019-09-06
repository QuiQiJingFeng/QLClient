local csbPath = "ui/csb/Mall/UIMalltips.csb"
local super = require("app.game.ui.UIBase")

local UIMallTips = class("UIMallTips", super, function () return kod.LoadCSBNode(csbPath) end)

function UIMallTips:ctor()
    self._btnCancle = nil
    self._btnConfirm = nil
end

function UIMallTips:init()
    self._btnCancle  = seekNodeByName(self, "Button_qx_Malltips",  "ccui.Button");
    self._btnConfirm  = seekNodeByName(self, "Button_qd_Malltips",  "ccui.Button");
    self._phoneNumber = seekNodeByName(self, "BitmapFontLabel_z_Malltips", "ccui.TextBMFont")
    self._txt = seekNodeByName(self, "Text_messagebox", "ccui.Text")
    self._btnClose = seekNodeByName(self, "Button_x_Malltips", "ccui.Button")

    bindEventCallBack(self._btnCancle,    handler(self, self.onClose),    ccui.TouchEventType.ended);
    bindEventCallBack(self._btnConfirm,    handler(self, self.onConfirm),    ccui.TouchEventType.ended);
    bindEventCallBack(self._btnClose,    handler(self, self.onClose),    ccui.TouchEventType.ended);
end

function UIMallTips:onShow(...)
    local args = {...}
    self._phoneNumber:setString(args[1])
    self._txt:setString("确定为该手机号码充值" .. args[2])
    self.callback = args[3]
end

function UIMallTips:onClose()
    UIManager:getInstance():destroy("UIMallTips")
end

function UIMallTips:onConfirm()
    self.callback()
    UIManager:getInstance():destroy("UIMallTips")
end

function UIMallTips:needBlackMask()
	return true;
end

function UIMallTips:closeWhenClickMask()
	return false
end

function UIMallTips:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return UIMallTips;
