local Constants = require("app.gameMode.mahjong.core.Constants")
local CardDefines = require("app.gameMode.mahjong.core.CardDefines")
local csbPath = "ui/csb/Effect/HuanSanZhang/UIHuanSanZhang.csb"
local M = class("UIHuanSanZhang", require("app.game.ui.UIBase"), function() return kod.LoadCSBNode(csbPath) end)
function M:ctor()
    M.super.ctor(self)
    self:playAnimation(csbPath, nil, true)
end

function M:init()
    self.btnEnsure = seekNodeByName(self, "Button", "ccui.Button")
    self.cardsLeft = seekNodeByName(self, "Image_Cards_Left", "ccui.ImageView")
    self.cardsRight = seekNodeByName(self, "Image_Cards_Right", "ccui.ImageView")
    self.cardsDown = seekNodeByName(self, "Node_Cards_Down", "cc.Node")

    self.tipsLeft = seekNodeByName(self, "BMFont_Tips_Left", "ccui.TextBMFont")
    self.tipsRight = seekNodeByName(self, "BMFont_Tips_Right", "ccui.TextBMFont")
    self.tipsDown = seekNodeByName(self, "Layout_Tips_Down", "ccui.Layout") -- 按钮在其中

    self.tipsBankerDiscard = seekNodeByName(self, "Layout_Banker_Discard_Tips", "ccui.Layout")

    bindEventCallBack(self.btnEnsure, handler(self, self._onBtnSureClick), ccui.TouchEventType.ended)
end

function M:onShow()
    self:showDefault()
end

function M:showDefault()
    self.cardsLeft:setVisible(false)
    self.cardsRight:setVisible(false)
    self.cardsDown:setVisible(false)

    self.tipsLeft:setVisible(true)
    self.tipsRight:setVisible(true)
    self.tipsDown:setVisible(true)

    self.tipsBankerDiscard:setVisible(false)
    
    self.btnEnsure:setVisible(true)
    self.btnEnsure:setEnabled(true)
end

function M:hideAll()
    self.btnEnsure:setVisible(false)
    self.cardsLeft:setVisible(false)
    self.cardsRight:setVisible(false)
    self.cardsDown:setVisible(false)
    self.tipsLeft:setVisible(false)
    self.tipsRight:setVisible(false)
    self.tipsDown:setVisible(false)
    self.tipsBankerDiscard:setVisible(false)
end

function M:setOnButtonEnsureClickCallback(callback)
    self._onBtnEnsureClickCallback = callback
end

function M:_onBtnSureClick(sender)
    if self._onBtnEnsureClickCallback then
        self._onBtnEnsureClickCallback()
    end
    -- 可能因为点击了之后，消息没有回复，又再次点击了，导致重复发了两次
    self._onBtnEnsureClickCallback = nil
end

function M:setButtonEnsureEnable(value)
    self.btnEnsure:setEnabled(value or false)
end

function M:onHide()
end

function M:onOneMenSelected(chairType)
    if chairType == CardDefines.Chair.Down then
        self.btnEnsure:setVisible(false)
        self.tipsDown:setVisible(false)
        self.cardsDown:setVisible(true)
    elseif chairType == CardDefines.Chair.Left then
    elseif chairType == CardDefines.Chair.Right then
    else
    end
end

function M:showBankerDiscardTipsAndAutoHide()
    self:hideAll()

    self.tipsBankerDiscard:setVisible(true)

    scheduleOnce(function()
        UIManager:getInstance():hide(self.class.__cname)
    end, 3, self)
end

return M