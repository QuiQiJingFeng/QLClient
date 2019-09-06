local ns = namespace("game.service")

local LoginPhoneService = require("app.game.service.LoginPhoneService")
local LoginDingTalkService = require("app.game.service.LoginDingTalkService")
local LogService = require("app.game.service.LogService")

--[[Event:
USER_DATA_RETRIVED : 登录成功并获得用户基本数据
AFTER_USER_DATA_RETRIVED : USER_DATA_RETRIVED刷新数据之后的事件
USER_LOGOUT : 用户退出登录
EVENT_USER_RELOGIN : 用户重新登录
EVENT_PLAYER_REGION_CHANGED -- 玩家换区通知
EVENT_SHOW_SWITCH_REGION --显示切换地区按钮
EVENT_SHOW_CLUB --显示亲友圈按钮
EVENT_USER_LOGIN_SUCCESS: 用户登录成功
EVENT_USER_LOGIN_FAILED: 用户登录失败

EVENT_AGREEMENT_CHANGED -- 新添加一个消息，本身并不会发出，是一个UI用来通知另一个UI的

--]]
local SavedLoginInfoKey = "lastLoginInfo";
local SavedLoginInfoVer = 1

local BaseLocalData = require("app.kod.data.BaseLocalData")
-- 用于本地存储的登录数据
local SavedLoginData = class("SavedLoginData", BaseLocalData)
function SavedLoginData:ctor()
    self.account = "";
    self.refreshToken = "";
    self.channel = "";

    self._deviceIdAuth = ""
    self._deviceIdReadOp = -1
    self._deviceIdWriteOp = -1
    self._deviceIdInfoUploaded = false
end

function SavedLoginData:upgrade()
    self.__ver = SavedLoginInfoVer
    self.roleId = 0
end

-- 存储的areaId，选择地区的时候会存下来 毕节10001，安顺10004
local SavedAreaIdData = class("SavedAreaIdData")
local SavedAreaIdKey = "SavedAreaIdKey";
function SavedAreaIdData:ctor()
    self.areaId = 0;
end

--------------------------------------------
-- 处理登录相关逻辑流程
--------------------------------------------
local LoginService = class("LoginService")
ns.LoginService = LoginService

-- 单例支持
-- @return LoginService
function LoginService:getInstance()
    return manager.ServiceManager.getInstance():getLoginService();
end

function LoginService:ctor()
    self._autoLogin = true
    -- 经常碰到微信回调多次的情况，做一下保护
    self._waitingForWeixin = false
    self._savedLoginData = SavedLoginData.new()
    self._successCallback = nil
    self._libVersion    = ""

    -- 选择地区
    self._isNeedSelectRegion = false
    self._areas = {}
    self._default = 0
    self._savedAreaIdData = SavedAreaIdData.new();

    self._loginPhoneService = LoginPhoneService.new()
    self._loginDingTalkService = LoginDingTalkService.new()

    self._deviceIdAuth = ""
    self._deviceIdReadOp = -1
    self._deviceIdWriteOp = -1
    self._deviceIdInfoUploaded = false

    cc.bind(self, "event");
end

function LoginService:onCodeRec(response)
    local protocol = response:getProtocol():getProtocolBuf()
    if protocol.result == net.ProtocolCode.AI_VERIFY_CODE_SUCCESS then
        self:dispatchEvent({name = "EVENT_VERIFYCODE"})
    else
        game.ui.UIMessageBoxMgr.getInstance():show(net.ProtocolCode.code2Str(protocol.result), { "确定" })
        -- ui.codehint:setString(net.ProtocolCode.code2Str(protocol.result))
    end
end

