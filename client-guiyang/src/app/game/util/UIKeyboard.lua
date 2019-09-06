local csbPath = "ui/csb/Util/UIKeyboard.csb"
local super = require("app.game.ui.UIBase")
---@class UIKeyboard:UIBase
local UIKeyboard = super.buildUIClass("UIKeyboard",csbPath)

function UIKeyboard:ctor()
    self._btnNumbers = {}
    self._callBack = nil
    self._limet = 15
    self._tips = ""
end

function UIKeyboard:init()
    self._textTitle = seekNodeByName(self, "BitmapFontLabel_Title", "ccui.TextBMFont")
    self._textNumber = seekNodeByName(self, "BitmapFontLabel_Number", "ccui.TextBMFont")
    self._textBtnName = seekNodeByName(self, "BitmapFontLabel_BtnName", "ccui.TextBMFont")

    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnRetype = seekNodeByName(self, "Button_Retype", "ccui.Button")
    self._btnDelete = seekNodeByName(self, "Button_Delete", "ccui.Button")
    self._btnClick = seekNodeByName(self, "Button_Click", "ccui.Button")

    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key0",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key1",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key2",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key3",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key4",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key5",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key6",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key7",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key8",  "ccui.Button"))
    table.insert(self._btnNumbers, seekNodeByName(self, "Button_Key9",  "ccui.Button"))

    bindEventCallBack(self._btnClose, handler(self, self._onClickClose),ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRetype, handler(self, self._onClickRetype),ccui.TouchEventType.ended)
    bindEventCallBack(self._btnDelete, handler(self, self._onClickDelete),ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClick, handler(self, self._onClick), ccui.TouchEventType.ended)

    for i = 1,#self._btnNumbers do
        bindEventCallBack(self._btnNumbers[i], function()
            self:_onClickNumber(i-1)
        end,ccui.TouchEventType.ended);
    end

    -- 监听是否要关闭该界面或者清空字符串
    event.EventCenter:addEventListener("EVENT_KEYBOARD", function (event)
        if event.isClear then
            self:_onClickRetype()
        end
        if event.isDestroy then
            self:_onClickClose()
        end
    end , self)
end

-- 关闭
function UIKeyboard:_onClickClose()
    self:destroySelf()
end

-- 重新输入
function UIKeyboard:_onClickRetype()
    self._textNumber:setString("")
end

-- 删除
function UIKeyboard:_onClickDelete()
    local str = self._textNumber:getString()
    if str == "" then
        return
    end
    str = string.sub(str, 0, string.len(str) - 1)
    self._textNumber:setString(str)
end

-- 数字事件
function UIKeyboard:_onClickNumber(number)
    local str = self._textNumber:getString()
    -- 限制最多输入15位
    if string.len(str) >= self._limet then
        return
    end
    self._textNumber:setString(string.format("%s%s", str, number))
end

-- 回调（返回值为string）
function UIKeyboard:_onClick()
    local str = self._textNumber:getString()
    if str == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips(self._tips)
        return
    end
    self._callBack(str)
end

--[[
    title       标题
    limit       字数限制
    tips        字符串为空的时候tips提示内容
    btnName     回调按钮显示文字
    callBack    回调事件

]]--
function UIKeyboard:onShow(title, limit, tips, btnName, callBack)
    self._limet = limit
    self._tips = tips
    self._textTitle:setString(title)
    self._textBtnName:setString(btnName)
    -- 如果没有回调事件就不显示改按钮
    if callBack ~= nil then
        self._callBack = callBack
        self._btnClick:setVisible(true)
    else
        self._btnClick:setVisible(false)
    end

    self._textNumber:setString("")
    self:playAnimation_Scale()
end

function UIKeyboard:onHide()

end

function UIKeyboard:destroy()
    self._btnNumbers = {}
    self._callBack = nil
    self._limet = 15
    self._tips = ""
    event.EventCenter:removeEventListenersByTag(self)
end

function UIKeyboard:needBlackMask()
    return true
end

function UIKeyboard:closeWhenClickMask()
    return false
end

function UIKeyboard:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIKeyboard