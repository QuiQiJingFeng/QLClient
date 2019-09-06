--[[
安全监测逻辑
-- 新玩家加入房间的时候进行GPS监测

事件EVENT
EVENT_SRCURITY_PLAYER_ENTERED
EVENT_SRCURITY_STATUS_CHANGED
EVENT_SRCURITY_INFO_INITIALIZED
EVENT_SRCURITY_INFO_CHANGED

技术设计
1. 收到用户加入房间, 
	0. 什么算是用户加入房间
		1. 本地保存当前的房间Id,是否已经开始,房间的用户ID,
		2. 如果房间Id不一样, 清空
		3. 如果当前服务器下发的安全信息条目与不在本地保存, 或者保存的不一样, 提示呼吸灯
	1. 执行检测逻辑, 获得检测结果
	2. 播放检测动画(如果正在播放检测动画, 不需要重新播放)
	3. 检测动画完成之后, 显示检测结果
	4. 检测结果显示
		4.0 危险的定义:关闭GPS, GPS失败, 距离过近
		4.1 没有危险, 显示正常状态
			4.1.1 如果当前有呼吸灯, 停止呼吸灯
		4.2 有冲突, 相对上一次检测有新加的冲突条目, 激活提醒呼吸灯
			4.2.1 如果有呼吸灯, 不再重复播放呼吸灯
		4.3 呼吸灯时间结束之后, 根据现在的冲突结果, 显示图标状态
2. 用户加入房间
	1. 获取GPS
	2. 如果GSP关闭(各种关闭状态)
		1. 上报GSP关闭
	3. GPS获取失败
		1. 重试
		2. 重试超过10次, 认为失败, 上报GPS失败
	4. 获取成功, 上报GPS
	
测试点:
	1. GpsUI
		1. 安全状态界面为绿色
		2. 不安全状态界面为蓝色
	2. 

注意生命同期问题：
	因为其是RoomService下的子Service，其生命周期与RoomService相同
	监听其事件，需要注册RoomCreatorService的RoomService初始化完成消息，然后去完成相关监听处理
--]]
local UNSAFE_DISTANCE = 500;
local GPS_TRY_TIMES = 10;

local SecurityInfo = class("SecurityInfo")
function SecurityInfo:ctor()
	self.roomId = 0;
	self.lastCheckedRoomId = 0; -- 记录上一次进入的房间, 只有第一进入房间的时候才播放自己的Check动画
	-- {roleId, ip, gpsStatus, latitude, longitude}
	self.playerInfos = {}
	-- {roleId...}
	self.ipConflictPlayerIds = {}
	-- { [status, roleId, conflictRoleId] }
	self.gpsConflictInfos = {}
end

function SecurityInfo:init(roomId, lastCheckedRoomId)
	self.roomId = roomId;
	self.lastCheckedRoomId = lastCheckedRoomId;
	return self;
end

local GpsConflictRoom = class("GpsConflictRoom")
function GpsConflictRoom:ctor()
	self.lastConflictRoom = 0;
end

-------------------------
local ServerGPSStatus = {
	DEFAULT = 1,	-- 默认（正在检测中）
	CLOSE = 2,		-- 关闭
	FAIL = 3,		-- 失败
	SUCCESS = 4,	-- 成功
}

local SecurityChecker = class("SecurityChecker")

SecurityChecker.GPSCheckStatus = {
	DEFAULT = 1,	-- 默认（正在检测中）
	CLOSE = 2,      -- 关闭
	FAIL = 3,       -- 失败
	SUCCESS = 4,    -- 成功
	UNSAFE = 5;		-- 有冲突
}

function SecurityChecker:ctor(roomService)
	self._isEnable = true;
	self._roomService = roomService;
	self._securityInfo = nil;
	self._lastSecurityInfo = nil;

	-- 绑定事件系统
	cc.bind(self, "event");
	
	local requestManager = net.RequestManager.getInstance();
	requestManager:registerResponseHandler(net.protocol.BCRoomPlayerInfoSYN.OP_CODE, self, self._onRoomPlayerInfoSYN);
	requestManager:registerResponseHandler(net.protocol.BCGpsInfoRES.OP_CODE, self, self._onBCGpsInfoRES);
	requestManager:registerResponseHandler(net.protocol.BCSecureDetectSYN.OP_CODE, self, self._onBCSecureDetectSYN);

	-- 注册定位服务器回调
	game.service.AMapService.getInstance():addEventListener("EVENT_GET_LOCATION_SUCCESS", handler(self, self._onGetLocationSuccess), self)
	game.service.AMapService.getInstance():addEventListener("EVENT_GET_LOCATION_FAILED", handler(self, self._onGetLocationFailed), self)	
