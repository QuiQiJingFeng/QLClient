--[[
JPush模块
事件
EVENT_REGISTRATION	--注册成功
EVENT_ONSETALIASANDTAGS --设置别名标签 code，alias，tag
EVENT_REGISTERAPNSSUCC --APNS注册成功 token
EVENT_REGISTERAPNFAILED --APNS注册失败 error
EVENT_IOS_REGISTRATIONID --IOS getRegistrationId code, registrationId
--]]
local ReceiveType_Android = 
{
	REGISTRATION = "cn.jpush.android.intent.REGISTRATION",									-- SDK 向 JPush Server 注册所得到的注册 ID
	MESSAGE_RECEIVED = "cn.jpush.android.intent.MESSAGE_RECEIVED",							-- 收到了自定义消息 Push
	NOTIFICATION_RECEIVED = "cn.jpush.android.intent.NOTIFICATION_RECEIVED",				-- 收到了通知 Push
	NOTIFICATION_OPENED = "cn.jpush.android.intent.NOTIFICATION_OPENED",					-- 用户点击了通知。
	ACTION_NOTIFICATION_CLICK_ACTION = "cn.jpush.android.intent.NOTIFICATION_CLICK_ACTION",	-- 用户点击了通知栏中自定义的按钮。
	ACTION_CONNECTION_CHANGE = "cn.jpush.android.intent.CONNECTION",						-- JPush 服务的连接状态发生变化
}

local ReceiveType_iOS = 
{
	CONNECTING = "kJPFNetworkIsConnectingNotification",				-- 正在连接中
	CONNECTED = "kJPUSHNetworkDidSetupNotification",					-- 建立连接
	CONNECCLOSE = "kJPUSHNetworkDidCloseNotification",				-- 关闭连接
	REGISTRATION = "kJPUSHNetworkDidRegisterNotification",			-- 注册成功
	REGISTRATIONFAILED = "kJPFNetworkFailedRegisterNotification",	-- 注册失败
	LOGIN = "kJPUSHNetworkDidLoginNotification",						-- 登录成功
	MESSAGE_RECEIVED = "kJPUSHNetworkDidReceiveMessageNotification",	-- 收到自定义消息(非APNs)
	NOTIFICATION_OPENED = "NOTIFICATION_OPENED"
}

local ns = namespace("game.service")
local Version = require "app.kod.util.Version"

local JPushService = class("JPushService")
ns.JPushService = JPushService

function JPushService.getInstance()
	return manager.ServiceManager.getInstance():getJPushService()
end

function JPushService:ctor()
   	cc.bind(self, "event");
	self._registerAPNsFailed = false
end

function JPushService:isLocalPushNotEnabled()
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.8.0.0")
	return currentVersion:compare(supportVersion) < 0;
end

-- JPush模块是否生效
function JPushService:isEnabled()
    if self:checkIsLowVersion() then
        return false
	elseif not self:isSupported() then
		return false
	else
		return game.plugin.Runtime.isEnabled();
	end
end
-- 检查是否在低版本， 低版本jpush有bug，不能使用，会闪退
function JPushService:checkIsLowVersion()
    if device.platform == "ios" then
        Logger.debug("JPush ios system version")
		Logger.debug(game.plugin.Runtime.getSystemVersion())
		if not game.plugin.Runtime.getSystemVersion() then
			return false
		end
		local currentVersion = Version.new(game.plugin.Runtime.getSystemVersion())
		local supportVersion = Version.new("9.0.0")
        return currentVersion:compare(supportVersion) < 0;
    elseif device.platform == 'android' then
        return false
    else
        return false
    end
end

-- 判断当前版本是否支持JPush
function JPushService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.0.8.0")
	return currentVersion:compare(supportVersion) >= 0;
end

