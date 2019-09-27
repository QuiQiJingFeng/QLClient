local csbPath = "ui/csb/UILogin.csb"
local super = require("app.game.ui.UIBase")
local Version = require "app.kod.util.Version"
local UILogin = class("UILogin", super, function() return kod.LoadCSBNode(csbPath) end)

function UILogin:ctor()
    super.ctor(self);
    self._btnLoginGuest = nil;
    self._checkBoxAgreed = nil;
    self._textFieldIP = nil;
    self._textFieldPort = nil;
end

-- 获取显示大层层级,需要修改默认层级的，覆盖这个函数
function UILogin:getGradeLayerId()
    return config.UIConstants.UI_LAYER_ID.Bottom;
end

function UILogin:init()
    self._btnLaunch = seekNodeByName(self, "Button_wxdl_launch", "ccui.Button");
    self._btnLoginGuest = seekNodeByName(self, "Button_ykdl_launch", "ccui.Button");
    self._checkBoxAgreed = seekNodeByName(self, "CheckBox_launch", "ccui.CheckBox");
    self._textFieldIP = seekNodeByName(self, "TextField_IP", "ccui.TextField");
    self._textFieldUsername = seekNodeByName(self, "TextField_Username", "ccui.TextField")
    self._agreementPanel = seekNodeByName(self, "Panel_Agree_launch", "ccui.Layout")
    self._versionBuild = seekNodeByName(self, "versionBuild", "ccui.Text")
    self._spriteFeedback        = seekNodeByName(self, "Sprite_Feekback", "cc.Sprite")
    self._btnFixGame = seekNodeByName(self, "Button_fixgame", "ccui.Button")
    self._btnLoginMetod = seekNodeByName(self, "Button_loginMetod", "ccui.Button")

    -- 玩家是否已经登录成功，登录成功后正在登录字样不消失
    self._textTip = seekNodeByName(self, "LoginTip", "ccui.Layout")
    self._textTip:hide()
    self._spriteFeedback:setGlobalZOrder(65535)

    game.service.LoginService.getInstance():addEventListener("EVENT_AGREEMENT_CHANGED", handler(self, self._agreementChanged), self)
    -- release_print("UILogin~~~~~~~~~", game.service.GlobalSetting.getInstance():isFirstInGame(), cc.UserDefault:getInstance():getBoolForKey("First_to_login", false))
    if cc.UserDefault:getInstance():getBoolForKey("First_to_login", false) == false and game.service.GlobalSetting.getInstance():isFirstInGame() then
        cc.UserDefault:getInstance():setBoolForKey("First_to_login", true) 
        -- game.service.TDGameAnalyticsService.getInstance():login( game.plugin.Runtime.getDeviceId());
        if device.platform == "android" then
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_login_android);
        else
            game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.first_in_login_ios);
        end

        local params = {
            log_time = kod.util.Time.nowMilliseconds(),
            channel = device.platform,
            deviceId = game.plugin.Runtime.getDeviceId(),
            playerId = game.service.LocalPlayerService.getInstance():getRoleId(),
            event_type = "first_in_login",
            areaid = game.service.LocalPlayerService.getInstance():getArea(),
        }
        kod.util.Http.uploadInfo(params, config.UrlConfig.getUploadFirstInUrl())
    end
end

--析构函数
function UILogin:destroy()
    --释放内存
    game.service.LoginService.getInstance():removeEventListenersByTag(self)
end

