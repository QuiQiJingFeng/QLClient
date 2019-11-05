local SortedListView = class("SortedListView")

function SortedListView.extend(self)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, SortedListView)
    self:init()
    return self	
end

function SortedListView:init()
    self:setScrollBarEnabled(false)
    local items = self:getItems()
    for i, item in ipairs(items) do
        item:setTag(i)
    end
end

function SortedListView:insertItemByTag(item,tag)
    local items = self:getItems()
    table.insert(items,tag,item)

    for i, item in ipairs(items) do
        item:setTag(i)
    end

    table.sort(items,function(a,b) 
        local aValue = a:getTag() - (a:isVisible() and 1000 or 0)
        local bValue = b:getTag() - (b:isVisible() and 1000 or 0)
        return aValue < bValue
    end)
    self:removeAllItems()
    for i, item in ipairs(items) do
        self:pushBackCustomItem(item)
    end

end

function SortedListView:sort()
    local items = self:getItems()
    table.sort(items,function(a,b) 
        local aValue = a:getTag() - (a:isVisible() and 1000 or 0)
        local bValue = b:getTag() - (b:isVisible() and 1000 or 0)
        return aValue < bValue
    end)
    self:removeAllItems()
    for i, item in ipairs(items) do
        self:pushBackCustomItem(item)
    end
end

return SortedListView