function LoginService:onBindPhoneRes(response)
    local protocol = response:getProtocol():getProtocolBuf()
    local ui = UIManager:getInstance():getUI("UIPhoneLogin")
    local result = net.ProtocolCode.AI_BIND_PHONE_SUCCESS == protocol.result
    if ui then
        ui:bindResult(result, net.ProtocolCode.code2Str(protocol.result))
    end
    if net.ProtocolCode.AI_BIND_PHONE_SUCCESS == protocol.result then
        game.service.LocalPlayerService:getInstance():setBindPhone(protocol.phone)

        self:dispatchEvent({name = "EVENT_BINDPHONE_CHANGED"})
        -- 绑定成功关闭个人信息
        UIManager.getInstance():hide("UIPlayerInfo")
    elseif net.ProtocolCode.AI_BIND_PHONE_ERROR_ALREADY_BIND == protocol.result then
        game.ui.UIMessageBoxMgr.getInstance():show("绑定失败，该手机号已被绑定", {"确定"})
    elseif not ui then
        game.ui.UIMessageBoxMgr.getInstance():show('请输入正确的手机号和验证码', {"确定"})
    end
end


function LoginService:initialize()
    -- 注册消息回调
    local requestManager = net.RequestManager:getInstance();
    requestManager:registerResponseHandler(net.protocol.ICAccountAuthRES.OP_CODE, self, self._onLoginInterfaceRes);
    requestManager:registerResponseHandler(net.protocol.GCLoginRES.OP_CODE, self, self._onLoginGameServerRes);
    requestManager:registerResponseHandler(net.protocol.GCLogoutRES.OP_CODE, self, self._onLogoutRes);
    requestManager:registerResponseHandler(net.protocol.ServerExceptionSYNC.OP_CODE, self, self._onServerExceptionSync);
    requestManager:registerResponseHandler(net.protocol.GCSelectAreaREQ.OP_CODE, self, self._onSelectArea);
    requestManager:registerResponseHandler(net.protocol.GCSelectAreaRES.OP_CODE, self, self._onRecvSelectArea);
    requestManager:registerResponseHandler(net.protocol.GCAreaListRES.OP_CODE, self, self._onRecvAreaList);

    requestManager:registerResponseHandler(net.protocol.ICVerifyCodeRES.OP_CODE, self, self.onCodeRec)
    requestManager:registerResponseHandler(net.protocol.ICBindPhoneRES.OP_CODE, self, self.onBindPhoneRes)
    requestManager:registerResponseHandler(net.protocol.GCUploadClientInfoRES, self, self._onUploadClientInfo)
    -- requestManager:registerResponseHandler(net.protocol.GCAreaListRES.OP_CODE, self, self._onRecvAreaList);
    
    self._loginPhoneService:initialize()
    self._loginDingTalkService:initialize()

    self:_loadSavedLoginInfo();
    self:_loadSavedAreaIdData();
    game.service.WeChatService.getInstance():addEventListener("EVENT_AUTH_RESP", handler(self, self._onWeChatAuthResp), self);
    game.service.LoginService.getInstance():addEventListener("EVENT_SELECT_NEED_REGION", handler(self, self._firstSelectRegion), self)
end

function LoginService:dispose()
    net.RequestManager.getInstance():unregisterResponseHandler(self)
    if game.service.WeChatService.getInstance() ~= nil then
        game.service.WeChatService.getInstance():removeEventListenersByTag(self)
    end

    self._loginPhoneService:dispose()
    self._loginDingTalkService:dispose()

    cc.unbind(self, "event");
end

function LoginService:getLoginPhoneService()
	return self._loginPhoneService
end

function LoginService:getLoginDingTalkService()
	return self._loginDingTalkService
end

function LoginService:_firstSelectRegion()
    if self._isNeedSelectRegion then
        --先销毁notice
        -- UIManager:getInstance():hide("UINotice");
        UIManager:getInstance():show("UISelectDistrict", self._areas, self._default, true)
    end
end

-- GCAreaListRES
function LoginService:_onRecvAreaList(response)
    local protocol = response:getProtocol():getProtocolBuf();
    scheduleOnce(function()
        self._areas = protocol.areas
        UIManager:getInstance():show("UISelectDistrict", protocol.areas, game.service.LocalPlayerService:getInstance():getArea(), false)
    end, 0)
end

