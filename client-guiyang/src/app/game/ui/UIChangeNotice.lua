-- UI界面弹窗
local csbPath = "ui/csb/UIChange_Notice.csb"
local super = require("app.game.ui.UIBase")

local UIChangeNotice = class("UIChangeNotice", super, function () 
	return kod.LoadCSBNode(csbPath) 
end)

function UIChangeNotice:ctor()
end

function UIChangeNotice:init()
	local imgBg = seekNodeByName(self, "Image_bg", "ccui.ImageView")
	local btnClose = seekNodeByName(self, "Button_close", "ccui.Button")
	
    bindEventCallBack(btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

-- arg1:显示页面
function UIChangeNotice:onShow()
    self:playAnimation_Scale()
end

function UIChangeNotice:_onBtnClose()
    UIManager:getInstance():hide("UIChangeNotice")
end

function UIChangeNotice:needBlackMask()
	return true;
end

function UIChangeNotice:closeWhenClickMask()
	return false
end
 
return UIChangeNotice
