--extern Layout
local UITableViewEx2 = class("UITableViewEx2")

function UITableViewEx2.extend(self, cellTemplate,clickFunc)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UITableViewEx2)
    self:initWithCellTemplate(cellTemplate,clickFunc)
    assert(self:getDescription() == "ScrollView","must be scrollView")

    return self
end

function UITableViewEx2:initWithCellTemplate(cellTemplate,clickFunc)
    self._cellTemplate = cellTemplate
    self._clickFunc = clickFunc
    self._tableViewSize = self:getContentSize()
    self._container = self:getInnerContainer()
    self:setScrollBarEnabled(false)

    --间隔默认0个像素
    self:setDeltUnit(0)
    --默认竖直滑动
    self:setVirtical(self:getDirection() == ccui.ScrollViewDir.vertical)
 

    self._datas = {}
    self._usedCell = {}

    self._currentSelectedIdx = nil
    self:addEventListener(function(sender, eventType)
        if eventType ==  ccui.ScrollviewEventType.containerMoved then
            self:update()
        elseif eventType == ccui.ScrollviewEventType.autoscrollEnded then
            if self._scrollItemToCenter then
                self:scrollItemToCenter()
            end
        end
    end)
end

--设置列表元素间隔
function UITableViewEx2:setDeltUnit(deltUnit)
    self._deltUnit = deltUnit
end

--设置滑动方向
function UITableViewEx2:setVirtical(isVirtical)
    self._isVertical = isVirtical
end

function UITableViewEx2:getVirtical(isVirtical)
    return self._isVertical
end

function UITableViewEx2:updateDatas(datas)
    self:clear()
    local datas = clone(datas)
    self._datas = datas
 
    if self._isVertical then
        self:jumpToPercentVertical(0)
    else
        self:jumpToPercentHorizontal(0)
    end

    self:checkAddCell()
    if self._clickFunc then
        self:setCurrentSelectIndex(1)
    end
end

function UITableViewEx2:update(dt)
    if #self._datas <= 0 then
        return
    end
    local containPos = cc.p(self._container:getPosition())
    if not self._containerPos then
        self._containerPos = containPos
        return
    end
    if cc.pGetDistance(self._containerPos,containPos) == 0 then
        return
    end

    self:checkRemoveCell()
    self:checkAddCell()
end

function UITableViewEx2:dequeueCell(idx)
    if not self._queue then
        self._queue = {}
    end
    local cell
    if #self._queue > 0 then
        cell = table.remove(self._queue)
    else
        cell = self._cellTemplate.new()
        cell:init()
        self._container:addChild(cell)
    end
    cell:setVisible(true)
    cell:setDiffDelt(cc.p(0,0))
    local data = self:getDataByIndex(idx)
    cell:setIdx(idx)
    cell:setData(data)
    self._usedCell[idx] = cell

    if self._clickFunc then
        cell:setTouchEnabled(true)
        cell:addTouchEventListener(function(cell, eventType)
            if eventType == ccui.TouchEventType.ended then
                local selectIdx = cell:getIdx()
                self:setCurrentSelectIndex(selectIdx)
                local data = cell:getData()
                self._clickFunc(cell,data,eventType)
            end
        end)
        cell:setSelectState(idx == self._currentSelectedIdx)
    end

    return cell
end

function UITableViewEx2:setCurrentSelectIndex(selectIdx)
    self._currentSelectedIdx = selectIdx
    for idx, ucell in pairs(self._usedCell) do
        ucell:setSelectState(idx == self._currentSelectedIdx)
    end
end

function UITableViewEx2:getCellByIndex(idx)
    return self._usedCell[idx]
end

function UITableViewEx2:getUsedCell()
    return self._usedCell
end

function UITableViewEx2:pushQueue(cell)
    cell:setPosition(cc.p(-10000000,-10000000))
    cell:setVisible(false)
    table.insert(self._queue,cell)
end

function UITableViewEx2:getDataByIndex(idx)
    return self._datas[idx]
end

function UITableViewEx2:getDatas()
    return self._datas
end

function UITableViewEx2:checkAddCell()
    for idx = 1, #self._datas do
        if not self._usedCell[idx] and self._datas[idx] then
            local cell = self:dequeueCell(idx)
            local size = cell:setData(self._datas[idx])
            local x,y = 0,0
            if self._posMap[idx] then
                x,y = self._posMap[idx].x,self._posMap[idx].y
            else
                x,y = self._currentPos.x,self._currentPos.y
            end
            local diffDelt = cell:getDiffDelt()
            x = x + diffDelt.x
            y = y + diffDelt.y
            
            cell:setPosition(cc.p(x,y))

            local boundingBox = cell:getBoundingBox()
            --检测点是否在可视区域内
            local origin = self._container:convertToNodeSpace(self:convertToWorldSpace(cc.p(0,0)))
            local rect = {x=origin.x,y=origin.y,width=self._tableViewSize.width,height=self._tableViewSize.height}
            if not cc.rectIntersectsRect(rect,boundingBox ) then
                self:pushQueue(cell)
                self._usedCell[idx] = nil
            else
                if self._isVertical then
                    y = y - size.height - self._deltUnit
                else
                    x = x + size.width + self._deltUnit
                end
                self._posMap[idx] = cc.p(x,y)
                self._currentPos = self._posMap[idx]
            end
        elseif self._datas[idx] then
            if self._usedCell[idx]:getData() ~= self._datas[idx] then
                self._usedCell[idx]:setData(self._datas[idx])
            end
        end
    end
end

function UITableViewEx2:clear()
    local keys = table.keys(self._usedCell)
    table.sort(keys,function(a,b)
        return a > b
    end)
    for _, idx in ipairs(keys) do
        self:pushQueue(self._usedCell[idx])
    end

    self._usedCell = {}
    self._currentPos = cc.p(0,0)
    self._posMap = {}
end

function UITableViewEx2:checkRemoveCell()
    for idx, cell in pairs(self._usedCell) do
        local boundingBox = cell:getBoundingBox()
        --检测点是否在可视区域内
        local origin = self._container:convertToNodeSpace(self:convertToWorldSpace(cc.p(0,0)))
        local rect = {x=origin.x,y=origin.y,width=self._tableViewSize.width,height=self._tableViewSize.height}
        if not cc.rectIntersectsRect(rect,boundingBox ) then
            self:pushQueue(cell)
            self._usedCell[idx] = nil
        end
    end
end

return UITableViewEx2
