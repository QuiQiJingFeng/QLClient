local UISortListView = class("UISortListView")

function UISortListView.extend(self,revert)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UISortListView)
    if revert then
        self:revert()
    end
    self:init()
    return self 
end

--反转ListView,比如本来ListView是从左开始的,现在变成了从右边开始
function UISortListView:revert()
    local originAnchor = self:getAnchorPoint()
    local newAnchor = cc.p(0.5,0.5)
    game.Util:changeAnchor(self,newAnchor)
    local isVertical = self:getDirection() == ccui.ScrollViewDir.vertical
    local items = self:getItems()
    self:removeAllItems()
    if isVertical then
        self:setScaleY(-1)
        for i = #items, 1, -1 do
            local item = items[i]
            item:setScaleY(-1)
            self:pushBackCustomItem(item)
        end
    else
        self:setScaleX(-1)
        local scaleX = self:getScaleX()
        for i = #items, 1, -1 do
            local item = items[i]
            item:setScaleX(-1)
            self:pushBackCustomItem(item)
        end
    end
end

function UISortListView:init()
    self:setScrollBarEnabled(false)
    local items = self:getItems()
    for i, item in ipairs(items) do
        item:setTag(i)
    end
end

function UISortListView:insertItemByTag(item,tag)
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

function UISortListView:sort()
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

--修改节点的锚点,但不移动位置
function UISortListView:changeAnchor(node,newAnchor)
    local anchor = node:getAnchorPoint()
    local pos = cc.p(node:getPosition())
    local size = node:getContentSize()
    local diffAnchor = cc.pSub(anchor,newAnchor)
    diffAnchor.x = diffAnchor.x * size.width
    diffAnchor.y = diffAnchor.y * size.height
    node:setAnchorPoint(newAnchor)
    local scaleX = node:getScaleX()
    local scaleY = node:getScaleY()
    local newPos = cc.p(pos.x - diffAnchor.x,pos.y - diffAnchor.y)
    node:setPosition(newPos)
end

return UISortListView