-- GCSelectAreaREQ
function LoginService:_onSelectArea(response)
    local protocol = response:getProtocol():getProtocolBuf();
    self._areas = protocol.areas
    self._default = protocol.default
    self._isNeedSelectRegion = true
end

-- GCSelectAreaRES
function LoginService:_onRecvSelectArea(response)
    local protocol = response:getProtocol():getProtocolBuf();
    if protocol.result == net.ProtocolCode.GC_SELECT_AREA_SUCCESS then
        self:switchArea(protocol.area)
        self._isNeedSelectRegion = false;
    else
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result))
    end
end

--切换地区
function LoginService:switchArea(area)
    -- body
    game.service.LoginService.getInstance():startLogin(game.service.LocalPlayerService:getInstance():getName(), false, area);
    manager.ServiceManager.getInstance():clearLocalPlayerData()
    UIManager:getInstance():hide("UISelectDistrict")

    -- 存储选择的areaId
    self._savedAreaIdData.areaId = area;
    self:_saveSavedAreaIdData();
    --切换地区后将UI重新生成一遍
    game.service.LoginService.getInstance():dispatchEvent({ name = "EVENT_PLAYER_REGION_CHANGED" });
end

-- 是否需要自动登录
-- @return boolean
function LoginService:needAutoLogin()
    return self._autoLogin and self:_hasCachedLoginInfo();
end

-- 客户端版本是否需要更新
function LoginService:getIsNeedUpdate()
    local Version = require "app.kod.util.Version"
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    local newestVersion = Version.new(self._libVersion.highestLibVersion)
    return currentVersion:compare(newestVersion) < 0;
end

-- 设置是否可以自动登录
function LoginService:_setAutoLogin(value)
    self._autoLogin = value;
end

--[[-- 本地缓存的登录信息
--]]
function LoginService:_loadSavedLoginInfo()
    self._savedLoginData = manager.LocalStorage.getGlobalData(SavedLoginInfoKey, SavedLoginData);
end

function LoginService:_saveCachedLoginInfo()
    manager.LocalStorage.setGlobalData(SavedLoginInfoKey, self._savedLoginData);
end

-- 存储选择地区id
function LoginService:_loadSavedAreaIdData()
    self._savedAreaIdData = manager.LocalStorage.getGlobalData(SavedAreaIdKey, SavedAreaIdData);
end

function LoginService:_saveSavedAreaIdData()
    manager.LocalStorage.setGlobalData(SavedAreaIdKey, self._savedAreaIdData);
end

-- 获取areaId
function LoginService:getSavedareaId()
    return self._savedAreaIdData.areaId;
end

function LoginService:getSavedRoleId()
    return self._savedLoginData.roleId
end

function LoginService:_clearCachedLoginInfo()
    self._savedLoginData = SavedLoginData.new()
    self:_saveCachedLoginInfo();
end

-- @return boolean
function LoginService:_hasCachedLoginInfo()
    return self._savedLoginData.account ~= nil and self._savedLoginData.account ~= ""
    and self._savedLoginData.refreshToken ~= nil and self._savedLoginData.refreshToken ~= ""
    and self._savedLoginData.channel ~= nil and self._savedLoginData.channel ~= ""
end

--[[-- 游客账号
--]]
-- @return string
function LoginService:getGuestAccount()
    if self._savedLoginData.account == nil or self._savedLoginData.account == "" then
        self._savedLoginData.account = tostring(math.modf(kod.util.Time.now() * 1000 % 1000000));
    end
    return self._savedLoginData.account;
end

-- @param account: string
function LoginService:setGuestAccount(account)
    self._savedLoginData.account = account;
    if self._savedLoginData.account == nil or self._savedLoginData.account == "" then
        self._savedLoginData.account = tostring(math.modf(kod.util.Time.now() * 1000 % 1000000));
    end
    self:_saveCachedLoginInfo();
end

