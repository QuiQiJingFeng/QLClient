--[[0
    加密规则：
    1、异或加密
    2、异或 56046
    3、如果数为0，不进行异或
    4、只对 roleId  areaId  channelId 进行异或
]]
local encrypt = function(value)
	if type(value) ~= "number" then
		value = tonumber(value)
	end
	if value == nil or value == 0 then
		return 0
	else
		return require("bit").bxor(value, 56046)
	end
end
--[[
美洽模块
--]]
local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local MeiQiaService = class("MeiQiaService")
ns.MeiQiaService = MeiQiaService

local AppRegisterStatus =
{
	NoRegister = 1,
	Registering = 2,
	Registered = 3,
}

function MeiQiaService.getInstance()
	return manager.ServiceManager.getInstance():getMeiQiaService()
end

function MeiQiaService:ctor()
    cc.bind(self, "event")
	self._appRegisterStatus = AppRegisterStatus.NoRegister;
	self._listenerEnterBackground = nil
    self._listenerEnterForeground = nil
    -- 是否有未读消息， 在进入美洽的时候置为 false， 在接收到消息的时候置为 true， 只会缓存在内存在，不会保留到磁盘内
    self._hasUnReadMsg = false
    -- 是否在美洽内
    self._isInMeiQia = false
end

-- 美洽模块是否声响
function MeiQiaService:isEnabled()
    if not self:isSupported() then
        return false
    else
        return game.plugin.Runtime.isEnabled();
    end
end

-- 判断当前版本是否支持美洽
function MeiQiaService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end

	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.0.0")
	return currentVersion:compare(supportVersion) >= 0;
end

-- 判断当前版本是否支持美洽新接口
function MeiQiaService:isNewEnabled()
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    if currentVersion:compare(Version.new("4.10.0.0")) >= 0 then
        return true
    else
    	return false
    end
end


-- 初始化
function MeiQiaService:initialize()
	-- 4.10.0之后
	if self:isNewEnabled() == true then
		self:_initMQ(handler(self, self._onRegisterApp), handler(self, self._onCloseMeiQia), handler(self, self._onReceiveMessages), handler(self, self._onGetUnreadMessages))
	else
		self:_init(handler(self, self._onRegisterApp), handler(self, self._onCloseMeiQia))
	end
	
	self._listenerEnterBackground = listenGlobalEvent("EVENT_APP_DID_ENTER_BACKGROUND", handler(self, self._onEnterBackground))
	self._listenerEnterForeground = listenGlobalEvent("EVENT_APP_WILL_ENTER_FOREGROUND", handler(self, self._onEnterForeground))
end

-- 卸载
function MeiQiaService:dispose()
	-- 注册前后台切换事件监听
	if self._listenerEnterBackground ~= nil then
		unlistenGlobalEvent(self._listenerEnterBackground)
		self._listenerEnterBackground = nil;
	end
	
	if self._listenerEnterForeground ~= nil then
		unlistenGlobalEvent(self._listenerEnterForeground)
		self._listenerEnterForeground = nil;
    end
    
    cc.unbind(self, "event")
end

-- 内部初始化
function MeiQiaService:_init(onRegisterAppCallback, onCloseCallback)
	Logger.debug("[MeiQiaService] _init")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "initialize", {onRegisterAppCallback,onCloseCallback})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "initialize", { onRegisterAppCallback = onRegisterAppCallback, onCloseCallback = onCloseCallback })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 内部初始化 4.10.0之后
function MeiQiaService:_initMQ(onRegisterAppCallback, onCloseCallback, onReceiveMessages, onGetUnreadMessages)
	Logger.debug("[MeiQiaService] _initMQ")
	if self:isNewEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "initialize", {
			onRegisterAppCallback, onCloseCallback, onReceiveMessages, onGetUnreadMessages}, "(IIII)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "initialize", { 
			onRegisterAppCallback = onRegisterAppCallback, 
			onCloseCallback = onCloseCallback,
			onReceiveMessages = onReceiveMessages,
			onGetUnreadMessages = onGetUnreadMessages })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	Macro.assetFalse(false);
