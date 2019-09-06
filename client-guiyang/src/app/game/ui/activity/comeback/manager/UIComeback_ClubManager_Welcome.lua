--
-- 每日自动弹出，没有其他入口
--
local csbPath = 'ui/csb/Activity/Comeback/UIComeback_ClubManager_Welcome.csb'
local super = require("app.game.ui.UIBase")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local M = class("UIComeback_ClubManager_Welcome", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    -- self._btnRule = UtilsFunctions.seekButton(self, "", handler(self, self._onRuleClicked))
    local imgRule = seekNodeByName(self, "Image_Rule", "ccui.ImageView")
    bindEventCallBack(imgRule, handler(self, self._onRuleClicked), ccui.TouchEventType.ended)

    self._btnInvite = UtilsFunctions.seekButton(self, "Button_Invite", handler(self, self._onInviteClick))
    self._btnShowBindPlayers = UtilsFunctions.seekButton(self, "Button_BindPlayer", handler(self, self._onShowBindPlayerClick))
    self._btnClose = UtilsFunctions.seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))

    self._textTotalCardNum = seekNodeByName(self, "BMFont_Card_Num", "ccui.TextBMFont")
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    self:playAnimation(csbPath, nil, true)
end

function M:onShow(msgBuffer)
    self._textTotalCardNum:setString(msgBuffer.totalCard)
end

function M:_onRuleClicked(sender)
    UIManager:getInstance():show("UIComeback_Rule", true)
end

function M:_onInviteClick(sender)
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if service then
        -- 显示了这个界面则一定是 manager
        service:comebackShare(true)
    end
end

function M:_onShowBindPlayerClick(sender)
    local service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if service then
        service:sendCACBackCheckBindUserREQ()
    end
end

function M:_onBtnCloseClick(sender)
    if self._service then
        self._service:managerLeaveTip(handler(self, self.hideSelf))
    else
        self:hideSelf()
    end
end

function M:needBlackMask() return true end

return M