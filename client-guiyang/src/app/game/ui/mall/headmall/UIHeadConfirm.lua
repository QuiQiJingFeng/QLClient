local csbPath = "ui/csb/HeadFrame/UIHeadConfirmTips.csb"
local super = require("app.game.ui.UIBase")

local UIHeadConfirm = class("UIHeadConfirm", super, function () return kod.LoadCSBNode(csbPath) end)

function UIHeadConfirm:ctor()
    self.data = {}
    self.time = {}
end

function UIHeadConfirm:init()
    self._headIcon         = seekNodeByName(self,"Image_1",      "ccui.ImageView")
    self._timeTxt          = seekNodeByName(self,"BitmapFontLabel_31_0_0",      "ccui.TextBMFont")
    self._comfirmText      = seekNodeByName(self,"Text_12_0_0",      "ccui.Text")
    self._btnConfirm       = seekNodeByName(self,"Button_17_0",      "ccui.Button")
    self._btnClose         = seekNodeByName(self,"Button_17",      "ccui.Button")

    bindEventCallBack(self._btnConfirm, handler(self, self._onBuy), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
end

function UIHeadConfirm:onShow( ... )
    local args = {...}
    self.time = args[1]
    self.data = args[2]
    local money = args[3]
    game.util.PlayerHeadIconUtil.setIconFrame(self._headIcon,PropReader.getIconById(self.data.id),0.7)
    if tonumber(self.time) > 0 then
        self._timeTxt:setString(self.time.."天")
    else
        self._timeTxt:setString("永久")
    end

    self._comfirmText:setString("您确定用" .. money .. config.STRING.UIHEADCONFIRM_STRING_100)
end

function UIHeadConfirm:_onBtnClose()
    UIManager:getInstance():destroy("UIHeadConfirm")    
end

function UIHeadConfirm:_onBuy()
    game.service.HeadFrameService:getInstance():queryBuyHeadframe(self.data.id,self.time)
end

function UIHeadConfirm:needBlackMask()
	return false;
end

function UIHeadConfirm:closeWhenClickMask()
	return false
end

return UIHeadConfirm;