end

function SecurityChecker:dispose()
	self._securityInfo = nil
	self:_saveLastSecurityInfo();

	cc.unbind(self, "event");
	net.RequestManager.getInstance():unregisterResponseHandler(self);
	game.service.AMapService.getInstance():removeEventListenersByTag(self)
end

function SecurityChecker:isEnable()
	return self._isEnable;
end

function SecurityChecker:setEnable(tf)
	self._isEnable = tf;
end

function SecurityChecker:isFirstTimeCheck()
	return self._securityInfo.lastCheckedRoomId ~= self._securityInfo.roomId;
end

function SecurityChecker:setChecked()
	self._securityInfo.lastCheckedRoomId = self._securityInfo.roomId;
	-- 先不存盘, 这个时候玩家数据还没有到, 会清空本地数据
end

function SecurityChecker:getPlayerCount()
	return #self._securityInfo.playerInfos;
end

function SecurityChecker:loadLastSecurityInfo()
	local roomId = game.service.LocalPlayerService:getInstance():getRoleId()
	self._lastSecurityInfo = manager.LocalStorage.getUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "LastSecurityInfo", SecurityInfo);
end

function SecurityChecker:_saveLastSecurityInfo()
	local roomId = game.service.LocalPlayerService:getInstance():getRoleId()
	self._lastSecurityInfo = self._securityInfo and clone(self._securityInfo) or SecurityInfo.new();
	manager.LocalStorage.setUserData(game.service.LocalPlayerService:getInstance():getRoleId(), "LastSecurityInfo", self._lastSecurityInfo);
end

function SecurityChecker:isSafe()
	if #self._securityInfo.ipConflictPlayerIds ~= 0 then
		return false 
	end		

	for _,info in ipairs(self._securityInfo.gpsConflictInfos) do
		if info.status == SecurityChecker.GPSCheckStatus.CLOSE
			or info.status == SecurityChecker.GPSCheckStatus.FAIL 
			or info.status == SecurityChecker.GPSCheckStatus.UNSAFE then
			return false;
		end
	end
	
	return true;
end

function SecurityChecker:getSecurityInfo()
	return self._securityInfo;
end

function SecurityChecker:_checkSecurity()
	--分别记录同ip和距离过近的总次数
	local sameIpNum = 0;
	local samePosNum = 0;

	-- 检测IP冲突
	self._securityInfo.ipConflictPlayerIds = {}
	for i=1,#self._securityInfo.playerInfos do
		local player1 = self._securityInfo.playerInfos[i];

		-- 检测冲突
		for j=i+1,#self._securityInfo.playerInfos do
			local player2 = self._securityInfo.playerInfos[j];
			if player1.ip == player2.ip then
				sameIpNum = sameIpNum + 1;
				if table.indexof(self._securityInfo.ipConflictPlayerIds, player1.roleId) == false then
					table.insert(self._securityInfo.ipConflictPlayerIds, player1.roleId);
				end
				if table.indexof(self._securityInfo.ipConflictPlayerIds, player2.roleId) == false then
					table.insert(self._securityInfo.ipConflictPlayerIds, player2.roleId);
				end
			end
		end
	end
	
	-- 检测GPS信息
	self._securityInfo.gpsConflictInfos = {}
	self._securityInfo.gpsDistanceInfos = {}
	for i=1,#self._securityInfo.playerInfos do
		local player1 = self._securityInfo.playerInfos[i];
		Logger.debug("player1.gpsStatus = %s", player1.gpsStatus)
		if player1.gpsStatus ~= ServerGPSStatus.SUCCESS then
			-- 没有获取GPS信息
			table.insert(self._securityInfo.gpsConflictInfos, {
				status = player1.gpsStatus, 
				roleId = player1.roleId,
				conflictRoleId = 0,
			})

			for j=i+1,#self._securityInfo.playerInfos do
				-- 处理其它的几条全是未知
				local player2 = self._securityInfo.playerInfos[j];
				table.insert(self._securityInfo.gpsDistanceInfos, {
					status = player1.gpsStatus, 
					roleId = player1.roleId,
					conflictRoleId = player2.roleId,
					distance = -1,
				})
			end
		else
			-- 获取到GPS信息, 检测冲突
			for j=i+1,#self._securityInfo.playerInfos do
				local player2 = self._securityInfo.playerInfos[j];
				local dis = -1
				Logger.debug("player2.gpsStatus = %s", player2.gpsStatus)
				if player2.gpsStatus == ServerGPSStatus.SUCCESS then
					dis = self:_getDistance(player1.latitude, player1.longitude, player2.latitude, player2.longitude)
				end

				if player2.gpsStatus == ServerGPSStatus.SUCCESS and dis < UNSAFE_DISTANCE then
					samePosNum = samePosNum + 1;
					-- 距离过近
					table.insert(self._securityInfo.gpsConflictInfos, {
						status = SecurityChecker.GPSCheckStatus.UNSAFE, 
						roleId = player1.roleId,
						conflictRoleId = player2.roleId,
					})
				end

				-- 将计算的距离保存下来
				table.insert(self._securityInfo.gpsDistanceInfos, {
					status = player1.gpsStatus, 
					roleId = player1.roleId,
					conflictRoleId = player2.roleId,
					distance = dis,
				})
			end
		end	
	end

	if self:_checkSecurityChanged() == false then
		-- 对比上一次的数据没有变化, 不需要后续的检测
		return;
	end

	if self:_checkPlayerEntered() == true then
