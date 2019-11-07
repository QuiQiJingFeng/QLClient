local UITableViewEx2 = class("UITableViewEx2")
--[[ 
    多模板 单列表
]]
local OUT_OF_BOUNDARY_BREAKING_FACTOR = 0.05
function UITableViewEx2.extend(self,cellTemplates,filterCellType,clickFunc)
    local t = tolua.getpeer(self)
    if not t then
        t = {}
        tolua.setpeer(self, t)
    end
    setmetatable(t, UITableViewEx2)
    self:initWithCellTemplate(cellTemplates,filterCellType,clickFunc)
    assert(self:getDescription() == "Layout","must be Layout")

    return self
end

function UITableViewEx2:initWithCellTemplate(cellTemplates,filterCellType,clickFunc)
    assert(filterCellType)
    self._filterCellType = filterCellType
    self._clickFunc = clickFunc
    self._cellTemplates = cellTemplates
    local children = self:getChildren()
    for i, child in pairs(children) do
        child:setVisible(false)
    end
    self._queue = {}
    for i, _ in ipairs(cellTemplates) do
        self._queue[i] = {}
    end
    self._cellNodes = children
    self._tableViewSize = self:getContentSize()
    self._container = cc.Layer:create()
    self._container:setContentSize(self._tableViewSize)
    self:addChild(self._container)

    local box1 = children[1]:getBoundingBox()
    local box2 = children[2]:getBoundingBox()
    local dx = math.abs(box2.x - box1.x)
    local dy = math.abs(box2.y - box1.y)
    --默认竖直滑动
    self:setVirtical(dy > dx)
    if self._isVertical then
        self:setDeltUnit(dy - box2.height)
    else
        self:setDeltUnit(dx - box2.width)
    end

    self._datas = {}
    self._usedCell = {}
    self:addTouchEventListener(function(sender, eventType,touch) 
        if eventType == ccui.TouchEventType.began then
            self._container:stopAllActions()
            local pos = sender:getTouchBeganPosition()
            self:onTouchBegan(pos)
            local time = kod.util.Time.nowMilliseconds()
            self._recordTouchMoved = { {pos = pos,time = time} }
        elseif eventType == ccui.TouchEventType.moved then
            local pos = sender:getTouchMovePosition()
            self:onTouchMoved(pos)
        elseif eventType == ccui.TouchEventType.ended then
            local pos = self:getTouchEndPosition()
            self:onTouchMoved(pos)
            local time = kod.util.Time.nowMilliseconds()
            table.insert(self._recordTouchMoved,{pos = pos,time = time})
            local velocity = cc.pSub(self._recordTouchMoved[2].pos,self._recordTouchMoved[1].pos)
            local deltTime = (self._recordTouchMoved[2].time - self._recordTouchMoved[1].time) / 1000
            velocity = cc.pMul(velocity, 1/(deltTime))
            --开始惯性移动
            self:startInertiaScroll(velocity) 
        end
    end)

    local function onNodeEvent(event)
        if "exit" == event then
            if self._schedueId then
                self:unscheduleUpdate(self._schedueId)
            end
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function UITableViewEx2:onTouchBegan(pos)
    self._touchPos = self:convertToNodeSpace(pos)
    self._preTime = kod.util.Time.nowMilliseconds()
    local boundingBox = self:getBoundingBox()
    boundingBox.x = 0
    boundingBox.y = 0
    if cc.rectContainsPoint(boundingBox, self._touchPos ) then
        return true
    end
end

