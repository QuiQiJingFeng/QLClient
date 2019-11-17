local LocationService = class("LocationService")

local _instance = nil
function LocationService:getInstance()
    if not _instance then
        _instance = LocationService.new()
    end

    return _instance
end

function LocationService:ctor()

end

--初始化参数
--[[
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
        ScanSpan = 1000,
        NeedLocationDescribe = true,
        OpenGps = true,
    }
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("BaiduLocationService","initOptions",json.encode(options))
        assert(ok,ret)
    elseif device.platform == "ios" then
    
    end
end

--code 0:开启 1:GPS未开启 2:GPS权限未开启
function LocationService:isSupportGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("BaiduLocationService","isSupportGps")
        assert(ok,ret)
        return ret
    elseif device.platform == "ios" then
    
    end
end

--跳转到开启GPS的面板
function LocationService:jumpEnableGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("BaiduLocationService","jumpEnableGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
    
    end
end

--跳转到允许GPS权限的面板
function LocationService:jumpEnableLimitGps()
    if device.platform == "android" then
        local ok,ret = luaj.callStaticMethod("BaiduLocationService","jumpEnableLimitGps")
        assert(ok,ret)
    elseif device.platform == "ios" then
    
    end
end

function LocationService:start(callBack)
    if device.platform == "android" then
        local ok,isStart = luaj.callStaticMethod("BaiduLocationService","isStart")
        assert(ok)
        if isStart then
            ok = luaj.callStaticMethod("BaiduLocationService","requestLocation",handlerFix(self,self.handleProcessLocation,callBack))
            assert(ok)
            return
        else
            local ok = luaj.callStaticMethod("BaiduLocationService","start",handlerFix(self,self.handleProcessLocation,callBack))
            assert(ok)
        end
    elseif device.platform == "ios" then
    
    end
end

--Latitude  Longitude
function LocationService:handleProcessLocation(callBack,result)
    local map = json.decode(result)
    return callBack(map)
end

return LocationService