--		Logger.debug("EVENT_SRCURITY_PLAYER_ENTERED")
		self:dispatchEvent({name = "EVENT_SRCURITY_PLAYER_ENTERED"});
	end
	
	if self:isSafe() then
		-- 安全
--		Logger.debug("EVENT_SRCURITY_STATUS_CHANGED, true")
		self:dispatchEvent({name = "EVENT_SRCURITY_STATUS_CHANGED", safe = true});
	elseif self:_checkSecurityWarning() == true then
		-- 产生了新的冲突
--		Logger.debug("EVENT_SRCURITY_STATUS_CHANGED, false")
		self:dispatchEvent({name = "EVENT_SRCURITY_STATUS_CHANGED", safe = false});
	end
	
	-- 数据产生了变化
--	Logger.debug("EVENT_SRCURITY_INFO_CHANGED, false")
	self:dispatchEvent({name = "EVENT_SRCURITY_INFO_CHANGED"});
	self:_saveLastSecurityInfo();

	-- 发送同ip数量，gps冲突数量
	game.service.RoomService:getInstance():CBIpSameREQ(sameIpNum,samePosNum)
end

function SecurityChecker:_checkPlayerEntered()
	return #self._securityInfo.playerInfos > #self._lastSecurityInfo.playerInfos
end

function SecurityChecker:_checkSecurityChanged()
	-- 检测IP冲突组是否有变化
	if #self._securityInfo.ipConflictPlayerIds ~= #self._lastSecurityInfo.ipConflictPlayerIds then
		-- 组数量不一样
		return true
	else
		-- 检测RoleId是否一致
		for i,roleId in ipairs(self._securityInfo.ipConflictPlayerIds) do
			if roleId ~= self._lastSecurityInfo.ipConflictPlayerIds[i] then
				return true;
			end
		end
	end
	
	if #self._securityInfo.gpsConflictInfos ~= #self._lastSecurityInfo.gpsConflictInfos then
		-- 组数量不一样
		return true
	else
		for i,info in ipairs(self._securityInfo.gpsConflictInfos) do
			local lastInfo = self._lastSecurityInfo.gpsConflictInfos[i];
			if info.status ~= lastInfo.status or info.roleId ~= lastInfo.roleId or info.conflictRoleId ~= lastInfo.conflictRoleId then
				-- 相对应的组, 信息不一样
				return true
			end
		end
	end
	
	return false;
end

function SecurityChecker:_checkSecurityWarning()
	-- 与上一次比较, 
	local showWarning = false;
	local changed = false;
	Macro.assertFalse(self._securityInfo.roomId == self._lastSecurityInfo.roomId);
	
	-- 比较IP, 检测ip冲突组有没有变化
	for _,roleId in ipairs(self._securityInfo.ipConflictPlayerIds) do
		if table.indexof(self._lastSecurityInfo.ipConflictPlayerIds, roleId) == false then
			-- 新的冲突id
			return true;
		end		
	end
	
	-- 比较GPS
	for v,gpsInfo in ipairs(self._securityInfo.gpsConflictInfos) do
		if gpsInfo.status == SecurityChecker.GPSCheckStatus.CLOSE 
			or gpsInfo.status == SecurityChecker.GPSCheckStatus.FAIL 
			or gpsInfo.status == SecurityChecker.GPSCheckStatus.UNSAFE then
			-- 获取信息有问题, 检测状态
			local hasInfo = false;
			for j=1,#self._lastSecurityInfo.gpsConflictInfos do
				local lastGpsInfo = self._lastSecurityInfo.gpsConflictInfos[j]
				if gpsInfo.status == lastGpsInfo.status 
					and gpsInfo.roleId == lastGpsInfo.roleId 
					and gpsInfo.conflictRoleId == lastGpsInfo.conflictRoleId then
					hasInfo = true;
				end
			end
			
			if hasInfo == false then
				-- 产生了新的不安全信息
				return true;
			end
		end
	end
	
	return false;
