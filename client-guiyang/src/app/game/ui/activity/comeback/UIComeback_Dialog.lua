--[[0
    活动通用的弹出， 无论各个按钮是否有设置回调，最后都会关闭他们
]]
local seekButton = require("app.game.util.UtilsFunctions").seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "ui/csb/Activity/Comeback/UIComeback_Dialog.csb"
local M = class("UIComeback_Dialog", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    self:playAnimation(csbPath, nil, true)

    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnLeft = seekButton(self, "Button_Left", handler(self, self._onBtnLeftClick))
    self._btnMiddle = seekButton(self, "Button_Middle", handler(self, self._onBtnMiddleClick))
    self._btnRight = seekButton(self, "Button_Right", handler(self, self._onBtnRightClick))
    self._icon = seekNodeByName(self, "Icon", "ccui.ImageView")
    self._iconEffect = seekNodeByName(self, "BG_Effect", "ccui.ImageView")
    self._textMiddle = seekNodeByName(self, "Text_Content_Middle", "ccui.Text")
    self._textBottom = seekNodeByName(self, "Text_Content_Bottom", "ccui.Text")
    self._textTitle = seekNodeByName(self, "BMFont_Title", "ccui.TextBMFont")
end

function M:onDestroy()
    self:resetButtonStatus()
end

function M:onHide()
    self:resetButtonStatus()
end

function M:onShow(args)
    local title = args.title or "提示"
    local content = args.content or ""
    self._textTitle:setString(title)
    self._textMiddle:setString(content)
    self._textBottom:setString(content)

    -- 没有则不限时icon，并且 content 用 middle，否则用 bottom
    local iconPath = args.iconPath
    local invalidIcon = iconPath == nil or iconPath == ""
    if not invalidIcon then
        self._icon:loadTexture(iconPath)
    end
    self._icon:setVisible(not invalidIcon)
    self._iconEffect:setVisible(not invalidIcon)
    self._textBottom:setVisible(not invalidIcon)
    self._textMiddle:setVisible(invalidIcon)
    -- 只可能是 1个 或者 2个 的情况
    self:resetButtonStatus()
    self._btnCloseCallback = args.onCloseClick
    self:pushButtons(args.btns or {})
end

function M:pushButtons(btns)
    local len = #btns
    if len == 1 then
        local cfg = btns[1]
        seekNodeByName(self._btnMiddle, "BMFont", "ccui.TextBMFont"):setString(cfg.text)
        self._btnMiddleCallback = cfg.onClick
        self._btnMiddle:show()
    elseif len == 2 then
        local cfg1 = btns[1]
        local cfg2 = btns[2]
        seekNodeByName(self._btnLeft, "BMFont", "ccui.TextBMFont"):setString(cfg1.text)
        seekNodeByName(self._btnRight, "BMFont", "ccui.TextBMFont"):setString(cfg2.text)
        self._btnLeft:show()
        self._btnRight:show()
        self._btnLeftCallback = cfg1.onClick
        self._btnRightCallback = cfg2.onClick
    end
end

function M:resetButtonStatus()
    self._btnLeft:hide()
    self._btnMiddle:hide()
    self._btnRight:hide()
    self._btnLeftCallback = nil
    self._btnMiddleCallback = nil
    self._btnRightCallback = nil
    self._btnCloseCallback = nil
end

function M:onHide()
end

function M:_onBtnCloseClick(sender)
    if self._btnCloseCallback then
        self._btnCloseCallback()
    end
    self:hideSelf()
end

function M:_onBtnLeftClick(sender)
    if self._btnLeftCallback then
        self._btnLeftCallback()
    end
    self:hideSelf()
end

function M:_onBtnMiddleClick(sender)
    if self._btnMiddleCallback then
        self._btnMiddleCallback()
    end
    self:hideSelf()
end

function M:_onBtnRightClick(sender)
    if self._btnRightCallback then
        self._btnRightCallback()
    end
    self:hideSelf()
end

function M:needBlackMask() return true end

return M