function UILogin:_registerCallBack()
    bindEventCallBack(self._btnLoginGuest, handler(self, self._onTapGuestLogin), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnLaunch, handler(self, self._onTapWeiXinLogin), ccui.TouchEventType.ended);
    bindEventCallBack(self._agreementPanel, handler(self, self._onAgreement), ccui.TouchEventType.ended);
    bindEventCallBack(self._btnFixGame, handler(self, self._onGameFix), ccui.TouchEventType.ended)
    bindEventCallBack(self._btnLoginMetod, handler(self, self._onLoginMetodClick), ccui.TouchEventType.ended)

    local listener = cc.EventListenerTouchOneByOne:create()
    local dispatcher = self._spriteFeedback:getEventDispatcher()
    listener:registerScriptHandler(handler(self, self._onSpriteFeedbackTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self._onSpriteFeedbackTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self._spriteFeedback)
    self.globalBusyListener = listenGlobalEvent("EVENT_NOT_IN_SERVICE", function()
        self._textTip:hide()
    end)
end

function UILogin:onShow(...)
    -- self._textTip:hide()
    -- game.service.GlobalSetting.getInstance():loadLaunchPicTextrue(seekNodeByName(self, "imgBackground", "ccui.ImageView"))
    -- self._btnLoginMetod:setVisible(true)
    -- --提审相关（微信按钮隐藏）
    -- if GameMain.getInstance():isReviewVersion() then
    --     self._textFieldIP:setVisible(false)
    --     self._textFieldUsername:setVisible(false)
    --     self._btnLaunch:setVisible(false)
    --     self._btnLoginGuest:setVisible(true)
    --     self._textFieldUsername:setString("");
    --     self._spriteFeedback:setVisible(false)
    --     self._btnLoginMetod:setVisible(false)
    -- elseif game.plugin.Runtime.isEnabled() then
    --     self._textFieldIP:setVisible(false)
    --     self._textFieldUsername:setVisible(false)
    --     self._btnLaunch:setVisible(true)
    --     self._btnLoginGuest:setVisible(false)
    --     self._textFieldUsername:setString("");
    -- else
    --     self._textFieldIP:setVisible(true)
    --     self._textFieldUsername:setVisible(true)
    --     self._btnLaunch:setVisible(true)
    --     self._btnLoginGuest:setVisible(false)
    --     self._textFieldUsername:setString(game.service.LoginService.getInstance():getGuestAccount());
    -- end

    -- self._action = cc.CSLoader:createTimeline(csbPath)
    -- self:runAction(self._action)
    -- self:setVersion()

    -- -- 尝试自动登录
    -- if game.service.LoginService.getInstance():needAutoLogin() and game.plugin.Runtime.isEnabled() then
    --     self._action:play("animation1", false)
    --     self:_login()
    --     self._btnFixGame:setVisible(false) -- 自动登录不显示修复客户端
    -- else
    --     self._action:gotoFrameAndPlay(0, false)
    -- end

    -- -- 暂时屏蔽
    -- self._btnFixGame:setVisible(false)

    -- -- 显示不同的游戏名称(产品说不需要代码暂时注释)
    -- -- self:showAreaName();	
    -- --控制反馈按钮的显隐，潮汕没有这个按钮
    -- if config.GlobalConfig.getIsShowFeedback() == false then
    --     self._spriteFeedback:setVisible(false);
    --     self._spriteFeedback:setPosition(cc.p(-0xFFFF, -0xFFFF))
    -- end

    -- self:_registerCallBack()

    -- config.configHelper.refreshAllConfigs()
    -- local service = game.service.UserEventService:getInstance()

    
end

function UILogin:onHide()
    local dispatcher = self._spriteFeedback:getEventDispatcher()
    dispatcher:removeEventListenersForTarget(self._spriteFeedback)
    unlistenGlobalEvent(self.globalBusyListener)
end

-- 显示各个地区的游戏名称,如果本地有存储就读取本地的，否则按照当前的默认的areaid来显示登录页游戏名称
-- 注意 ：在取area时从localplayerservice取而不要从login里取，login的只是作为缓存上一次登录的地区以防在login的时候localplayerservice没初始化
function UILogin:showAreaName()
    local lastSelAreaId = game.service.LoginService.getInstance():getSavedareaId();
    local area = config.GlobalConfig.getConfigArea(lastSelAreaId);
    local areaId = area and lastSelAreaId or nil;
    if areaId == nil then
        areaId = config.GlobalConfig.getConfig().AREA_ID;
    end
    if areaId == 10001 then		-- 毕节
        self._sprGameName:loadTexture("art/fm/icon_fbt.png")
    elseif areaId == 10004 then -- 安顺
        self._sprGameName:loadTexture("art/fm/icon_fbt2.png")
    elseif areaId == 10005 or areaId == 10002 then
        self._sprGameName:loadTexture("art/fm/icon_fbt3.png")
    elseif areaId == 10003 then
        self._sprGameName:loadTexture("art/fm/icon_fbt4.png")
    else 	-- 默认毕节
        self._sprGameName:loadTexture("art/fm/icon_fbt.png")
    end
end

-- 检查用户协议相关，如果登陆的时候没有选中，提示
-- 如果第一次弹出没有确认过的话，也提示
function UILogin:_checkAgreement()
    -- 提审的时候，不主动弹出这个用户协议
    -- if not game.service.LoginService:getInstance():isAcceptAgreement() and not GameMain.getInstance():isReviewVersion() then
    -- 	UIManager:getInstance():show("UIAgreementOnLogin")
    -- 	return false
    -- end
    if not self._checkBoxAgreed:isSelected() then
        --game.ui.UIMessageBoxMgr.getInstance():show("请同意用户协议！", { "确定" })
        game.ui.UIMessageTipsMgr.getInstance():showTips("请同意用户协议！")
        return false
    end
    return true
end

function UILogin:_login()
    --local _ip = self._textFieldIP:getText();
    if not self:_checkAgreement() then return end

    game.service.LoginService.getInstance():startLogin(self._textFieldUsername:getString(), false, 0);

    self._textTip:stopAllActions()
    self._textTip:hide()
    -- 隐藏正在登录中
    --[[
    self._textTip:runAction(cc.RepeatForever:create(cc.Sequence:create(
    cc.FadeIn:create(45/60),
    cc.FadeOut:create(45/60)
    )))
    self._textTip:show()
    ]]
end

function UILogin:setVersion()
    -- 运行库版号和产品版号合在一起了
    local runversion = Version.new(game.plugin.Runtime.getBuildVersion())
    runversion._versions[4] = game.service.UpdateService.getInstance():getProductVersion():getVersions()[1]
    self._versionBuild:setString(runversion:toString())

    game.service.UserEventService.getInstance():initVersion()
end

function UILogin:_onTapGuestLogin(sender)
    self:_login();
end

function UILogin:_onTapWeiXinLogin(sender)
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Login_Wechat)
    self:_onTapGuestLogin()