end

--[[
* 根据两点的经纬度，计算出其之间的距离（返回单位为m）
* @param lat1 纬度1
* @param lng1 经度1
* @param lat2 纬度2
* @param lng2 经度2
* @return
--]]
function SecurityChecker:_getDistance(lat1, lng1, lat2, lng2)
	local EARTH_RADIUS = 6378137 --地球半径 米
	local radLat1 = math.rad(lat1)
	local radLat2 = math.rad(lat2)
	local a = math.rad(lat1) - math.rad(lat2)
	local b = math.rad(lng1) - math.rad(lng2)
	local _s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2),2) + math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)))
	_s = _s * EARTH_RADIUS
	local _z,_y = math.modf(_s * 100)
	if _y > 0.5 then
		_s = _z + 1
	else
		_s = _z
	end
	_s = _s / 100.0
	Logger.debug("_getDistance, lat1 = %s, lng1 = %s, lat2 = %s, lng2 = %s, _s = %s", lat1, lng1, lat2, lng2, _s)
	return _s
end

function SecurityChecker:_reportLocalInfo()
	if self:isEnable() == false then return end
	
	if game.service.AMapService.getInstance():isLocationServiceEnabled() == false then
		self:_sendCBGpsInfoREQ(ServerGPSStatus.CLOSE, 0, 0);
		return
	end
		
	self:_startGps();	
end

function SecurityChecker:_startGps()
	if self:isEnable() == false then return end
    --如果执行安全监测的时候缓存的位置还没有失效，就使用缓存的位置信息
    local location = game.service.LocalPlayerService:getInstance():getGpsLocationInfo()
    if location and location.expireTime > kod.util.Time.now() then
        self:_sendCBGpsInfoREQ(ServerGPSStatus.SUCCESS, location.latitude, location.longitude)
        game.service.LocalPlayerService.getInstance():updateAccountGpsInfo(location.province, location.city, location.district)
        return
    end
	game.service.AMapService.getInstance():startLocation(true);

	-- 之前可能是失败状态, 重新发起检测
	Macro.assertFalse(self._securityInfo ~= nil)
	local localPlayerId = game.service.LocalPlayerService.getInstance():getRoleId();
	for _,player in ipairs(self._securityInfo.playerInfos) do
		if player.roleId == localPlayerId and player.gpsStatus ~= ServerGPSStatus.DEFAULT then
			self:_sendCBGpsInfoREQ(ServerGPSStatus.DEFAULT, 0, 0);
		end
	end
end

function SecurityChecker:_onGetLocationSuccess(event)
--	Logger.debug("_onGetLocationSuccess,%f,%f", event.latitude, event.longitude)
	self:_sendCBGpsInfoREQ(ServerGPSStatus.SUCCESS, event.latitude, event.longitude);
    game.service.LocalPlayerService.getInstance():updateAccountGpsInfo(event.province, event.city, event.district)
end

function SecurityChecker:_onGetLocationFailed(event)
--	Logger.debug("_onGetLocationFailed")
	self:_sendCBGpsInfoREQ(ServerGPSStatus.FAIL, 0, 0);
end

-- 本地玩家加入房间
function SecurityChecker:onEnterRoomRes(response)
	local request = response:getRequest():getProtocol():getProtocolBuf();
	local protocol = response:getProtocol():getProtocolBuf();
	
	if protocol.result ~= net.ProtocolCode.BC_ENTER_ROOM_SUCCESS and protocol.result ~= net.ProtocolCode.BC_WATCH_BATTLE_SUCCESS then
		return;
	end

	self._securityInfo = SecurityInfo.new():init(request.roomId, self._lastSecurityInfo.lastCheckedRoomId);

	if self._lastSecurityInfo.roomId ~= request.roomId then
		-- 与上一次加入的房间不一样, 重置上次信息		
		self:_saveLastSecurityInfo();
	end	
end

