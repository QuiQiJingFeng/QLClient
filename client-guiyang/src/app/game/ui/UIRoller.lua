local UIRollerCell = class("UIRollerCell")

function UIRollerCell:ctor()
	self._layout = ccui.Layout:create()
	self._text = ccui.TextBMFont:create()
	self._text:setFntFile("ui/art/font/font_jsz.fnt")
	self._text:setColor(cc.c3b(128, 65, 48))
	self._text:setScale(1.2)
	self._text:setPositionType(ccui.PositionType.percent)
	self._text:setPositionPercent(cc.p(0.5, 0.5))
	self._layout:addChild(self._text)
	self._layout:setTouchEnabled(false)
	self._id = -1
end

function UIRollerCell:setPosition(pos)
	self._layout:setPosition(pos)
end

function UIRollerCell:getPosition()
	return cc.p(self._layout:getPosition())
end

function UIRollerCell:getBottomBoundary()
	return self._layout:getBottomBoundary()
end

function UIRollerCell:getTopBoundary()
	return self._layout:getTopBoundary()
end

function UIRollerCell:setContentSize(size)
	self._layout:setContentSize(size)
end

function UIRollerCell:getContentSize()
	return self._layout:getContentSize()
end

function UIRollerCell:getWidget()
	return self._layout
end

function UIRollerCell:getId()
	return self._id
end

function UIRollerCell:setId(id)
	self._id = id
end

function UIRollerCell:setValue(value)
	self._value = value
	self:setString("" .. (value >= 10 and value or "0" .. value))
end

function UIRollerCell:getValue()
	return self._value
end

function UIRollerCell:setString(str)
	self._text:setString(str)
end

function UIRollerCell:setBackGroundColorType(ty)
	self._layout:setBackGroundColorType(ty)
end

function UIRollerCell:setBackGroundColor(color)
	self._layout:setBackGroundColor(color)
end

function UIRollerCell:getCenter()
	local size = self:getContentSize()
	local pos = self:getPosition()

	return cc.p(pos.x + size.width/2, pos.y + size.height/2)
end

--[[
	hhhhhhh	
	sssssss -- up boundary
	sssssss
	sssssss -- bottom boundary
	hhhhhhh 

	hhhhhhh	-- up boundary
	sssssss 
	sssssss
	sssssss 
	hhhhhhh -- bottom boundary
--]]

local UIRoller = class("UIRoller")

UIRoller.AutoScrollDirection = {
	UP = 1,
	DOWN = 2
}

UIRoller.AutoScrollEvent = {
	SCROLLING = 1
}

UIRoller.MOVE_SPEED_GATE = 200
UIRoller.MOVE_SPEED_MAX = 800

function UIRoller:ctor()
	self._layout = nil
	self._pages = {}
	self._pageSize = nil

	self._pageNumberShowed = 1
	self._loop = false

	self._pageBufferSize = self._pageNumberShowed + 2
	self._center = nil
	self._preTouchPoint = nil
	self._doLayoutDirty = false
	self._touchMoveDirection = nil
	self._upperBoundary = nil 
	self._bottomBoundary = nil
	self._autoScrolling = false
	self._autoScrollSpeed = nil
	self._speedAcc = nil
	self._isSpring = false
	self._springDistance = 0
	self._springOffset = { x=0, y=0 }
	self._gotoMode = false
	self._gotoTargetId = 0
	self._gotoTravelDistance = 0

	self._itemMin = nil
	self._itemMax = nil
	self._setIdx = 0
	self._itemCount = 0
	self._touchStartTime = nil
	self._eventListener = nil
	self._curPage = nil

	self:_init()
end

function UIRoller:dispose()
	self._layout:unscheduleUpdate()
end

function UIRoller:_init()
	self._layout = ccui.Layout:create()
	self._layout:setTouchEnabled(true)
	self._layout:setClippingEnabled(true)
	-- self._layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	-- self._layout:setBackGroundColor(cc.c3b(200, 100, 0))
	-- self._layout:setBackGroundColorOpacity(150)

	self._layout:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			self:_onTouchBegan(sender, eventType)
		elseif eventType == ccui.TouchEventType.moved then
			self:_onTouchMoved(sender, eventType)
		elseif eventType == ccui.TouchEventType.ended then
			self:_onTouchEnded(sender, eventType)
		elseif eventType == ccui.TouchEventType.canceled then
			self:_onTouchCancelled(sender, eventType)
		end
	end)

	local update = function (dt)
		self:_update(dt)
	end

	self._layout:scheduleUpdateWithPriorityLua(update, 0)
