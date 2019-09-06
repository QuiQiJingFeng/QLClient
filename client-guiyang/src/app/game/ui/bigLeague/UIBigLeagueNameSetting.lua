local csbPath = "ui/csb/BigLeague/UIBigLeagueNameSetting.csb"
local super = require("app.game.ui.UIBase")
---@class UIBigLeagueNameSetting:UIBase
local UIBigLeagueNameSetting = super.buildUIClass("UIBigLeagueNameSetting", csbPath)

--[[
    修改名称界面
        比如备注、大联盟名称、玩法名称
]]

function UIBigLeagueNameSetting:ctor()

end

function UIBigLeagueNameSetting:init()
    self._textField = seekNodeByName(self, "TextField_Name", "ccui.TextField")

    self._btnCancel = seekNodeByName(self, "Button_Cancel", "ccui.Button")
    self._btnOk = seekNodeByName(self, "Button_Ok", "ccui.Button")

    self._textTitle = seekNodeByName(self, "BitmapFontLabel_Title", "ccui.TextBMFont")

    self._layoutNode = seekNodeByName(self, "Panel_Node", "ccui.Layout")
    self._textField:addEventListener(handler(self, self._onTouchTextField))
    self._beginPosY = self._layoutNode:getPositionY()

    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
end

function UIBigLeagueNameSetting:_onClickCancel()
    self:hideSelf()
end

function UIBigLeagueNameSetting:_onClickOk()
    if self._textField:getString() == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips("您输入的内容不符合命名规范，请重新输入")
        return
    end

    if kod.util.String.getUTFLen(self._textField:getString()) > self._len then
        game.ui.UIMessageTipsMgr.getInstance():showTips("您输入的内容过长，请重新输入")
        return
    end

    if self._callBack then
        self._callBack(self._textField:getString())
        self:hideSelf()
    end
end

--[[
    title：标题
    tips：输入框默认显示内容
    len：长度
    callBack：回调
]]
function UIBigLeagueNameSetting:onShow(title, tips, len, callBack)
    self._callBack = callBack
    self._len = len
    self._textField:setPlaceHolderColor(config.ColorConfig.InputField.White.InputHolder)
    self._textField:setTextColor(config.ColorConfig.InputField.White.inputTextColor)

    self._textTitle:setString(title)
    self._textField:setPlaceHolder(tips)
    self._textField:setString("")

    self:playAnimation_Scale()
end

function UIBigLeagueNameSetting:onHide()

end

function UIBigLeagueNameSetting:needBlackMask()
    return true
end

function UIBigLeagueNameSetting:closeWhenClickMask()
    return false
end

function UIBigLeagueNameSetting:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Normal
end

function UIBigLeagueNameSetting:_onTouchTextField(obj, event)
    local platForm = cc.Application:getInstance():getTargetPlatform()
    if platForm ~= cc.PLATFORM_OS_ANDROID then
        if event == ccui.TextFiledEventType.attach_with_ime then
            self._layoutNode:setPositionY(self._beginPosY + 200)
        elseif event == ccui.TextFiledEventType.detach_with_ime then
            self._layoutNode:setPositionY(self._beginPosY)
        elseif event == ccui.TextFiledEventType.insert_text then
            local content = kod.util.String.getMaxLenString(obj:getString(), self._len)
            self._textField:setString(content)
        end
    end
end

return UIBigLeagueNameSetting