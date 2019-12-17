local testCases = {}

testCases[1] = {
    name = "是否支持GPS",
    func = function()
        local ret = game.BaiduLocationService:getInstance():isSupportGps()
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
        game.BaiduLocationService:getInstance():jumpEnableGps()
    end
}

testCases[3] = {
    name = "跳转到允许GPS权限的面板",
    func = function()
        game.BaiduLocationService:getInstance():jumpEnableLimitGps()
    end
}

testCases[4] = {
    name = "获取GPS位置",
    func = function()
        game.BaiduLocationService:getInstance():start(function(obj) 
            game.UITipManager:getInstance():show("单次定位获取到GPS返回定位数据")
            dump(obj,"单次定位[[获取GPS位置]]")
        end)
    end
}

testCases[5] = {
    name = "开启连续定位回调",
    func = function()
        game.BaiduLocationService:getInstance():startUpdate(function(obj) 
            game.UITipManager:getInstance():show("连续定位获取到GPS返回定位数据")
            dump(obj,"连续定位[[获取GPS位置]]")
        end)
    end
}

testCases[6] = {
    name = "关闭连续定位回调",
    func = function()
        game.BaiduLocationService:getInstance():stopUpdate()
    end
}

testCases[7] = {
    name = "测试lua-protobuf",
    func = function()
        require("test.protoTest")
    end
}

testCases[8] = {
    name = "测试登陆",
    func = function()
        game.EventCenter:on("EVENT_CONNECTION_VERIFYPASS",function() 
            print("connect success")
            game.NetWork:send("login",{user_id = 10001,token="226729048d7752f63dc2afc0ada1be116c513382"},true)
        end)
        game.EventCenter:on("login",function(responseMessage) 
            dump(responseMessage,"FYD=====")
        end)
        game.NetWork:connect("192.168.0.101:8888")
    end
}

testCases[9] = {
    name = "测试牌创建Bottom",
    func = function()
        local scene = cc.Director:getInstance():getRunningScene()
        local card = game.CardFactory:getInstance():createCardWithOptions("Bottom","HANDCARD",{cardValue = 255})
        card:setPosition(cc.p(200,200))
        scene:addChild(card)
    
        local card = game.CardFactory:getInstance():createCardWithOptions("Bottom","OUTCARD",{cardValue = 255})
        card:setPosition(cc.p(300,200))
        scene:addChild(card)
    
        local card = game.CardFactory:getInstance():createCardWithOptions("Bottom","DISCARD",{cardValue = 255})
        card:setPosition(cc.p(400,200))
        scene:addChild(card)
    
    
        local GROUP_TYPE = {
            CHI = 1,
            PENG = 2,
            GANG = 3,
        }
    
        local GANG_TYPE = {
            ANGANG = 1,
            MINGGANG = 2,
            PENGGANG = 3
        }
        local data = {
            type = GROUP_TYPE.GANG,
            gangType = GANG_TYPE.PENGGANG,
            cardValue = 5,
            from = 4,
            pos = 1
        }
        local card = game.CardFactory:getInstance():createCardWithOptions("Bottom","GROUPCARD",data)
        card:setPosition(cc.p(600,200))
        scene:addChild(card)
    end
}

return testCases