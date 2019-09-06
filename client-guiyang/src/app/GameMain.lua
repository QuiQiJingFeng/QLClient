--------------------------------------------
-- 游戏总入口, 控制整个游戏生命周期.
--------------------------------------------
cc.exports.GameMain = class("GameMain", function() return cc.Scene:create() end)

local CollectorService = require("app.game.service.CollectorService")
--------------------------------------------
-- 单例支持
local _instance = nil;

local _testcallback = nil

-- @return boolean
function GameMain.create(testcallback)
    if _instance ~= nil then
        return false;
    end

    _instance = GameMain:new();
    _instance:_initialize();
    _instance:_start();
    _testcallback = testcallback
    return true;
end

function GameMain.destroy()
    if _instance == nil then
        return;
	end

    _instance:_stop();
    _instance:_dispose();
    _instance = nil;
end

function GameMain.getInstance()
    return _instance;
end

--------------------------------------------
-- 构造函数
function GameMain:ctor()
	self._isReviewVersion = false;

    -- 注册场景回调
	self:registerScriptHandler(function(event)
        if "enter" == event then
            self:_onEnter()
        elseif "exit" == event then
            self:_onExit()
        end
    end)

    CollectorService:getInstance():collect()
end

-- 初始化
-- @return boolean
function GameMain:_initialize()
	net.core.ProtocolManager.create()
    
    -- for deviceId operation report
    local deviceId, readOp, writeOp = game.plugin.Runtime.getDeviceId()

    local securityLogEnabled = config.GlobalConfig.SECURITY_OPEN_LOG
    local Version = require "app.kod.util.Version"
	local buildver = Version.new(game.plugin.Runtime.getBuildVersion())
    local securityHashIPEnabled = buildver:compare("4.0.9.0") >= 0
    -- local securityHashIPEnabled = false
	net.WebProfileManager.create(securityHashIPEnabled, securityLogEnabled)

	-- 重新启动游戏时 重新获取当前group对应的ip池
    net.WebProfileManager.getInstance():refreshProfile()
    
    -- 创建agt安全检查
    game.util.AgtDomainChecker.create(securityLogEnabled)
    
    share.ShareWTF.create(true)

    UIManager:create()
    GameFSM:create();
    manager.ServiceManager.create();
	manager.RemoteFileManager.create();
    manager.AudioManager.getInstance():init()
    manager.RedDotStateTreeManager.create()

    -- for deviceId operation report
    game.service.LoginService:getInstance():setGetDeviceIdInfos(deviceId, readOp, writeOp)

    --TODO:安卓手机需要先注册一下，以后再修改
    game.plugin.Runtime.getBatteryLevel()

    -- 配置网络层模式
    local connection_service = game.service.ConnectionService.getInstance()
    if config.GlobalConfig.CONNECTION_TYPE_INTRANET then
        connection_service:setConnectionType(net.ConnectionType.Intranet, config.GlobalConfig.CONNECTION_INTRANET_SERVER)
    else
        connection_service:setConnectionType(net.ConnectionType.Public)
    end
	
    -- 配置是否加密连接
    local encrypt = config.GlobalConfig.getEncryptConnection()
	Logger.info("connection_service setCryptConnection %s", tostring(encrypt));
    connection_service:getConnection():setCryptConnection(encrypt)

    --设置汉字 config
    config.GlobalConfig.setChineseStrings()
    config.GlobalConfig.setChannelConfig("ChatConfig")
    config.GlobalConfig.setChannelConfig("ColorConfig")
    
    -- 处理启动参数
    self:_handleStartupParameter()

    return true;
end

function GameMain:_dispose()
end

-- 启动参数支持
function GameMain:_handleStartupParameter()
    -- iOS函数调用顺序有问题, 延迟处理启动参数
    local delayTask
    delayTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        -- 终止task
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(delayTask);

        -- 解析启动参数
        local startupParameter = nil
        local parameter = game.plugin.Runtime.getStartupParameter()
        if parameter then
            local jsonstr = loho.decodeConfigure(parameter)
            --Logger.debug("Startup parameter: " .. jsonstr)
            startupParameter = json.decode(jsonstr)
        end
        
        -- 处理启动参数
        if startupParameter then
            -- 默认链接IP
            local serverIp = startupParameter["ip"]
            if serverIp ~= "" then
                game.service.ConnectionService.getInstance():setConnectionType(net.ConnectionType.Intranet, serverIp)
            else
                game.service.ConnectionService.getInstance():setConnectionType(net.ConnectionType.Public)
            end		
        end
    end, 0.1, false)
end

function GameMain:isReviewVersion()
	return self._isReviewVersion;
end

function GameMain:setReviewVersion(tf)
	self._isReviewVersion = tf;
end

function GameMain:_start()
    cc.Director:getInstance():runWithScene(self);
    manager.AudioManager.getInstance():playMusic("sound/BGM/bgm.mp3", true)
end

function GameMain:_onEnter()
    -- UIManager:getInstance():init();
    -- game.plugin.Runtime.setIdleTimerDisabled(true)
    -- if _testcallback ~= nil then
    --     _testcallback()
    -- end
    ---[[
    GameFSM = require("mengya.app.manager.fsm.GameFSM")
    --]]
    GameFSM:getInstance():enterState("GameState_Club")
    
end

function GameMain:_onExit()
    game.plugin.Runtime.setIdleTimerDisabled(false)
end

return GameMain;
