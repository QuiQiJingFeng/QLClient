local testCases = {}

testCases[1] = {
    name = "是否支持GPS",
    func = function()
        for i = 1, 100 do
            game.LocationService:getInstance():isSupportGps()
        end
        local ret = game.LocationService:getInstance():isSupportGps()
        -- 0:开启 1:GPS未开启 2:GPS权限未开启
        local CONVERT = {
            [0] = "GPS已经开启",
            [1] = "GPS未开启",
            [2] = "GPS权限未开启"
        }
        game.UITipManager:getInstance():show(CONVERT[ret] or "UN NONE")
    end
}

testCases[2] = {
    name = "跳转到开启GPS的面板",
    func = function()
        game.LocationService:getInstance():jumpEnableGps()
    end
}

testCases[3] = {
    name = "跳转到允许GPS权限的面板",
    func = function()
        game.LocationService:getInstance():jumpEnableLimitGps()
    end
}

testCases[4] = {
    name = "获取GPS位置",
    func = function()
        game.LocationService:getInstance():start(function(obj) 
            game.UITipManager:getInstance():show("获取到GPS返回定位数据")
            dump(obj,"[[获取GPS位置]]")
        end)
    end
}

return testCases