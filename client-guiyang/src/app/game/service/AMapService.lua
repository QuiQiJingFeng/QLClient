--[[
高德地图定位服务

EVENT:
EVENT_GET_LOCATION_SUCCESS {latitude, longitude}
EVENT_GET_LOCATION_FAILED
--]]
local ns = namespace("game.service")

local AMapLocationMode = {
	Battery_Saving = 0,
	Device_Sensors = 1,
	Hight_Accuracy = 2,
}

local AMapLocationProtocol = {
	HTTP = 0;
	HTTPS = 1;
}

local AMapLocation2StrType = {
	NONE = 0,
	FULL = 1, 		-- 完整描述
	BRIEF = 2, 		-- 精简描述
	MORE_BRIEF = 3 	-- 极简描述
}

-- ios常亮
local kCLDistanceFilterNone = -1;
local CLLocationAccuracy = {
	BestForNavigation = -2,
	Best = -1,
	NearestTenMeters = 10,
	HundredMeters = 100,
	Kilometer = 1000,
	ThreeKilometers = 3000
}

local AMapLocationError = {
	Success = 0,               -- 成功
	Unknown = 1,               -- 未知错误
	LocateFailed = 2,          -- 定位错误
	ReGeocodeFailed  = 3,      -- 逆地理错误
	TimeOut = 4,               -- 超时
	Canceled = 5,              -- 取消
	CannotFindHost = 6,        -- 找不到主机
	BadURL = 7,                -- URL异常
	NotConnectedToInternet = 8,-- 连接异常
	CannotConnectToHost = 9,   -- 服务器连接失败
	RegionMonitoringFailure=10,-- 地理围栏错误
	RiskOfFakeLocation = 11,   -- 存在虚拟定位风险
}

local CLAuthorizationStatus = {
	NotDetermined = 0,
	Restricted = 1,
	Denied = 2,
	AuthorizedAlways = 3,
	AuthorizedWhenInUse = 4,
	Authorized = 5,
}

local AMapService = class("AMapService")
ns.AMapService = AMapService

function AMapService:getInstance()
	return manager.ServiceManager.getInstance():getAMapService();
end

function AMapService:ctor()
	cc.bind(self, "event");
	self._amapStart = 0
end

function AMapService:isEnabled()
    return game.plugin.Runtime.isEnabled();
end

function AMapService:initialize()
	local locationOption = {}
	if device.platform == "android" then
        locationOption = self:_createLocationOption_android(false, 1000, true, true, AMapLocationMode.Hight_Accuracy, AMapLocationProtocol.HTTP,
			false, false, 10000, true, true, true, AMapLocation2StrType.NONE);
    elseif device.platform == "ios" then
    	locationOption = self:_createLocationOption_ios(1, CLLocationAccuracy.BestForNavigation,false, false, 10, 5, true, true);
    end
	
	self:_setApiKey(config.GlobalConfig.getConfig().AMAP_APPID);
	self:_setCallback(handler(self, self._getLocationCallback))
	self:_setLocationOption(locationOption)
end

function AMapService:dispose()
	cc.unbind(self, "event");
end

function AMapService:isLocationServiceEnabled()
	if self:_isServiceEnabled() == false then
		return false
	end
	
	local authStatus = self:_getAuthorizationStatus();
	return authStatus ~= CLAuthorizationStatus.Restricted and authStatus ~= CLAuthorizationStatus.Denied;
end

function AMapService:_isServiceEnabled()
	if self:isEnabled() == false then return false end

	if device.platform == "android" then
        -- Android始终是开启的
        return true;
    elseif device.platform == "ios" then
    	local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "isServiceEnabled")
        if Macro.assertTrue(ok == false, tostring(ret)) then return false end
        return ret;
    end

     Macro.assertFalse(false);
end

function AMapService:_getAuthorizationStatus()
	if self:isEnabled() == false then return 0 end

	if device.platform == "android" then
        -- Android始终是开启的
        return CLAuthorizationStatus.Authorized;
    elseif device.platform == "ios" then
    	local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "getAuthorizationStatus")
        if Macro.assertTrue(ok == false, tostring(ret)) then return false end
        return ret;
    end

     Macro.assertFalse(false);
end

function AMapService:_setApiKey(apiKey)
    if self:isEnabled() == false then return end
    
    if device.platform == "android" then
        -- Android不支持代码设置
        return;
    elseif device.platform == "ios" then
    	local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "setApiKey", { apiKey = apiKey})
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    end

     Macro.assertFalse(false);
end

function AMapService:_setCallback(getLocationCallback)
	-- Logger.debug("[AMapService] _init")
    if self:isEnabled() == false then return end
    
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/lohogames/common/amap/AMapLuaWrapper", "setCallback", {getLocationCallback})
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    elseif device.platform == "ios" then
       	local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "setCallback", { getLocationCallback = getLocationCallback })
       	if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    end

    Macro.assertFalse(false);
end

