local UIFreeList = class("UIFreeList")

function UIFreeList:extend(list,template)
    for _, node in ipairs(list) do
        template.extend(node,self)
    end
    self._list = list
end

function UIFreeList:updateDatas(datas)
    self._datas = datas
    for idx, data in ipairs(datas) do
        self:setData(idx,data)
    end
end

function UIFreeList:getData()
    return self._datas
end

function UIFreeList:setData(idx,data)
    self._list[idx]:setData(data,idx)
end





return UIFreeList