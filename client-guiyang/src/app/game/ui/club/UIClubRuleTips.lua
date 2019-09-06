local csbPath = "ui/csb/Club/UIClubRuleTips.csb"
local super = require("app.game.ui.UIBase")
---@class UIClubRuleTips:UIBase
local UIClubRuleTips = super.buildUIClass("UIClubRuleTips", csbPath)

function UIClubRuleTips:ctor()

end

function UIClubRuleTips:init()
    self._btnClose = seekNodeByName(self, "Button_Close", "ccui.Button")
    self._testTips = seekNodeByName(self, "Text_Tips", "ccui.Text")
    self._testTimer = seekNodeByName(self, "Text_Timer", "ccui.Text")

    self._btnOk = seekNodeByName(self, "Button_ok", "ccui.Button")
    self._btnCancel = seekNodeByName(self, "Button_cancel", "ccui.Button")

    bindEventCallBack(self._btnOk, handler(self, self._onClickOk), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnClose, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnCancel, handler(self, self._onClickCancel), ccui.TouchEventType.ended)
end

function UIClubRuleTips:_onClickOk()
    if self._callBack ~= nil then
        self._callBack()
    end
    self:_onClickCancel()
end

function UIClubRuleTips:_onClickCancel()
    self:hideSelf()
end

function UIClubRuleTips:onShow(test, time, callBack)
    self._callBack = callBack
    self._time = time

    self._testTips:setString(test)
    self._testTimer:setString(string.format("%s秒后自动进入", self._time))
    self._timerScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self._time = self._time - 1
        if self._time <= 0 then
            self._callBack()
            self:_onClickCancel()
        else
            self._testTimer:setString(string.format("%s秒后自动进入", self._time))
        end
    end, 1, false)
end

function UIClubRuleTips:onHide()
    if self._timerScheduler then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerScheduler)
        self._timerScheduler = nil
    end
end

function UIClubRuleTips:needBlackMask()
    return true
end

function UIClubRuleTips:closeWhenClickMask()
    return false
end

function UIClubRuleTips:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Top
end

return UIClubRuleTips