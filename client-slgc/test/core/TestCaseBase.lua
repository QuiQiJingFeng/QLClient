-- 测试用例的基类
-- 提供各种测试
-- 以及输出格式化的log
local TestCaseBase = class("TestCaseBase")

function TestCaseBase:ctor()
    -- 测试用例，_init时初始化
    self._cases = {}
    -- 测试用例key列表，按顺序执行，有些cases可能有先后依赖
    self._list = nil
    self:_init()
end

-- 需要子类实现
function TestCaseBase:_init()
end

--[[
    @desc: 设置测试用例的排序
    author:{author}
    time:2018-04-29 24:14:58
    --@list: 测试用例的key
    return
]]
function TestCaseBase:sorted( list )
    self._list = list
end

--[[
    @desc: 运行某个或全部测试用例，并输出响应的测试结果
    author:{author}
    time:2018-04-29 24:15:24
    --@name: key
    return
]]
function TestCaseBase:run( name )
    tlog.info("[%s] Test run <%s>", self.__cname, name)
    local total
    local correct = 0
    if name == tconst.runAllTest then
        total, correct = self:_runAll() --统计正确和错误
    else 
        total = 1
        if self._cases[name] ~= nil then
            if self._cases[name]() then correct = 1 end
            tlog.info("========================\n")
        end
    end
    tlog.info("[%s] Test run <%s> finished", self.__cname, name)
    tlog.info("total cases %d, correct = %d, accuracy = %.02f%%", total, correct, correct / total * 100)
    tlog.info("========================\n\n")
end

-- 
--[[
    @desc: 获取所有cases，
            如果有设置排序，则按排序去取;
            否则按table的随意顺序
    author:{author}
    time:2018-04-29 24:16:52
    return
]]
function TestCaseBase:getAllCases()
    local result = {}
    if self._list ~= nil then
        for i = 1, #self._list do
            local k = self._list[i]
            table.insert(result, k)
        end
    else
        for k, v in pairs(self._cases) do
            table.insert(result, k)
        end
    end
    return result
end

--[[
    @desc: 运行并统计所有cases
    author:{author}
    time:2018-04-29 24:17:42
    return
]]
function TestCaseBase:_runAll()
    local function exec_case( k, v )
        tlog.info(k .. ":")
        local result = v()
        tlog.info("========================\n")
        return result
    end
    local list = self:getAllCases()
    local total = #list
    local correct = 0
    for i, k in ipairs(list) do
        local v = self._cases[k]
        if exec_case(k,v) then correct = correct + 1 end
    end
    return total, correct
end

return TestCaseBase