-- 初始化
function JPushService:initialize()
	Logger.debug("[JPushService] initialize")

	self:setCallback(
		handler(self, self._onRegisterAPNsSucceed), 
		handler(self, self._onRegisterAPNsFailed), 
		handler(self, self._onRegistrationId), 
		handler(self, self._onReceiveNotification), 
		handler(self, self._onSetAliasAndTags),
		handler(self, self._onWillPresentNotification),
		handler(self, self._onTagOperatorResult),
		handler(self, self._onCheckTagOperatorResult),
		handler(self, self._onAliasOperatorResult),
		handler(self, self._onMobileNumberOperatorResult))

	game.service.LoginService:getInstance():addEventListener("EVENT_USER_LOGIN_SUCCESS", handler(self, self._onUserLoginSuccess), self)
	
	if not self:isInitialized() or device.platform == "android" then
		self:setDebugMode(true)
		self:_init()
	end
end

-- 卸载
function JPushService:dispose()
	Logger.debug("[JPushService] dispose")
	cc.unbind(self, "event");
end

-- 是否已经初始化
function JPushService:isInitialized()
	Logger.debug("[JPushService] isInitialized")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "isInitialized", {},"()Z")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "isInitialized")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- 设置回调
function JPushService:setCallback(registerAPNsSucceedCallback, registerAPNsFailedCallback, registrationIdCallback, receiveNotificationCallback, setAliasAndTagsCallback, willPresentNotificationCallback, tagOperatorResult, checkTagOperatorResult, aliasOperatorResult, mobileNumberOperatorResult)
	Logger.debug("[JPushService] setCallback")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		-- local params = json.encode({
		-- 	receiveNotificationCallback = receiveNotificationCallback, 
		-- 	setAliasAndTagsCallback = setAliasAndTagsCallback,
		-- 	tagOperatorResult = tagOperatorResult,
		-- 	checkTagOperatorResult = checkTagOperatorResult,
		-- 	aliasOperatorResult = aliasOperatorResult,
		-- 	mobileNumberOperatorResult = mobileNumberOperatorResult
		-- })
		local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
		local ok, ret
		if currentVersion:compare(Version.new("4.8.0.0")) >= 0 then
			ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setCallback2", {setAliasAndTagsCallback, receiveNotificationCallback, tagOperatorResult, checkTagOperatorResult, aliasOperatorResult, mobileNumberOperatorResult})			
		else
			ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setCallback", {setAliasAndTagsCallback, receiveNotificationCallback})
		end
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "setCallback",{
			registerAPNsSucceedCallback = registerAPNsSucceedCallback,
			registerAPNsFailedCallback = registerAPNsFailedCallback,
			registrationIdCallback = registrationIdCallback,
			receiveNotificationCallback = receiveNotificationCallback, 
			setAliasAndTagsCallback = setAliasAndTagsCallback,
			willPresentNotificationCallback = willPresentNotificationCallback,
			tagOperatorResult = tagOperatorResult,
			checkTagOperatorResult = checkTagOperatorResult,
			aliasOperatorResult = aliasOperatorResult
		})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 设置调试模式，该接口必须在初始化接口前被调用
function JPushService:setDebugMode(debugEnalbed)
	Logger.debug("[JPushService] setDebugMode,%s",tostring(debugEnalbed))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setDebugMode",{debugEnalbed})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "setDebugMode",{debugMode = debugEnalbed})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 内部初始化
function JPushService:_init()
	Logger.debug("[JPushService] _init")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "initialize")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "initialize", 
            {appKey = config.GlobalConfig.getConfig().JPUSH_APPKEY, channel = "AppStor", production = config.GlobalConfig.JPUSH_PRODUCTION})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

function JPushService:getRegistrationID()
	Logger.debug("[JPushService] getRegistrationID")
	if self:isEnabled() == false then return "" end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "getRegistrationID",{},"()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "getRegistrationID")
		if Macro.assetTrue(ok == false, tostring(ret)) then return "" end
		return ret
	end
	
	Macro.assetFalse(false);
end

--校验Tag Alias 只能是数字,英文字母和中文
function JPushService:isValidTagAndAlias(alias)
	local result = true
	local s,n = string.gsub(alias,"^[%w_]+$","");
	if n ~= 1 or s ~= "" then
		result = false
	end
	return result
end

