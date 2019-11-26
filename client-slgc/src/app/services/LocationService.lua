local LocationService = class("LocationService")

local _instance = nil
function LocationService:getInstance()
    if not _instance then
        _instance = LocationService.new()
    end

    return _instance
end

function LocationService:ctor()
    self:initOptions()
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
function LocationService:initOptions()
    local options = {
        -- ScanSpan = 1000,
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
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "initOptions", args)
        assert(ok,ret)
    end
end

--code 0:开启 1:GPS未开启 2:GPS权限未开启
function LocationService:isSupportGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","isSupportGps",{},"()I")
        assert(ok,ret)
        return ret
    elseif device.platform == "ios" then
        --ios不需要动态申请权限,所以无需区分1和2
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "isSupportGps")
        assert(ok,ret)
        return ret
    end
end

--跳转到开启GPS的面板
function LocationService:jumpEnableGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","jumpEnableGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "jumpEnableGps")
        assert(ok,ret)
    end
end

--动态申请GPS权限
function LocationService:jumpEnableLimitGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("com/mengya/game/BaiduLocationService","jumpEnableLimitGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("BaiduLocationService", "jumpEnableLimitGps")
        assert(ok,ret)  
    end
end

function LocationService:start(callBack)
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
function LocationService:handleProcessLocation(callBack,result)
    if device.platform == "android" then
        local map = json.decode(result)
        local resultType = map.locType
        local str = RESULT_CODE[resultType] or 'AK验证失败，请按照说明文档重新申请AK。'
        release_print("LocationService:code=",tostring(resultType)," message = ",str)

        if resultType == 61 or resultType == 161 then
            callBack(map)
        end
    elseif device.platform == "ios" then
        callBack(result)
    end
end

return LocationService