-- phone login
function LoginService:startPhoneLogin(phone, verifycode, relogin, area, token)
    local request = net.NetworkRequest.new(net.protocol.CIPhoneLoginREQ, 0);
    request:getProtocol():setData(config.GlobalConfig.getLoginChannel().phone, phone, verifycode, token, area)
    request.relogin = relogin or false
    game.util.RequestHelper.request(request)
end

-- phone bind 
function LoginService:phoneBindReq(newphone, verifycode, type, oldphone)
    local request = net.NetworkRequest.new(net.protocol.CIBindPhoneREQ, 0);
    request:getProtocol():setData(newphone, verifycode, type, oldphone)
    game.util.RequestHelper.request(request)
end

-- @param guestName: string
function LoginService:startLogin(username, relogin, area)
    -- 开始认证
    if GameMain.getInstance():isReviewVersion() then
        -- 审核版
        self:setGuestAccount(self:getGuestAccount());
        self:_loginAuthWithUsername(relogin, area);
    elseif game.plugin.Runtime.isEnabled() then
        -- 正式版
        self:_loginPlatform(relogin, area);
    else
        -- 测试版
        self:setGuestAccount(username);
        self:_loginAuthWithUsername(relogin, area);
    end
end

-- 断线之后重新发起登陆
function LoginService:startRelogin()
    Logger.debug("startRelogin");

    -- 如果自己退出了，不要自动登录
    if self:needAutoLogin() == false then
        return
    end

    self:dispatchEvent({ name = "EVENT_USER_RELOGIN" });

    -- 清空本地玩家数据
    -- manager.ServiceManager.getInstance():clearLocalPlayerData()
    self:startLogin(self:getGuestAccount(), true)
end

function LoginService:_loginPlatform(relogin, area)
    if self:_hasCachedLoginInfo() == false then
        if game.service.WeChatService.getInstance():checkApp() == false then
            game.ui.UIMessageTipsMgr.getInstance():showTips("微信没有安装或者版本过低");
            return;
        end

        self._waitingForWeixin = true
        -- 本地没有缓存的登录数据, 需要申请授权
        game.service.WeChatService.getInstance():sendAuthReq("snsapi_userinfo", "sendAuthReq")
    else
        -- 直接使用缓存的数据登录 
        -- 如果有手机登录缓存
        local phoneToken = self._savedLoginData.phoneToken
        if phoneToken and phoneToken ~= '' then
            local phone = ''
            self:startPhoneLogin(phone, '', relogin, area, phoneToken)
        else
            self:_loginAuthWithCache(self._savedLoginData.channel, self._savedLoginData.account, self._savedLoginData.refreshToken, relogin, area);
        end
    end
end

-- 微信登录的回调
function LoginService:_onWeChatAuthResp(event)
    if not self._waitingForWeixin then
        return
    end
    self._waitingForWeixin = false

    Macro.assertFalse(event.name == "EVENT_AUTH_RESP")
    if event.errCode == game.service.WeChatService.WXErrorCode.WXSuccess then
        -- 认证成功,
        self:loginAuthWithCode(config.GlobalConfig.getLoginChannel().wx, event.code);
    elseif event.errCode ~= game.service.WeChatService.WXErrorCode.WXErrCodeUserCancel then
        -- 非取消型失败, 显示错误
        game.ui.UIMessageBoxMgr.getInstance():show(event.errStr, { "确定" })

        -- 埋点
        game.service.DataEyeService.getInstance():reportError("wxLoginError", event.errStr);
    end
end

function LoginService:phoneCodeReq(phone, type)
    if phone == nil or phone == "" or string.len(phone) ~= 11 then
        return
    end

    local request = net.NetworkRequest.new(net.protocol.CIVerifyCodeREQ, 0)
    request:getProtocol():setData(tonumber(phone), type)
    game.util.RequestHelper.request(request)
end

-- 通过用户名登录入口服务器（测试渠道）
function LoginService:_loginAuthWithUsername(relogin, area)
    local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
    request:getProtocol():setData(config.GlobalConfig.getLoginChannel().test, self:getGuestAccount(), '', '', area);
    request.relogin = relogin or false
    game.util.RequestHelper.request(request);
