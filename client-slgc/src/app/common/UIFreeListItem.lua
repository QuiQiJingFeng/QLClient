local UIFreeListItem = class("UIFreeListItem")

function UIFreeListItem:extend(node,freeList)
    local peer = tolua.getpeer(node)
    if not peer then
        peer = {}
        tolua.setpeer(node, peer)
    end
    setmetatable(peer, self)
    node:init(freeList)
    return node 
end



function UIFreeListItem:init(freeList)
    self._freeList = freeList
end

function UIFreeListItem:getData()
    return self._data
end

function UIFreeListItem:setData(data)
    self._data = data
    self:updateData(data)
end

function UIFreeListItem:updateData(data)
end

function UIFreeListItem:setIdx(idx)
    self._idx = idx
end

function UIFreeListItem:getIdx()
    return self._idx
end

function UIFreeListItem:getFreeList()
    return self._freeList
end

function UIFreeListItem:setSelectState(boolean)
end



return UIFreeListItem