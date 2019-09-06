local csbPath = "ui/csb/Agent/UIRecruit2.csb"
local super = require("app.game.ui.UIBase")
local UIRecruit2 = class("UIRecruit2", super, function () return kod.LoadCSBNode(csbPath) end)

function UIRecruit2:ctor()
end

function UIRecruit2:init()
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._btnApplication = seekNodeByName(self, "Button_application", "ccui.Button") -- 申请
    self._imgImg = seekNodeByName(self, "Image_img", "ccui.ImageView") -- 宣传图

    bindEventCallBack(self._btnClose, handler(self, self._onBtnClose), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnApplication, handler(self, self._onBtnApplication), ccui.TouchEventType.ended)
end

function UIRecruit2:_onBtnClose()
    UIManager:getInstance():destroy("UIRecruit2")
end

function UIRecruit2:_onBtnApplication()
    -- 复制信息
    local text = string.format("你好，我已成功提交了代理申请\n手机：%s\n微信号：%s", self._phone, self._weChat)
    if game.plugin.Runtime.setClipboard(text) == true then
        game.ui.UIMessageTipsMgr.getInstance():showTips("复制成功")
    end
    -- 跳转客服
    game.service.MeiQiaService:getInstance():openMeiQia()
end

function UIRecruit2:onShow(phone, weChat)
    self._phone = phone
    self._weChat = weChat
    self._imgImg:loadTexture("art/activity/agt/2.jpg")

    self:playAnimation_Scale()
end

function UIRecruit2:needBlackMask()
	return true
end

function UIRecruit2:closeWhenClickMask()
	return false
end

function UIMain:getUIRecordLevel()
	return config.UIRecordLevel.MainLayer
end

return UIRecruit2