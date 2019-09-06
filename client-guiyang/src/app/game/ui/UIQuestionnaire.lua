--[[	有奖问卷UI
]]
local csbPath = "ui/csb/UIPapers.csb"
local super = require("app.game.ui.UIBase")
local M = class("UIQuestionnaire", super, function() return kod.LoadCSBNode(csbPath) end)


function M:ctor()
    self._btnOpen = nil
    self._btnClose = nil
    self._url = nil
    self._btnReward = nil
end

-- 初始化所有的控件
function M:init()
    self._btnOpen = seekNodeByName(self, "Button_btn_Papers", "ccui.Button")
    self._btnClose = seekNodeByName(self, "Button_x_papers", "ccui.Button")
    self._btnReward = seekNodeByName(self, "Button_btn_lqjl", "ccui.Button")
    self.ruleInfo = seekNodeByName(self, "listTextItem_z_Papers", "ccui.Text")
    self:_registerCallBack()
end

-- 注册所有控件的监听
function M:_registerCallBack()
    bindEventCallBack(self._btnOpen,    handler(self, self._onOpen),        ccui.TouchEventType.ended);
    bindEventCallBack(self._btnClose,    handler(self, self._onClose),        ccui.TouchEventType.ended);
    bindEventCallBack(self._btnReward,    handler(self, self._onLingQu),            ccui.TouchEventType.ended);
end

function M:onShow(buffer)
    Logger.debug("Questionnaire, UIQuestionnaire OnShow")
    dump(buffer)
    local activityService = game.service.ActivityService.getInstance()
    local jumpVisible = not activityService:isQuestionnaireDone() -- 跳转webView
    local rewardVisible = activityService:isQuestionnaireDone() and (not activityService:isQuestionnaireRewardReceived()) -- 领奖

    self._btnOpen:setVisible(jumpVisible)
    self._btnReward:setVisible(rewardVisible)
    self._url = buffer.url

    local text = ''
    if rewardVisible then
        text = string.format(config.STRING.UI_QUESTIONNAIRE_STRING_100, buffer.reward)
    else
        text = string.format(config.STRING.UI_QUESTIONNAIRE_STRING_101, buffer.reward)
    end

    self.ruleInfo:setString(text)
end

function M:onHide()
    game.service.ActivityService.getInstance():removeEventListenersByTag(self)
end

function M:_onOpen()
    if self._url ~= nil then
        game.service.WebViewService.getInstance():openWebView(self._url);
        self:_onClose()
    end
end

function M:_onClose()
    self:onHide()
    self:destroySelf()
end

-- 请求领取问卷调查奖励
function M:_onLingQu()
    game.service.ActivityService.getInstance():sendCACQuestionnaireRewardREQ()
    self:_onClose()
end

function M:needBlackMask()
    return true
end

function M:closeWhenClickMask()
    return true
end

return M

