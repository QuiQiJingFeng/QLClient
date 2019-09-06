---
--- 从俱乐部的活动按钮 或者 每日弹出的分享成功后 进入
---
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = 'ui/csb/Activity/Comeback/UIComeback_ClubManager_Lights.csb'
local LightOn_csbPath = 'ui/csb/Activity/Comeback/Light_On.csb'
local LightOff_csbPath = 'ui/csb/Activity/Comeback/Light_Off.csb'

local M = class("UIComeback_ClubManager_Lights", super, function() return kod.LoadCSBNode(csbPath) end)
function M:init()
    self._btnClose = seekButton(self, "Button_Close", handler(self, self._onBtnCloseClick))
    self._btnInvite = seekButton(self, "Button_Invite", handler(self, self._onBtnInviteClick))
    self._btnGetCard = seekButton(self, "Button_GetCard", handler(self, self._onBtnGetCardClick))
    self._btnRule = seekButton(self, "Button_Rule", handler(self, self._onBtnRuleClick))
    self._btnShowBindPlayers = seekButton(self, "Button_BindPlayer", handler(self, self._onBtnShowBindPlayersClick))

    self._textTimeToReset = seekNodeByName(self, "BMFont_TimeToReset", "ccui.TextBMFont")
    self._textLightCount = seekNodeByName(self, "BMFont_LightNum", "ccui.TextBMFont")
    self._textGetCardCount = seekNodeByName(self, "BMFont_CardNum", "ccui.TextBMFont")

    self._lvLights = seekNodeByName(self, "ListView", "ccui.ListView")
    self:_initLightTemplate(self._lvLights)

    self._service = game.service.activity.ActivityServiceManager.getInstance():getService(net.protocol.activityServerType.COME_BACK)
    if self._service then
        self._service:addEventListener("EVENT_ACTIVITY_COMEBACK_EXTRACT_CARD_SUCCEED", handler(self, self._onEvent), self)
    end
    self:playAnimation(csbPath, nil, true)
end

function M:onDestroy()
    if self._service then
        self._service:removeEventListenersByTag(self)
    end
    self:_destroyLightTemplate()
end

function M:onShow(msgBuffer)
    self._cardCount = msgBuffer.cacheCard
    self:_setTexts(msgBuffer)
    self:_pushLights(msgBuffer)

    -- 跳转到最后亮的那盏灯
    local lightIndex = msgBuffer.bindNum
    if lightIndex >= 3 then
        self._lvLights:jumpToItem(lightIndex, display.CENTER, display.CENTER)
    end

    -- 如果是最后的领取时间，隐藏部分控件
    if self._service then
        local v = not self._service:getIsInFinalRewardTime()
        self._textTimeToReset:setVisible(v)
        self._textLightCount:setVisible(v)
        self._btnInvite:setVisible(v)
        self._btnShowBindPlayers:setVisible(v)
    end
end

function M:onHide()
end

function M:_setTexts(msgBuffer)
    self._textGetCardCount:setString(msgBuffer.cacheCard)
    self._textTimeToReset:setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_TIME_TO_RESET_FORMAT, msgBuffer.leftResetDay))

    local lightCount = msgBuffer.bindNum
    if msgBuffer.shared then
        lightCount = lightCount + 1
    end
    self._textLightCount:setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_COUNT_FORMAT, lightCount))
end

function M:_pushLights(msgBuffer)
    self._lvLights:removeAllChildren()
    local isLightFirst = msgBuffer.shared
    local a1 = msgBuffer.increaseCard
    local an
    local d = msgBuffer.increaseCard
    local max = msgBuffer.cardLimit
    local lightCount = self:_getLightCount(a1, d, max)
    -- 先创建第一盏灯
    self:_createLight(1, a1, isLightFirst)
    -- 其他的从第二盏灯开始
    for lightIndex = 2, lightCount do
        an = a1 + (lightIndex - 1) * d
        self:_createLight(lightIndex, an, msgBuffer.bindNum >= (lightIndex - 1))
    end
end

function M:_getLightCount(a1, d, max)
    -- 进行等差数列算灯的数量
    -- 做个判断，避免死循环
    if d < 1 then
        Macro.assertFalse(false, 'd value should bigger or equals than 1')
        return 0
    end
    local sum = 0
    local n = 1
    local an
    while true do
        an = a1 + (n - 1) * d
        if sum + an > max then
            break
        end
        sum = sum + an
        n = n + 1
    end
    return n
end

function M:_createLight(i, cardCount, isOn)
    local temp, itemCsbPath
    if isOn then
        itemCsbPath = LightOn_csbPath
    else
        itemCsbPath = LightOff_csbPath
    end
    temp = cc.CSLoader:createNode(itemCsbPath)
    if i == 1 then
        seekNodeByName(temp, "BMFont", "ccui.TextBMFont"):setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_CARD_COUNT_FORMAT_FIRST, cardCount))
    else
        seekNodeByName(temp, "BMFont", "ccui.TextBMFont"):setString(string.format(config.STRING.ACTIVITY_COMEBACK_LIGHT_CARD_COUNT_FORMAT, cardCount))
    end
    local layout = seekNodeByName(temp, "Layout", "ccui.Layout")
    layout:removeFromParent()
    self._lvLights:pushBackCustomItem(layout)
    -- 先注释掉这个，看会不会看崩溃
    -- self.playAnimation(layout, LightOff_csbPath, nil, true)
end

function M:_initLightTemplate(parentListView)
    if self._onTemplate == nil then
        self._onTemplate = parentListView:getItem(0) -- 开模板
        self._onTemplate:retain()
        self._onTemplate:removeFromParent()
    end
    if self._offTemplate == nil then
        self._offTemplate = parentListView:getItem(1) -- 关模板
        self._offTemplate:retain()
        self._offTemplate:removeFromParent()
    end
    parentListView:removeAllChildren()
end

function M:_destroyLightTemplate()
    if self._offTemplate then
        self._offTemplate:release()
    end
    self._offTemplate = nil

    if self._onTemplate then
        self._onTemplate:release()
    end
    self._onTemplate = nil
end

function M:_onBtnCloseClick(sender)
    if self._service then
        local isFinalRewardTime = self._service:getIsInFinalRewardTime()
        -- 如果在最后的领取时间内的话，就不弹出提示了
        if not isFinalRewardTime then
            self._service:managerLeaveTip(handler(self, self.hideSelf))
            return
        end
    end
    
    self:hideSelf()
end

function M:_onBtnInviteClick(sender)
    if self._service then
        -- 显示了这个界面则一定是 manager
        self._service:comebackShare(true)
    end
end

function M:_onBtnGetCardClick(sender)
    if self._service then
        self._service:sendCACBackExtractCardREQ()
    end
end

function M:_onBtnRuleClick(sender)
    UIManager:getInstance():show("UIComeback_Rule", true)
end

function M:_onBtnShowBindPlayersClick(sender)
    if self._service then
        self._service:sendCACBackCheckBindUserREQ()
    end
end

function M:_onEvent(event)
    if event.name == "EVENT_ACTIVITY_COMEBACK_EXTRACT_CARD_SUCCEED" then
        self._textGetCardCount:setString(event.data)
    end
end

function M:needBlackMask() return true end

return M