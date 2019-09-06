local MainTagData = class("MainTagData")

MainTagData.ButtonId = {
	Club = 1,
	CreateRoom = 2,
	Gold = 3,
	Campaign = 4,
	League = 5,
}

function MainTagData:ctor()
	--用于时间变化的定时器
	self._action = nil
	--用于主界面标签的数据
	self._tagShowData = {}
	--用于定时器触发后用的时间表(将对所有时间排序去重后依次触发定时器)
	self._timeArray = {}
	--用于存储原始的标签数据
	self._protocolData = {}
	
	game.service.ActivityService.getInstance():addEventListener("EVENT_MAIN_TAG_DATA_RECEIVE", handler(self, self._onReceiveData), self)
end

--接收并处理服务器数据
function MainTagData:_onReceiveData(event)
	self._protocolData = event.protocol.activityTag
	self._timeArray = {}
	
	if self._action then
		unscheduleOnce(self._action)
		self._action = nil
	end
	
	local timeSet = {}
	
	for k, v in ipairs(self._protocolData) do
		timeSet[v.start] = true
		timeSet[v["end"]] = true
	end
	
	for k, v in pairs(timeSet) do
		table.insert(self._timeArray, k / 1000)
	end
	
	table.sort(self._timeArray, function(l, r)
		return l < r
	end)
	
	self:_setTimerAndShowData()
end

--设置定时器并改变数据
function MainTagData:_setTimerAndShowData()
	local currentTime = game.service.TimeService:getInstance():getCurrentTime()
	--去除过期数据
	table.arrayFilter(self._protocolData, function(v) return v["end"] / 1000 > currentTime end)
	table.arrayFilter(self._timeArray, function(v) return v > currentTime end)
	
	--启动下一个timer
	local nextTime = self._timeArray[1]
	if nextTime then
		self._action = scheduleOnce(handler(self, self._setTimerAndShowData), nextTime - currentTime)
	end
	
	self:_changeShowData()
end
--改变显示用的数据
function MainTagData:_changeShowData()
	local currentTime = game.service.TimeService:getInstance():getCurrentTime()
	self._tagShowData = {}
	
	for k, v in ipairs(self._protocolData) do
		if v.start / 1000 < currentTime and v["end"] / 1000 > currentTime then
            -- self._tagShowData[v.buttonId] = v
            table.insert(self._tagShowData, v)
		end
	end
	game.service.ActivityService.getInstance():dispatchEvent({name = "EVENT_MAIN_TAG_CHANGE"})
end

function MainTagData:getShowData()
	return self._tagShowData
end

local mainTagData = MainTagData.new()

return mainTagData 