--[[
    封装的可以循环使用的listview
    在使用的时候，注意，需要在某个界面上开启帧更新事件，没有测试直接开启timer如何
    例：
	self:scheduleUpdateWithPriorityLua(function(dt)
		ListViewSimpleCircle:update(dt)
	end, 1)
    为方便，这里没有没有设置任何的潜规则
]]

local ListViewSimpleCircle = class("ListViewSimpleCircle")

--[[
    @param listView 一个包含，默认扩展item的list
    @param totalCount 总供要处理的item数，用来计算sliderbar
    @param funcItemUpdate 更新item的函数，原型function(itemClass, index, item)
    @param itemClass item的处理器，更新的时候直接填充数据，不必再去重新seek
]]
function ListViewSimpleCircle:ctor(listView, totalCount, funcItemUpdate, itemClass)
    -- 可循环的item数量
	self._spawnCount = 0
    -- 更新最小间隔
	self._updateInterval = 0.01
    -- 要显示的最大个数
	self._totalCount = 10
    -- 上次的list位置，用来判断向上还是向下滑动
	self._lastContentPosY = 0
    -- 一个缓冲的大小，当超过这个距离后，就从这个位置移动到另一个位置了，保守设置为一个item的高+两个间隔的距离
	self._bufferZone = 50

    -- 要处理的listview
	self._listView = nil
    -- 更新函数，当这个item位置发生变化的时候，更新显示的内容
    self._funcItemUpdate = nil
    -- 一个item的高度
	self._itemTemplateHeight = nil
    -- 两个行的间距
    self._itemMargin = nil
    -- item的数据结构
	self._itemClass = 8

    -- 上次的更新间隔
    self._updateTimer = 0
    -- 获取当前item，在total中的index，即总个数中表示的实际位置
    -- 具体的转化原理，可以理解为贪吃蛇，尾部移动一格子放到头部，或者头部移动一格子到尾部，只有这两个移动方式，
    -- 故，坐标的变化只会是items的长度
    -- 变量已无用，但是原理保留一下吧
    -- self._spawnIndex2totalIndex = {}

    self._initialized = false

    self:_init(listView, totalCount, funcItemUpdate, itemClass)
end

--[[
    @param listView 一个包含，默认扩展item的list
    @param totalCount 总供要处理的item数，用来计算sliderbar
    @param funcItemUpdate 更新item的函数，原型function(itemClass, index, item)
    @param itemClass item的处理器，更新的时候直接填充数据，不必再去重新seek
]]
function ListViewSimpleCircle:_init(listView, totalCount, funcItemUpdate, itemClass)
	self._listView = listView
	self._totalCount = totalCount
    self._funcItemUpdate = funcItemUpdate
	self._itemClass = itemClass

    Macro.assetTrue(listView == nil, "listView = nil")
    Macro.assetTrue(totalCount == nil, "totalCount = nil")
    Macro.assetTrue(type(funcItemUpdate) ~= "function", "funcItemUpdate ~= function")
    Macro.assetTrue(itemClass == nil, "itemClass = nil")

    local defaultItem = self._listView:getItem(0)
    if Macro.assetTrue(defaultItem == nil, "ListView doesn`t have default item!") then
        -- listView 不合法
        return
    end

    self._itemTemplateHeight = defaultItem:getContentSize().height
    self._itemMargin = self._listView:getItemsMargin()
    self._bufferZone = self._itemTemplateHeight + self._itemMargin * 2

	local listViewHeight = self._listView:getContentSize().height
    local totalIndex = 0

    self._spawnCount = math.ceil(listViewHeight / (self._itemTemplateHeight + self._itemMargin)) + 1
	self._reuseItemOffset = (self._itemTemplateHeight + self._itemMargin) * self._spawnCount

    local maxItemNumber = self._spawnCount >= self._totalCount and self._totalCount or self._spawnCount
    local currItemNumber = #self._listView:getItems()

    -- 先全部创建出来
    for ii=1,self._spawnCount do
        -- 注意现在调用init的时候，重置位置，如果保存位置的话，再另行考虑
        local item = nil
        local index = ii
        if index <= currItemNumber then
            -- 如果item已经存在，获取
            item = self._listView:getItem(index-1)
        else
            -- 如果不够，循环使用的个数，clone
            item = defaultItem:clone()
            self._listView:pushBackCustomItem(item)
        end
        item.itemData = self._itemClass.new(item)
        item.index = ii
        if ii > self._totalCount then
            item:setVisible(false)
        else
            -- 更新数据
            self._funcItemUpdate(item.itemData, item.index, item)
            item:setVisible(true)
        end
    end
    -- 调整显示
	self._listView:forceDoLayout();
	local totalHeight = self._itemTemplateHeight * self._totalCount + (self._totalCount - 1) * self._itemMargin
	self._listView:getInnerContainer():setContentSize(cc.size(self._listView:getInnerContainerSize().width, totalHeight > listViewHeight and totalHeight or listViewHeight))
	self._listView:jumpToTop()
    self._initialized = true
end

