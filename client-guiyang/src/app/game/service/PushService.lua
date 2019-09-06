local ns = namespace("game.service")


local PushService = class("PushService")
ns.PushService = PushService

-- 服务器定义的推送类型
local PushType = 
{
	Null = 0,
	StartBattle = 1,
	DismissRoom = bit.lshift(1, 1),
	StartCampaign = bit.lshift(1, 2),
	All = 0xfffffff
}
PushService.PushType = PushType

----------------------------------
-- 推送相关的本地存储
local PushSetting = class("PushSetting")
function PushSetting:ctor()
	self.registrationId = nil
	self.pushType = PushType.All
end

-- 单例
function PushService.getInstance()
	if game.service.LocalPlayerService.getInstance() == nil then
		return nil
	end
	return game.service.LocalPlayerService.getInstance():getPushService();
end

function PushService:ctor()
	self._roleId = nil
	self._pushServerId = nil
	self._pushSetting = nil
	self.eventRegistered = false
end

function PushService:initialize()
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.GCUploadRolePushTypeRES.OP_CODE, self, self._onGCUploadRolePushTypeRES);
	requestManager:registerResponseHandler(net.protocol.GCUploadPushInfoRES.OP_CODE, self, self._onGCUploadRolePushInfoRES);

	-- 监听上报模块的事件，当上报模块初始化完成后，上报相应数据
	game.service.DataEyeService.getInstance():addEventListener("EVENT_DATA_SERVICE_LOGINED", handler(self, self._updateStatus), self)
	-- 先不注册事件, 等到请求成功之后再注册, 防止请求之前收到注册结果
end

function PushService:dispose()
	game.service.JPushService.getInstance():removeEventListenersByTag(self)
	game.service.DataEyeService.getInstance():removeEventListenersByTag(self)
end

function PushService:_registerEvent()	
	if self.eventRegistered == false then
		-- 注册事件, 确保只注册一次
		game.service.JPushService.getInstance():addEventListener("EVENT_REGISTRATION", handler(self, self._trySendRegistrationId), self)
		self.eventRegistered = true
	end
end

-- 加载本地数据
function PushService:loadLocalStorage()
	self._pushSetting = manager.LocalStorage.getUserData(self._roleId, "PushSetting", PushSetting);

	--现在默认给牌局推送打开
	if not self:isPushTypeEnabled(game.service.PushService.PushType.StartBattle) then
		self:enablePushType(game.service.PushService.PushType.StartBattle, true)
	end
end

-- 上报事件
function PushService:_updateStatus()
	-- 为防止，从没有设置过此选项的时候，没有上传数据，在加载的时候就要上传
	game.service.DataEyeService.getInstance():onStatusEvent("PushSwitch", "PushSwitch_"..(self:isPushTypeEnabled(PushType.All) and "On" or "Off"))
end

-- 保存本地数据
function PushService:_saveLocalSetting()
	manager.LocalStorage.setUserData(self._roleId, "PushSetting", self._pushSetting);
end

function PushService:setId(roleId, pushServerId)
	self._roleId = roleId;
	self._pushServerId = pushServerId
end

function PushService:isPushTypeEnabled(pushType)
	return bit.band(self._pushSetting.pushType, pushType) ~= 0
end

function PushService:enablePushType(pushType, enable)
	if self:isPushTypeEnabled(pushType) == enable then
		-- 没有改变, 不用设置
		return
	end

	-- 设置参数
	-- 说明一下，现在只有两个状态，但是开关只有一个，所以现在:开是一起开，关是一起关
	if enable == true then
		self._pushSetting.pushType = PushType.All
	else
		self._pushSetting.pushType = PushType.Null
	end
	self:_saveLocalSetting()
	-- 请求改变设置	
	self:_sendCGUploadRolePushTypeREQ(self._pushSetting.pushType)
	if PushType.All == pushType then
		-- 更新状态上传，现在只有一种状态，但是还是判断一下吧
		game.service.DataEyeService.getInstance():onStatusEvent("PushSwitch", "PushSwitch_"..(self:isPushTypeEnabled(pushType) == true and "On" or "Off"))
	end
end

function PushService:_trySendRegistrationId()
	

	local id = game.service.JPushService.getInstance():getRegistrationID()
	Logger.debug("[PushService] _trySendRegistrationId~~~~~~~~"..id)
	local getuiId = game.service.GetuiService.getInstance():getRegisterId()
	-- RegistrationID获取失败，说明还没有注册成功
	if (id ~= nil and id ~= "") or (getuiId ~= nil and getuiId ~= "") then
		-- _pushRegistrationId已经获取到了，不应该重复发送
		if self._pushSetting.registrationId ~= id or self._pushSetting.getuiId ~= getuiId then
			-- 上传RegistrationId
			Logger.debug("_sendCGUploadRolePushInfoREQ")
			self:_sendCGUploadRolePushInfoREQ(id, getuiId)
		end
	end
end

function PushService:setRegisterId( id , getuiId)
	if self._pushSetting.registrationId ~= id or self._pushSetting.getuiId ~= getuiId then
		self._pushSetting.registrationId = id
		self._pushSetting.getuiId = getuiId
		self:_saveLocalSetting()
	end
	-- 尝试上报registrationId		
	self:_trySendRegistrationId();
	-- 防止在获取过程中收到注册成功事件, 延迟注册
	self:_registerEvent()
end

-- 上传客户端的推送id
function PushService:_sendCGUploadRolePushInfoREQ(id, getuiId)
	local request = net.NetworkRequest.new(net.protocol.CGUploadPushInfoREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(self._roleId, game.plugin.Runtime.getChannelId(), id, getuiId)
	game.util.RequestHelper.request(request)
end

-- 上传客户端的推送id结果
function PushService:_onGCUploadRolePushInfoRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	if protocol.result == net.ProtocolCode.GC_UPLOAD_PUSHINFO_SUCCESS then
		-- 成功了
	else
		-- TODO : 统计错误
	end
end


-- 设置推送设置
function PushService:_sendCGUploadRolePushTypeREQ(pushType)
	local request = net.NetworkRequest.new(net.protocol.CGUploadRolePushTypeREQ, game.service.LocalPlayerService:getInstance():getGameServerId())
	request:getProtocol():setData(self._roleId, pushType)
	-- request:setWaitForResponse(false)
	game.util.RequestHelper.request(request)
end

-- 设置推送设置结果
function PushService:_onGCUploadRolePushTypeRES(response)
	local protocol = response:getProtocol():getProtocolBuf();
	if protocol.result == net.ProtocolCode.GC_UPLOAD_ROLE_PUSHTYPE_SUCCESS then
		-- 成功了
	else
		-- TODO : 统计错误
	end
end