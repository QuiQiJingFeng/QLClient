local csbPath = "ui/csb/Agent/UIDlsq.csb"
local super = require("app.game.ui.UIBase")
local UIRichTextEx = require("app.game.util.UIRichTextEx")

local UIAgentHasApply = class("UIAgentHasApply", super, function () return kod.LoadCSBNode(csbPath) end)

function UIAgentHasApply:ctor()
	self._btnClose = nil
	self._richText = nil
    self._innerText = nil
end

function UIAgentHasApply:init()
	self._btnClose = seekNodeByName(self, "Button_x_user", "ccui.Button")
    self._innerText = seekNodeByName(self, "Panel_1", "ccui.Layout")
    self._richText = UIRichTextEx:create{size = 22}    

    self._richText:setAnchorPoint(cc.p(0,0));
    self._richText:setName("richText")
    self._richText:setPosition(cc.p(0,0))
	
	bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIAgentHasApply:onShow( ... )
    local args = { ... }
    local wechat = args[1] or ""

    self._innerText:addChild(self._richText)
    local text = "激活代理商请联系客服微信：" .. wechat  
    self._richText:setText(text)
end

function UIAgentHasApply:_onBtnClose()
    UIManager:getInstance():destroy("UIAgentHasApply")
end

function UIAgentHasApply:onHide()
    
end

function UIAgentHasApply:needBlackMask()
	return true;
end

function UIAgentHasApply:closeWhenClickMask()
	return false
end

return UIAgentHasApply