end

-- 通过微信code登录入口服务器
-- @param code: string
function LoginService:loginAuthWithCode(channel, code, relogin, area)
    local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
    request:getProtocol():setData(channel, '', code, '', area);
    request.relogin = relogin or false
    game.util.RequestHelper.request(request);
end

-- 通过微信refreshToken登录入口服务器
-- @param username: string
-- @param refreshToken: string
function LoginService:_loginAuthWithCache(channel, username, refreshToken, relogin, area)
    local request = net.NetworkRequest.new(net.protocol.CIAccountAuthREQ, 0);
    request:getProtocol():setData(channel, username, '', refreshToken, area);
    request.relogin = relogin or false
    game.util.RequestHelper.request(request);
end

-- 登录入口服务器结果
-- @param protocol: net.core.net.protocol.ICAccountAuthRES
function LoginService:_onLoginInterfaceRes(response)
    local protocol = response:getProtocol():getProtocolBuf();
    local request = response:getRequest()
    if protocol.result == net.ProtocolCode.IC_AUTH_SUCCESS then
        self:_interfaceToLogin(protocol, request.relogin);
        game.service.GlobalSetting.getInstance():setLaunchPicUrl(protocol.loginUrl, protocol.loginUrlSwitch)
    else
        -- 登錄失敗, 端口連接
        game.service.ConnectionService.getInstance():close();

        if protocol.result == net.ProtocolCode.AI_AUTH_FAILED_FORCE_UPDATE then
            game.ui.UIMessageBoxMgr.getInstance():show("检测游戏版本过低，请更新为新版本！", { "确定" }, function()
                GameFSM.getInstance():enterState("GameState_Update");
                -- TODO:强更的时候，不再清楚玩家本地登陆缓存
                -- self:_clearCachedLoginInfo();
            end)
        else
            -- 重连登陆时,有可能当前不是登陆状态,如果失败,需要返回登陆状态
            if GameFSM.getInstance():getCurrentState():isGamingState() then
                GameFSM.getInstance():enterState("GameState_Login");
            end

            if protocol.result == net.ProtocolCode.AI_AUTH_FAILED_DINGTALK_ERROR_NO_BIND then
                game.ui.UIMessageBoxMgr.getInstance():show("请用微信登录,在个人中心绑定钉钉后,方可使用钉钉登录", {"确定"})
            elseif protocol.result == net.ProtocolCode.AI_AUTH_FAILED_HUTONG then
                game.ui.UIMessageBoxMgr.getInstance():show("您已更新至新版本，请用新版本客户端登陆游戏", { "前往新版" },function()
                    if device.platform == "android" then
                        cc.Application:getInstance():openURL("gymjzhht://")
                    elseif device.platform == "ios" then
                        cc.Application:getInstance():openURL("wx7c6c29fe20b11316://")
                        cc.Application:getInstance():openURL("wxc1334d94320a7333://")
                    end
                end)
			else
                game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
            end

            -- 认证失败, 清除本地保存的登录信息
            -- TODO : 数据清理顺序不合理, 需要调整
            if protocol.result ~= net.ProtocolCode.AI_AUTH_FAILED_WHITE_LIST
            and protocol.result ~= net.ProtocolCode.AI_AUTH_FAILED_FORBID_REGISTER then
                self:_clearCachedLoginInfo();
            end
        end
    end
    return true;
end

