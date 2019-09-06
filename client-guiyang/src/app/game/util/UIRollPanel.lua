local NodeTools = require("app.game.util.NodeTools")

--[[    封装的可以拖动并自动循环滚动的容器
	node需要是panel并且第一个元素是一个有背景img和text组成的子控件
	text要是img的子控件
]]
local UIRollPanel = class("UIRollPanel")
local textSpace = 15

function UIRollPanel.extendItem(node)
	NodeTools.extendItem(node, UIRollPanel)
	node:_initialize()
	return node
end

-- 设置滚动列表内容
function UIRollPanel:setTextList(textContentList)
	self._hasData = true
	local totalHeight = 0
	for k, v in ipairs(textContentList) do
		if not self._textList[k] then
			self:_createTextNode()
		end
		self._textList[k].text:setString(v)
		local size = self._textList[k].text:getVirtualRendererSize()
		self._textList[k].text:setContentSize(size)
		local imgWidth =(self._textList[k].img:getContentSize()).width
		local imgHeight = size.height + 9
		self._textList[k].img:setContentSize(cc.size(imgWidth, imgHeight))
		self._textList[k].text:setPositionY(imgHeight / 2)
		totalHeight = totalHeight + imgHeight
	end
	
	totalHeight = textSpace *(#textContentList - 1) + totalHeight
	self._scollConfig.needRoll = self._scollConfig.size.height < totalHeight
	self._scollConfig.num = #textContentList
	self:initTextPosition()
end

-- 开始滚动
function UIRollPanel:startRoll(speed)
	if not self._hasData then
		return
	end
	
	self:unscheduleUpdate()
	if speed then
		self._scollConfig.moveSpeed = speed
	end
	
	self._preMove = self._scollConfig.moveSpeed
	if self._scollConfig.needRoll then
		self:scheduleUpdateWithPriorityLua(function(dt)
			self:_update(dt)
		end, 0)
	end
end

-- 停止滚动
function UIRollPanel:stopRoll()
	self:unscheduleUpdate()
end

-- 停止滚动
function UIRollPanel:clear()
	self:unscheduleUpdate()
	self._hasData = false
	--所有控件移出显示区域
	for k, v in ipairs(self._textList) do
		local node = self._textList[k].img
		node:setPositionY(10000)
	end
	
end

--设置/重置自滚动控件的位置
function UIRollPanel:initTextPosition()
	if not self._hasData then
		return
	end
	local num = self._scollConfig.num
	local positionY = self:getContentSize().height
	if self._scollConfig.needRoll then
		positionY = positionY / 2
	end
	
	for k, v in ipairs(self._textList) do
		local node = self._textList[k].img
		if k > num then
			node:setPositionY(10000)
		else
			positionY = positionY - node:getContentSize().height - textSpace
			node:setPosition(0, positionY)
		end
	end
	if(num ~= 0) then
		self._scollConfig.lowerBound = self:getContentSize().height / 2 + self._textList[num].img:getPositionY()
	end
	self._scollConfig.isGetBound = false
end


function UIRollPanel:_initialize()
	--是否有数据
	self._hasData = false
	self._last = 0
	-- 设定的移动速度
	self._preMove = 0
	--滑动移动距离
	self._touchMoved = 0
	self._beginTouchPos = 0
	--子控件缓存列表
	self._textList = {}
	--[[缓存运动控件各位置的参数(size:滑动容器参数,num:可用元素的数值,isStart:是否已经开始运动,
	needRoll是否需要滚动,isGetBound是否达到panel上边界,lowerBound元素的下边界)
	]]
	--
	self._scollConfig = {}
	
	self._scollConfig.size = self:getContentSize()
	self._scollConfig.isGetBound = false
	self._scollConfig.needRoll = false
	self._scollConfig.lowerBound = 0
	self._scollConfig.moveSpeed = 0
	--子控件模板
	self._templateNode = self:getChildren() [1]
	self._templateNode:removeFromParent(false)
	self:getParent():addChild(self._templateNode)
	self._templateNode:setVisible(false)
	self:removeAllChildren(false)
	local text = self._templateNode:getChildren() [1]
	text:ignoreContentAdaptWithSize(true)
	text:setTextAreaSize(cc.size(self._scollConfig.size.width - 10, 0))
	
	self:addTouchEventListener(function(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			self._preMove = 0
			self._beginTouchPos = sender:getTouchBeganPosition()
		elseif eventType == ccui.TouchEventType.moved then
			local pt = sender:getTouchMovePosition()
			self._touchMoved = pt.y - self._beginTouchPos.y + self._touchMoved
			self._beginTouchPos = pt
		elseif eventType == ccui.TouchEventType.ended then
			self._preMove = self._scollConfig.moveSpeed
			self._touchMoved = 0
		elseif eventType == ccui.TouchEventType.canceled then
			self._preMove = self._scollConfig.moveSpeed
			self._touchMoved = 0
		end
	end)
end

--创建新的条目
function UIRollPanel:_createTextNode()
	local node = self._templateNode:clone()
	node:setVisible(true)
	self:addChild(node)
	table.insert(self._textList, {img = node, text = node:getChildren() [1]})	
end

--控制滚动条的帧动画
function UIRollPanel:_update(dt)
	
	local y = 0
	-- touch 位移
	if self._touchMoved ~= 0 then
		for i = 1, self._scollConfig.num do
			local node = self._textList[i].img
			y = node:getPositionY()
			
			y = y + self._touchMoved
			node:setPositionY(y)
		end
		
	end
	
	-- 自动向上移动和位置循环(往下移动时必须倒叙遍历否则,会导致坐标不好算)
	if self._scollConfig.needRoll then
		if self._touchMoved >= 0 then
			for i = 1, self._scollConfig.num do
				local node = self._textList[i].img
				y = node:getPositionY()
				
				y = y + self._preMove * dt
				if y > self._scollConfig.size.height then
					self._scollConfig.isGetBound = true
					--找到前一个元素
					local prevNodeIndex = i - 1 > 0 and i - 1 or self._scollConfig.num
					local prevNode = self._textList[prevNodeIndex].img
					y = prevNode:getPositionY() - textSpace - node:getContentSize().height
				else
					if self._scollConfig.isGetBound and y < self._scollConfig.lowerBound then
						--找到后一个元素
						local nextNodeIndex = i + 1 <= self._scollConfig.num and i + 1 or 1
						local nextNode = self._textList[nextNodeIndex].img
						y = nextNode:getPositionY() + textSpace + nextNode:getContentSize().height
					end
				end
				node:setPositionY(y)
			end
		else
			for i = self._scollConfig.num, 1, - 1 do
				local node = self._textList[i].img
				y = node:getPositionY()
				if self._scollConfig.isGetBound and y < self._scollConfig.lowerBound then
					--找到后一个元素
					local nextNodeIndex = i + 1 <= self._scollConfig.num and i + 1 or 1
					local nextNode = self._textList[nextNodeIndex].img
					local nextNodeY = nextNode:getPositionY()
					if y < nextNodeY then
						y = nextNodeY + textSpace + nextNode:getContentSize().height
					end
				end
				
				node:setPositionY(y)
			end
		end
	end
	
	self._touchMoved = 0
	
end

return UIRollPanel 