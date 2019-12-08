local BaiduLocationService = class("BaiduLocationService")

local _instance = nil
function BaiduLocationService:getInstance()
    if not _instance then
        _instance = BaiduLocationService.new()
    end

    return _instance
end

function BaiduLocationService:ctor()
    
end

--初始化参数
--[[ 
    ANDROID
    (int)
    ScanSpan =>// 可选，默认0，即仅定位一次，设置发起连续定位请求的间隔需要大于等于1000ms才是有效的
    (boolean)
    NeedAddress =>// 可选，设置是否需要地址信息，默认不需要
    (boolean)
    NeedLocationDescribe =>// 可选，设置是否需要地址描述
    (boolean)
    NeedDeviceDirect =>// 可选，设置是否需要设备方向结果
    (boolean)
    LocationNotify =>// 可选，默认false，设置是否当gps有效时按照1S1次频率输出GPS结果
    (boolean)
    IgnoreKillProcess =>// 可选，默认true，定位SDK内部是一个SERVICE，并放到了独立进程，设置是否在stop
    (boolean)
    NeedLocationPoiList =>// 可选，默认false，设置是否需要POI结果，可以在BDLocation
    (boolean)
    IgnoreCacheException =>// 可选，默认false，设置是否收集CRASH信息，默认收集
    (boolean)
    OpenGps =>// 可选，默认false，设置是否开启Gps定位  
    (boolean)
    NeedAltitude" =>// 可选，默认false，设置定位时是否需要海拔信息，默认不需要，除基础定位版本都可用
]]
--[[
    IOS
    double a = kCLDistanceFilterNone;
    double b = kCLLocationAccuracyBestForNavigation;
    double c = kCLLocationAccuracyBest;
    double d = kCLLocationAccuracyNearestTenMeters;
    double e = kCLLocationAccuracyHundredMeters;
    double f = kCLLocationAccuracyKilometer;
    double y = kCLLocationAccuracyThreeKilometers;
]]
local LOCATION_TYPE = {
    kCLDistanceFilterNone = -1,
    kCLLocationAccuracyBest = -1,
    kCLLocationAccuracyBestForNavigation = -2,
    kCLLocationAccuracyNearestTenMeters = 10,
    kCLLocationAccuracyHundredMeters = 100,
    kCLLocationAccuracyKilometer = 1000,
    kCLLocationAccuracyThreeKilometers = 3000
}

function BaiduLocationService:initOptionsSingle()
    local options = {
        NeedAddress = true,
        NeedLocationDescribe = true,
        OpenGps = true,
    }
    if device.platform == "android" then
        --android 提交了keystore的sha1所以不需要填写appKey
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","initOptions",{json.encode(options)})
        assert(ok,ret)
    elseif device.platform == "ios" then
        local args = {}
        args.appKey = "fd9GPF35tqOqmov9Kb0rh19UlOxXwCCm"
        --//设置位置获取超时时间
        args.locationTimeout = 30
        --//设置获取地址信息超时时间
        args.reGeocodeTimeout = 30
        args.distanceFilter = LOCATION_TYPE["kCLDistanceFilterNone"]
        args.desiredAccuracy = LOCATION_TYPE["kCLLocationAccuracyBest"]
        args.pausesLocationUpdatesAutomatically = false
        args.allowsBackgroundLocationUpdates = false --要开启后台权限还要在plist里面添加
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "initOptions", args)
        assert(ok,ret)
    end
end

--连续回调参数设置
function BaiduLocationService:initOptionsUpdate()
    local options = {
        ScanSpan = 1000, --1秒回调一次
        NeedAddress = true,
        NeedLocationDescribe = true,
        OpenGps = true,
    }
    if device.platform == "android" then
        --android 提交了keystore的sha1所以不需要填写appKey
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","initOptions",{json.encode(options)})
        assert(ok,ret)
    elseif device.platform == "ios" then
        local args = {}
        args.appKey = "fd9GPF35tqOqmov9Kb0rh19UlOxXwCCm"
        --//设置位置获取超时时间
        args.locationTimeout = 10
        --//设置获取地址信息超时时间
        args.reGeocodeTimeout = 10
        args.distanceFilter = LOCATION_TYPE["kCLDistanceFilterNone"]
        --误差10米 定位时间10s左右
        args.desiredAccuracy = LOCATION_TYPE["kCLLocationAccuracyBest"]
        --误差百米 定位时间2s左右
        -- args.desiredAccuracy = LOCATION_TYPE["kCLLocationAccuracyHundredMeters"]
        args.pausesLocationUpdatesAutomatically = false
        args.allowsBackgroundLocationUpdates = false --要开启后台权限还要在plist里面添加
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "initOptions", args)
        assert(ok,ret)
    end