-- boolean isMockEnable, 			设置是否允许模拟位置
-- int interval, 					设置发起定位请求的时间间隔
-- boolean isNeedAddress, 			设置是否返回地址信息，默认返回地址信息
-- boolean isWifiPassiveScan, 		设置是否允许调用WIFI刷新
-- int mode, 						定位模式
-- int protocol, 					协议类型
-- boolean isKillProcess, 			获取退出时是否杀死进程
-- boolean isGpsFirst, 				设置首次定位是否等待GPS定位结果, 只有在单次定位高精度定位模式下有效
-- int httpTimeOut, 				设置联网超时时间
-- boolean isLocationCacheEnable, 	设置是否使用缓存策略
-- boolean isOnceLocationLatest, 	设置单次定位是否等待WIFI列表刷新
-- boolean isSensorEnable, 			设置是否使用设备传感器
-- int aMapLocation2StrType, 		设置转换信息的类型
function AMapService:_createLocationOption_android(isMockEnable, interval, isNeedAddress, isWifiPassiveScan, mode, protocol, isKillProcess,
		isGpsFirst, httpTimeOut, isLocationCacheEnable, isOnceLocationLatest, isSensorEnable, aMapLocation2StrType)
	return {
		isMockEnable, 
		interval, 
		isNeedAddress, 
		isWifiPassiveScan, 
		mode, 
		protocol, 
		isKillProcess,
		isGpsFirst, 
		httpTimeOut, 
		isLocationCacheEnable, 
		isOnceLocationLatest, 
		isSensorEnable, 
		aMapLocation2StrType,
	}	
end

-- float distanceFilter:                	设定定位的最小更新距离。
-- float desiredAccuracy:                   设定期望的定位精度。
-- bool pausesLocationUpdatesAutomatically: 指定定位是否会被系统自动暂停。
-- bool allowsBackgroundLocationUpdates:    是否允许后台定位。
-- int locationTimeout:                     指定单次定位超时时间
-- int reGeocodeTimeout:                    指定单次定位逆地理超时时间
-- bool locatingWithReGeocode:              连续定位是否返回逆地理信息
-- bool detectRiskOfFakeLocation:           检测是否存在虚拟定位风险
function AMapService:_createLocationOption_ios(distanceFilter, desiredAccuracy, pausesLocationUpdatesAutomatically, allowsBackgroundLocationUpdates, locationTimeout, 
	reGeocodeTimeout, locatingWithReGeocode, detectRiskOfFakeLocation)
	return {
		distanceFilter = distanceFilter, 
		desiredAccuracy =desiredAccuracy, 
		pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically, 
		allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates, 
		locationTimeout = locationTimeout, 
		reGeocodeTimeout = reGeocodeTimeout, 
		locatingWithReGeocode = locatingWithReGeocode, 
		detectRiskOfFakeLocation = detectRiskOfFakeLocation,
	}	
end

function AMapService:_setLocationOption(param)
	-- Logger.debug("[AMapService] _init")
    if self:isEnabled() == false then return end
    
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/lohogames/common/amap/AMapLuaWrapper", "setLocationOption", param)
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "setLocationOption", param)
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    end

    Macro.assertFalse(false);
end

function AMapService:startLocation(isOnceLocation,needSkipEvent)
	if self:isEnabled() == false then return end
	self._amapStart = kod.util.Time.now()
	game.service.DataEyeService.getInstance():onEvent("Gps_AMap_GetLocation_Start")
	game.service.TDGameAnalyticsService.getInstance():onBegin("Gps_AMap_GetLocation")
    self._needSkipEvent = needSkipEvent
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/lohogames/common/amap/AMapLuaWrapper", "startLocation", {isOnceLocation})
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "startLocation", {isOnceLocation = isOnceLocation})
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    end

    Macro.assertFalse(false);
end

function AMapService:stopLocation()
	if self:isEnabled() == false then return end
    
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/lohogames/common/amap/AMapLuaWrapper", "stopLocation", param)
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
        return;
    elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("AMapLuaWrapper", "stopLocation")
        if Macro.assertTrue(ok == false, tostring(ret)) then return end        return;
    end

    Macro.assertFalse(false);
end

function AMapService:_getLocationCallback(jsonStr)
	Logger.debug("_getLocationCallback,"..jsonStr)
	
	-- Android错误描述: http://lbs.amap.com/api/android-location-sdk/guide/utilities/errorcode 
	-- IOS错误描述: http://lbs.amap.com/api/ios-location-sdk/guide/utilities/errorcode
	local params = json.decode(jsonStr)

    if params.errorCode == nil or params.errorCode == AMapLocationError.Success then
        if self._needSkipEvent then
            self:dispatchEvent({name = "LOCAL_SERVICE_EVENT_GET_LOCATION_SUCCESS", latitude = params.latitude, longitude = params.longitude, 
            province = params.province, city = params.city, district = params.district});
        else
            -- 定位成功, 有可能获取地址失败
            self:dispatchEvent({name = "EVENT_GET_LOCATION_SUCCESS", latitude = params.latitude, longitude = params.longitude, 
                                province = params.province, city = params.city, district = params.district});

            -- 统计
            game.service.TDGameAnalyticsService.getInstance():onEvent("Gps_AMap_GetLocation_Success",
            {
                time = kod.util.Time.now() - self._amapStart,
            })
            game.service.TDGameAnalyticsService.getInstance():onCompleted("Gps_AMap_GetLocation")
        end
    else
        if not self._needSkipEvent then
            -- 定位失败
            self:dispatchEvent({name = "EVENT_GET_LOCATION_FAILED"});

            -- 统计
            game.service.DataEyeService.getInstance():amapError(params.errorCode, params.errorInfo);
            game.service.TDGameAnalyticsService.getInstance():onEvent("Gps_AMap_GetLocation_Failed", 
            {
                time = kod.util.Time.now() - self._amapStart,
            })

            game.service.TDGameAnalyticsService.getInstance():onEvent("Gps_AMap_GetLocationError", 
                {
                    errorCode = params.errorCode,
                    errorInfo = params.errorInfo,
                })
            game.service.TDGameAnalyticsService.getInstance():onFailed("Gps_AMap_GetLocation", tostring(params.errorCode))
        end
	end
end