local csbPath = "ui/csb/UILaunch.csb"
local super = require("app.game.ui.UIBase")

-- 更新状态文本
local STATE = {
    CHECK = "检测版本更新中...",
    UPDATE = "正在更新，请稍后...",
    FINISH = "更新完毕，祝您游戏愉快",
    LOAD = "资源加载中...",
}

local UILaunch = class("UILaunch", super, function() return kod.LoadCSBNode(csbPath) end)

local BAR_GLOW_MARGIN_X = 8
function UILaunch:ctor()
    super.ctor(self); 
    self._bg = ccui.Helper:seekNodeByName(self, "Panel_BG")
    self._bfj = ccui.Helper:seekNodeByName(self, "Panel_tx_launch")
    self._Image_Icon = ccui.Helper:seekNodeByName(self, "Image_Icon")
    self._LoadingBar_update = ccui.Helper:seekNodeByName(self, "LoadingBar_launch")             -- 进度条
    self._LoadingBar_background = ccui.Helper:seekNodeByName(self, "Image_pro_launch")          -- 进度条背景
    self._Text_launch = ccui.Helper:seekNodeByName(self, "Text_launch")                         -- 进度文本
    self._Text_state = ccui.Helper:seekNodeByName(self, "Text_state")                           -- 状态文本
    self._updateTips = ccui.Helper:seekNodeByName(self, "Panel_dw_Loading_2")                   -- 正在更新panel
    self._reviewVersionLoadingText = ccui.Helper:seekNodeByName(self, "TipText")                -- 资源加载文本(审核)
    self._checkVersionLoadingText = ccui.Helper:seekNodeByName(self, "Panel_check_loading")     -- 正在检查更新panel

    self._glowNode = ccui.Helper:seekNodeByName(self, "Image_img_tx_launch")                    -- 进度动画
    self._glowNodeWidth = self._glowNode:getContentSize().width
    self._reviewVersionLoadingText:setVisible(false)
    self._checkVersionLoadingText :setVisible(false)
    self._updateTips:setVisible(false)

    self._updateTips:stopAllActions()
    --[[
    self._updateTips:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeIn:create(45/60),
        cc.FadeOut:create(45/60)
    )))

    self._checkVersionLoadingText:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeIn:create(45/60),
        cc.FadeOut:create(45/60)
    )))
    ]]

    if GameMain.getInstance():isReviewVersion() then
        self._updateTips:setVisible(false)
        self._checkVersionLoadingText :setVisible(false)
        -- 
        --self._reviewVersionLoadingText:setVisible(true)
        self._Text_state:setString(STATE.LOAD)
    else
        -- 隐藏检查更新panel,替换为文本显示
        self._Text_state:setString(STATE.CHECK)
        self:setProgress(0)
        --self._checkVersionLoadingText :setVisible(true)
    end

    -- release_print("UILaunch~~~~~~~~~", game.service.GlobalSetting.getInstance():isFirstInGame(), cc.UserDefault:getInstance():getBoolForKey("First_to_update", false),cc.UserDefault:getInstance():getBoolForKey("First_to_updloadInfo", false))
    config.UrlConfig.getUploadFirstInUrl()
    --这个地方分开处理，不然可能会导致部分代码触发不了，又是要用更新前的标记位执行更新后的代码的问题~
    if cc.UserDefault:getInstance():getBoolForKey("First_to_update", false) == false and game.service.GlobalSetting.getInstance():isFirstInGame() then       
        cc.UserDefault:getInstance():setBoolForKey("First_to_update", true) 
        -- game.service.TDGameAnalyticsService.getInstance():login( game.plugin.Runtime.getDeviceId());
        if device.platform == "android" then
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_update_android);
            
        else
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_update_ios);
        end       
    end   
    if cc.UserDefault:getInstance():getBoolForKey("First_to_updloadInfo", false) == false and game.service.GlobalSetting.getInstance():isFirstInGame() then 
        cc.UserDefault:getInstance():setBoolForKey("First_to_updloadInfo", true) 
        local params = {
            log_time = kod.util.Time.nowMilliseconds(),
            channel = device.platform,
            deviceId = game.plugin.Runtime.getDeviceId(),
            playerId = game.service.LocalPlayerService.getInstance():getRoleId(),
            event_type = "first_in_update",
            areaid = game.service.LocalPlayerService.getInstance():getArea(),
        }
        kod.util.Http.uploadInfo(params, config.UrlConfig.getUploadFirstInUrl())
    end    
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UILaunch:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UILaunch:needBlackMask()
    return false
end

function UILaunch:onShow()
    Logger.debug("UILaunch:onShow")
    -- 测试更新进度
    --self:onShow_Debug()
    --do return end 

    game.service.GlobalSetting.getInstance():loadLaunchPicTextrue(seekNodeByName(self, "imgBackground", "ccui.ImageView"))
    self._LoadingBar_update:setPercent(0)
    self._LoadingBar_update:hide()
    self._LoadingBar_background:hide()
    self._Text_launch:hide()
    self._glowNode:hide()
    self._isShowProgress = false
    game.service.UpdateService.getInstance():start()
end

function UILaunch:onShow_Debug()
    self._LoadingBar_update:setPercent(0)
    self._LoadingBar_update:hide()
    self._LoadingBar_background:hide()
    self._Text_launch:hide()
    self._glowNode:hide()
    self._isShowProgress = false

    local counter = -1
    local taskId = nil
    math.newrandomseed()
    taskId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        --counter = counter + math.floor(math.random(1,50))
        counter = counter + 1
        if counter < 10 then 
            self._Text_state:setString(STATE.CHECK)
        elseif counter < 95 then 
            self._Text_state:setString(STATE.UPDATE)
        else 
            self._Text_state:setString(STATE.FINISH)
        end 

        self:setProgress(counter)
        if counter >= 100 then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(taskId)
            game.service.UpdateService.getInstance():done()
        end
    end, 1, false)
end 

function UILaunch:setProgress(percent)
    if not self._isShowProgress then
        self._isShowProgress = true
        self._LoadingBar_update:show()
        self._LoadingBar_background:show()
        self._Text_launch:show()
        self._glowNode:show()
    end
    local bar_bb = self._LoadingBar_update:getBoundingBox()
    local x = bar_bb.x + bar_bb.width * percent * 0.01
    if percent < 100 then
        self._glowNode:show()
        local p_for_glow = self._glowNode:getParent():convertToNodeSpace(cc.p(x, bar_bb.y))
        local x = p_for_glow.x + BAR_GLOW_MARGIN_X
        self._glowNode:setPositionX(x)
        if x < self._glowNodeWidth then
            self._glowNode:setScaleX(x / self._glowNodeWidth)
        else
            self._glowNode:setScaleX(1)
        end
    else
        self._glowNode:hide()
        self._Text_state:setString(STATE.FINISH)
    end

    self._LoadingBar_update:setPercent(percent)
    self._Text_launch:setString(string.format("%.1f%%", percent))
end

function UILaunch:hideCheckVersionText()
    -- 隐藏正在更新panel，替换为文本
    --self._updateTips:setVisible(true)
    self._Text_state:setString(STATE.UPDATE)
    self._checkVersionLoadingText:setVisible(false)
end

return UILaunch