-- 更新当前listview的最大数量
-- 同时更新一下当前正在显示的内容
-- TODO:现在基本能保持坐标的不变，在动态调整的时候，但是可能会出现不显示的情况，再改一下
function ListViewSimpleCircle:setTotalCount(totalCount)
	self._totalCount = totalCount
    local y = self._listView:getInnerContainer():getPositionY()
    local size = self._listView:getInnerContainer():getContentSize()
    -- 更新一下item的显示
    for ii=1,self._spawnCount do
        local item = self._listView:getItem(ii-1)
        if ii > self._totalCount then
            item:setVisible(false)
        else
            -- 更新数据
            self._funcItemUpdate(item.itemData, item.index, item)
            item:setVisible(true)
        end
        item.index = ii
    end
	local listViewHeight = self._listView:getContentSize().height
	local totalHeight = self._itemTemplateHeight * self._totalCount + (self._totalCount - 1) * self._itemMargin
    -- 重新调整布局
	self._listView:forceDoLayout();
    local newHeight = totalHeight > listViewHeight and totalHeight or listViewHeight
	self._listView:getInnerContainer():setContentSize(cc.size(self._listView:getInnerContainerSize().width, newHeight))
    -- TODO:这种是插入的时候，维持百分比不变
    -- 缺点是发生改变后，原有的滑动效果消失
    -- 如果add是>0 那么是添加了，如果add是<0 那么是减小了
    local addHeight = (newHeight - size.height)
    local allLenght = newHeight - listViewHeight
    local realPercent = (allLenght + (y - addHeight)) / allLenght * 100
    local percent = allLenght == 0 and 100 or (realPercent <= 0 and 0 or (realPercent > 100 and 100 or realPercent))
    self._listView:jumpToPercentVertical(percent)

    -- TODO:这种是设置坐标的方式
    -- 这种的好处是可以维持原本的滑动效果，但是同样也有bug，在滑动的时候，会保持原有的百分比，也即会超前
    -- 还一个bug，在最上面的时候，会死循环卡死
    -- y = y - (newHeight - size.height)
    -- if y > 0 then
    --     y = 0
    -- end
    -- self._listView:getInnerContainer():setPositionY(y)

    -- 当某一个item进入到显示窗口内就可以了
    local tryTimes = 0
	scheduleOnce(function()
        while not self:_updateListViewItems() do
            print("tryTimes: "..tryTimes)
            tryTimes = tryTimes + 1
        end
	end, self._updateInterval)
end

-- -- 当listview 子控件发生变化时，需要先将item定位到实际显示的窗口内
-- -- TODO:此种方式是递归，会随控件数，时间递增
-- function ListViewSimpleCircle:_updateListViewItems()
-- 	local totalHeight = self._itemTemplateHeight * self._totalCount + (self._totalCount - 1) * self._itemMargin
-- 	local listViewHeight = self._listView:getContentSize().height
-- 	local items = self._listView:getItems()
-- 	local isDown = self._listView:getInnerContainer():getPositionY() < self._lastContentPosY

--     local result = 0
-- 	local i = 1
-- 	while i <= self._spawnCount and i <= self._totalCount do
-- 		local item = items[i]
-- 		local itemPos = self:getItemPositionYInView(item)
--         if itemPos < -self._bufferZone and item:getPositionY() + self._reuseItemOffset < totalHeight then
--             local totalIndex = item.index - #items
--             print("totalIndex: "..totalIndex)
--             -- TODO:不知道为啥，这里会有bug，第一次会进来，添加一下保护
--             -- 应该是放值控件位置的layout发生变化，没有做位置调整
--             if totalIndex > 0 then
--                 item:setPositionY(item:getPositionY() + self._reuseItemOffset)
--                 self._funcItemUpdate(item.itemData, totalIndex, item)
--                 item.index = totalIndex
--             end
--         elseif itemPos > self._bufferZone + listViewHeight and item:getPositionY() - self._reuseItemOffset >= 0 then
--             local totalIndex = item.index + #items
--             print("totalIndex: "..totalIndex)
--             if totalIndex <= self._totalCount then
--                 item:setPositionY(item:getPositionY() - self._reuseItemOffset)
--                 self._funcItemUpdate(item.itemData, totalIndex, item)
--                 item.index = totalIndex
--             end
--         end

--         if itemPos > -self._bufferZone and itemPos < self._bufferZone + listViewHeight then
--             result = result + 1
--         else
--             print("itemPos: "..itemPos)
--         end
-- 		i = i + 1
-- 	end
-- 	self._lastContentPosY = self._listView:getInnerContainer():getPositionY()
--     print("result: "..result)
--     print("_spawnCount: "..self._spawnCount)
--     print("_totalCount: "..self._totalCount)
--     return result >= self._spawnCount - 2 or result == self._totalCount
-- end

