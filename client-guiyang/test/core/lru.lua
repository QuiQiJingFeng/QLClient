-- lru 缓存
-- 面试题标准答案
-- 具体功能不解释了
local LRUCache = function (max)
    local tail = {next = nil, prev = nil, data = nil, key = nil} -- tail指针
    local head = {next = tail, prev = nil, data = nil, key = nil} -- head指针
    tail.prev = head -- 头尾互指
    local map = {} -- 真正存放数据的map
    local size = 0 -- 缓存的大小

    -- 添加一个元素
    -- notinc size是否增加1 ：如果命中的话，只是移动位置，不需要增加size
    local _add = function (key, value, notinc)
        if not notinc then
            size = size + 1
            if size > max then
                -- 为提高效率，每次从头部淘汰整体的1/4
                local expires = bit.rshift(max, 2)
                for i = 1, expires do
                    local removeK = head.next.key -- 找到对应的key
                    map[removeK] = nil -- 一定要把map里的key给置为nil
                    -- head指针后移一位
                    head.next = head.next.next
                    head.next.prev = head
                end
                size = size - expires -- size减小到删除后的真实size
            end
        end
        -- 添加到尾部和map中
        local node = {next = tail, prev = tail.prev, data = value, key = key}
        tail.prev.next = node
        tail.prev = node
        map[key] = node
    end

    -- 查找元素
    local _find = function ( key )
        if map[key] ~= nil then
            -- 命中，将此node移到双向链表的末尾
            local node = map[key]
            node.prev.next = node.next -- 前的后是后
            node.next.prev = node.prev -- 后的前是前
            _add(key, node.data, true) -- 因为命中了 所以size不自增
            return node.data
        end
        return nil -- 没有命中返回nil
    end

    return {
        -- 添加一个元素，外部接口，先查找，如果找到了就不添加了
        -- 复杂度O(1)
        ['add'] = function ( key, value )
            if _find(key) ~= nil then
                return -- 先查找，找到了直接返回
            end
            _add(key, value)
        end,
        -- 查找元素
        -- 复杂度O(1) -- 理论上，去决定table的底层实现
        ['find'] = function ( key )
            return _find(key)
        end,
        -- 缓存当前大小
        ['size'] = function ()
            return size
        end,
        -- 迭代器
        -- reverse true = 正序 false = 倒序(默认，淘汰的是从头部，所以从后往前是默认)
        ['iterator'] = function ( reverse )
            local p = reverse and head or tail -- 从头还是尾开始
            local d = reverse and 'next' or 'prev' -- 方向是啥
            return function ()
                p = p ~= nil and p[d] or nil
                return p ~= nil and p.data or nil
            end
        end
    }
end

_G.tlrucache = LRUCache