end

-- 注册AppId
function MeiQiaService:_registerApp(appId)
    -- game.ui.UIMessageBoxMgr.getInstance():show("[MeiQiaService] _registerApp", {"确定"})
	Logger.debug("[MeiQiaService] _registerApp")

	if self:isEnabled() == false then return false; end

	Macro.assetFalse(self._appRegisterStatus == AppRegisterStatus.NoRegister)
	self._appRegisterStatus = AppRegisterStatus.Registering;

	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "registerApp", {appId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "registerApp", { appId = appId })
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function MeiQiaService:openMeiQiaWithTip()
    local appName = config.GlobalConfig.getShareInfo()[1]
    local str = string.format("即将进入\"%s\"客服会话", appName)
    local boxId
    boxId = game.ui.UIMessageBoxMgr.getInstance():show(str, 
        {"确认", "取消"},
        function()
			game.ui.UIMessageBoxMgr.getInstance():hide(boxId)
			self:openMeiQia()
        end,
        function()
        end,
        function()
        end
    )
end

-- 打开美洽
function MeiQiaService:openMeiQia()
    -- 每次打开美洽的时候重置未读状态 
    self._hasUnReadMsg = false
    self._isInMeiQia = true
    self:dispatchEvent({ name = "EVENT_MEIQIA_MSG_STATUS_CHANGED" }) 
    Logger.debug("[MeiQiaService] openMeiQia")
    
	if self:isEnabled() == false then return false; end
	
	if self._appRegisterStatus == AppRegisterStatus.NoRegister then
		-- 延迟注册, 防止美洽影响正常逻辑
		self:_registerApp(config.GlobalConfig.getConfig().MeiQia_APPID);
		return
	elseif self._appRegisterStatus == AppRegisterStatus.Registering then
		-- 正在注册, 等等再试
		return
	end
    self:openMeiqia_Internal()
end

function MeiQiaService:openMeiqia_Internal()
    -- game.ui.UIMessageBoxMgr.getInstance():show("[MeiQiaService] openMeiqia_Internal", {"确定"})
    if self:isNewEnabled() then
        local service = game.service.LocalPlayerService.getInstance();
        local id = service:getRoleId()
        local name = tostring(service:getName())
        local phoneNum = service:getBindPhone() or 0
        local areaId = encrypt(service:getArea())
        local channelId = encrypt(game.plugin.Runtime.getChannelId())
        self:setCustomizedInfo(id, name, areaId, channelId, phoneNum)
        Logger.error("[MeiQiaService] openMeiqia_Internal, id:[%s], name:[%s], areaId:[%s] phoneNum:[%s]", id, name, areaId, phoneNum)
        self:openMeChatUI()
        return true
    else
        if device.platform == "android" then
            local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "openMeiQia")
            if Macro.assetTrue(ok == false, tostring(ret)) then return false end
            return true
        elseif device.platform == "ios" then
            local ok, ret = luaoc.callStaticMethod("MeiQia", "openMeiQia")
            if Macro.assetTrue(ok == false, tostring(ret)) then return false end
            return true
        end
    end
	
	Macro.assetFalse(false);
end



-- 自定义信息
-- Key	说明(已有)
-- name	真实姓名
-- gender	性别
-- age	年龄
-- tel	电话
-- weixin	微信
-- weibo	微博
-- address	地址
-- email	邮件
-- weibo	微博
-- avatar	头像 URL
-- tags	标签，数组形式，且必须是企业中已经存在的标签
-- source	顾客来源
-- comment	备注

