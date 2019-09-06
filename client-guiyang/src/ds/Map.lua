--[[0
    一个简单的 Map 数据结构，封装了一些常用的函数，写代码更加OOP吧
    ~~ 目前还没有文件引用它，请暂且不要使用，等待作者自行踩坑，觉得ok再说吧 ~~
    create date: 2018/09/12

    CHANGE LOG:
    2018-11-30 优化了下，可以初步使用了
]]
---@class Map
local M = class("Map")

function M:ctor(luaMap)
    self.innerTable = luaMap or {}
end

function M:_checkKey(key)
    if key ~= nil and key ~= "" then
        return true
    end
    local debugStr = string.format("catch an illegal key:[%s]. map.toString :%s", key or "nil", self:toString())
    if Logger then
        Logger.error(debugStr)
    else
        print(debugStr)
    end

    return false
end

function M:put(key, value)
    if self:_checkKey(key) then
        self.innerTable[key] = value
    end
end

function M:get(key)
    if self:_checkKey(key) then
        return self.innerTable[key]
    end
end

function M:hasKey(key)
    return self:get(key) ~= nil
end

function M:tryGet(key, defaultValue)
    return self:get(key) or defaultValue
end

function M:getKeys()
    local ret = {}
    for key, _ in pairs(self.innerTable) do
        table.insert(ret, key)
    end
    return ret
end

function M:getValues()
    local ret = {}
    for _, value in pairs(self.innerTable) do
        table.insert(ret, value)
    end
    return ret
end

function M:getCount()
    local count = 0
    for key, value in pairs(self.innerTable) do
        count = count + 1
    end
    return count
end

function M:forEach(fn)
    if fn then
        for key, value in pairs(self.innerTable) do
            if fn(key, value) then
                break
            end
        end
    end
end

-- maxMatchTimes 匹配次数
function M:filter(fn, maxMatchTimes)
    maxMatchTimes = checknumber(maxMatchTimes)
    if maxMatchTimes == 0 then
        maxMatchTimes = math.huge
    end
    local ret = {}
    local times = 0
    if fn then
        self:forEach(function(key, value)
            if fn(key, value, self) then
                ret[key] = value
                times = times + 1
                return times >= maxMatchTimes
            end
        end)
    end
    return M.new(ret)
end

function M:clear()
    self.innerTable = {}
end

function M:toString(splitChar)
    splitChar = splitChar or ", "
    local _table = {}
    self:forEach(function(key, value, array)
        local keyStr, valueStr
        if type(key) == 'table' and key.toString then
            keyStr = key:toString()
        else
            keyStr = tostring(key)
        end
        if type(key) == 'table' and value.toString then
            valueStr = value:toString()
        else
            valueStr = tostring(value)
        end
        print(keyStr)
        print(valueStr)
        table.insert(_table, string.format("[%s]:[%s]", keyStr, valueStr))
    end)
    return table.concat(_table, splitChar)
end

return M