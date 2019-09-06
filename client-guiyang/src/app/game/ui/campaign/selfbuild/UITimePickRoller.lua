--[[
时间选择器
--]]
local csbPath = "ui/csb/Campaign/selfbuild/UIBattleDate.csb"
local super = require("app.game.ui.UIBase")
local UIRoller = require("app.game.ui.UIRoller")

-- range helper class
local UITimePickRollerRange = class("UITimePickRollerRange")
function UITimePickRollerRange:ctor(s, e)
	self._start = s
	self._end = e
end

function UITimePickRollerRange:getStart()
	return self._start
end

function UITimePickRollerRange:getEnd()
	return self._end
end

function UITimePickRollerRange:getCount()
	return 1 + self._end - self._start
end

function UITimePickRollerRange:getValue(idx)
	return self._start + idx
end

function UITimePickRollerRange:convertValue2Inx(value)
	return value - self._start
end


local UITimePickRoller = class("UITimePickRoller", super, function() return kod.LoadCSBNode(csbPath) end)

function UITimePickRoller:ctor(confirmCallback)
	self._callback = confirmCallback
	self._delayTime = 10*60
	self._pickers = {}
	
	self._timeList = {}
	self._timeList.year = nil
	self._timeList.month = nil
	self._timeList.day = nil
	self._timeList.hour = nil
	self._timeList.min = nil

	local button = seekNodeByName(self, "Button_close", "ccui.Button")
	bindEventCallBack(button, handler(self, self._onClose), ccui.TouchEventType.ended)
	button = seekNodeByName(self, "Button_qd", "ccui.Button")
	bindEventCallBack(button, handler(self, self._onConfirm), ccui.TouchEventType.ended)
	self._settedTimeText = seekNodeByName(self, "Text_1", "ccui.Text")
	local tip = seekNodeByName(self, "Text_1_0", "ccui.Text")
	-- tip:setString("可选时间范围（当前时间" .. self._delayTime / 60 .. "分钟后，7天以内）")
	-- init pickers
	-- years
	local onYearEvent = function(sender, eventType)
		if eventType == UIRoller.AutoScrollEvent.SCROLLING then
			-- print(sender:getValue())
			local old = self._time.year
			local new = sender:getValue()
			if old ~= new then
				self._time.year = sender:getValue()
				self:_updateSettedTimeString()
			end
		end
	end
	
	local pickerBackgroundImage = seekNodeByName(self, "Image_bg1", "ccui.ImageView")
	local maskImg = seekNodeByName(pickerBackgroundImage, "Image_xz1", "ccui.ImageView")
	maskImg:retain()
	pickerBackgroundImage:removeAllChildren(true)
	maskImg:release();
	local pos = {}
	local size = pickerBackgroundImage:getContentSize()
	pos.x, pos.y = pickerBackgroundImage:getPosition()
	pos.x = pos.x - size.width / 2
	pos.y = pos.y - size.height / 2
	local picker = self:_createPicker(size, pos, 3, false, onYearEvent)
	pickerBackgroundImage:getParent():addChild(picker:getWidget())
	self._pickers.year = picker
	
	-- -- months
	local onMonthEvent = function(sender, eventType)
		if eventType == UIRoller.AutoScrollEvent.SCROLLING then
			-- print(sender:getValue())
			local old = self._time.month
			local new = sender:getValue()
			if old ~= new then
				self._time.month = new
				self:_updateDaysPicker()
				self:_updateSettedTimeString()
			end
		end
	end
	
	pickerBackgroundImage = seekNodeByName(self, "Image_bg2", "ccui.ImageView")
	pickerBackgroundImage:removeAllChildren(true)
	pos = {}
	size = pickerBackgroundImage:getContentSize()
	pos.x, pos.y = pickerBackgroundImage:getPosition()
	pos.x = pos.x - size.width / 2
	pos.y = pos.y - size.height / 2
	picker = self:_createPicker(size, pos, 3, true, onMonthEvent)
	pickerBackgroundImage:getParent():addChild(picker:getWidget())
	self._pickers.month = picker
	
	-- -- days
	local onDaysEvent = function(sender, eventType)
		if eventType == UIRoller.AutoScrollEvent.SCROLLING then
			-- print(sender:getValue())
			local old = self._time.day
			local new = sender:getValue()
			if old ~= new then
				self._time.day = new
				self:_updateSettedTimeString()
			end
		end
	end
	
	pickerBackgroundImage = seekNodeByName(self, "Image_bg3", "ccui.ImageView")
	pickerBackgroundImage:removeAllChildren(true)
	pos = {}
	size = pickerBackgroundImage:getContentSize()
	pos.x, pos.y = pickerBackgroundImage:getPosition()
	pos.x = pos.x - size.width / 2
	pos.y = pos.y - size.height / 2
	picker = self:_createPicker(size, pos, 3, true, onDaysEvent)
	pickerBackgroundImage:getParent():addChild(picker:getWidget())
	self._pickers.day = picker
	
	-- -- hours
	local onHoursEvent = function(sender, eventType)
		if eventType == UIRoller.AutoScrollEvent.SCROLLING then
			-- print(sender:getValue())
			local old = self._time.hour
			local new = sender:getValue()
			if old ~= new then
				self._time.hour = new
				self:_updateSettedTimeString()
			end
		end
	end
	
	pickerBackgroundImage = seekNodeByName(self, "Image_bg4", "ccui.ImageView")
	pickerBackgroundImage:removeAllChildren(true)
	pos = {}
	size = pickerBackgroundImage:getContentSize()
	pos.x, pos.y = pickerBackgroundImage:getPosition()
	pos.x = pos.x - size.width / 2
	pos.y = pos.y - size.height / 2
	picker = self:_createPicker(size, pos, 3, true, onHoursEvent)
	pickerBackgroundImage:getParent():addChild(picker:getWidget())
	self._pickers.hour = picker
	
	-- -- minutes
	local onMinutesEvent = function(sender, eventType)
		if eventType == UIRoller.AutoScrollEvent.SCROLLING then
			-- print(sender:getValue())
			local old = self._time.min
			local new = sender:getValue()
			if old ~= new then
				self._time.min = new
				self:_updateSettedTimeString()
			end
		end
	end
	
	pickerBackgroundImage = seekNodeByName(self, "Image_bg5", "ccui.ImageView")
	pickerBackgroundImage:removeAllChildren(true)
	pos = {}
	size = pickerBackgroundImage:getContentSize()
	pos.x, pos.y = pickerBackgroundImage:getPosition()
	pos.x = pos.x - size.width / 2
	pos.y = pos.y - size.height / 2
	picker = self:_createPicker(size, pos, 3, true, onMinutesEvent)
	pickerBackgroundImage:getParent():addChild(picker:getWidget())
	self._pickers.min = picker
