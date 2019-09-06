local csbPath = "ui/csb/Club/UIClubPushGuidance.csb"
local super = require("app.game.ui.UIBase")
local UIClubPushGuidance = class("UIClubPushGuidance", super, function() return kod.LoadCSBNode(csbPath) end)

function UIClubPushGuidance:ctor()
end

function UIClubPushGuidance:init()
    self._btnNotWilling = seekNodeByName(self, "Button_notWilling", "ccui.Button") -- 不愿意
    self._btnWilling = seekNodeByName(self, "Button_willing", "ccui.Button") -- 愿意

    bindEventCallBack(self._btnNotWilling, handler(self, self._onBtnNotWillingClick), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnWilling, handler(self, self._onBtnWillingClick), ccui.TouchEventType.ended)
end

-- 不愿意
function UIClubPushGuidance:_onBtnNotWillingClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.btn_club_push_notWilling)

    game.ui.UIMessageBoxMgr.getInstance():show("这将使您在离线时错过亲友圈牌局邀请,确定要拒收吗？" , {"坚决拒收", "我再想想"},
        function ()
            -- 设置界面的推送按钮变为关
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.btn_club_push_refuse)

            game.service.LocalPlayerSettingService:getInstance():setEffectValues({effect_ClubPush = false})
            game.service.LocalPlayerSettingService:getInstance():saveSetting()
            -- getEffectValues
            UIManager:getInstance():hide("UIClubPushGuidance")
        end,
        function ()
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.btn_club_push_hesitate)
        end
    )
end

-- 愿意
function UIClubPushGuidance:_onBtnWillingClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.btn_club_push_willing)

    -- 判断推送权限是否开启
    if game.plugin.Runtime.notificationsEnabled() == nil or game.plugin.Runtime.notificationsEnabled() == 0 then
        -- 没有开启
        game.ui.UIMessageBoxMgr.getInstance():show("接收离线邀请需要开启“通知”权限" , {"去开启", "取消"}, function ()
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.btn_club_push_open)
            game.plugin.Runtime.openSetting()
        end)
    else
        -- 通知权限已经开启
        -- 设置界面的推送按钮变为开
        game.service.LocalPlayerSettingService:getInstance():setEffectValues({effect_ClubPush = true})
        game.service.LocalPlayerSettingService:getInstance():saveSetting()
        UIManager:getInstance():hide("UIClubPushGuidance")
    end
end

function UIClubPushGuidance:onShow()
    self:_talkingData("clubPush_onShow")
end

function UIClubPushGuidance:onHide()
    self:_talkingData("clubPush_onHide")
end

function UIClubPushGuidance:_talkingData(str)
    local text = ""
    if game.plugin.Runtime.notificationsEnabled() == nil or game.plugin.Runtime.notificationsEnabled() == 0 then
        text = string.format("%s_on", str)
    else
        text = string.format("%s_off", str)
    end
    if text == "" then
        return
    end
    game.service.DataEyeService.getInstance():onEvent(text)
end

function UIClubPushGuidance:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

function UIClubPushGuidance:needBlackMask()
    return true
end

function UIClubPushGuidance:closeWhenClickMask()
    return false
end

return UIClubPushGuidance