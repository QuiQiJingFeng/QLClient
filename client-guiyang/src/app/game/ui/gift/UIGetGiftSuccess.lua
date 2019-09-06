-- 新手礼包
-- 回归礼包

local csbPath = "ui/csb/Backpack/UIGetGiftSucess.csb"
local super = require("app.game.ui.UIBase")

local UIGetGiftSuccess = class("UIGetGiftSuccess", super, function () return kod.LoadCSBNode(csbPath) end)

function UIGetGiftSuccess:ctor()
    self._animNode = nil
    self.id = 0
end

function UIGetGiftSuccess:init()
    self._btnConfirm = seekNodeByName(self, "Button_x_MessageHelp_0", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button")

    bindEventCallBack(self._btnClose, handler(self, self._onClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnConfirm, handler(self, self._onBtnConfirm), ccui.TouchEventType.ended)
end

function UIGetGiftSuccess:onShow( ... )
    local args = {...}
    local gifts = args[1]
    for i = 1, 3 do
        local item = seekNodeByName(self, "Image_" .. i, "ccui.ImageView")
        local text = seekNodeByName(self, "Text" .. i, "ccui.Text")
        item:loadTexture("art/function/img_none.png")
        item:setVisible(false)
        text:setString("")
        if gifts[i] ~= nil then
            item:setVisible(true)
            PropReader.setIconForNode(item,gifts[i].itemId)
            text:setString("X" .. gifts[i].count)
        end
    end
end

function UIGetGiftSuccess:_onBtnConfirm()
    UIManager:getInstance():destroy("UIGetGiftSuccess")
    UIManager:getInstance():destroy("UIGiftRegress")
    UIManager:getInstance():destroy("UIBackpackGiftDetail")
end

function UIGetGiftSuccess:needBlackMask()
	return true;
end

function UIGetGiftSuccess:closeWhenClickMask()
	return false
end

function UIGetGiftSuccess:_onClose()
    UIManager:getInstance():destroy("UIGetGiftSuccess")
    UIManager:getInstance():destroy("UIGiftRegress")
    UIManager:getInstance():destroy("UIBackpackGiftDetail")
end

function UIGetGiftSuccess:onHide()
    -- 取消事件监听
end

return UIGetGiftSuccess