function MeiQiaService:setCustomizedInfo(playerId, name, areaId, channelId, tel, weixin, comment)
	Logger.debug("[MeiQiaService] customizedInfo")
    if self:isNewEnabled() == false then return false; end
	local params = {
		playerId = tostring(playerId),
        playerId_v2 = tostring(playerId),
        name = tostring(name),
        tel = tostring(tel or ""),
        weixin = tostring(weixin or ""),
        comment = tostring(comment or ""),
        areaId = tostring(areaId or ""),
        channelId = tostring(channelId or ""),
    }
    local jsonStr = json.encode(params)
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "customizedInfo", {jsonStr}, "(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "customizedInfo", params)
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 自定义id
-- customizedId
function MeiQiaService:setCustomizedId(customizedId)
	Logger.debug("[MeiQiaService] setCustomizedId")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "setCustomizedId", {customizedId}, "(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "setCustomizedId", { 
			customizedId = customizedId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 指定客服分配
-- agentId
function MeiQiaService:setScheduledAgent(agentId)
	Logger.debug("[MeiQiaService] setScheduledAgent")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "setScheduledAgent", {agentId}, "(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "setScheduledAgent", { 
			agentId = agentId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end


-- 指定客服分组分配
-- groupId
function MeiQiaService:setScheduledGroup(groupId)
	Logger.debug("[MeiQiaService] setScheduledGroup")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "setScheduledGroup", {groupId}, "(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "setScheduledGroup", { 
			groupId = groupId})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 打开美恰界面
function MeiQiaService:openMeChatUI()
	Logger.debug("[MeiQiaService] openMeChatUI")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "openMeChatUI")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "openMeChatUI")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end


-- 设置用户离线
function MeiQiaService:setClientOffline()
	Logger.debug("[MeiQiaService] setClientOffline")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "setClientOffline")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "setClientOffline")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 获取当前用户信息
-- return string
function MeiQiaService:getCurrentClientInfo()
	Logger.debug("[MeiQiaService] getCurrentClientInfo")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getCurrentClientInfo")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获取当前顾客ID
-- return string
function MeiQiaService:getCurrentClientID()
	if self:isNewEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "getCurrentClientID", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getCurrentClientID")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获取当前自定义 ID
-- return string
function MeiQiaService:getCurrentCustomizedID()
	Logger.debug("[MeiQiaService] getCurrentCustomizedID")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getCurrentCustomizedID")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获取当前的客服 id
-- return string
function MeiQiaService:getCurrentAgentId()
	if self:isNewEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "getCurrentAgentId", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getCurrentAgentId")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获取当前使用的 app key
-- return string
function MeiQiaService:getCurrentKey()
	Logger.debug("[MeiQiaService] getCurrentKey")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getCurrentKey")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 设置顾客头像
-- imagePath
function MeiQiaService:setUserImage(imagePath)
	Logger.debug("[MeiQiaService] setUserImage")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		return false
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "setUserImage", { 
			imagePath = imagePath})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 获得当前美洽SDK的版本号
-- return string
function MeiQiaService:getMQSDKVersion()
	if self:isNewEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "getMQSDKVersion", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getMQSDKVersion")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获得所有未读消息，包括本地和服务端的
-- 会在onGetUnreadMessages回调
function MeiQiaService:getUnreadMessages()
	Logger.debug("[MeiQiaService] getUnreadMessages")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "getUnreadMessages")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getUnreadMessages")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 获得本地未读消息
-- return string
function MeiQiaService:getLocalUnreadeAllMessages()
	Logger.debug("[MeiQiaService] getLocalUnreadeAllMessages")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getLocalUnreadeAllMessages")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 当前用户是否被加入黑名单
-- return int
function MeiQiaService:isBlackUser()
	Logger.debug("[MeiQiaService] isBlackUser")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "isBlackUser")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 获取是否第一次上线
-- return int
function MeiQiaService:getLoginStatus()
	Logger.debug("[MeiQiaService] getLoginStatus")
	if self:isNewEnabled() == false then return ""; end
	
	if device.platform == "android" then
		return "";
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "getLoginStatus")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret;
	end

	Macro.assetFalse(false);