end

function UITimePickRoller:_createPicker(size, pos, showedNum, loop, callback)
	local picker = UIRoller.new()
	picker:setPageNumberShowed(showedNum)
	picker:setContentSize(size)
	picker:setPosition(cc.p(pos))
	picker:setLoop(loop)
	picker:setSpringOffset({x = 0, y = 20})
	picker:setEventListener(callback)
	
	return picker
end

function UITimePickRoller:setTime(startTime, endTime, selectedTime)
	self._startTime = startTime
	local settedTime = kod.util.Time.date(selectedTime)
	self._time = {year = settedTime.year, month = settedTime.month, day = settedTime.day, hour = settedTime.hour, min = settedTime.min}
	
	local startDate = kod.util.Time.date(startTime)
	local endDate = kod.util.Time.date(endTime)
	
	local range = UITimePickRollerRange.new(startDate.year, endDate.year)
	self:_updatePicker("year", range, range:convertValue2Inx(self._time.year))
	range = UITimePickRollerRange.new(1, 12)
	self:_updatePicker("month", range, range:convertValue2Inx(self._time.month))
	range = UITimePickRollerRange.new(1, kod.util.Time.getMonthDayNum(startDate.year, startDate.month))
	self:_updatePicker("day", range, range:convertValue2Inx(self._time.day))
	range = UITimePickRollerRange.new(0, 23)
	self:_updatePicker("hour", range, range:convertValue2Inx(self._time.hour))
	range = UITimePickRollerRange.new(0, 59)
	self:_updatePicker("min", range, range:convertValue2Inx(self._time.min))
	
	self:_updateSettedTimeString()
end

function UITimePickRoller:_updatePicker(pickerName, range, setIdx)
	local picker = self._pickers[pickerName]
	self._timeList[pickerName] = range
	picker:reset()
	picker:setItems(range:getStart(), range:getEnd(), setIdx)
	picker:doLayout()
	picker:GoTo(setIdx)
end

function UITimePickRoller:getWidget()
	return self
end

function UITimePickRoller:_onClose()
	self:setVisible(false)
end

function UITimePickRoller:_onConfirm()
	if self:_checkTimeAvailable() then
		if self._callback ~= nil then
			self._callback(self._time)
		end
		
		self:_onClose()
	else
		game.ui.UIMessageTipsMgr.getInstance():showTips("须设置为当前时间" .. self._delayTime / 60 .. "分钟后，7天以内的比赛！");
	end
end

function UITimePickRoller:_updateDaysPicker()
	self._timeList.day = UITimePickRollerRange.new(1, kod.util.Time.getMonthDayNum(self._time.year, self._time.month))
	local oldDayIdx = self._timeList.day:convertValue2Inx(self._time.day)
	local picker = self._pickers.day
	local range = self._timeList.day
	picker:reset()
	picker:setItems(range:getStart(), range:getEnd(), math.min(oldDayIdx, range:getCount() - 1))
	picker:doLayout()
	picker:GoTo(math.min(oldDayIdx, range:getCount() - 1))
end

function UITimePickRoller:_updateSettedTimeString()
	self._settedTimeText:setString(kod.util.Time.dateWithFormat(nil, os.time(self._time)))
end

function UITimePickRoller:_checkTimeAvailable()
	local settedTimeStamp = os.time(self._time)
	local currentTimeStamp = kod.util.Time.now()
	local upperTime = math.floor(currentTimeStamp) + 6 * 24 * 60 * 60
	local upperTimeDetail = kod.util.Time.date(upperTime)
	upperTimeDetail.hour = 23
	upperTimeDetail.min = 59
	
	return settedTimeStamp >= currentTimeStamp + self._delayTime and settedTimeStamp <= os.time(upperTimeDetail)
end

function UITimePickRoller:needBlackMask()
	return true;
end

return UITimePickRoller 