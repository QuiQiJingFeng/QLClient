--------------------------------
-- 单元测试模块初始化的代码
-- 构建所需的必要元素
--  1. lru缓存
--  2. 设置require，添加搜索test文件的功能
--  3. 构建testlayer、网络模拟器等必要组件
--  4. 提供各种接口
--------------------------------
local testCase = {}
release_print("[TEST INIT] The Unit Test Initializing")
--[[
    @desc: 创建testlayer
    author:{author}
    time:2018-04-29 24:37:05
    return
]]
local function createtestlayer()
    local layer = require("test.core.TestLayer").new()
    cc.Director:getInstance():getRunningScene():addChild(layer)

    local datas = require("test.testCase")
    game.EventCenter:dispatch("TEST_CASE_FILE_REFRESH",datas)
end

-- 测试框架启动方法
testCase.run = function ()
    release_print("[TEST INIT] The Unit Test Starting")
    createtestlayer()
end

return testCase