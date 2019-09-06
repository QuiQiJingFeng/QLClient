local csbPath = 'ui/csb/Activity/UICollectionActivity.csb'
local super = require("app.game.ui.UIBase")
local UICollectionActivity = class("UICollectionActivity", super, function() return kod.LoadCSBNode(csbPath) end)

-- 图片配置
local IMG = 
{
    [28] = "art/activity/fxlnh/share/28.jpg",
    [29] = "art/activity/fxlnh/share/29.jpg",
    [30] = "art/activity/fxlnh/share/30.jpg",
    [31] = "art/activity/fxlnh/share/31.jpg",
    [1] = "art/activity/fxlnh/share/1.jpg",
    [2] = "art/activity/fxlnh/share/2.jpg",
    [3] = "art/activity/fxlnh/share/3.jpg",
    [4] = "art/activity/fxlnh/share/4.jpg",
    [5] = "art/activity/fxlnh/share/5.jpg",
    [6] = "art/activity/fxlnh/share/6.jpg",
    [7] = "art/activity/fxlnh/share/7.jpg",
}

function UICollectionActivity:ctor()
    self:playAnimation(csbPath, nil, true)
end

function UICollectionActivity:init()
    self._btnReceive = seekNodeByName(self, "Button_receive", "ccui.Button") -- 领取
    self._btnRule = seekNodeByName(self, "Button_rule", "ccui.Button") -- 活动说明
    self._btnClose = seekNodeByName(self, "Button_close", "ccui.Button") -- 关闭
    self._btnShare = seekNodeByName(self, "Button_share", "ccui.Button") -- 分享

    bindEventCallBack(self._btnReceive, handler(self, self._onBtnReceiveClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnShare, handler(self, self._onBtnReceiveClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnRule, handler(self, self._onBtnRuleClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onBtnCloseClick), ccui.TouchEventType.ended)
end

function UICollectionActivity:_onBtnRuleClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.collectionActivityRule)
    UIManager:getInstance():show("UIActivityRule")
end

function UICollectionActivity:_onBtnCloseClick()
    UIManager:getInstance():hide("UICollectionActivity")
end

-- 分享
function UICollectionActivity:_onBtnReceiveClick()
    local type = self._isVisible and game.globalConst.StatisticNames.collectionActivityReceive or game.globalConst.StatisticNames.collectionActivityShare
    game.service.DataEyeService.getInstance():onEvent(type)

    self:_addEventListener()
    local time = game.service.TimeService:getInstance():getCurrentTime()
    local day = tonumber(os.date("%d", time))
    local img = IMG[day] or "art/activity/fxlnh/share/28.jpg"
    share.ShareWTF.getInstance():share(share.constants.ENTER.SHARE_COLLECTION, {{res = img}})
end

function UICollectionActivity:_addEventListener()
    if self._isListening then
        return
    end
    if device.platform == 'android' then
        if self._listenerEnterForeground == nil then
            self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onShareAndroid))
        end
    else
        self:_onShare()        
    end
    self._isListening = true
end

function UICollectionActivity:_onShareAndroid()
    if self._isShared == true then
        return
    end
    self._isShared = true
    game.service.ActivityService.getInstance():sendCACMainSceneSharePickREQ()
end

function UICollectionActivity:_onShare()
    if self._isShared == true then
        return
    end

    self._isShared = true
    game.service.ActivityService.getInstance():getReceiveCard()
end

function UICollectionActivity:_removeEventListener()
    if not self._isListening then
        return
    end
    game.service.WeChatService.getInstance():removeEventListenersByTag(self)

    if self._listenerEnterForeground ~= nil then
        unlistenGlobalEvent(self._listenerEnterForeground)
        self._listenerEnterForeground = nil;
    end
end

function UICollectionActivity:onShow(isVisible)
    self._isShared = false
    self._isListening = false
    self._isVisible = isVisible
    self._btnReceive:setVisible(isVisible)
    self._btnShare:setVisible(not isVisible)
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UICollectionActivity:getGradeLayerId()
	return config.UIConstants.UI_LAYER_ID.Top
end

function UICollectionActivity:onHide()
    self:_removeEventListener()
end

function UICollectionActivity:needBlackMask() 
    return true
end

function UICollectionActivity:closeWhenClickMask()
    return false
end

return UICollectionActivity