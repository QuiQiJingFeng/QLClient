-- 按钮位置配置，根据当前显示的个数作为key
local ButtonPositionXConfig = {
    [1] = { 330 },
    [2] = { 165, 495 }
}
local csbPath = "ui/csb/UIMessageBox.csb"
local super = require("app.game.ui.UIBase")
local M = class("UIConnectionMessageBox", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    super.ctor(self)
end

function M:init()
    self._btnEnsure = seekNodeByName(self, "Button_qd_messagebox", "ccui.Button")
    self._btnEnsure.text = seekNodeByName(self, "BitmapFontLabel_1", "ccui.TextBMFont")
    self._btnCancel = seekNodeByName(self, "Button_qx_messagebox", "ccui.Button")
    self._btnCancel.text = seekNodeByName(self, "BitmapFontLabel_1_0", "ccui.TextBMFont")
    self._btnClose = seekNodeByName(self, "Button_1", "ccui.Button")
    self._txtContent = seekNodeByName(self, "Text_messagebox", "ccui.Text") 

    -- 不需要中间这个
    local btnCenter = seekNodeByName(self, "Button_qd2_messagebox", "ccui.Button")
    if btnCenter then
        btnCenter:removeFromParent()
    end
end

--[[    参数配置，按照index配置，如果传入的参数的大小在意料之外，可能会报错
    [1]、content [string] 内容
    [2]、button texts [string table] 按钮显示的文本，接受范围为[1-2]
    [3,+INF]、callbacks [function table] 按钮点击的回调， 外部传入的回调会在内部进行升级一次（触发外部回调前先关闭此UI）
        接受范围为[1-2]
]]
function M:onShow(...)
    local args = { ... }
    local content = args[1]
    -- 预想的长度是[1,2]
    local btnTextArr = args[2]
    -- 第三个之后的都为callback， 预想的长度是[1,2]
    local callbacks = { unpack(args, 3, #args) }

    self._txtContent:setString(content)

    -- 此数组与传入的[2]是对应的，在此，默认第一个是确定型按钮，第二个是否定型按钮
    local btnArr = { self._btnEnsure, self._btnCancel }

    self:_hideButtons(btnArr)
    callbacks = self:_upgradeOuterCallbacks(callbacks)
    self:_setButtonTextsAndShow(btnArr, btnTextArr)
    self:_setButtonCallbacks(btnArr, callbacks)
    self:_setCloseButtonCallback(self._btnClose, callbacks)
    self:_adjustVisiableButtonPosition(btnArr)
end

function M:onHide()
end

-- 设置按钮的文字并且显示按钮
function M:_setButtonTextsAndShow(btnArr, btnTextArr)
    for index, txt in ipairs(btnTextArr) do
        btnArr[index].text:setString(txt)
        btnArr[index]:setVisible(true)
    end
end

-- 设置按钮的点击回调，传入的回调应该是在内部被升级过的
function M:_setButtonCallbacks(btnArr, callbacks)
    for index, callback in ipairs(callbacks) do
        bindEventCallBack(btnArr[index], callback, ccui.TouchEventType.ended)
    end
end

-- 隐藏按钮
function M:_hideButtons(btnArr)
    for _, btn in ipairs(btnArr) do
        btn:setVisible(false)
    end
end

-- 根据可见的按钮去调整按钮的位置，若可见按钮不为配置的个数，逻辑会出现错误 @see at top
function M:_adjustVisiableButtonPosition(btnArr)
    local counter = 0
    local visiableBtns = {}
    for _, btn in ipairs(btnArr) do
        if btn:isVisible() then
            table.insert(visiableBtns, btn)
        end
    end

    local posConfig = ButtonPositionXConfig[#visiableBtns]
    if Macro.assertFalse(posConfig, 'config not found, visiable button is too many ?') then
        for index, btn in ipairs(visiableBtns) do
            btn:setPositionX(posConfig[index])
        end
    end
end

-- close 绑定最后一个回调
function M:_setCloseButtonCallback(btnClose, callbacks)
    bindEventCallBack(btnClose, callbacks[#callbacks], ccui.TouchEventType.ended)
end

-- 调用外部回调前先关闭自身
function M:_upgradeOuterCallbacks(callbacks)
    local ret = {}
    for _, callback in ipairs(callbacks) do
        local fn = function()
            UIManager:getInstance():hide(self.class.__cname)
            callback()
        end
        table.insert(ret, fn)
    end
    return ret
end

function M:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top;
end

return M