end

-- 用户协议
function UILogin:_onAgreement()
    UIManager:getInstance():show("UIAgreement")
end

function UILogin:_onSpriteFeedbackTouchBegan(touch, event)
    local location = touch:getLocation()
    location = self._spriteFeedback:getParent():convertToNodeSpace(location)
    if cc.rectContainsPoint(self._spriteFeedback:getBoundingBox(), location) then
        self._spriteFeedback:setScale(1.2)
        return true
    end
end

function UILogin:_onSpriteFeedbackTouchEnded(touch, event)
    local location = touch:getLocation()
    location = self._spriteFeedback:getParent():convertToNodeSpace(location)
    self._spriteFeedback:setScale(1.0)
    if cc.rectContainsPoint(self._spriteFeedback:getBoundingBox(), location) then
        game.service.MeiQiaService:getInstance():openMeiQia()
    end
end

function UILogin:_agreementChanged(event)
    self._checkBoxAgreed:setSelected(event.agreement)
end

function UILogin:_onGameFix()
    -- 统计登录页修复游戏次数
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.LoginFix_Click)

    game.ui.UIMessageBoxMgr.getInstance():show("点击修复游戏会重新加载游戏资源，是否确认修复？", { "确定", "取消" }, function()
        game.service.UpdateService.getInstance():clearDownloadedData()
    end, function()
    end,
    true)
end

function UILogin:_onLoginMetodClick()
    game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Login_Method)
    if not self:_checkAgreement() then return end

    UIManager:getInstance():show("UILoginMethod")
end

return UILogin;