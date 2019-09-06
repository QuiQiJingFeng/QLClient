-- 倒计时阶段
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/CollectCode/UICollectCodeCountDown.csb'
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local UICollectCodeCountDown = super.buildUIClass("UICollectCodeCountDown", csbPath)

function UICollectCodeCountDown:init()
    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COLLECT_CODE)
    
    self._btnBack = UtilsFunctions.seekButton(self, "Button_Back", handler(self, self._onBtnBackClick))
    self._btnHelp = UtilsFunctions.seekButton(self, "Button_Help", handler(self, self._onBtnHelpClick))
    self._btnMyCode = UtilsFunctions.seekButton(self, "Button_My_Code", handler(self, self._onBtnMyCodeClick))

    self._textCurrentPeriod = seekNodeByName(self, "Text_Current_Period", "ccui.Text")
    self._textSlogan = seekNodeByName(self, "Text_Slogan", "ccui.Text")
    self._textCurrentPeriod:setString("第" .. self._service:getCollectCodeInfo().period + 1 .. "期")
    self._textSlogan:setString(string.format("当前已获得%s组幸运码", self._service:getCodeCount()))
    self._textOpenCodeTime = seekNodeByName(self, "Text_Open_Code_Time", "ccui.Text")
    self._textStopTime = seekNodeByName(self, "Text_Stop_Time", "ccui.Text")

    self._textCountDown = seekNodeByName(self, "Text_Count_Down_Time", "ccui.Text")
    self._countDownTime = 0
    self._scheduleId = nil
end

function UICollectCodeCountDown:onShow()
    self._service:destroyAllActivityUIWithout(self.class.__cname)

    local openTimeMS = self._service:getCurrentOpenCodeTime()
    local nowMS = game.service.TimeService.getInstance():getCurrentTimeInMSeconds() -- 现在时刻
    self:startCountDown((openTimeMS - nowMS) * 0.001)
    self._textOpenCodeTime:setString("开奖时间: " .. self._service:getCurrentOpenCodeTime(true))
end

function UICollectCodeCountDown:onHide()
    self:stopCountDown()
end

function UICollectCodeCountDown:onDestroy()
    self:stopCountDown()
end

function UICollectCodeCountDown:startCountDown(countDownTime)
    self:stopCountDown()
    self._countDownTime = countDownTime
    self._scheduleId = scheduleUpdate(self._scheduleId, function()
        self._countDownTime = self._countDownTime - 1
        self:updateCountDownText()
    end, 1)
    self:updateCountDownText()
end

function UICollectCodeCountDown:updateCountDownText()
    local date = kod.util.Time.convertToDate(self._countDownTime * 1000)
    local str = date.hour .. "小时" .. date.minute .. "分" .. date.second .. "秒"
    self._textCountDown:setString("距离本期开奖还有" .. str)
    if self._countDownTime <= 0 then
        self:stopCountDown()
        if self._service then
            -- self._service:dispatchEvent({ name = "EVENT_COLLECT_CODE_COUNT_DOWN_OVER" })
            self._service:onCountDownOver()
        end
    end
end

function UICollectCodeCountDown:stopCountDown()
    self._scheduleId = unscheduleUpdate(self._scheduleId)
    self._countDownTime = 0
end

function UICollectCodeCountDown:_onBtnBackClick(sender)
    self:hideSelf()
end

function UICollectCodeCountDown:_onBtnHelpClick(sender)
    UIManager:getInstance():show("UICollectCodeHelp")
end

function UICollectCodeCountDown:_onBtnMyCodeClick(sender)
    self._service:sendCACCollectCodeQueryCodeREQ()
end

function UICollectCodeCountDown:needBlackMask() return true end


return UICollectCodeCountDown