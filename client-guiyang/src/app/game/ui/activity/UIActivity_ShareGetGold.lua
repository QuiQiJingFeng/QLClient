local csbPath = 'ui/csb/Activity/UIActivity_ShareGetGold.csb'
local super = require("app.game.ui.UIBase")
local M = class("UIActivity_ShareGetGold", super, function() return kod.LoadCSBNode(csbPath) end)

function M:ctor()
    self._isShared = false
    self._isListening = false
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._btnShare = seekNodeByName(self, "Button_Share", "ccui.Button")

    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onBtnShareClick), ccui.TouchEventType.ended)

    
end

function M:init()
end

function M:onShow()
    self:_removeEventListener()
end

function M:onHide()
    self:_removeEventListener()
end

function M:_onBtnShareClick(sender)
    self:_addEventListener()
    local dataArray = { { res = "art/activity/avtivity_share_get_gold.png" } }
    local enter = share.constants.ENTER.SHARE_GET_GOLD_ANDROID
    if device.platform == 'ios' then
        enter = share.constants.ENTER.SHARE_GET_GOLD_IOS
        dataArray = {
            {
                enter = enter,
                shareInfo = "话费免费送",
                shareContent = "玩牌金币场，话费领不停！ 每日6千话费，等你瓜分！"
            }
        }
    end
    share.ShareWTF.getInstance():share(enter, dataArray)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Daily_Share_Get_Gold)
end

function M:_onShareSuccAndroid()
    if self._isShared == true then
        return
    end
    self._isShared = true
    game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
    UIManager.getInstance():destroy(self.class.__cname)
end

function M:_onShareSuccIOS(event)
    if self._isShared == true then
        return
    end
    if event.errCode ~= game.service.WeChatService.WXErrorCode.WXSuccess then -- ios wx share failed
        -- do nothing
        return
    end
    self._isShared = true
    game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
    UIManager.getInstance():destroy(self.class.__cname)
end

function M:_onBtnCloseClick(sender)
    UIManager.getInstance():destroy(self.class.__cname)
end

function M:_addEventListener()
    if self._isListening then
        return
    end
    if device.platform == 'ios' then
        game.service.WeChatService.getInstance():addEventListener("EVENT_SEND_RESP", handler(self, self._onShareSuccIOS), self);
    elseif device.platform == 'android' or device.platform == 'windows' then
        if self._listenerEnterForeground == nil then
            self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onShareSuccAndroid))
        end
    end
    self._isListening = true
end

function M:_removeEventListener()
    if not self._isListening then
        return
    end
    game.service.WeChatService.getInstance():removeEventListenersByTag(self)

    if self._listenerEnterForeground ~= nil then
        unlistenGlobalEvent(self._listenerEnterForeground)
        self._listenerEnterForeground = nil;
    end
end

function M:needBlackMask() return true end

function M:closeWhenClickMask() return true end

return M