-- 停止推送服务
-- 本功能是一个完全本地的状态操作。也就是说：停止推送服务的状态不会保存到服务器上。
-- 如果停止推送服务后，开发者App被卸载重新安装，JPush SDK 会恢复正常的默认行为。
-- 而清理应用数据的情况，还是必须要调用恢复服务接口才能恢复。
-- 本功能其行为类似于网络中断的效果，即：推送服务停止期间推送的消息，
-- 恢复推送服务后，如果推送的消息还在保留的时长范围内，则客户端是会收到离线消息。
function JPushService:stopPush()
	Logger.debug("[JPushService] stopPush")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "stopPush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "stopPush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 恢复推送服务
-- 本功能是一个完全本地的状态操作。也就是说：停止推送服务的状态不会保存到服务器上。
-- 如果停止推送服务后，开发者App被卸载重新安装，JPush SDK 会恢复正常的默认行为。
-- 而清理应用数据的情况，还是必须要调用恢复服务接口才能恢复。
-- 本功能其行为类似于网络中断的效果，即：推送服务停止期间推送的消息，
-- 恢复推送服务后，如果推送的消息还在保留的时长范围内，则客户端是会收到离线消息。
function JPushService:resumePush()
	Logger.debug("[JPushService] resumePush")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "resumePush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "resumePush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
	
	Macro.assetFalse(false);
end

-- 用来检查 Push Service 是否已经被停止
-- 可以检查权限
function JPushService:isPushStopped()
	Logger.debug("[JPushService] isPushStopped")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "isPushStopped", {},"()Z")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "isPushStopped")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- 调用此 API 来同时设置别名与标签
-- 需要理解的是，这个接口是覆盖逻辑，而不是增量逻辑。即新的调用会覆盖之前的设置。
-- 在之前调用过后，如果需要再次改变别名与标签，只需要重新调用此 API 即可。
-- 参数定义
-- alias:
-- nil 此次调用不设置此值。（注：不是指的字符串"nil"）
-- "" （空字符串）表示取消之前的设置。
-- 每次调用设置有效的别名，覆盖之前的设置。
-- 有效的别名组成：字母（区分大小写）、数字、下划线、汉字、特殊字符(v2.1.6支持)@!#$&*+=.|。
-- 限制：alias 命名长度限制为 40 字节。（判断长度需采用UTF-8编码）
-- tags:
-- nil 此次调用不设置此值。（注：不是指的字符串"nil"）
-- 空数组或列表表示取消之前的设置。
-- 每次调用至少设置一个 tag，覆盖之前的设置，不是新增。
-- 有效的标签组成：字母（区分大小写）、数字、下划线、汉字、特殊字符(v2.1.6支持)@!#$&*+=.|。
-- 限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，但总长度不得超过7K字节。（判断长度需采用UTF-8编码）
-- callback:
-- 在 TagAliasCallback 的 gotResult 方法，返回对应的参数 alias, tags。并返回对应的状态码：0为成功，其他返回码请参考错误码定义。
function JPushService:setAliasAndTags(alias, tags)
	Logger.debug("[JPushService] setAliasAndTags,%s,%s", tostring(alias),tostring(tags))
	if self:isEnabled() == false then return false; end
	
	local _alias = "nil"
	if alias ~= nil then
		_alias = alias
	end
	local _tags = "nil"
	if tags ~= nil then
		_tags = json.encode(tags)
	end

	Logger.debug("[JPushService] setAliasAndTags,%s,%s", tostring(alias),tostring(_tags))
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setAliasAndTags", {_alias, _tags},"(Ljava/lang/String;Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "setAliasAndTags", 
			{alias = _alias, tags = _tags})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 清除所有 JPush 展现的通知（不包括非 JPush SDK 展现的）
function JPushService:clearAllNotifications()
	Logger.debug("[JPushService] clearAllNotifications")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "clearAllNotifications")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end

-- 清除指定某个通知。
function JPushService:clearNotificationById(notificationId)
	Logger.debug("[JPushService] clearNotificationById,%s",tostring(notificationId))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "clearNotificationById",(notificationId),"(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end

