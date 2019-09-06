-- 回归礼包

local csbPath = "ui/csb/Backpack/UIHuiGuiLiBao.csb"
local super = require("app.game.ui.UIBase")
local UI_ANIM = require("app.manager.UIAnimManager")
local UIRichTextEx = require("app.game.util.UIRichTextEx")

local UIGiftRegress = class("UIGiftRegress", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGiftRegress:ctor()
    self._animNode = nil
end

function UIGiftRegress:init()
    self._animNode = seekNodeByName(self, "Node_anim", "cc.Node")
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
    self._btnConfirm = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")
    self._panel = seekNodeByName(self, "Panel_Djq","ccui.Layout")
    self._touchPanel = seekNodeByName(self, "Panel_touch", "ccui.Layout")
    self._innerText = seekNodeByName(self, "Text_purpose", "ccui.Layout")

    self._richText = UIRichTextEx:create{size = 24}   
    self._innerText:addChild(self._richText)
     
    local text = "<#97561f>终于等到你,还好没放弃\n \n再次见到你,内心好欣喜~\n \n送你一份<font><#ff7639>回归礼包<font><#97561f>,以表\n \n心意.......<font>"
    self._richText:setText(text)

    self._richText:setAnchorPoint(cc.p(0,0));
    self._richText:setName("richText")
    self._richText:setPosition(cc.p(0,0))

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnConfirm, handler(self, self._onBtnConfirm), ccui.TouchEventType.ended)
    bindEventCallBack(self._touchPanel, handler(self, function ()
        self._animNode:setVisible(false)
        self._panel:setVisible(true)
    end), ccui.TouchEventType.ended)
end

function UIGiftRegress:onShow( ... )
    local args = {...}
    self.id = args[1]
    self._panel:setVisible(false)

    local anim = UI_ANIM.UIAnimManager:getInstance():onShow({
		_path = "ui/csb/Backpack/Effect_huigui.csb",
        _parent = self._animNode,
        _replay = true
    })
end

function UIGiftRegress:_onBtnConfirm()
    game.service.GiftService:getInstance():queryReceiveGift(self.id)
end

function UIGiftRegress:needBlackMask()
	return true;
end

function UIGiftRegress:closeWhenClickMask()
	return false
end

function UIGiftRegress:_onClose()
    UIManager:getInstance():destroy("UIGiftRegress")
end

function UIGiftRegress:onHide()
    -- 取消事件监听
end

return UIGiftRegress