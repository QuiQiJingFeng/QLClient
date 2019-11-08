local UIFreeList = class("UIFreeList")

function UIFreeList.extend(list,template,clickFunc)
    for idx, node in ipairs(list) do
        template:extend(node,self)
        node:setIdx(idx)
    end
    local freeList = UIFreeList.new()
    freeList:init(list,clickFunc)
    return freeList
end

function UIFreeList:init(list,clickFunc)
    self._list = list
    self._clickFunc = clickFunc
    for idx, item in ipairs(list) do
        item:setTouchEnabled(true)
        item:addTouchEventListener(function(item, eventType)
            if eventType == ccui.TouchEventType.ended then
                local selectIdx = item:getIdx()
                self:setCurrentSelectIndex(selectIdx)
                local data = item:getData()
                self._clickFunc(item,data)
            end
        end)
        item:setSelectState(idx == self._currentSelectedIdx)
    end
end

function UIFreeList:setCurrentSelectIndex(selectIdx)
    if self._currentSelectedIdx == selectIdx then
        return
    end
    self._currentSelectedIdx = selectIdx
    for idx, item in pairs(self._list) do
        item:setSelectState(idx == self._currentSelectedIdx)
    end
end

function UIFreeList:updateDatas(datas)
    self._datas = clone(datas)
    self._currentSelectedIdx = nil
    for idx, data in ipairs(datas) do
        self:setData(idx,data)
    end
end

function UIFreeList:getData()
    return clone(self._datas)
end

function UIFreeList:setData(idx,data)
    self._list[idx]:setData(data,idx)
end





return UIFreeList