end

--code 0:开启 1:GPS未开启 2:GPS权限未开启
function BaiduLocationService:isSupportGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","isSupportGps",{},"()I")
        assert(ok,ret)
        return ret
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "isSupportGps")
        assert(ok,ret)
        return ret
    end
end

--跳转到开启GPS的面板
function BaiduLocationService:jumpEnableGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","jumpEnableGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "jumpEnableGps")
        assert(ok,ret)
    end
end

--动态申请GPS权限
function BaiduLocationService:jumpEnableLimitGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","jumpEnableLimitGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "jumpEnableLimitGps")
        assert(ok,ret)  
    end
end

--开始定位
function BaiduLocationService:start(callBack)
    self:initOptionsSingle()
    if device.platform == "android" then
        local ok,isStart = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","isStart",{},"()Z")
        assert(ok)
        if isStart then
            ok = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","requestLocation",{handlerFix(self,self.handleProcessLocation,callBack)})
            assert(ok)
            return
        else
            local ok = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","start",{handlerFix(self,self.handleProcessLocation,callBack)})
            assert(ok)
        end
    elseif device.platform == "ios" then
        local args = {}
        args.callBack = handlerFix(self,self.handleProcessLocation,callBack)
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "start", args)
        assert(ok,ret)
    end
end

--连续定位
function BaiduLocationService:startUpdate(callBack)
    self:initOptionsUpdate()
    if device.platform == "android" then
        local ok,isStart = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","isStart",{},"()Z")
        assert(ok)
        if isStart then
            ok = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","requestLocation",{handlerFix(self,self.handleProcessLocation,callBack)})
            assert(ok)
            return
        else
            local ok = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","start",{handlerFix(self,self.handleProcessLocation,callBack)})
            assert(ok)
        end
    elseif device.platform == "ios" then
        local args = {}
        args.callBack = handlerFix(self,self.handleProcessLocation,callBack)
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "startUpdate", args)
        assert(ok,ret)
    end
end

--stopUpdate
function BaiduLocationService:stopUpdate()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","stop")
        assert(ok,ret)
        release_print("停止连续回调成功")
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "stopUpdate")
        assert(ok,ret)
        release_print("停止连续回调成功")
    end
end

local RESULT_CODE = {
    [61] =' GPS定位结果，GPS定位成功。',
    [62] =' 无法获取有效定位依据，定位失败，请检查运营商网络或者WiFi网络是否正常开启，尝试重新请求定位。',
    [63] =' 网络异常，没有成功向服务器发起请求，请确认当前测试手机网络是否通畅，尝试重新请求定位。',
    [65] =' 定位缓存的结果。',
    [66] =' 离线定位结果。通过requestOfflineLocaiton调用时对应的返回结果。',
    [67] =' 离线定位失败。通过requestOfflineLocaiton调用时对应的返回结果。',
    [68] =' 网络连接失败时，查找本地离线定位时对应的返回结果。',
    [161] =' 网络定位结果，网络定位成功。',
    [162] =' 请求串密文解析失败，一般是由于客户端SO文件加载失败造成，请严格参照开发指南或demo开发，放入对应SO文件。',
    [167] =' 服务端定位失败，请您检查是否禁用获取位置信息权限，尝试重新请求定位。',
    [502] =' AK参数错误，请按照说明文档重新申请AK。',
    [505] =' AK不存在或者非法，请按照说明文档重新申请AK。',
    [601] =' AK服务被开发者自己禁用，请按照说明文档重新申请AK。',
    [602] =' key mcode不匹配，您的AK配置过程中安全码设置有问题，请确保：SHA1正确，“;”分号是英文状态；且包名是您当前运行应用的包名，请按照说明文档重新申请AK。',
    --501～700：'AK验证失败，请按照说明文档重新申请AK。'
}
--Latitude  Longitude
-- "[[获取GPS位置]]" = {
--     "addr"      = ""
--     "latitude"  = 37.793197631836
--     "longitude" = 37.793197631836
-- }
function BaiduLocationService:handleProcessLocation(callBack,result)
    if device.platform == "android" then
        local map = json.decode(result)
        local resultType = map.locType
        local str = RESULT_CODE[resultType] or 'AK验证失败，请按照说明文档重新申请AK。'
        release_print("BaiduLocationService:code=",tostring(resultType)," message = ",str)

        if resultType == 61 or resultType == 161 then
            callBack(map)
        end
    elseif device.platform == "ios" then
        if result.errcode then
            release_print("BaiduLocationService:code=",tostring(result.errcode)," message = ",result.descript)
        else
            callBack(result)
        end
        
    end
end

return BaiduLocationService