-- 用户信息改变, 包括其他用户加入房间和退出房间
function SecurityChecker:_onRoomPlayerInfoSYN(response)
	local protocol = response:getProtocol():getProtocolBuf()
	local playerInfos = protocol.playerInfo

	local hasPlayer = #self._securityInfo.playerInfos ~= 0;
	
	-- 保存新的信息
	self._securityInfo.playerInfos = {}	
	for i = 1, #playerInfos do
		local playerInfo = playerInfos[i]

		local info = {
			roleId = playerInfo.roleId,
			position = playerInfo.position,
			ip = playerInfo.ip,
			gpsStatus = playerInfo.gpsInfo.status,
			latitude = playerInfo.gpsInfo.latitude,
			longitude = playerInfo.gpsInfo.longitude,
		}

		table.insert(self._securityInfo.playerInfos, info);
	end
	
	-- 排序
	table.sort(self._securityInfo, function(l,r)
		return l.position < r.position;
	end)
	
	-- 检测冲突
	self:_checkSecurity();
	
	if hasPlayer == false then
		-- 在本房间中第一次收到玩家数据
		self:dispatchEvent({name = "EVENT_SRCURITY_INFO_INITIALIZED"});

		local localPlayerId = game.service.LocalPlayerService.getInstance():getRoleId();
		for _,info in ipairs(self._securityInfo.playerInfos) do
			if info.roleId == localPlayerId and info.gpsStatus ~= ServerGPSStatus.SUCCESS then
				-- 保证一个房间只获取一次GPS信息
				self:_reportLocalInfo();
			end
		end
	end
end

-- 当获取到GSP信息之后, 发送GPS数据
function SecurityChecker:_sendCBGpsInfoREQ(status, latitude, longitude)
	local request = net.NetworkRequest.new(net.protocol.CBGpsInfoREQ, self._roomService:getRoomServerId())
	request:getProtocol():setData(status, latitude, longitude)
	request:setWaitForResponse(false)
    game.util.RequestHelper.request(request)
    Macro.assertFalse(self._roomService:getRoomServerId() ~= 0,"SEND GPS SERVER ID IS 0")
end

function SecurityChecker:_onBCGpsInfoRES(response)
	
end

-- 收到其他玩家的GPS数据信息
function SecurityChecker:_onBCSecureDetectSYN(response)	
	local protocol = response:getProtocol():getProtocolBuf()
	
	for _,player in ipairs(protocol.players) do
		-- 保存新的信息
		for __,info in ipairs(self._securityInfo.playerInfos) do
			if player.roleId == info.roleId then
				info.gpsStatus = player.gpsInfo.status;
				info.latitude = player.gpsInfo.latitude;
				info.longitude = player.gpsInfo.longitude;
			end
		end
	end
	
	-- 检测冲突
	self:_checkSecurity();
end

-- 统计GPS检测有冲突的房间
function SecurityChecker:statisticalConflictRoom()
	local roomId = game.service.RoomService:getInstance():getRoomId()
	local id = game.service.LocalPlayerService.getInstance():getRoleId()
	local processor = gameMode.mahjong.Context.getInstance():getGameService():getPlayerProcessorByPlayerId(id);
	if not processor then -- 旁观者不需要检查
		return;
	end
	local player = processor:getRoomSeat():getPlayer()
	-- 只有房主统计一次,该房间内其余玩家不做统计
	if not player:isHost() then
		return
	end
	local gpsConflictRoom = manager.LocalStorage.getUserData(id, "GpsConflictRoom", GpsConflictRoom)
	-- 只统计房间第一局
	if roomId ~= gpsConflictRoom.lastConflictRoom then
		-- 统计冲突的人做为房间冲突的次数
		local conflictCount = 0
		-- A与B冲突  B与A冲突 做为一条统计  （原本逻辑就是这样）
		for _,data in ipairs(self._securityInfo.gpsConflictInfos) do
			if data.status == SecurityChecker.GPSCheckStatus.UNSAFE then
				conflictCount = conflictCount + 1
			end
		end
		-- duration  冲突的人数
		if conflictCount > 0 then
			game.service.DataEyeService.getInstance():onEvent("Gps_ConflictRoom", conflictCount)
			game.service.TDGameAnalyticsService.getInstance():onEvent("Gps_ConflictRoom", {conflictCount = conflictCount})
		else
			game.service.DataEyeService.getInstance():onEvent("Gps_NotConflictRoom")
		end
		gpsConflictRoom.lastConflictRoom = roomId
		manager.LocalStorage.setUserData(id, "GpsConflictRoom", gpsConflictRoom)
	end
end

return SecurityChecker;