-- interface连接成功后,开始连接game
-- @param protocol: net.core.net.protocol.ICAccountAuthRES
function LoginService:_interfaceToLogin(protocol, relogin)
    Macro.assertFalse(relogin ~= nil)

    -- bugly
    buglySetUserId(tostring(protocol.roleId))
    local updateService = game.service.UpdateService.getInstance()
    -- 设置bugly参数, 用于错误上报

    buglyAddUserValue("version", updateService:getProductVersion():getVersions()[1])
    buglyAddUserValue("nickname", protocol.nickname)
    buglyAddUserValue("roleId", protocol.accountId)
    buglyAddUserValue("buildVersion", game.plugin.Runtime.getBuildVersion())


    -- 缓存微信登录信息
    self._savedLoginData.roleId = protocol.roleId
    self._savedLoginData.account = protocol.username
    self._savedLoginData.refreshToken = protocol.refreshToken
    -- 钉钉数据跟微信数据不同
    if protocol.channel == config.GlobalConfig.getLoginChannel().dingtalk then
        self._savedLoginData.account = protocol.dingOpenId
        self._savedLoginData.refreshToken = protocol.dingRefreshToken
    end
   
    -- 缓存登录渠道
    self._savedLoginData.channel = protocol.channel
    -- 缓存手机登录信息
    self._savedLoginData.phoneToken = protocol.phoneToken
    self._savedLoginData.phoneNum = protocol.phoneNum
    
    self:_saveCachedLoginInfo();

    -- 获取wxUrl
    if protocol.wxUrl ~= nil and protocol.wxUrl ~= "" then
        config.GlobalConfig.getConfig().SHARE_HOSTNAME = protocol.wxUrl
    end

    -- 保存libVersion
    self._libVersion = protocol.libVersion

    -- 设置以后可以自动登录,可以自動重登
    self:_setAutoLogin(true);
    game.service.LocalPlayerService.getInstance():initInterfaceData(protocol)

    -- 4 手机登录 0 微信登录
    local loginType = protocol.phoneToken and protocol.phoneToken ~= '' and 4 or 0

    -- 登录到游戏服务器
    self:_loginGameServer(
    protocol.gameServerId,
    protocol.roleId,
    protocol.sex,
    protocol.nickname,
    protocol.headImageUrl,
    protocol.channel,
    protocol.signature,    
    protocol.area,
    protocol.developerId,
    protocol.unionId,
    protocol.username,
    loginType,
        protocol.phoneNum
    );
    -- 设置上报信息
    LogService:getInstance():setUploadInfo(game.service.LocalPlayerService:getInstance():getArea(), protocol.roleId)

     game.service.LocalPlayerService.getInstance():setInterflow(protocol.hasHuTong)
end
-- 登录到游戏服务器
-- @param serverId: number
-- @param roleId: number
-- @param sex: number
-- @param nickname: string
-- @param headImageUrl: string
-- @param channel: string
-- @param username string 渠道用户名
-- @param unionid string 微信unionid
-- @param developerId
function LoginService:_loginGameServer(serverId, roleId, sex, nickname, headImageUrl, channel, signature, area, developerId, unionId, username, type, phone)
    -- TODO : 登录到游戏服务器的时候需要传nick这些信息？
    local request = net.NetworkRequest.new(net.protocol.CGLoginREQ, serverId);
    request:getProtocol():setData(roleId, sex, nickname, headImageUrl, channel, signature, area, developerId , unionId, username, game.plugin.Runtime.getChannelId(), type, phone, game.plugin.Runtime.getBuildVersion());
    game.util.RequestHelper.request(request);
end