end

function UIRoller:reset()
	self._layout:removeAllChildren()
	self._pages = {}
end

function UIRoller:setEventListener(listener)
	self._eventListener = listener
end

function UIRoller:setContentSize(s)
	self._layout:setContentSize(s)
	self._doLayoutDirty = true
end

function UIRoller:getContentSize()
	return self._layout:getContentSize()
end

function UIRoller:setSpringOffset(offset)
	self._springOffset = offset
end

function UIRoller:getSpringOffset()
	return self._springOffset
end

function UIRoller:setPosition(pos)
	self._layout:setPosition(pos)
end

function UIRoller:getPosition()
	return self._layout:getPosition()
end

function UIRoller:setPageNumberShowed(n)
	self._doLayoutDirty = true
	self._pageNumberShowed = n
	self._pageBufferSize = self._pageNumberShowed + 2
end

function UIRoller:getPageNumberShowed()
	return self._pageNumberShowed
end

function UIRoller:setLoop(b)
	if self._loop ~= b then self._doLayoutDirty = true end
	self._loop = b
end

function UIRoller:isLoop()
	return self._loop
end

function UIRoller:setItems(min, max, setIdx)
	self._doLayoutDirty = true
	self._itemMin = min
	self._itemMax = max
	self._itemCount = 1 + self._itemMax - self._itemMin
	self._setIdx = setIdx
end

function UIRoller:getWidget()
	return self._layout
end

function UIRoller:doLayout()
	if not self._doLayoutDirty then return end

	self._layout:removeAllChildren()
	self._pages = {}
	local s = self:getContentSize()

	self._pageSize = cc.size(s.width, s.height/self._pageNumberShowed)
	self._center = cc.p(0, s.height/2)

	local startPos = cc.p(0, self._center.y - self._pageSize.height/2)
	local count = self._itemCount
	if count <= self._pageNumberShowed then
		self._pageBufferSize = count
		self._loop = false
	else
		self._pageBufferSize = self._pageNumberShowed + 2
	end

	self._upperBoundary = self:getContentSize().height
	self._bottomBoundary = 0

	local startId = self._setIdx
	local halfPageBufferNum = math.floor(self._pageBufferSize/2)
	if self._loop then
		startId = (startId - halfPageBufferNum + self._itemCount)%self._itemCount
		startPos.y = startPos.y + halfPageBufferNum * self._pageSize.height
	else
		startId = startId - halfPageBufferNum
		if startId < 0 then 
			startId = 0
			local diff = self._setIdx - startId
			startPos.y = startPos.y + diff * self._pageSize.height
		else
			startPos.y = startPos.y + halfPageBufferNum * self._pageSize.height
			local upperId = startId + self._pageBufferSize
			if upperId > self._itemCount then
				local diff = upperId - self._itemCount
				startId = startId - diff
				startPos.y = startPos.y + diff * self._pageSize.height
			end
		end
	end

	for i=0, self._pageBufferSize-1 do
		local page = UIRollerCell.new()
		page:setContentSize(self._pageSize)
		-- page:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		-- page:setBackGroundColor(cc.c3b(255, i * 30, 0))
		local id = (startId + i)%self._itemCount
		page:setPosition(cc.p(0, startPos.y - i * self._pageSize.height))
		page:setId(id)
		page:setValue(self:convertId2Item(id))
		self._layout:addChild(page:getWidget())
		table.insert(self._pages, page)
	end

	local page, _ = self:_findTarget()
	self._curPage = page
	-- print("curpage value is " .. page:getValue())
	self._doLayoutDirty = false
end

function UIRoller:_update(dt)
	if not self._autoScrolling then
		return
	end

	self:_autoScroll(dt)
end

