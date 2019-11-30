local testCases = {}

testCases[1] = {
    name = "是否支持GPS",
    func = function()
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
            game.UITipManager:getInstance():show("单次定位获取到GPS返回定位数据")
            dump(obj,"单次定位[[获取GPS位置]]")
        end)
    end
}

testCases[5] = {
    name = "开启连续定位回调",
    func = function()
        game.LocationService:getInstance():startUpdate(function(obj) 
            game.UITipManager:getInstance():show("连续定位获取到GPS返回定位数据")
            dump(obj,"连续定位[[获取GPS位置]]")
        end)
    end
}

testCases[6] = {
    name = "关闭连续定位回调",
    func = function()
        game.LocationService:getInstance():stopUpdate()
    end
}

testCases[7] = {
    name = "测试lua-protobuf",
    func = function()
        require("test.app.gameStates.GameState_Login.test")
    end
}

return testCases