-- @param protocol: net.core.net.protocol.GCLoginRES
function LoginService:_onLoginGameServerRes(response)
    local protocol = response:getProtocol():getProtocolBuf();
    local request = response:getRequest():getProtocol():getProtocolBuf();
    local isLoginSucc = protocol.result == net.ProtocolCode.GC_LOGIN_SUCCESS
    if protocol.result == net.ProtocolCode.GC_LOGIN_SUCCESS then
        -- 登录成功
        local playerService = game.service.LocalPlayerService.getInstance();
        -- 初始化玩家数据
        playerService:initGameData(protocol, request.unionId)

        -- 刷新房间房卡，玩家ID，BtnValueUI，身份认证状态
        if UIManager:getInstance():getIsShowing("UIMain") then
            local ui = UIManager:getInstance():getUI("UIMain");
            ui:changeRoleId(playerService:getRoleId())
        end
        self:dispatchEvent({ name = "EVENT_SWITCH_AREA_CHANGED" });
        self:dispatchEvent({ name = "EVENT_VERIFIED_CHANGED" });
        self:dispatchEvent({ name = "EVENT_AGT_STATUS_CHANGED", isAgent = protocol.isAgency });
        self:dispatchEvent({ name = "EVENT_CLUB_REDDOT_CHANGED" });

        --刷新摇钱树奖励和抽奖次数
        if UIManager:getInstance():getIsShowing("UIMoneyTree") then
            game.service.MoneyTreeService:getInstance():setBReconnection(true);
        end

        local activityService = game.service.ActivityService.getInstance()
        if activityService:isActivitieswithin(net.protocol.activityType.TURN_TABLE) then
            game.service.MoneyTreeService:getInstance():requestQueryTurntableInfo();    
        end


        -- 初始化语音开关系统
        -- if game.service.RT_VoiceService.getInstance():isSupported() then
        game.service.RT_VoiceService:getInstance():setAppInfo(
        config.GlobalConfig.getConfig().GVOICE_APPID, -- AppId
        config.GlobalConfig.getConfig().GVOICE_APPKEY, -- appKey
        playerService:getRoleId())
        -- end
        -- game.service.IM_VoiceService.getInstance():cpLogin(tostring(playerService:getRoleId()), tostring(playerService:getRoleId()));

        -- DataEyeSDK 登陆
        game.service.DataEyeService.getInstance():login(playerService:getRoleId());
        game.service.DataEyeService.getInstance():setUserInfo(playerService:getName(), playerService:getGender());

        -- 统计当前版本验证td是否有用
        -- local ver = game.plugin.Runtime.getBuildVersion()
        -- game.service.DataEyeService.getInstance():onEvent(game.globalConst.StatisticNames.Version_2_TD .. ver, ver)
        -- TDAdTrackingService
        game.service.TDAdTrackingService.getInstance():onLogin(tostring(playerService:getRoleId()));

        -- 检查是否有充值漏单
        game.service.PaymentService:getInstance():recheckPayment()

        -- 根据当前是否在房间, 选择接下来进入的场景
        if protocol.battleId ~= nil and protocol.battleId ~= 0 and
        protocol.roomId ~= nil and protocol.roomId ~= 0 then            
            -- 在房间中
            game.service.RoomCreatorService.getInstance():enterRoom(protocol.battleId, protocol.roomId, nil, false)
        else
            self:dispatchEvent({ name = "USER_DATA_RETRIVED" });
            self:dispatchEvent({ name = "AFTER_USER_DATA_RETRIVED" });
        end

        -- 请求比赛状态
        local campaignService = game.service.CampaignService.getInstance()
        if campaignService:getId() ~= 0 and campaignService:getCampaignList():getCurrentCampaignId() ~= 0 then
            if campaignService:getCampaignList():getCurrentCampaignId() == config.CampaignConfig.ARENA_ID then
                campaignService:getArenaService():sendCCAArenaInfoREQ()
            else
                campaignService:sendCCAPlayerStatusREQ()
            end
        elseif campaignService:getCampaignList():getCurrentCampaignId() == 0 then
            campaign.CampaignFSM.getInstance():enterState("CampaignState_NotSignUp")
        end

        -- 安全策略		
        net.WebProfileManager:getInstance():setGroup(protocol.connGroup)  
        
        if not self._deviceIdInfoUploaded then
            local deviceModel = game.plugin.Runtime.getDeviceModel()
            local deviceVersion = game.plugin.Runtime.getSystemVersion()
            self:uploadClientInfo(self._deviceIdWriteOp, self._deviceIdReadOp, self._deviceIdAuth, deviceModel, deviceVersion)
            self._deviceIdInfoUploaded = true
        end
    else
        -- 登录出错
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
        
        -- 情况本地玩家数据
        manager.ServiceManager.getInstance():clearLocalPlayerData();
        
        -- 重连登陆时,有可能当前不是登陆状态,如果失败,需要返回登陆状态
        if GameFSM.getInstance():getCurrentState():isGamingState() then
            GameFSM.getInstance():enterState("GameState_Login");
        end
    end
    
    if isLoginSucc then
        self:dispatchEvent({name = "EVENT_USER_LOGIN_SUCCESS"})
    else
        self:dispatchEvent({name = "EVENT_USER_LOGIN_FAILED", reason = protocol.result })
    end