function UIRoller:_autoScroll(dt)
	if self._gotoMode then
		local step = self._autoScrollSpeed * dt
		local trigger = false
		if self._touchMoveDirection == UIRoller.AutoScrollDirection.UP then
			if self._gotoTravelDistance - step <= 0 then
				step = self._gotoTravelDistance
				self._gotoTravelDistance = 0
				self._autoScrolling = true
				self._isSpring = false
				self._gotoMode = false
				trigger = true
			end

			self._gotoTravelDistance = self._gotoTravelDistance - step
		elseif self._touchMoveDirection == UIRoller.AutoScrollDirection.DOWN then
			if self._gotoTravelDistance - step >= 0 then
				step = self._gotoTravelDistance
				self._gotoTravelDistance = 0
				self._isSpring = false
				self._autoScrolling = true
				self._gotoMode = false
				trigger = true
			end

			self._gotoTravelDistance = self._gotoTravelDistance - step
		end

		self:_move({x=0, y=step})
		if trigger then
			if self._eventListener ~= nil then
				self._eventListener(self._curPage, UIRoller.AutoScrollEvent.SCROLLING)
			end
		end
	else
		if math.abs(self._autoScrollSpeed) <= UIRoller.MOVE_SPEED_GATE and not self._isSpring then
			self._isSpring = true
			local page, diff = self:_findTarget()
			self._curPage = page
			self._springDistance = diff
			if self._springDistance < 0 then
				self._touchMoveDirection = UIRoller.AutoScrollDirection.UP
				self._autoScrollSpeed = UIRoller.MOVE_SPEED_GATE
			else
				self._touchMoveDirection = UIRoller.AutoScrollDirection.DOWN
				self._autoScrollSpeed = -UIRoller.MOVE_SPEED_GATE
			end
		end

		if self._isSpring then
			local step = self._autoScrollSpeed * dt
			local trigger = false
			if self._touchMoveDirection == UIRoller.AutoScrollDirection.UP then
				if self._springDistance + step >= 0 then
					step = -self._springDistance
					self._springDistance = 0
					self._isSpring = false
					self._autoScrolling = false
					trigger = true
				end

			elseif self._touchMoveDirection == UIRoller.AutoScrollDirection.DOWN then
				if self._springDistance + step <= 0 then
					step = -self._springDistance
					self._springDistance = 0
					self._isSpring = false
					self._autoScrolling = false
					trigger = true
				end

			end

			self._springDistance = self._springDistance + step
			self:_move({x=0, y=step})
			
			if trigger then
				if self._eventListener ~= nil then
					self._eventListener(self._curPage, UIRoller.AutoScrollEvent.SCROLLING)
				end
			end
		else
			local distance = self._autoScrollSpeed * dt
			self._autoScrollSpeed = self._autoScrollSpeed + self._speedAcc * dt
			if self._touchMoveDirection == UIRoller.AutoScrollDirection.UP then
				local offset = {x=0, y=distance}
				offset = self:_reviseOffset(self._touchMoveDirection, offset)
				self:_move(offset)
			elseif self._touchMoveDirection == UIRoller.AutoScrollDirection.DOWN then
				local offset = {x=0, y=distance}
				offset = self:_reviseOffset(self._touchMoveDirection, offset)
				self:_move(offset)
			end
		end
	end
end

function UIRoller:GoTo(id)
	local curId = self._curPage:getId()
	local diff = id - curId
	local moveOffset = diff * self._pageSize.height
	self._gotoMode = true
	self._autoScrollSpeed = moveOffset > 0 and UIRoller.MOVE_SPEED_GATE or -UIRoller.MOVE_SPEED_GATE
	self._speedAcc = -self._autoScrollSpeed / 1
	self._gotoTravelDistance = moveOffset
	self._touchMoveDirection = moveOffset > 0 and UIRoller.AutoScrollDirection.UP or UIRoller.AutoScrollDirection.DOWN
	self._autoScrolling = true
	self._isSpring = false
end

function UIRoller:convertId2Item(id)
	return self._itemMin + id
end

function UIRoller:convertItem2Id(item)
	return item - self._itemMin
end

function UIRoller:_findTarget()
	local pageId = -1
	local minDistance = 999999
	for i=1, #self._pages do
		local page = self._pages[i]
		local center = page:getCenter()
		local diff = center.y - self._center.y
		if math.abs(diff) < math.abs(minDistance) then
			pageId = i
			minDistance = diff
		end
	end

	return self._pages[pageId], minDistance
end

function UIRoller:_move(diff)
	if self._touchMoveDirection == UIRoller.AutoScrollDirection.UP then
		for i=1, #self._pages do
			local pos = cc.p(self._pages[i]:getPosition())
			pos.y = pos.y + diff.y
			local boundary = self._pages[i]:getBottomBoundary()
			if boundary + diff.y > self._upperBoundary then
				local oldId = self._pages[i]:getId()
				local newId = oldId + self._pageBufferSize
				newId = newId % self._itemCount
				if self._loop or newId > oldId then
					self._pages[i]:setId(newId)
					self._pages[i]:setValue(self:convertId2Item(newId))
					pos.y = pos.y - #self._pages * self._pageSize.height
				end
			end

			self._pages[i]:setPosition(pos)
		end
	elseif self._touchMoveDirection == UIRoller.AutoScrollDirection.DOWN then
		for i=1, #self._pages do
			local pos = cc.p(self._pages[i]:getPosition())
			pos.y = pos.y + diff.y
			local boundary = self._pages[i]:getTopBoundary()
			if boundary + diff.y < self._bottomBoundary then
				local oldId = self._pages[i]:getId()
				local newId = oldId + self._itemCount - self._pageBufferSize
				newId = newId % self._itemCount
				if self._loop or newId < oldId then
					self._pages[i]:setId(newId)
					self._pages[i]:setValue(self:convertId2Item(newId))
					pos.y = pos.y + #self._pages * self._pageSize.height
				end
			end

			self._pages[i]:setPosition(pos)
		end
	end
