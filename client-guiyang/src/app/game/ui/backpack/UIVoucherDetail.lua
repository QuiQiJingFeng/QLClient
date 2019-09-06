local csbPath = "ui/csb/Backpack/UIVoucherDetail.csb"
local super = require("app.game.ui.UIBase")

local UIVoucherDetail = class("UIVoucherDetail", super, function() return kod.LoadCSBNode(csbPath) end)

function UIVoucherDetail:ctor()
    self._btnClose = nil
    self.propObj = nil
end

function UIVoucherDetail:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button");
    self._btnCopy = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")

    self._textSource = seekNodeByName(self, "Text_source", "ccui.Text")
    self._textTime = seekNodeByName(self, "Text_time", "ccui.Text")
    self._textDetail = seekNodeByName(self, "Text_detail", "ccui.Text");
    self._textPurpose = seekNodeByName(self, "Text_purpose", "ccui.Text")
    self._textSerial = seekNodeByName(self, "BitmapFontLabel_3", "ccui.TextBMFont");

    bindEventCallBack(self._btnClose,    handler(self, self._onBtnCloseClick),    ccui.TouchEventType.ended);
    bindEventCallBack(self._btnCopy,    handler(self, self._onBtnUseageClick),    ccui.TouchEventType.ended);
end

function UIVoucherDetail:onShow(...)
    local data = { ... };
    self.propObj = data[1]
    self._textDetail:setString("道具详情:" .. self.propObj:getDesc())
    self._textSource:setString("道具来源:" .. self.propObj:getSource())
    self._textPurpose:setString("使用方式:".. self.propObj:getPurpose())

    local creatrTime = self.propObj:getExternal().createTime
    local endTime = self.propObj:getExternal().destroyTime
    self._textTime:setString("使用期限:剩余" .. self:calcExistsDays(endTime,creatrTime) .. "天到期")
    self._textSerial:setString(self.propObj:getExternal().content)
end

function UIVoucherDetail:calcExistsDays(createTime, endTime)
    local result = math.ceil((createTime- endTime)/ 86400000)
    return result
end

function UIVoucherDetail:needBlackMask()
    return true;
end

function UIVoucherDetail:closeWhenClickMask()
    return true
end

function UIVoucherDetail:_onBtnCloseClick()
    UIManager:getInstance():destroy("UIVoucherDetail")
end

function UIVoucherDetail:_onBtnUseageClick()
    if game.plugin.Runtime.setClipboard(self.propObj:getExternal().content) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制失败")
    end
end

return UIVoucherDetail;