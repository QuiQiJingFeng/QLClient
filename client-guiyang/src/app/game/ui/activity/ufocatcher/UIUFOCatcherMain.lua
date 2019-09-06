local DollLevelSequence = { 1, 2, 1, 3, 1, 2 }
local HookCSB = {
    [1] = "csb/Activity/UFOCatcher/Hooks/Hook_1.csb",
    [2] = "csb/Activity/UFOCatcher/Hooks/Hook_2.csb",
}
local CSBAnimationHelper = require("app.game.util.CSBAnimationHelper")
local Doll = require("app.game.ui.activity.ufocatcher.Doll")
local Catcher = require("app.game.ui.activity.ufocatcher.Catcher")
local UtilsFunctions = require("app.game.util.UtilsFunctions")
local seekButton = UtilsFunctions.seekButton
local super = require("app.game.ui.UIBase")
local csbPath = "csb/Activity/UFOCatcher/UIUFOCatcherMain.csb"
---@class UIUFOCatcherMain:UIBase
local UIUFOCatcherMain = super.buildUIClass("UIUFOCatcherMain", csbPath)
function UIUFOCatcherMain:init()
    ---@type UFOCatcherActivityService
    self._service = game.service.activity.ActivityServiceManager:getInstance():getService(net.protocol.activityServerType.UFO_CATCHER)
    local eventHandler = handler(self, self._onEvent)
    self._service:addEventListener("ACCCatchDollRES", eventHandler, self)
    self._service:addEventListener("ACCBuyCatchDollRES", eventHandler, self)
    -- close button
    UtilsFunctions.attachCloseButton(self, true)

    -- remain time text
    self._txtRemainTimes = seekNodeByName(self, "Text_Remain_Times")

    -- help button
    seekButton(self, "Button_Help", function()
        UIManager:getInstance():show("UIUFOCatcherHelp")
    end)

    -- record button
    seekButton(self, "Button_Record", function()
        self._service:sendCACCatchRecordREQ()
    end)

    -- chance list button
    seekButton(self, "Button_Chance", function()
        self._service:sendCACCatchDollTaskREQ()
    end)

    -- catch button
    seekButton(self, "Button_Catch", function()
        if not self._catcher:isCatching() then
            if self:_useOneHook() then
                -- 开始抓起
                self._touchLayout:show()
                local success = self._catcher:startCatch()
                local catchType = 0
                if success then
                    local doll = self._catcher:getCurrentCatchDoll()
                    if doll then
                        catchType = doll.level
                    end
                end
                self._service:sendCACCatchDollREQ({
                    isCatch = success,
                    type = catchType
                })
            end
        else
            UIManager:getInstance():show("UIUFOCatcherAlert")
        end
    end)

    self._pressedLeft = seekNodeByName(self, "Pressed_Left")
    self._pressedLeft:hide()
    self._pressedRight = seekNodeByName(self, "Perssed_Right")
    self._pressedRight:hide()
    -- move controller
    UtilsFunctions.registerPressTouchEvent(seekNodeByName(self, "Release_Left"),
            function()
                self._pressedLeft:show()
            end,
            function()
                self._catcher:move("left")
            end,
            function()
                self._pressedLeft:hide()
            end)
    -- move controller
    UtilsFunctions.registerPressTouchEvent(seekNodeByName(self, "Release_Right"),
            function()
                self._pressedRight:show()
            end,
            function()
                self._catcher:move("right")
            end,
            function()
                self._pressedRight:hide()
            end)

    -- UFO catcher container
    -- UFO anchors
    self._catcherContainer = seekNodeByName(self, "Catcher_Container")
    self._positions = {
        rightMaxPosition = cc.p(seekNodeByName(self, "Right_Max"):getPosition()),
        leftMaxPosition = cc.p(seekNodeByName(self, "left_Max"):getPosition()),
        safeDropDownPosition = cc.p(seekNodeByName(self, "Safe_Drop_Down"):getPosition()),
        ufoSpawnPosition = cc.p(seekNodeByName(self, "UFO_Spawn"):getPosition()),
        successPosition = cc.p(seekNodeByName(self, "Success_Position"):getPosition()),
    }

    self:_createCatcher()

    self._loopAnimationHelper = CSBAnimationHelper.new(self, csbPath)
    self._entranceAnimationHelper = CSBAnimationHelper.new(self, csbPath)

    self._loopAnimationHelper:playAnimationByName("loop", true)

    --- 一个遮挡触摸层
    self._touchLayout = ccui.Layout:create()
    self._touchLayout:setContentSize(self:getContentSize())
    self._touchLayout:setTouchEnabled(true)
    self:addChild(self._touchLayout)
    self._touchLayout:hide()
end

function UIUFOCatcherMain:onShow(buffer)
    self._silverHookCount = buffer.catchCounts
    self._goldenHookCounts = buffer.goldCatchCounts or 0
    self:_refreshHook()
    self:_refreshCountText()

    self._catcher:destroyCloneDoll()
    self._catcher:startRollDolls()
end

function UIUFOCatcherMain:onHide()

end

function UIUFOCatcherMain:onDestroy()
    if self._catcher then
        self._catcher:destroy()
    end
    self._service:removeEventListenersByTag(self)
end

