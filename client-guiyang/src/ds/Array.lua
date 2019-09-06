--[[0
    一个简单的 Array 数据结构，封装了一些常用的函数，写代码更加OOP吧
    ** 注意 ** 
    1、慎用，因为API没有完全测试过，目前坑点有：
        - 本地的序列化与反序列化有点麻烦，需要额外操作下
        - API 没有完全测试过
        - 如果可以，请不要在外部直接访问 innerTable
    2、因为 Lua 没有泛型，所以在 Array 中项可以是不同类型的，在使用一个例如 forEach 、removeIf 函数时注意
    3、为了满足 Array 的特性， insert 不支持插入一个 Lua nil 值， 如果要插入一个占位空值的话，可以使用 Array.NULL ， 他是一个字符串 "NULL"
    4、其中很都函数都是以以下形式给出
        function(item, index, array)
            -- item 为当前项
            -- index 为当前项下标
            -- array 为当前数组（纯 lua 数组，并非 Array 对象）
        end
        解释一下为什么这么排序： 参考了 JS 的函数库， 80% 的情况下，只需要用到 item， 其他的可以不传入

    create date: 2018/09/12
    example 1:
        local Array = require("ds.Array")
        local arr = Array.new()
        for i = 1, 10 do
            arr:add(i)
        end
        arr:sort()
        print(arr:toString('\n'))
    example 2:(暂未实现)
        -- 如果你觉得 new 的形式不喜欢，可以采用以下的方式
        local Array = require("ds.Array")
        local t = {}
        for i = 1, 10 do
            Array.add(t, i)
        end
        Array.sort(t)
        print(Array.toString(t))
]]
---@class Array
local M = class("Array")
M.NULL = "NULL"

--[[0
    解决存储后，不能正常序列化的问题
    只能解决单层的，多层嵌套暂时无法解决
]]
function M.resumeFromStorage(storageData, itemClass)
    local array = M.new()
    local tbl = storageData.innerTable or {}
    if itemClass then
        for idx, item in ipairs(tbl) do
            local instance = {}
            setmetatableindex(instance, itemClass)
            instance.class = itemClass
            for key, value in pairs(item) do
                instance[key] = value
            end
            array:add(instance)
        end
        return array
    else
        return M.new(tbl)
    end
end

function M:ctor(luaList)
    self.innerTable = luaList or {}
end

--[[0
    检查边界
]]
function M:_checkBounds(index)
    return Macro.assertFalse(index and index >= 1 and index <= self:getCount(), 'error index:' .. tostring(index))
end

--[[0
    插入一个值， index 是插入的下表， 不填写默认插入末尾
]]
function M:insert(item, index)
    if Macro.assertFalse(item, 'item is a nil value, if you want to insert a NULL value, use Array.NULL') then
        if index then
            table.insert(self.innerTable, index, item)
        else
            table.insert(self.innerTable, item)
        end
        return self
    end
end

--[[0
    在末尾插入一个项
]]
function M:add(item)
    self:insert(item)
    return
end

--[[0
    根据下标取得一个项
]]
function M:get(index)
    return self.innerTable[index]
end

--[[0
    通过下标删除一个项， 若删除的为中间项， 后续的会往前移动， 保证 Array 的连续性
]]
function M:remove(index)
    if self:_checkBounds(index) then
        return table.remove(self.innerTable, index)
    end
end


--[[0
    移除某些项， 当项传入 func 函数返回为 非 nil 和 false 时
    此API设计参考了 Java 的 removeIf(仅名称参考)
    **注意** ：移除操作是统一执行的，也就是在满足条件下遍历完所有项后

    func: 参考此文档顶端，注意中的第4点
    isRemoveAll： 如果为 true 则移除所有满足项，否则只移除满足的第一项
]]
function M:removeIf(func, isRemoveAll)
    local idxArr = {}
    self:forEach(function(item, index, array)
        if func(item, index, array) then
            table.insert(idxArr, index)
            return not isRemoveAll
        end
    end)

    -- 需要从后往前删除， 也需要保证 idxArr 是顺序的
    for i = #idxArr, 1, -1 do
        local index = idxArr[i]
        self:remove(index)
    end
end

--[[0
    获取某项的下标，如果找不到则范围 -1 （这与 functions.lua 中不同，他是返回 false）
    -1 是致敬 Java 吧.
]]
function M:indexOf(item)
    local index = nil
    self:forEach(function(_item_, _index, array)
        if item == _item_ then
            index = _index
            return true
        end
    end)
    return index or -1
end

--[[0
    获取项的数量
]]
function M:getCount()
    return #self.innerTable
end

--[[0
    遍历所有项，返回满足 fn 执行后返回为 非 nil 和 false 的项

    func: 参考此文档顶端，注意中的第4点
]]
function M:filter(fn)
    if Macro.assertFalse(fn, 'fn is a nil value') then
        local ret = {}
        for index, item in ipairs(self.innerTable) do
            if fn(item, index, self.innerTable) then
                table.insert(ret, item)
            end
        end
        return ret
    end
end

--[[0
    遍历所有节点，不建议在遍历时进行 Array 的增加与删除操作， 你可以使用 removeIf 和 replaceIf
    
    fn: 参考此文档顶端，注意中的第4点
    如果你想中断 forEach， fn 如果返回为 true 的话，即会中断此次遍历
]]
function M:forEach(fn)
    if Macro.assertFalse(fn, 'fn is a nil value') then
        for index, item in ipairs(self.innerTable) do
            if fn(item, index, self.innerTable) then
                break
            end
        end
    end
end

--[[0
    数组连接，如果传入的为非 Array 对象， 会转为 Array 对象后进行操作
    返回的是 Array 对象， 并非 简单的 Lua Table
]]
function M:concat(array_b)
    if array_b.class ~= nil and array_b.class.__cname == self.class.__cname then
        -- is an array object
        local ret = {}
        for _, _table in ipairs({ self.innerTable, array_b.innerTable }) do
            for _, item in ipairs(_table) do
                table.insert(ret, item)
            end
        end
        return M.new(ret)
    else
        -- not an array object
        local array_b = M.new(array_b)
        self:concat(array_b)
    end
end

--[[0
    排序函数
]]
function M:sort(sortFunc)
    if sortFunc then
        table.sort(sortFunc)
    else
        table.sort()
    end
end

--[[0
    替换函数
    func: 参考此文档顶端，注意中的第4点
        若 func 返回为 true， 则会使用 replaceItem 去替换当前遍历项
    replaceItem: 替换项
    isReplaceAll: 是否替换所有满足条件的项目
]]
function M:replaceIf(func, replaceItem, isReplaceAll)
    if not Macro.assertFalse(replaceItem, 'replaceItem is a nil value') then
        return
    end

    self:forEach(function(item, index, array)
        if func(item, index, array) then
            array[index] = replaceItem
            return not isReplaceAll
        end
    end)
end

function M:clear()
    self.innerTable = {}
end

--[[0
    反向
]]
function M:reverse()
    local ret = {}
    for i = #self.innerTable, 1, -1 do
        table.insert(ret, self.innerTable[i])
    end
    return M.new(ret)
end

function M:toString(splitChar)
    local _table = {}
    self:forEach(function(item, index, array)
        if type(item) == 'table' and rawget(item, "class") ~= nil and item.toString ~= nil then
            table.insert(_table, item:toString())
        else
            table.insert(_table, tostring(item))
        end
    end)
    return table.concat(_table, splitChar or ",")
end

return M