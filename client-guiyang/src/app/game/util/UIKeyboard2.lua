local csbPath = "ui/csb/Util/UIKeyboard2.csb"
local super = require("app.game.ui.UIBase")
---@class UIKeyboard2:UIBase
local UIKeyboard2 = super.buildUIClass("UIKeyboard2",csbPath)

function UIKeyboard2:ctor()
    self._btnNumbers = {}
    self._callBack = nil
    self._limet = 15
    self._tips = ""
end

function UIKeyboard2:init()
    self._textTitle = seekNodeByName(self, "BitmapFontLabel_Title", "ccui.TextBMFont")
    self._textNumber = seekNodeByName(self, "BitmapFontLabel_Number", "ccui.TextBMFont")
    self._textBtnName = seekNodeByName(self, "BitmapFontLabel_BtnName", "ccui.TextBMFont")

    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnSymbol = seekNodeByName(self, "Button_Symbol", "ccui.Button")
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
    bindEventCallBack(self._btnSymbol, handler(self, self._onClickSymbol),ccui.TouchEventType.ended)
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
            self._textNumber:setString("")
        end
        if event.isDestroy then
            self:_onClickClose()
        end
    end , self)
end

-- 关闭
function UIKeyboard2:_onClickClose()
    self:destroySelf()
end

-- +/- 符号
function UIKeyboard2:_onClickSymbol()
    local str = self._textNumber:getString()
    if string.len(str) > 1 then
        return
    end

    if str == "+" then
        self._textNumber:setString("-")
    else
        self._textNumber:setString("+")
    end

end

-- 删除
function UIKeyboard2:_onClickDelete()
    local str = self._textNumber:getString()
    if str == "" then
        return
    end
    str = string.sub(str, 0, string.len(str) - 1)
    self._textNumber:setString(str)
end

-- 数字事件
function UIKeyboard2:_onClickNumber(number)
    local str = self._textNumber:getString()
    if string.len(str) < 1 then
        game.ui.UIMessageTipsMgr.getInstance():showTips("请先选择正负号")
        return
    end


    -- 限制最多输入15位
    if string.len(str) >= self._limet then
        return
    end
    self._textNumber:setString(string.format("%s%s", str, number))
end

-- 回调（返回值为string）
function UIKeyboard2:_onClick()
    local str = self._textNumber:getString()
    if str == "" then
        game.ui.UIMessageTipsMgr.getInstance():showTips(self._tips)
        return
    end

    str = tonumber(str)
    if str ~= nil and str > 0 then
        str = string.format("+%s", str)
    else
        str = tostring(str)
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
function UIKeyboard2:onShow(title, limit, tips, btnName, callBack)
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

function UIKeyboard2:onHide()

end

function UIKeyboard2:destroy()
    self._btnNumbers = {}
    self._callBack = nil
    self._limet = 15
    self._tips = ""
    event.EventCenter:removeEventListenersByTag(self)
end

function UIKeyboard2:needBlackMask()
    return true
end

function UIKeyboard2:closeWhenClickMask()
    return false
end

function UIKeyboard2:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIKeyboard2