local ns = namespace("game.service")

local Version = require "app.kod.util.Version"

-- 事件
-- EVENT_AUTH_RESP
-- {
--	errCode:int
--	errStr:string
-- 	code:string
-- 	state:string
-- }
-- EVENT_SEND_RESP
-- {
--	errCode:int
--	errStr:string
-- }

local GetuiService = class("GetuiService")
ns.GetuiService = GetuiService

-- 单例支持
-- @return LoginService
function GetuiService:getInstance()
    return manager.ServiceManager.getInstance():getGetuiService();
end

function GetuiService:ctor()
	cc.bind(self, "event");
	self._clientId = ""
end

function GetuiService:initialize()
    local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
    if currentVersion:compare(Version.new("4.10.0.0")) >= 0 then
        self:_init(handler(self, self._onReceiveMessages),
        handler(self, self._onReceiveClientId), 
        handler(self, self._onReceiveOnlineState), 
        handler(self, self._onSetTagResult),
		handler(self, self._onBindAliasResult),
		handler(self, self._onUnbindAliasResult),
		handler(self, self._feedbackResult),
		handler(self, self._onNotificationMessageArrived),
		handler(self, self._onNotificationMessageClicked));
    end
	
end

function GetuiService:dispose()
	cc.unbind(self, "event");
end

function GetuiService:isEnabled()
	return game.plugin.Runtime.isEnabled();
end

function GetuiService:isNewEnabled()
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	if currentVersion:compare(Version.new("4.10.0.0")) >= 0 then
		return true
	else
		return false
	end
end


function GetuiService:_init(onReceiveMessages, onReceiveClientId, onReceiveOnlineState, onSetTagResult, onBindAliasResult, onUnbindAliasResult, feedbackResult, onNotificationMessageArrived, onNotificationMessageClicked)
	-- Logger.debug("initialize")
	if self:isEnabled() == false then return false; end
	
	if device.platform == "android" then
		local param = { 
			onReceiveMessages, 
			onReceiveClientId, 
			onReceiveOnlineState, 
			onSetTagResult, 
			onBindAliasResult,
			onUnbindAliasResult,
			feedbackResult,
			onNotificationMessageArrived, 
			onNotificationMessageClicked
		}
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "initialize", param, "(IIIIIIIII)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		Logger.debug("initialize"..tostring(ret))
		return ret;
	end
end


-- 停止SDK服务
function GetuiService:stopService()
	Logger.debug("[GetuiService] stopService")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "stopService")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 开启推送
function GetuiService:turnOnPush()
	Logger.debug("[GetuiService] turnOnPush")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "turnOnPush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 关闭推送
function GetuiService:turnOffPush()
	Logger.debug("[GetuiService] turnOffPush")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "turnOffPush")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 设置标签
-- tags String "," 分开
-- sn - 用户自定义的序列号，用来唯一标识该动作 
function GetuiService:setTag(tags, sn)
	Logger.debug("[GetuiService] setTag")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "setTag", {tags, sn}, "(Ljava/lang/String;Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end


-- 设置静默时间
-- beginHour：开始时间，设置范围在0-23小时之间，单位 h
-- Duration：持续时间，设置范围在0-23小时之间。持续时间为0则不静默，单位 h
-- 1 成功 0 失败
function GetuiService:setSilentTime(beginHour, duration)
	Logger.debug("[GetuiService] setSilentTime")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "setSilentTime", {beginHour, duration}, "(II)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 自定义回执
-- 1 成功 0 失败
-- 1 成功 0 失败
function GetuiService:sendFeedbackMessage(taskid, messageid, actionid)
	Logger.debug(("[GetuiService] sendFeedbackMessage taskId:%s, messageId:%s, actionId:%s"):format(taskid or "nil", messageid or "nil", actionid or "nil"))
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		if taskid and messageid and actionid then
			local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "sendFeedbackMessage", {taskid, messageid, actionid}, "(Ljava/lang/String;Ljava/lang/String;I)I")
			if Macro.assetTrue(ok == false, tostring(ret)) then return false end
			return ret
		end
	end
end

-- 发送Applink点击回执
-- 1 成功 0 失败
function GetuiService:sendApplinkFeedback(url)
	Logger.debug("[GetuiService] sendApplinkFeedback")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "sendApplinkFeedback", {url}, "(Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 绑定别名
