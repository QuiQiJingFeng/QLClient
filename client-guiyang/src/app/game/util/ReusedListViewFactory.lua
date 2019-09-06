--[[    ReusedListViewFactory 复用ListView的工厂类，提供构造能够重复利用的ListView（item重复利用）

    features:
        1、减少代码量，相同的数据已经在此过滤了
    todo:

    
    Example1:
        local factory = require("ReusedListViewFactory")
        self._reusedLst = factory.get(self._listView, handler(self, self._listItemInit) , handler(self, self._listItemSetData))
    
    Example2:
        local factory = require("ReusedListViewFactory")
        self._reusedLst = factory.get(self._listView,
            function(listItem)
                -- your code
            end,
            function (listItem, val)
                -- your code
            end)
    
    CHANGEDLOG:
        2017/11/22： 增加splitTable方法，方便pushBackItem的调用
        2018/07/23： 参照 UIItemReusedListView 的example， 在 setData 中，进行了值判断，避免无意义的刷新
        2018/08/17： formated file， 修正拼写
]]
local UIItemReusedListView = require("app.game.util.UIItemReusedListView")
local ReusedListViewFactory = {}

function ReusedListViewFactory.get(widget, initCallback, setDataCallback, cname)
    ReusedListViewFactory.check(widget, initCallback, setDataCallback)

    local bridge = class(cname or "bridge")

    -- the function call by UIItemReusedListView
    -- the self is a list item copy
    bridge.extend = function(self)
        local t = tolua.getpeer(self)
        if not t then
            t = {}
            tolua.setpeer(self, t)
        end
        setmetatable(t, bridge)
        self:_initialize()
        return self
    end

    bridge._initialize = function(self)
        initCallback(self)
    end

    bridge.setData = function(self, val, isForce)
        -- 这里需要刷新操作的
        if self._val == val and not isForce then
            return
        end
        self._val = val
        setDataCallback(self, val, self._itemId)
    end

    return UIItemReusedListView.extend(widget, bridge)
end

function ReusedListViewFactory.check(widget, initCallback, setDataCallback)
    Macro.assetTrue(widget == nil or initCallback == nil or setDataCallback == nil)
    Macro.assetFalse(type(initCallback) == "function" and type(setDataCallback) == "function", "illegal argument")
end

--- @param longTable 长表
--- @param count 块大小
--- @param dValue 如果存在则填充块置count大小
--- @return masterTable 分割后的表，表内嵌套了n个count大小的表
function ReusedListViewFactory.splitTable(longTable, count, dValue)
    if type(longTable) ~= "table" then return {} end
    if #longTable <= count then return { longTable } end
    local masterTable = {}
    local t = nil
    for i, v in ipairs(longTable) do
        local bNew = i % count == 1
        if bNew then
            table.insert(masterTable, t)
            local tempT = {}
            t = tempT
        end
        t[#t + 1] = v
    end
    if dValue ~= nil and #t < count then
        t = t or {}
        for i = #t + 1, count do t[i] = dValue end
    end
    table.insert(masterTable, t)
    return masterTable
end




local multiListF = {}

multiListF.__index = multiListF


--[[ 用于创建,行列共存的list结构式list,list,panel结构
设置数值时请使用下面自带的方法,除了清除全部数据外 请使用下面自带的方法
-- @param columnCout每行最多多少元素
-- 其他跟get参数含义相同
]]
--
function ReusedListViewFactory.multiListCreate(widget, initCallback, setDataCallback, columnCout, cname)
    widget.columnCout = columnCout

    local brige = class(cname or "brige")

    brige._innerTempNode = widget:getItem(0):getItem(0)
    brige._innerTempNode:removeFromParent(false)
    widget:getParent():addChild(brige._innerTempNode)
    brige._innerTempNode:setVisible(false)
    widget:getItem(0):removeAllChildren()

    brige.extend = function(self)
        local t = tolua.getpeer(self)
        if not t then
            t = {}
            tolua.setpeer(self, t)
        end
        setmetatable(t, brige)
        self:_initialize()
        return self
    end

    brige._initialize = function(self)

    end

    brige.setData = function(self, val)
        if not val then
            return
        end
        if self._val == val and not isForce then
            return
        end
        self._val = val

        for k, v in ipairs(val) do
            local node = self:getItem(k - 1)
            if not node then
                node = brige._innerTempNode:clone()
                initCallback(node)
                self:pushBackCustomItem(node)
            end
            node:setVisible(true)
            setDataCallback(node, v)
        end
        local len = self:getChildrenCount()
        for i = #val + 1, self:getChildrenCount() do
            self:getItem(i - 1):setVisible(false)
        end
    end

    brige.setAllData = ReusedListViewFactory.setAllData
    local node = UIItemReusedListView.extend(widget, brige)
    setmetatableindex(node, multiListF)
    return node
end

--设置列表数据
function multiListF:setAllData(longTable)
    self:deleteAllItems()
    self:beginUpdateItemDatas()
    local masterTable = ReusedListViewFactory.splitTable(longTable, self.columnCout)
    for i = 1, #masterTable do
        self:pushBackItem(masterTable[i])
    end
    self:endUpdateItemDatas()
end
-- 遍历所有可见的元素
function multiListF:foreach(callF)
    local index = 1
    table.walk(self:getChildren(), function(listC)
        table.walk(listC:getChildren(), function(v)
            if v:isVisible() then
                callF(v, index)
                index = index + 1
            end
        end)

    end)
end

return ReusedListViewFactory