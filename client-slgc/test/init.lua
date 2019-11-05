-- import
require("lfs") -- lua file system

--------------------------------
-- 单元测试模块初始化的代码
-- 构建所需的必要元素
--  1. lru缓存
--  2. 设置require，添加搜索test文件的功能
--  3. 构建testlayer、网络模拟器等必要组件
--  4. 提供各种接口
--------------------------------
local _test = {}
tlog.info("[TEST INIT] The Unit Test Initializing")

-- 文件目录，用于判断文件是否存在
local workspacepath = lfs.currentdir() -- 取出的是client所在的位置
tlog.info("[TEST INIT] workspace path :" .. workspacepath)

-- 创建module的lru缓存
local function createtestmodules()
    tlog.info("[TEST INIT] Test Module LRU Creating")
    -- module的缓存，大小为100
    _test.test_modules = tlrucache(100)
    _test.test_modules.add("core.test.lruTest", "core.test.lruTest") -- lru的单元测试
end
createtestmodules()


-- 每当src下require一个代码，这边就找是否有对应的test的文件，
-- 如果有就添加到test_modules里
local function addfile ( module )
    tlog.debug("file required " .. module)
    local file = module:gsub("%.", "\\")
    local filePath = workspacepath .. "\\test\\" .. file .. "Test.lua"
    tlog.debug(filePath)
    if tutils.file_exists(filePath) then
        tlog.debug("TEST FILE EXISTS %s", module)
        local testmodule = module .. "Test"
        _test.test_modules.add(testmodule, testmodule)
        -- 数据有变化，通知testlayer，刷新模块列表
        if _test.testlayer ~= nil then
            _test.testlayer:dispatchEvent({name = "EVENT_MODULE_DATA_DIRTY"})
        end
    end
end

--[[
    @desc: 重新定义require方法
            当时src下的app文件下的资源加载时
            寻找是否有与之对应的Test模块
            如果有加入缓存中，以供进行单元测试
    author:{author}
    time:2018-04-29 24:21:38
    --@event: {module=具体模块的名字}
    return
]]
local _require = require
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
    tlog.info("[TEST INIT] Test Layer Creating")
    local layer = require("core.TestLayer").new()
    cc.Director:getInstance():getRunningScene():addChild(layer)
    layer:show();

    _test.testlayer = layer
end

--[[
    @desc: 创建网络模拟器
    author:{author}
    time:2018-04-29 12:11:45
    return
]]
local function createnetsimulator()
    tlog.info("[TEST INIT] Test Network Simulator Creating")
    local service = game.service.ConnectionService:getInstance()
    local connection = service:getConnection()

    _test.netsimulator = tnetsimulator(connection)
    _test.test_modules.add("core.test.networksimulatorTest", "core.test.networksimulatorTest") -- 网络模拟器的单元测试
end

----------------------------------interface----------------------------------

-- 测试框架启动方法
_test.run = function ()
    tlog.info("[TEST INIT] The Unit Test Starting")
    
    createtestlayer()
    createnetsimulator()
end

-- 跑所有的模块中所有的单元测试
-- 可能会造成主线程卡住！！
_test.runalltest = function ()
    tlog.info("All The Tests Start Running")
    local iter = _test.test_modules.iterator()
    for i = 1, _test.test_modules.size() do
        local v = iter()
        local clz = require(v)
        local m = clz.new()
        m:run(tconst.runAllTest)
    end
end

return _test