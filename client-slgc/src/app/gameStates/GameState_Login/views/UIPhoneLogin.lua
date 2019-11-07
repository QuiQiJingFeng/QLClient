local csbPath = "ui/csb/mengya/UIPhoneLogin.csb"
local super = game.UIBase
local Util = game.Util
local UIManager = game.UIManager

local UIPhoneLogin = class("UIPhoneLogin",  super, function()
	return Util:loadCSBNode(csbPath)
end)

local PHONE_MAX_LENG = 11
local CODE_MAX_LEN = 6
local EDITBOX_INPUT_MODE_NUMERIC = 2

function UIPhoneLogin:init()
    self._btnClose = Util:seekNodeByName(self,"btnClose","ccui.Button")
    self._btnClear = Util:seekNodeByName(self,"btnClear","ccui.Button")
    self._btnLogin = Util:seekNodeByName(self,"btnLogin","ccui.Button")
    self._btnGetVerificationCode = Util:seekNodeByName(self,"btnGetVerificationCode","ccui.Button")
    self._txtInvalidFormat = Util:seekNodeByName(self,"txtInvalidFormat","ccui.TextBMFont")
    self._txtAuthFaild = Util:seekNodeByName(self,"txtAuthFaild","ccui.Text")
    self._txtFieldPhone = Util:replaceTextFieldToEditBox(Util:seekNodeByName(self,"txtFieldPhone","ccui.TextField"))
    self._txtFieldVerificationCode = Util:replaceTextFieldToEditBox(Util:seekNodeByName(self,"txtFieldVerificationCode","ccui.TextField"))
    self._txtFieldPhone:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
    self._txtFieldPhone:setMaxLength(PHONE_MAX_LENG)
    self._txtFieldVerificationCode:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
    self._txtFieldVerificationCode:setMaxLength(CODE_MAX_LEN)

    Util:bindTouchEvent(self._btnGetVerificationCode,handler(self,self._onBtnGetVerificationCodeClick))
    Util:bindTouchEvent(self._btnLogin,handler(self,self._onBtnLoginClick))
    Util:bindTouchEvent(self._btnClear,handler(self,self._onBtnClearClick))
    Util:bindTouchEvent(self._btnClose,handler(self,self._onBtnCloseClick))
end

function UIPhoneLogin:_onBtnCloseClick()
    UIManager:getInstance():hide("views.UIPhoneLogin")
end

function UIPhoneLogin:_onBtnGetVerificationCodeClick()
    local textPhone = self._txtFieldPhone:getText()
    if string.len(textPhone) < PHONE_MAX_LENG then
        self._txtInvalidFormat:setVisible(true)
        return
    else
        self._txtInvalidFormat:setVisible(false)
    end
    local phone = tonumber(textPhone)
    assert(type(phone) == "number")

    self._txtFieldVerificationCode:setText("")

    -->请求验证码
end

function UIPhoneLogin:_onBtnLoginClick()
    local textCode = self._txtFieldVerificationCode:getText()
    if string.len(textCode) < CODE_MAX_LEN then
        game.UITipManager:getInstance():show("验证码为6位数字")
        return
    end
    local code = tonumber(textCode)
    --发送登录请求
end

function UIPhoneLogin:_onBtnClearClick()
    self._txtFieldPhone:setText("")
    self._txtInvalidFormat:setVisible(false)
end
 
function UIPhoneLogin:onShow()
    Util:hide(self._txtInvalidFormat,self._txtAuthFaild)

end

function UIPhoneLogin:onHide()

end

function UIPhoneLogin:needBlackMask()
	return true
end

return UIPhoneLogin