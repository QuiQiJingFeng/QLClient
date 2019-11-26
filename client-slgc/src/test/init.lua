--------------------------------
-- 单元测试模块初始化的代码
-- 构建所需的必要元素
--  1. lru缓存
--  2. 设置require，添加搜索test文件的功能
--  3. 构建testlayer、网络模拟器等必要组件
--  4. 提供各种接口
--------------------------------
local testCase = {}
_G.testCase = testCase
release_print("[TEST INIT] The Unit Test Initializing")

local _require = require
local function addfile ( module )
    release_print("file required " .. module)
    local filePath = string.gsub("test." .. module .. "Test","%.","/") .. ".lua"
    release_print(filePath)
    --test.app.GameMainTest.lua
    local isExist = cc.FileUtils:getInstance():isFileExist(filePath)
    if isExist then
        release_print("TEST FILE EXISTS %s", module)
        local testmodule = module .. "Test"
        local datas = _require(testmodule)
        game.EventCenter:dispatch("TEST_CASE_FILE_REFRESH",datas)
    end
end

require = function ( module )
    if string.find( module, "app.%a+" ) then
        addfile(module)
    end
    return _require(module)
end

--[[
    @desc: 创建testlayer
    author:{author}
    time:2018-04-29 24:37:05
    return
]]
local function createtestlayer()
    local layer = require("test.core.TestLayer").new()
    cc.Director:getInstance():getRunningScene():addChild(layer)
end

-- 测试框架启动方法
testCase.run = function ()
    release_print("[TEST INIT] The Unit Test Starting")
    createtestlayer()
end

return testCase