-- 当listview 子控件发生变化时，需要先将item定位到实际显示的窗口内
-- TODO:此种方式是计算，计算一个大体的倍数，直接跳转过去，好处是速度快，但是算法需要验证
function ListViewSimpleCircle:_updateListViewItems()
	local totalHeight = self._itemTemplateHeight * self._totalCount + (self._totalCount - 1) * self._itemMargin
	local listViewHeight = self._listView:getContentSize().height
	local items = self._listView:getItems()
	local isDown = self._listView:getInnerContainer():getPositionY() < self._lastContentPosY

    local result = 0
	local i = 1
	while i <= self._spawnCount and i <= self._totalCount do
		local item = items[i]
		local itemPos = self:getItemPositionYInView(item)
        local multiple = 1
        if itemPos < -self._bufferZone and item:getPositionY() + self._reuseItemOffset < totalHeight then
            while itemPos + multiple * self._reuseItemOffset < - self._bufferZone do
                -- 整体移动一段，还赶不到屏幕内
                multiple = multiple + 1
            end
            local totalIndex = item.index - (#items) * multiple
            -- TODO:不知道为啥，这里会有bug，第一次会进来，添加一下保护
            -- 应该是放值控件位置的layout发生变化，没有做位置调整
            if totalIndex > 0 then
                item:setPositionY(item:getPositionY() + self._reuseItemOffset * multiple)
                self._funcItemUpdate(item.itemData, totalIndex, item)
                item.index = totalIndex
            end
        elseif itemPos > self._bufferZone + listViewHeight and item:getPositionY() - self._reuseItemOffset >= 0 then
            while itemPos - multiple * self._reuseItemOffset > self._bufferZone + listViewHeight do
                -- 整体移动一段，还赶不到屏幕内
                multiple = multiple + 1
            end
            local totalIndex = item.index + #items * multiple
            if totalIndex <= self._totalCount then
                item:setPositionY(item:getPositionY() - self._reuseItemOffset * multiple)
                self._funcItemUpdate(item.itemData, totalIndex, item)
                item.index = totalIndex
            end
        end
        print("multiple: "..multiple)

        if itemPos > -self._bufferZone and itemPos < self._bufferZone + listViewHeight then
            result = result + 1
        end
		i = i + 1
	end
	self._lastContentPosY = self._listView:getInnerContainer():getPositionY()
    return result >= self._spawnCount - 2 or result == self._totalCount
end

-- 逐帧更新函数
function ListViewSimpleCircle:update(dt)
    if not self._initialized then
        return
    end

	self._updateTimer = (self._updateTimer or 0) + dt
	if self._updateTimer < self._updateInterval then
		return
	end
	self._updateTimer = 0

	local totalHeight = self._itemTemplateHeight * self._totalCount + (self._totalCount - 1) * self._itemMargin
	local listViewHeight = self._listView:getContentSize().height
	local items = self._listView:getItems()
	local isDown = self._listView:getInnerContainer():getPositionY() < self._lastContentPosY

	local i = 1
	while i <= self._spawnCount and i <= self._totalCount do
		local item = items[i]
		local itemPos = self:getItemPositionYInView(item)
		if isDown then
			if itemPos < -self._bufferZone and item:getPositionY() + self._reuseItemOffset < totalHeight then
				local totalIndex = item.index - #items
                -- TODO:不知道为啥，这里会有bug，第一次会进来，添加一下保护
                -- 应该是放值控件位置的layout发生变化，没有做位置调整
                if totalIndex > 0 then
                    item:setPositionY(item:getPositionY() + self._reuseItemOffset)
                    self._funcItemUpdate(item.itemData, totalIndex, item)
                    item.index = totalIndex
                end
            elseif itemPos > self._bufferZone + listViewHeight and item:getPositionY() - self._reuseItemOffset >= 0 then
				local totalIndex = item.index + #items
                if totalIndex <= self._totalCount then
				    item:setPositionY(item:getPositionY() - self._reuseItemOffset)
                    self._funcItemUpdate(item.itemData, totalIndex, item)
                    item.index = totalIndex
                end
			end
		else
			if itemPos > self._bufferZone + listViewHeight and item:getPositionY() - self._reuseItemOffset >= 0 then
				local totalIndex = item.index + #items
                if totalIndex <= self._totalCount then
				    item:setPositionY(item:getPositionY() - self._reuseItemOffset)
                    self._funcItemUpdate(item.itemData, totalIndex, item)
                    item.index = totalIndex
                end
            elseif itemPos < -self._bufferZone and item:getPositionY() + self._reuseItemOffset < totalHeight then
				local totalIndex = item.index - #items
                -- TODO:不知道为啥，这里会有bug，第一次会进来，添加一下保护
                -- 应该是放值控件位置的layout发生变化，没有做位置调整
                if totalIndex > 0 then
                    item:setPositionY(item:getPositionY() + self._reuseItemOffset)
                    self._funcItemUpdate(item.itemData, totalIndex, item)
                    item.index = totalIndex
                end
			end
		end
		i = i + 1
	end
	self._lastContentPosY = self._listView:getInnerContainer():getPositionY()
end

function ListViewSimpleCircle:getItemPositionYInView(item)
	local worldPos = item:getParent():convertToWorldSpaceAR(cc.p(item:getPosition()))
	local viewPos = self._listView:convertToNodeSpaceAR(worldPos)
	return viewPos.y
end

return ListViewSimpleCircle