end

function UIRoller:_onTouchBegan(sender, eventType)
	self._preTouchPoint = sender:getTouchBeganPosition()
	self._autoScrolling = false
	self._gotoMode = false
	self._touchStartTime = kod.util.Time.now()
	self._autoScrollSpeed = 0
end

function UIRoller:_onTouchMoved(sender, eventType)
	local touchPos = sender:getTouchMovePosition()
	local preTouchPos = clone(self._preTouchPoint)
	self._preTouchPoint = clone(touchPos)

	local offset = {
		x = touchPos.x - preTouchPos.x,
		y = touchPos.y - preTouchPos.y,
	}

	offset.x = 0
	if offset.y > 0 then 
		self._touchMoveDirection = UIRoller.AutoScrollDirection.UP
	elseif offset.y < 0 then
		self._touchMoveDirection = UIRoller.AutoScrollDirection.DOWN
	end

	local currentTime = kod.util.Time.now()
	local dt = currentTime - self._touchStartTime
	self._touchStartTime = currentTime
	if dt == 0 then dt = 1 end
	self._autoScrollSpeed = offset.y/dt
	if math.abs(self._autoScrollSpeed) > UIRoller.MOVE_SPEED_MAX then
		self._autoScrollSpeed = self._autoScrollSpeed > 0 and UIRoller.MOVE_SPEED_MAX or - UIRoller.MOVE_SPEED_MAX
	end
	-- print("speed is " .. self._autoScrollSpeed)

	offset = self:_reviseOffset(self._touchMoveDirection, offset)
	self:_move(offset)
end

function UIRoller:_onTouchEnded(sender, eventType)
	-- print("end speed is " .. self._autoScrollSpeed)

	self:_handleTouchEnd()
end

function UIRoller:_onTouchCancelled(sender, eventType)
	self:_handleTouchEnd()
end

function UIRoller:_handleTouchEnd(sender, eventType)
	self._speedAcc = -self._autoScrollSpeed/1
	self._autoScrolling = true
	self._isSpring = false
end

function UIRoller:_reviseOffset(direction, offset)
	if self._loop then return offset end

	local newOffset = offset

	if direction == UIRoller.AutoScrollDirection.UP then
		local page = self:_findLowerPage()
		assert(page ~= nil)
		if page:getValue() >= self._itemMax and page:getBottomBoundary() > self._center.y - self._pageSize.height/2 then
			self._autoScrollSpeed = UIRoller.MOVE_SPEED_GATE
			local topBoundary = page:getTopBoundary()
			if topBoundary > self._upperBoundary + self._springOffset.y then 
				newOffset.y = 0
			elseif topBoundary + offset.y > self._upperBoundary then
				newOffset.y = self._upperBoundary - topBoundary
			end
		end
	elseif direction == UIRoller.AutoScrollDirection.DOWN then 
		local page = self:_findUpperPage()
		assert(page ~= nil)
		if page:getValue() <= self._itemMin and page:getTopBoundary() < self._center.y + self._pageSize.height/2 then
			self._autoScrollSpeed = -UIRoller.MOVE_SPEED_GATE
			local bottomBoundary = page:getBottomBoundary()

			if bottomBoundary < self._bottomBoundary - self._springOffset.y then
				newOffset.y = 0
			elseif bottomBoundary + offset.y < self._bottomBoundary then
				newOffset.y = self._bottomBoundary - bottomBoundary
			end
		end
	end

	return newOffset
end

function UIRoller:_findUpperPage()
	local minPage = nil 
	local minId = 999999
	for _, page in ipairs(self._pages) do
		local id = page:getId()
		if id < minId then
			minId = id
			minPage = page
		end
	end
	return minPage 
end

function UIRoller:_findLowerPage()
	local maxPage = nil 
	local maxId = -1 
	for _, page in ipairs(self._pages) do
		local id = page:getId()
		if id > maxId then
			maxId = id
			maxPage = page
		end
	end
	return maxPage
end

return UIRoller