end

-- 关闭美洽服务, 在进入后台时调用
function MeiQiaService:_closeMeiqiaService()
	Logger.debug("[MeiQiaService] _closeMeiqiaService")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "closeMeiqiaService")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "closeMeiqiaService")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 开启美洽务器, 在进入前台时调用
function MeiQiaService:_openMeiqiaService()
	Logger.debug("[MeiQiaService] _openMeiqiaService")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/meiqia/MeiQia", "openMeiqiaService")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("MeiQia", "openMeiqiaService")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function MeiQiaService:_onEnterBackground()
	if self._appRegisterStatus == AppRegisterStatus.Registered then
		self:_closeMeiqiaService();
	end
end

function MeiQiaService:_onEnterForeground()
	if self._appRegisterStatus == AppRegisterStatus.Registered then
		self:_openMeiqiaService();
	end
end

function MeiQiaService:_onRegisterApp(jsonStrOrResult, clientId, error)
	-- ios 4.0.4.0版本的接口改为与android一致
	if Version.new(game.plugin.Runtime.getBuildVersion()):compare(Version.new("4.0.4.0")) >= 0
		or device.platform == "android" then
		Logger.debug("[MeiQiaService] _onRegisterApp,%s", tostring(jsonStrOrResult));

		local params = json.decode(jsonStrOrResult)
		if params.result == true then
			-- 注册回调, 打开美洽
			Macro.assetFalse(self._appRegisterStatus == AppRegisterStatus.Registering)
			self._appRegisterStatus = AppRegisterStatus.Registered;
			self:openMeiQia()
		else
			-- 注册失败, 上报错误
			Macro.assetFalse(self._appRegisterStatus == AppRegisterStatus.Registering)
			self._appRegisterStatus = AppRegisterStatus.NoRegister;
			game.service.DataEyeService.getInstance():reportError("Meiqia", params.error)
		end
	else
		Logger.debug("[MeiQiaService] _onRegisterApp,%s,%s,%s", tostring(jsonStrOrResult), tostring(clientId), tostring(error));
		-- ios封装的回调接口有问题, 与android的不一致, 
		if jsonStrOrResult == true then
			-- 注册回调, 打开美洽
			Macro.assetFalse(self._appRegisterStatus == AppRegisterStatus.Registering)
			self._appRegisterStatus = AppRegisterStatus.Registered;
			self:openMeiQia();
		else
			-- 注册失败, 上报错误
			Macro.assetFalse(self._appRegisterStatus == AppRegisterStatus.Registering)
			self._appRegisterStatus = AppRegisterStatus.NoRegister;
			game.service.DataEyeService.getInstance():reportError("Meiqia", error)
		end
	end
	
	
end

function MeiQiaService:_onCloseMeiQia()
    self._isInMeiQia = false
	Logger.debug("[MeiQiaService] _onCloseMeiQia")
end

-- 客服收到新消息回调
function MeiQiaService:_onReceiveMessages(jsonstr)
    -- game.ui.UIMessageBoxMgr.getInstance():show("[MeiQiaService] _onReceiveMessages", {"确定"})
    Logger.debug("[MeiQiaService] _onReceiveMessages")
    -- 不在美洽应用内才发送消息
    if not self._isInMeiQia then
        self._hasUnReadMsg = true
        self:dispatchEvent({name = "EVENT_MEIQIA_MSG_STATUS_CHANGED"})
    end
end

-- 获取未读信息回调
function MeiQiaService:_onGetUnreadMessages(jsonstr)
    Logger.debug("[MeiQiaService] _onGetUnreadMessages")
    -- 不在美洽应用内才发送消息
    if not self._isInMeiQia then
        self._hasUnReadMsg = true
        self:dispatchEvent({name = "EVENT_MEIQIA_MSG_STATUS_CHANGED"})
    end
end

function MeiQiaService:getHasUnReadMessages()
    return self._hasUnReadMsg
end
