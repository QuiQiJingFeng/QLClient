-- 新手礼包
-- 回归礼包

local csbPath = "ui/csb/Backpack/UINewPlayer.csb"
local super = require("app.game.ui.UIBase")

local UIGiftNewPlayer = class("UIGiftNewPlayer", super, function () return kod.LoadCSBNode(csbPath) end)
local UIRichTextEx = require("app.game.util.UIRichTextEx")

function UIGiftNewPlayer:ctor()
    self._animNode = nil
    self.id = 0
end

function UIGiftNewPlayer:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._panel = seekNodeByName(self, "Panel_Djq", "ccui.Layout")
    self._btnConfirm = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")
    self._imgPackage = seekNodeByName(self, "Image_word_messagebox_0_0", "ccui.ImageView")

    self._innerText = seekNodeByName(self, "Text_purpose", "ccui.Layout")

    self._richText = UIRichTextEx:create{size = 24}   
    self._innerText:addChild(self._richText)

    local text = "<#97561f>欢迎来到聚友大世界，\n \n现在为您送上一份新手\n \n礼包，请您在<font><#ff7639>背包<font><#97561f>中查\n \n收，祝您搓麻愉快！<font>"
    self._richText:setText(text)

    self._richText:setAnchorPoint(cc.p(0,0));
    self._richText:setName("richText")
    self._richText:setPosition(cc.p(0,0))

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnConfirm, handler(self, self._onBtnConfirm), ccui.TouchEventType.ended)
end

function UIGiftNewPlayer:onShow( ... )
    local args = {...}
end

function UIGiftNewPlayer:needBlackMask()
	return true;
end

function UIGiftNewPlayer:closeWhenClickMask()
	return false
end

function UIGiftNewPlayer:_onBtnConfirm()
    self:onDisappear()
end

function UIGiftNewPlayer:_onClose()
    self:onDisappear()
end

function UIGiftNewPlayer:onHide()
    
end

function UIGiftNewPlayer:onDisappear()
    self._panel:setVisible(false)
    local delay = cc.DelayTime:create(1.5)

    local callback = cc.CallFunc:create(function()
        UIManager:getInstance():destroy("UIGiftNewPlayer")
    end)

    if UIManager:getInstance():getIsShowing("UIMain") ~= true then
        UIManager:getInstance():destroy("UIGiftNewPlayer")
        return
    end

    local uiMain = UIManager:getInstance():getUI("UIMain")

    local btn = uiMain._btnMore
    local panelPosX = uiMain._rightDownPanel:getPositionX()
    local panelWidth = uiMain._rightDownPanel:getContentSize().width

    local x,y = btn:getPosition()
    local menuWidth = btn:getContentSize().width
    local anchor = btn:getAnchorPoint()
    local scale = btn:getScale()
    local nodePos = btn:getParent():convertToWorldSpace(cc.p(x-menuWidth*(anchor.x-0.5)*scale,y))
    nodePos = self._imgPackage:getParent():convertToNodeSpace(nodePos)
    local spawn = cc.Spawn:create(
        cc.MoveTo:create(1.5,nodePos),
        cc.ScaleTo:create(1, 0.4, 0.4)
    )
    self._imgPackage:runAction(cc.Sequence:create(
        spawn,
        cc.FadeTo:create(0.2,0),        
        delay,
        callback
    ))
end

return UIGiftNewPlayer