-- 设置允许推送时间 API
-- 参数说明
-- Set days 0表示星期天，1表示星期一，以此类推。 （7天制，Set集合里面的int范围为0到6）
-- Sdk1.2.9 – 新功能:set的值为null,则任何时间都可以收到消息和通知，set的size为0，则表示任何时间都收不到消息和通知.
-- int startHour 允许推送的开始时间 （24小时制：startHour的范围为0到23）
-- int endHour 允许推送的结束时间 （24小时制：endHour的范围为0到23）
function JPushService:setPushTime(weekDays, startHour, endHour)
	Logger.debug("[JPushService] setPushTime,%s,%s,%s",tostring(weekDays),tostring(startHour),tostring(endHour))
	if self:isEnabled() == false then return false; end
	
	local _weekDats = "nil"
	if weekDays ~= nil then
		_weekDats = json.encode(weekDays)
	end

	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setPushTime", {_weekDats, startHour, endHour}, "(Ljava/lang/String;II)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	elseif device.platform == "ios" then
		return false
	end
end
	
-- 设置通知静默时间
-- 参数说明
-- int startHour 静音时段的开始时间 - 小时 （24小时制，范围：0~23 ）
-- int startMinute 静音时段的开始时间 - 分钟（范围：0~59 ）
-- int endHour 静音时段的结束时间 - 小时 （24小时制，范围：0~23 ）
-- int endMinute 静音时段的结束时间 - 分钟（范围：0~59 ）
function JPushService:setSilenceTime(startHour, startMinute, endHour, endMinute)
	Logger.debug("[JPushService] setSilenceTime,%s,%s,%s,%s",tostring(startHour),tostring(startMinute),tostring(endHour),tostring(endMinute))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setSilenceTime",
			{startHour,startMinute,endHour,endMinute},"(IIII)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end
	
-- 在 Android 6.0 及以上的系统上，请求一些用到的权限
function JPushService:requestPermission()
	Logger.debug("[JPushService] requestPermission")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "requestPermission")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end
	
-- 设置保留最近通知条数 API
function JPushService:setLatestNotificationNumber(maxNum)
	Logger.debug("[JPushService] setLatestNotificationNumber,%s",tostring(maxNum))
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setLatestNotificationNumber",{maxNum},"(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end

-- 获取推送连接状态
function JPushService:getConnectionState()
	Logger.debug("[JPushService] getConnectionState")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "getConnectionState",{},"()Z")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end


-- addDelayLocalNotification
-- 
-- String title, String subtitle, String dec, int notificationId(Android标识), String identifier(ios标识), int timeInterval（秒）, String json（android额外信息，以json形式传,不需要传""）
function JPushService:addDelayLocalNotification(title, subtitle, dec, notificationId, identifier, timeInterval, jsonstr)
	release_print("[JPushService] addDelayLocalNotification");
	Logger.debug("[JPushService] addDelayLocalNotification")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "addDelayLocalNotification",{title, dec, notificationId, timeInterval, jsonstr},"(Ljava/lang/String;Ljava/lang/String;IILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "addDelayLocalNotification", 
			{title = title, 
			subtitle = subtitle,
			dec = dec,
			identifier = identifier,
			timeInterval = timeInterval
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- addTimeLocalNotification
-- 
--String title, String subtitle, String dec, int notificationId(Android标识), String identifier(ios标识), int year, int month, int day, int hour, int minute, int second, String json（额外信息，以json形式传,不需要传""）
function JPushService:addTimeLocalNotification(title, subtitle, dec, notificationId, identifier, year, month, day, hour, minute, second, jsonstr)
	release_print("[JPushService] addTimeLocalNotification",year,month,day,hour,minute,second);
	Logger.debug("[JPushService] addTimeLocalNotification")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "addTimeLocalNotification",{title, dec, notificationId, year, month, day, hour, minute, second, jsonstr},"(Ljava/lang/String;Ljava/lang/String;IIIIIIILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "addTimeLocalNotification", 
			{title = title, 
			subtitle = subtitle,
			dec = dec,
			identifier = identifier,
			year = year,
			month = month,
			day = day,
			hour = hour,
			minute = minute,
			second = second
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

function JPushService:registerAllLocalNotification()
	release_print("registerAllLocalNotification before11111111111111111111111111111");
	if self:isLocalPushNotEnabled() then
		return false
	end
	release_print("registerAllLocalNotification after22222222222222222222222222222222222");
	local pushInfos = game.service.LocalPushService:getInstance():getLocalPushInfo()
	for _,val in pairs(pushInfos) do
		if val:needPush() then			
			-- if val:getPushType() == 1 then
			-- 	local title, subtitle, dec, notificationId, identifier, timeInterval = val:getPushInfo()
			-- 	self:addDelayLocalNotification(title, subtitle, dec, notificationId, identifier, timeInterval, "")				
			-- else
			local title, subtitle, dec, notificationId, identifier, year, month, day, hour, minute, second = val:getPushInfo()
			self:addTimeLocalNotification(title, subtitle, dec, notificationId, identifier, year, month, day, hour, minute, second, "")				
		end
	end	
end

-- removeLocalNotification
-- int notificationId(Android标识), String identifier(ios标识),
function JPushService:removeLocalNotification(notificationId, identifier)
	Logger.debug("[JPushService] removeLocalNotification")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "removeLocalNotification",{notificationId},"(J)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "removeLocalNotification", 
			{identifier = identifier
			})
		-- if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

function JPushService:clearLocalNotifications()
	Logger.debug("[JPushService] clearLocalNotifications")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "clearLocalNotifications")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "clearLocalNotifications")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	-- Macro.assetFalse(false);
