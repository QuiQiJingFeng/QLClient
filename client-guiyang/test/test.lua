--[[
    单元测试的入口
    干两件事儿
        1. require 核心组件和工具类
        2. 初始化
]]
-- 全局require，有依赖关系，不可随意调换
require("core.const")
require("core.lru")
require("utils.utils")
-- 初始化logger，并且设置日志等级
require("utils.logger").setLevel(7) -- debug太杂了，开到info
require("core.should")
require("core.must")
require("core.networksimulator")

-- 设置lohotest命名空间
_G.lohotest = require("init") 