-- alias – 别名名称：长度40字节，支持中、英文（区分大小写）、数字以及下划线
-- sn - 用户自定义的序列号，用来唯一标识该动作
-- 1 成功 0 失败
function GetuiService:bindAlias(alias, sn)
	Logger.debug("[GetuiService] bindAlias")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "bindAlias", {alias, sn}, "(Ljava/lang/String;Ljava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end



-- 解绑别名
-- alias – 别名名称：长度40字节，支持中、英文（区分大小写）、数字以及下划线
-- isSelf：是否只对当前 cid 有效，如果是 1，只对当前cid做解绑；如果是 0，对所有绑定该别名的cid列表做解绑
-- sn - 用户自定义的序列号，用来唯一标识该动作, 自定义 IntentService 中会回执该结果

function GetuiService:unBindAlias(alias, isSelf, sn)
	Logger.debug("[GetuiService] unBindAlias")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "unBindAlias", {alias, sn}, "(Ljava/lang/String;ILjava/lang/String;)I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 设置Tag的Name
-- Name：需要传入的Tag名，只支持以下：中文、英文字母（大小写）、数字、除英文逗号以外的其他特殊符号
function GetuiService:setName(name)
	Logger.debug("[GetuiService] setName")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "setName", {name}, "(Ljava/lang/String;)V")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return true
	end
end

-- 获取Clientid
function GetuiService:getClientid()
	Logger.debug("[GetuiService] getClientid")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "getClientid", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- //获取SDK服务状态
-- 1：当前推送已打开
-- 0：当前推送已关闭
function GetuiService:isPushTurnedOn()
	Logger.debug("[GetuiService] isPushTurnedOn")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "isPushTurnedOn", {}, "()I")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end

-- 获取SDK版本号
function GetuiService:getVersion()
	Logger.debug("[GetuiService] getVersion")
	if self:isNewEnabled() == false then return false; end
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("com/lohogames/common/getui/GetuiLuaWrapper", "getVersion", {}, "()Ljava/lang/String;")
		if Macro.assetTrue(ok == false, tostring(ret)) then return false end
		return ret
	end
end



function GetuiService:_onReceiveMessages(jsonstr)
	Logger.debug("_onGetMessageFromWXReq,%s", jsonstr)
	-- loho.messageBox("_onReceiveMessages, " .. jsonstr)
end

function GetuiService:_onReceiveClientId(jsonstr)
	Logger.debug("_onReceiveClientId,%s", jsonstr)
	-- loho.messageBox("_onReceiveClientId, " .. jsonstr)
	local obj = json.decode(jsonstr)
	self._clientId = obj.clientid
end

function GetuiService:_onReceiveOnlineState(jsonstr)
	Logger.debug("_onReceiveOnlineState,%s", jsonstr)
	-- loho.messageBox("_onReceiveOnlineState, " .. jsonstr)
end

function GetuiService:_onSetTagResult(jsonstr)
	Logger.debug("_onSetTagResult,%s", jsonstr)
	-- loho.messageBox("_onSetTagResult, " .. jsonstr)
end

function GetuiService:_onBindAliasResult(jsonstr)
	Logger.debug("_onBindAliasResult,%s", jsonstr)
	-- loho.messageBox("_onBindAliasResult, " .. jsonstr)
end

function GetuiService:_onUnbindAliasResult(jsonstr)
	Logger.debug("_onUnbindAliasResult,%s", jsonstr)
	-- loho.messageBox("_onUnbindAliasResult, " .. jsonstr)
end

function GetuiService:_feedbackResult(jsonstr)
	Logger.debug("_feedbackResult,%s", jsonstr)
	-- loho.messageBox("_feedbackResult, " .. jsonstr)
end

function GetuiService:_onNotificationMessageArrived(jsonstr)
	Logger.debug("_onNotificationMessageArrived,%s", jsonstr)
	-- loho.messageBox("_onNotificationMessageArrived, " .. jsonstr)
end

function GetuiService:_onNotificationMessageClicked(jsonstr)
	Logger.debug("_onNotificationMessageClicked,%s", jsonstr)
	-- loho.messageBox("_onNotificationMessageClicked, " .. jsonstr)
	local obj = json.decode(jsonstr)
	if obj.content and obj.title and obj.messageid then
		obj.time = os.time()
		obj.platform = device.platform
		local url = string.format(config.UrlConfig.getBIUrl(),"jiguang_request")
		kod.util.Http.uploadInfo(obj,url)
		-- actionId 是前后端约定的
		self:sendFeedbackMessage(obj.taskid, obj.messageid, 90001)
	end
end

function GetuiService:getRegisterId()
	return self._clientId
end