end


-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。

-- alias
-- 每次调用设置有效的别名，覆盖之前的设置。
-- 有效的别名组成：字母（区分大小写）、数字、下划线、汉字、特殊字符@!#$&*+=.|。
-- 限制：alias 命名长度限制为 40 字节。（判断长度需采用UTF-8编码

function JPushService:setAlias(sequence, alias)
	Logger.debug("[JPushService] setAlias")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setAlias", {sequence, alias}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "setAlias", 
			{alias = alias,
			sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。
function JPushService:deleteAlias(sequence)
	Logger.debug("[JPushService] deleteAlias")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "deleteAlias", {sequence}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "deleteAlias", 
			{sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。
function JPushService:getAlias(sequence)
	Logger.debug("[JPushService] getAlias")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "getAlias", {sequence}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "getAlias", 
			{sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。

-- tags
-- 每次调用至少设置一个 tag，覆盖之前的设置，不是新增。
-- 有效的标签组成：字母（区分大小写）、数字、下划线、汉字、特殊字符@!#$&*+=.|。
-- 限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，且单次操作总长度不得超过5000字节。（判断长度需采用UTF-8编码）
-- 单个设备最多支持设置 1000 个 tag。App 全局 tag 数量无限制。

-- tags 传值为数组类型的json
function JPushService:setTags(sequence, tags)
	Logger.debug("[JPushService] setTags")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setTags", {sequence, tags}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "setTags", 
			{tags = tags,
			sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- tags 传值为数组类型的json
function JPushService:addTags(sequence, tags)
	Logger.debug("[JPushService] addTags")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "addTags", {sequence, tags}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "addTags", 
			{tags = tags,
			sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- tags 传值为数组类型的json
function JPushService:deleteTags(sequence, tags)
	Logger.debug("[JPushService] deleteTags")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "deleteTags", {sequence, tags}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "deleteTags", 
			{tags = tags,
			sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。
function JPushService:cleanTags(sequence)
	Logger.debug("[JPushService] cleanTags")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "cleanTags", {sequence}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "cleanTags", 
			{sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end

-- sequence
-- 用户自定义的操作序列号, 同操作结果一起返回，用来标识一次操作的唯一性。
function JPushService:getAllTags(sequence)
	Logger.debug("[JPushService] getAllTags")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "getAllTags", {sequence}, "(I)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "getAllTags", 
			{sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- 查看tag的绑定状态
-- tag 单一指定的tag 为String
function JPushService:checkTagBindState(sequence, tag)
	Logger.debug("[JPushService] checkTagBindState")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "checkTagBindState", {sequence, tag}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("JPushLuaWrapper", "checkTagBindState", 
			{tag = tag,
			sequence = sequence
			})
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
	
	Macro.assetFalse(false);
end


-- 设置手机号接口
-- 该接口会控制调用频率，频率为 10s之内最多三次。
function JPushService:setMobileNumber(sequence, mobileNumber)
	Logger.debug("[JPushService] setMobileNumber")
	if self:isLocalPushNotEnabled() then return false; end
	
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/jpush/JPushLuaWrapper", "setMobileNumber", {sequence, mobileNumber}, "(ILjava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	elseif device.platform == "ios" then
		return false
	end
	
	Macro.assetFalse(false);
end









--------------------------工具函数-----------------------

function JPushService:_checkTable(tbl)
    local new_tbl = {}
    for k, v in pairs( tbl ) do
        if k == "class" then
            -- pass
        elseif type(v) == "function" then
            -- pass
		elseif type(v) == "nil" then
			-- pass
		elseif type(v) == "userdata" then
			-- pass
		elseif type(v) == "thread" then
			-- pass
		elseif type(v) == "table" then
            new_tbl[k] = self:_checkTable(v)
		elseif type(v) == "string" then
			if "" ~= v then
				new_tbl[k] = v
			end
        else
            new_tbl[k] = v
        end
    end
    return new_tbl
end

--------------------------Callback-----------------------
function JPushService:_onRegisterAPNsSucceed(deviceToken)
	Logger.debug("[JPushService] _onRegisterAPNsSucceed," .. deviceToken)
	self:dispatchEvent({name = "EVENT_REGISTERAPNSSUCC", token = deviceToken})
end

function JPushService:_onRegisterAPNsFailed(error)
	Logger.debug("[JPushService] _onRegisterAPNsFailed," .. error)
	self:dispatchEvent({name = "EVENT_REGISTERAPNFAILED", error = error})
	game.service.DataEyeService.getInstance():reportError("RegisterAPNsFailed", error)

	self._registerAPNsFailed = true
end

function JPushService:_onRegistrationId(jsonStr)
	Logger.debug("[JPushService] _onRegistrationId," .. jsonStr)
	local params = json.decode(jsonStr)
	self:dispatchEvent({name = "EVENT_IOS_REGISTRATIONID", code = params.code, registrationID = params.registrationID})
end

function JPushService:_onReceiveNotification(jsonStr)
	release_print("_onReceiveNotification__JsonStr:",jsonStr)
	Logger.debug("[JPushService] _onReceiveNotification," .. jsonStr)
	local params = json.decode(jsonStr)
	local notiType = params.type

	if device.platform == "android" then
		release_print('_onReceiveNotification~~~', notiType)
		local id = tonumber(params["values"]["cn.jpush.android.NOTIFICATION_ID"])
		release_print("NOTIFICATION_ID~~~~~~~~~~", id, type(id))
		if notiType == ReceiveType_Android.REGISTRATION then
			self:dispatchEvent({name = "EVENT_REGISTRATION"})
		elseif notiType == ReceiveType_Android.MESSAGE_RECEIVED	then
		elseif notiType == ReceiveType_Android.NOTIFICATION_RECEIVED then
		elseif notiType == ReceiveType_Android.NOTIFICATION_OPENED then
			local id = tonumber(params["values"]["cn.jpush.android.NOTIFICATION_ID"])
			if type(id) == 'number' and id >= 30000001 and id <32000000 then
				release_print("click local push~~~~~~~~",id)
				game.service.DataEyeService.getInstance():onEvent("JPush_Notification_Open"..params["values"]["cn.jpush.android.NOTIFICATION_ID"])
			else
				release_print("click server push~~~~~~~~~")
				game.service.DataEyeService.getInstance():onEvent("JPush_Notification_Open_Server")
			end
		elseif notiType == ReceiveType_Android.ACTION_NOTIFICATION_CLICK_ACTION then
		elseif notiType == ReceiveType_Android.ACTION_CONNECTION_CHANGE then
		end
	elseif device.platform == "ios" then
		if notiType == ReceiveType_iOS.CONNECTING then
		elseif notiType == ReceiveType_iOS.CONNECTED then
		elseif notiType == ReceiveType_iOS.CONNECCLOSE then
		elseif notiType == ReceiveType_iOS.REGISTRATION then
		elseif notiType == ReceiveType_iOS.REGISTRATIONFAILED then
			game.service.DataEyeService.getInstance():reportError("RegisterFailed", "RegisterFailed")
		elseif notiType == ReceiveType_iOS.LOGIN then
			-- 只有iOS有Login事件
			self:dispatchEvent({name = "EVENT_REGISTRATION"})
		elseif notiType == ReceiveType_iOS.MESSAGE_RECEIVED then
		elseif notiType == ReceiveType_iOS.NOTIFICATION_OPENED then
			game.service.DataEyeService.getInstance():onEvent("JPush_Notification_Open")
			local str = ""
			local url = string.format(config.UrlConfig.getBIUrl(),"jiguang_request")
			local roleId = game.service.LocalPlayerService.getInstance():getRoleId()
			local obj = {
				messageid = params.messageid or ("%s-%s"):format(roleId, os.time()),
				time = os.time(),
				title = params.title or "",
				content = params.content or params.body or "",
				platform = device.platform,
				--url = url,
			}
			str = json.encode(obj)
			kod.util.Http.uploadInfo(obj,url)

			--game.ui.UIMessageBoxMgr.getInstance():show(str, {"ok"})
		end
	end
end

function JPushService:_onSetAliasAndTags(jsonStr)
	Logger.debug("[JPushService] _onSetAliasAndTags," .. jsonStr)
	local tab = json.decode(jsonStr)
	 --设置别名标签 code，alias，tag
	self:dispatchEvent({name = "EVENT_ONSETALIASANDTAGS", code = tab.code, alias = tab.alias, tags = tab.tags})
end

function JPushService:_onWillPresentNotification(jsonStr)
	Logger.debug("[JPushService] _onWillPresentNotification," .. jsonStr)
	local params = json.decode(jsonStr)
	return false;
end


-- tag 之类的操作在此类方法回调
function JPushService:_onTagOperatorResult(jsonStr)
	Logger.debug("[JPushService] _onTagOperatorResult," .. jsonStr)
	local params = json.decode(jsonStr)
	return false;
end

-- 检查tag 在此类方法回调
function JPushService:_onCheckTagOperatorResult(jsonStr)
	Logger.debug("[JPushService] _onCheckTagOperatorResult," .. jsonStr)
	local params = json.decode(jsonStr)
	return false;
end

-- alias 再次方法中回调
function JPushService:_onAliasOperatorResult(jsonStr)
	Logger.debug("[JPushService] _onAliasOperatorResult," .. jsonStr)
	local params = json.decode(jsonStr)
	return false;
end

-- 绑定手机回调（目前之有android）
function JPushService:_onMobileNumberOperatorResult(jsonStr)
	Logger.debug("[JPushService] _onMobileNumberOperatorResult," .. jsonStr)
	local params = json.decode(jsonStr)
	return false;
end

function JPushService:_onUserLoginSuccess()
	Logger.debug("[JPushService] _onUserLoginSuccess _registerAPNsFailed = " .. tostring(self._registerAPNsFailed))
	if self._registerAPNsFailed then
	--if true then
		local service = game.service.LocalPlayerService:getInstance()
		if service then
			local roleId = service:getRoleId()
			Logger.debug("[JPushService] roleId = " .. tostring(roleId or "nil"))
			if roleId and roleId ~= 0 then
				local url = config.UrlConfig.getBIUrl("registration_push_failed")
				local obj = {
					roleId = roleId,
					platform = device.platform,
					proVersion = game.service.UpdateService.getInstance():getProductVersion():getVersions()[1],
					libVersion = game.plugin.Runtime.getBuildVersion(),
				}
				kod.util.Http.uploadInfo(obj, url)
				Logger.debug("[JPushService] send BI Request, obj = " .. json.encode(obj))
			end
		else
			Logger.debug("[JPushService] LocalPlayerService is a nil value")
		end
	end
end