function UITableViewEx2:fixPositionOutOfBound(newPos)
    if self._isVertical then
        newPos.x = 0
        --避免超出上边界
        newPos.y = newPos.y >= 0 and newPos.y or 0
        local info = self._cellTypeInfos[#self._datas]
        local box = info.box
        if box.y < 0 then
            local posY = math.abs(box.y)
            newPos.y = newPos.y <= posY and newPos.y or posY
        elseif box.y >= 0 then
            newPos.y = 0
        end
    else
        newPos.y = 0
        newPos.x = newPos.x <= 0 and newPos.x or 0
        local info = self._cellTypeInfos[#self._datas]
        local size = self._container:getContentSize()
        local box = info.box
        if box.x <= size.width then
            newPos.x = 0
        else
            --取元素右边的点
            local x = box.x + box.width
            local posX = size.width - x
            newPos.x = newPos.x >= posX and newPos.x or posX
        end
 
    end
    return newPos
end

function UITableViewEx2:setFixPosition(newPos)
    newPos = self:fixPositionOutOfBound(newPos)
    self._container:setPosition(newPos)
end

function UITableViewEx2:onTouchMoved(pos)
    local touchMove = self:convertToNodeSpace(pos)
    local distance = cc.pGetDistance(self._touchPos,touchMove)
    if distance > 0 then
        local pos = cc.pSub(touchMove,self._touchPos)
        local containerPos = cc.p(self._container:getPosition())
        local newPos = cc.pAdd(containerPos,pos)
        self:setFixPosition(newPos)
        self:update()
        self._touchPos = touchMove
    end
end

function UITableViewEx2:update()
    if #self._datas <= 0 then
        return
    end
    local containPos = cc.p(self._container:getPosition())
    if not self._containerPos then
        self._containerPos = containPos
        return
    end
    if cc.pGetDistance(self._containerPos,containPos) == 0 then
        if self._schedueId then
            self:unscheduleUpdate(self._schedueId)
        end
        return
    end

    self:checkRemoveCell()
    self:checkAddCell()
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

function UITableViewEx2:getUsedCell()
    return self._usedCell
end

function UITableViewEx2:getDataByIndex(idx)
    return self._datas[idx]
end

function UITableViewEx2:getDatas()
    return clone(self._datas)
end

function UITableViewEx2:updateDatas(datas)
    self._datas = clone(datas)
    
    --先行计算出所有元素的位置和大小
    --当前可用开始位置<元素的左下角位置>
    self._cellTypeInfos = {}
    local boundingBox = self._cellNodes[1]:getBoundingBox()
    local size = self._cellNodes[1]:getContentSize()
    --获取元素左上角位置
    self._currentPos = cc.p(boundingBox.x,boundingBox.y + size.height)
    for idx, data in ipairs(self._datas) do
       --其中pos用来设置位置,box用来检测是否在可视范围内
       self._cellTypeInfos[idx] = self:getCellTypeInfo(data)
    end
    self:checkAddCell()
end

function UITableViewEx2:getCellTypeInfo(data)
    local cellType = self._filterCellType(data)
    local cellTemplate = self._cellNodes[cellType]
    local anchor = cellTemplate:getAnchorPoint()
    local size = cellTemplate:getContentSize()
    local x = self._currentPos.x + anchor.x * size.width
    local y = self._currentPos.y + (1 - anchor.y) * size.height
    local targetPos = cc.p(x,y)
    --左下角位置+宽高
    local boundingBox = cc.rect(self._currentPos.x,self._currentPos.y - size.height,size.width,size.height)
    --更新下一个位置点
    if self._isVertical then
        self._currentPos.y = self._currentPos.y - size.height - self._deltUnit
    else
        self._currentPos.x = self._currentPos.x + size.width + self._deltUnit
    end
    
    return {pos = targetPos,box = boundingBox,type = cellType}
end

function UITableViewEx2:isInRectView(idx)
    local typeInfo = self._cellTypeInfos[idx]
    --检测点是否在可视区域内
    local origin = self._container:convertToNodeSpace(self:convertToWorldSpace(cc.p(0,0)))
    local rect = {x=origin.x,y=origin.y,width=self._tableViewSize.width,height=self._tableViewSize.height}
    if cc.rectIntersectsRect(rect, typeInfo.box ) then
        return true
    end
end

function UITableViewEx2:dequeueCell(idx)
    local typeInfo = self._cellTypeInfos[idx]
    local cellType = typeInfo.type
    local queue = self._queue[cellType]
    local cell
    if #queue > 0 then
        cell = table.remove(queue)
    else
        cell = self._cellTemplates[cellType]:extend(self._cellNodes[cellType]:clone(),self)
        self._container:addChild(cell)
    end
    cell:setVisible(true)
    local data = self:getDataByIndex(idx)
    cell:setIdx(idx)
    cell:setData(data)
    cell:setCellType(cellType)
    cell:setSwallowTouches(false)
    self._usedCell[idx] = cell
    return cell
end

function UITableViewEx2:checkAddCell()
    for idx = 1, #self._datas do
        if not self._usedCell[idx] and self._datas[idx] then
            if self:isInRectView(idx) then
                local cell = self:dequeueCell(idx)
                cell:setPosition(self._cellTypeInfos[idx].pos)
            end
        elseif self._usedCell[idx] then
            if self._usedCell[idx]:getData() ~= self._datas[idx] then
                self._usedCell[idx]:setData(self._datas[idx])
            end
        end
    end
end

function UITableViewEx2:pushQueue(cell)
    cell:setPosition(cc.p(-10000000,-10000000))
    cell:setVisible(false)
    local cellType = cell:getCellType()
    table.insert(self._queue[cellType],cell)
end

function UITableViewEx2:checkRemoveCell()
    for idx, cell in pairs(self._usedCell) do
        if not self:isInRectView(idx) then
            self:pushQueue(cell)
            self._usedCell[idx] = nil
        end
    end
end

function UITableViewEx2:startInertiaScroll(touchMoveVelocity)
    self._container:stopAllActions()
    if self._schedueId then
        self:unscheduleUpdate(self._schedueId)
    end
    local MOVEMENT_FACTOR = 0.7
    local inertiaTotalMovement = cc.pMul(touchMoveVelocity , MOVEMENT_FACTOR)
    if self._isVertical then
        inertiaTotalMovement.x = 0
    else
        inertiaTotalMovement.y = 0
    end
    local pos = cc.p(self._container:getPosition())
    local newPos = cc.pAdd(pos,inertiaTotalMovement)
    newPos = self:fixPositionOutOfBound(newPos)
    local action = cc.EaseOut:create(cc.MoveTo:create(0.5,newPos), 2.5)
    self._container:runAction(action)
    self._schedueId = self:scheduleUpdate(handler(self,self.update),0)
end

---------------------------------------------------
--开启持续的调度,如果回调方法返回true,会自动取消注册
---------------------------------------------------
function UITableViewEx2:scheduleUpdate(callback, intervalSec)
    assert(callback)
    intervalSec = intervalSec or 0
    local scheduleId = nil
    scheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        --如果回调方法返回true,那么直接停止调度
        local isStop = callback(dt)
        if isStop then
            if scheduleId then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
            end
        end
    end, intervalSec, false)
    return scheduleId
end

---------------------------------------------------
--取消持续的调度,
--如果在上一个方法中没有在回调方法中处理取消就需要手动取消
---------------------------------------------------
function UITableViewEx2:unscheduleUpdate(scheduleId)
    if scheduleId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleId)
    end
    return nil
end

--[[
    local cellTemplates = {UITestItem1,UITestItem2,UITestItem3}
    local node = seekNodeByName(self,"listEx2","ccui.Layout")
    self._listEx2 = UITableViewEx2.extend(node,cellTemplates,handler(self,self.filterCellType))

    self._listEx2:updateDatas({
        {type = 3},
        {type = 1},
        {type = 2},
        {type = 3},
        {type = 1},
    })

--type指的是子模板的ID,按照添加的顺序分别是1,2,3...
function XXX:filterCellType(data)
    return data.type
end
]]

return UITableViewEx2