end

-- 登出
-- @param serverId: number
function LoginService:logout(serverId)
    game.util.RequestHelper.request(net.NetworkRequest.new(net.protocol.CGLogoutREQ, serverId));
end

-- @param response: NetworkResponse<net.core.protocol.GCLogoutRES>
function LoginService:_onLogoutRes(response)
    local protocol = response:getProtocol():getProtocolBuf();
    if protocol.result == net.ProtocolCode.GC_LOGOUT_SUCCESS then
        -- game.plugin.DataEyeSender.logout();
        -- 清空本地玩家数据
        self:_clearCachedLoginInfo();
        self:forceLogout();
        event.EventCenter:dispatchEvent({name = "EVENT_LOGIN_OUT"})
    else
        -- 登录出错
        game.ui.UIMessageTipsMgr.getInstance():showTips(net.ProtocolCode.code2Str(protocol.result));
    end
    return true;
end

function LoginService:forceLogout(doRelogin)
    game.service.DataEyeService.getInstance():logout();
    -- game.service.IM_VoiceService.getInstance():cpLogout();

    -- 设置不要自动登录
    release_print("forceLogout~~~~~~~~~~~~~~~~",doRelogin)
    if not doRelogin then
    self:_setAutoLogin(false);
    end
    self:dispatchEvent({ name = "USER_LOGOUT" });

    -- 清空本地玩家数据, 需要在USER_LOGOUT之后, 过程中有可能用到本地玩家数据
    manager.ServiceManager.getInstance():clearLocalPlayerData();

    --清除数据
    self._areas = {}
    self._default = 0
end

-- 服务器协议处理异常的通知
-- @param response: NetworkResponse<protocol.ServerExceptionSYNC>
function LoginService:_onServerExceptionSync(response)
    local protocol = response:getProtocol():getProtocolBuf();
    local errorMsg = string.format("服务器协议处理异常:0x%x", protocol.protocolId);
    Logger.error(errorMsg)
    game.ui.UIMessageBoxMgr.getInstance():show(errorMsg, { "确定" })
    -- 埋点
    game.service.DataEyeService.getInstance():reportError("serverExceptionError", string.format("0x%x", protocol.protocolId));

    return true;
end

-- 这里还取不到用户相关数据，只能做成全局的
-- 获取当前的用户协议接受情况
function LoginService:isAcceptAgreement()
    return cc.UserDefault:getInstance():getBoolForKey("isAcceptAgreement", false)
end

-- 设置当前的用户协议接受情况
function LoginService:saveAcceptAgreement(is)
    cc.UserDefault:getInstance():setBoolForKey("isAcceptAgreement", is)
    cc.UserDefault:getInstance():flush()
end

function LoginService:uploadClientInfo(writeOp, readOp, deviceId, deviceName, deviceVersion)
    if device.platform ~= "windows" then
        release_print("uploadClientInfo~~~~~~", writeOp, readOp, deviceId, deviceName, deviceVersion)
        local request = net.NetworkRequest.new(net.protocol.CGUploadClientInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId());
        request:getProtocol():setData(writeOp, readOp, deviceId, deviceName, deviceVersion);
        game.util.RequestHelper.request(request);
    end
end

function LoginService:_onUploadClientInfo()
    release_print("upload client info succeed~~~~~~~~~~~~~~~~~")
end

function LoginService:setGetDeviceIdInfos(deviceId, readOp, writeOp)
    self._deviceIdAuth = deviceId
    self._deviceIdReadOp = readOp
    self._deviceIdWriteOp = writeOp
end

return LoginService
