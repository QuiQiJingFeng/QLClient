local ns = namespace("game.service")

local GlobalSetting = class("GlobalSetting")
ns.GlobalSetting = GlobalSetting

local _instance = nil;

function GlobalSetting.getInstance()
    if _instance == nil then
        _instance = manager.LocalStorage.getGlobalData("GlobalSettings", GlobalSetting)
        -- local hasSetting =  game.service.LoginService.getInstance():_hasCachedLoginInfo()
        -- local firstin = cc.UserDefault:getInstance():getStringForKey("FirstIn", "")
        -- if firstin == "" and hasSetting then
        --     _instance._isFirstInGame = false
        --     cc.UserDefault:getInstance():setStringForKey("FirstIn", "false")
        -- elseif firstin == "" and not hasSetting then
        --     _instance._isFirstInGame = true
        --     cc.UserDefault:getInstance():setStringForKey("FirstIn", "true")
        -- elseif firstin == "true" then
        --     _instance._isFirstInGame = true
        --     cc.UserDefault:getInstance():setStringForKey("FirstIn", "false")
        -- else
        --     _instance._isFirstInGame = false
        -- end               
        local hasSetting =  game.service.LoginService.getInstance():_hasCachedLoginInfo()
        _instance._isFirstInGame = cc.UserDefault:getInstance():getBoolForKey("First_In", true) and not hasSetting
        cc.UserDefault:getInstance():setBoolForKey("First_In", false)
    end

    if game.plugin.Runtime.isCommentSupported() and _instance.firstLoginTime == nil then
        --系统时间
        local nowtime = math.ceil(kod.util.Time.now())
        _instance.firstLoginTime = nowtime;
        _instance:saveSetting();
    end

    return _instance
end

function GlobalSetting:ctor()
    -- 背景音量
    self.bgmVolume = -1;
    -- 音效音量
    self.sfxVolume = -1;
    --0普通话，其他为地方话
    self.userDialect = 1;

    --是否提示过需要更新
    self.versionPromptTime = 0
    --今天已经购买过的钻石类型
    self.hasShoppedType = { dateKey = "", data = {} };

    --ios评价功能相关,记录第一次登录游戏的时间
    self.firstLoginTime = nil;
    --ios评价功能相关,记录弹窗弹出次数(如果3次没有评价就不需要再弹了)
    self.assessShowCount = 0;

    -- 测试用, 2D3D开关         -- by 赵杰
    self.is3D = nil;
    self.launchPicUrl = ''
    self.isShowLaunchPic = false
    self.isClassic = false -- 经典模式

    self.enableMoreShare = false  -- 更多分享开关
    self.settingFeaturesRedCache = true -- 设置界面功能栏的红点显示
    -- self.lastLaunchPicUrl = ''
    -- -- 碰杠提示
    -- self.effect_PengGangTiShi = false
    -- -- 出牌提示
    -- self.effect_ChuPaiTiShi = false
    -- -- 出牌放大
    -- self.effect_ChuPaiTingLiu = false
    -- -- 推送开关
    -- -- self.effect_TuiSongKaiGuan = false -- 该信息存储在 PushService中
    -- -- 斜插牌
    -- self.effect_XieChaPai = false
    -- 桌布选择
    -- self.desktop_BG_index = 1 -- 该信息存储在 localPlayerService中
    -- 牌面选择
    -- self.card_BG_index = 1 -- 该信息存储在 localPlayerService中


    self._isFirstInGame = false      --是否是第一次进游戏
end

function GlobalSetting:saveSetting()
    manager.LocalStorage.setGlobalData("GlobalSettings", self)
end

function GlobalSetting:setLaunchPicUrl(url, visible)
    visible = visible or false
    self.isShowLaunchPic = visible
    -- if url ~= self.launchPicUrl then
    --     self.lastLaunchPicUrl = self.launchPicUrl
    -- end
    self.launchPicUrl = url
    Logger.debug("GlobalSetting: launch pictrue url : " .. tostring(self.launchPicUrl))
    -- Logger.debug("GlobalSetting: launch last pictrue url : " .. tostring(self.lastLaunchPicUrl))
    if url == '' or url == nil then
        return
    end
    -- local imageView = seekNodeByName(self, "imgBackground", "ccui.ImageView")
    local FILE_TYPE = "LAUNCH_PIC"
    local fileMgr = manager.RemoteFileManager.getInstance()
    fileMgr:getRemoteFile(FILE_TYPE, url, function(ok, fileType, fileName)
        if ok then
            Logger.debug("GlobalSetting: launch pic download succ")
            self:saveSetting()
        else
            Logger.debug("GlobalSetting: launch pic download error")
        end
    end)
end

function GlobalSetting:loadLaunchPicTextrue(imageView)
    Macro.assertFalse(imageView and (imageView.loadTexture or imageView.setTexture), 'imageView is a nil value or not a ImageView object')
    local FILE_TYPE = "LAUNCH_PIC"
    local fileMgr = manager.RemoteFileManager.getInstance()
    local path = ''
    if fileMgr:doesFileExist(FILE_TYPE, self.launchPicUrl) then
        path = fileMgr:getFilePath(FILE_TYPE, self.launchPicUrl)
        -- elseif fileMgr:doesFileExist(FILE_TYPE, self.lastLaunchPicUrl) then
        --     path = fileMgr:getFilePath(FILE_TYPE, self.lastLaunchPicUrl)
    end

    if path == '' then
        Logger.debug("GlobalSetting Have no picture to load")
    else
        Logger.debug("GlobalSetting pic path = " .. tostring(path))
        Logger.debug("GlobalSetting is show launch pic = " .. tostring(self.isShowLaunchPic))
        if self.isShowLaunchPic then
            if imageView.loadTexture then
                imageView:loadTexture(path)
            elseif imageView.setTexture then
                imageView:setTexture(path)
            end
        end
    end
end

function GlobalSetting:isFirstInGame()
    return self._isFirstInGame
end