-- create catcher and set information
function UIUFOCatcherMain:_createCatcher()
    if self._catcher == nil then
        self._catcher = Catcher.new(self._catcherContainer)
        self._catcher:setSpawnPosition(self._positions.ufoSpawnPosition)
        self._catcher:setMovableMax(self._positions.leftMaxPosition.x, self._positions.rightMaxPosition.x)
        self._catcher:setSafeDropDownPosition(self._positions.safeDropDownPosition)
        self._catcher:setSuccessPosition(self._positions.successPosition)
        self._catcher:setCatchPercentFunction(function(percent)
            if percent > 0 and percent <= 0.6 then
                return "success"
            end
            return "failure"
        end)

        self:_creteDolls()
        self._catcher:setDollsInfo(self._dolls, self._dolls[1]:getSize())
        self._catcher:reset()
        self._catcher:setOnCatchDownCallback(handler(self, self._onCatchDownCallback))
        self._catcher:setOnCatchUpCallback(handler(self, self._onCatchUpCallback))
        self._catcher:setOnCatchFailureCallback(handler(self, self._onCatchFailureCallback))
        self._catcher:setOnCatchSuccessCallback(handler(self, self._onCatchSuccessCallback))
        self._catcher:setOnCatchHalfWayFailureCallback(handler(self, self._onCatchHalfWayFailureCallback))
    else
        self._catcher:reset()
    end
end

function UIUFOCatcherMain:_refreshHook()
    if self._catcher then
        if self._goldenHookCounts > 0 then
            self._catcher:createHook(2, HookCSB[2])
            for _, doll in ipairs(self._dolls) do
                doll:changeLevel(3)
            end
        else
            self._catcher:createHook(1, HookCSB[1])
            for idx, doll in ipairs(self._dolls) do
                doll:changeLevel(DollLevelSequence[idx])
            end
        end
    end
end

function UIUFOCatcherMain:_creteDolls()
    if self._dolls then
        return
    end
    -- doll positions
    ---@type Doll[]
    self._dolls = {}
    for i = 1, 6, 1 do
        local dollPos = cc.p(seekNodeByName(self._catcherContainer, "Item_Position_" .. i):getPosition())
        local dollObject = Doll.new(DollLevelSequence[i])
        self._catcherContainer:addChild(dollObject)
        dollObject:setPosition(dollPos)
        table.insert(self._dolls, dollObject)
    end
end

function UIUFOCatcherMain:_refreshCountText()
    self._txtRemainTimes:setStringFormat("%s", self._goldenHookCounts + self._silverHookCount)
end

---@return boolean 是否可以使用
function UIUFOCatcherMain:_useOneHook()
    if self._goldenHookCounts > 0 then
        self._goldenHookCounts = math.abs(self._goldenHookCounts - 1)
        return true
    elseif self._silverHookCount > 0 then
        self._silverHookCount = math.abs(self._silverHookCount - 1)
        return true
    else
        UIManager:getInstance():show("UIUFOCatcherAlert")
        return false
    end
    self:_refreshCountText()
end

function UIUFOCatcherMain:_onCatchDownCallback()
    Logger.debug("onCatchDownCallback")
end

function UIUFOCatcherMain:_onCatchUpCallback()
    Logger.debug("onCatchUpCallback")
end

function UIUFOCatcherMain:_onCatchFailureCallback()
    Logger.debug("onCatchFailureCallback")
    UIManager:getInstance():show("UIUFOCatcherFailed", {
        isHalfwayFailed = false,
        callback = handler(self, self._onFinish)
    })
end

function UIUFOCatcherMain:_onCatchSuccessCallback()
    Logger.debug("onCatchSuccessCallback")
    if self._currentCatchRES then
        UIManager:getInstance():show("UIUFOCatcherSuccess", {
            buffer = self._currentCatchRES:getBuffer(),
            callback = handler(self, self._onFinish)
        })
    end
end

function UIUFOCatcherMain:_onCatchHalfWayFailureCallback()
    Logger.debug("onCatchHalfWayFailureCallback")
    UIManager:getInstance():show("UIUFOCatcherFailed", {
        isHalfwayFailed = true,
        callback = handler(self, self._onFinish)
    })
end

function UIUFOCatcherMain:_onFinish()
    self._catcher:destroyCloneDoll()
    self._catcher:startRollDolls()
    self._catcher:replaceToSpawnPosition()
    self:_refreshCountText()
    self:_refreshHook()
    self._touchLayout:hide()
end

function UIUFOCatcherMain:_onEvent(event)
    if event.name == ("ACCCatchDollRES"):upper() then
        ---@type NetworkResponse
        self._currentCatchRES = event.response
        ---现在有一个问题是，当接收到这个消息的时候，不知道是否应该里面去显示
        ---存在歧义
        ---一是： 消息接收时，夹子还未处于等待状态，如果直接使用，会很突兀
        ---二是： 消息接收时，夹子已经处理等待状态了，需要直接使用
        ---如果正在等待消息，就直接执行结果
        ---如果还未等待消息，就等Catcher自己执行这个结果
        ---总结，把结果直接扔给catcher，由他决定什么时候执行
        if self._currentCatchRES:getRequest():getBuffer().isCatch then
            ---如果之前本地的判断是抓住了
            self._catcher:setWaitResult(self._currentCatchRES)
        else
            --- do nothing
        end
    elseif event.name == ("ACCBuyCatchDollRES"):upper() then
        if event.response:isSuccessful() then
            self._goldenHookCounts = self._goldenHookCounts + 1
            self:_refreshCountText()
            self:_refreshHook()
            game.ui.UIMessageBoxMgr.getInstance():show("购买成功", { "确认" }, function()
            end)
        else
            UIManager:getInstance():show("UIUFOCatcherTip")
        end
    end
end

function UIUFOCatcherMain:needBlackMask()
    return true
end

return UIUFOCatcherMain