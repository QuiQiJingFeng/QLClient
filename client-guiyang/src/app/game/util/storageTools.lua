local ns = namespace("storageTools")

local key = "AutoShowStorage"

local AutoShowStorage = {}

local AutoShowCache = class("AutoShowCache")
function AutoShowCache:ctor()
	self.autoShowData = {}
end

local autoShowCache = nil
local typeHasShowed = {}

ns.AutoShowStorage = AutoShowStorage

event.EventCenter:addEventListener("EVENT_LOGIN_OUT", function ()
	typeHasShowed = {}
end, AutoShowStorage)

function AutoShowStorage.saveData()
	manager.LocalStorage.setUserData(game.service.LocalPlayerService.getInstance():getRoleId(), key, autoShowCache)
end

function AutoShowStorage.initData()
	autoShowCache = manager.LocalStorage.getUserData(game.service.LocalPlayerService.getInstance():getRoleId(), key, AutoShowCache)
end

--[[    对外接口:返回是否需要"每日"自动显示的界面
    type:自定义对应需要的一个显示窗口的key
    times:传入需要自动显示的次数,默认1次
    showIgnoreProcess:不填或者false均认为每次开进程只显示一次,填true则认为无视这个条件

    ps:调用后对应的界面就认为是显示过了,请不要不显示界面凭空调用
]]
function AutoShowStorage.isNeedShow(type, times, showIgnoreProcess)
	times = times or 1
	local time = game.service.TimeService:getInstance():getCurrentTime()
	local currentDate = os.date("%x", time)
	
	local data = autoShowCache.autoShowData[type]
	if not data or data.date ~= currentDate then
		data = {
			date = currentDate,
			times = 0,
		}
		autoShowCache.autoShowData[type] = data
	end
	local flag = false
	if(not typeHasShowed[type] or showIgnoreProcess) and data.times < times then
		data.times = data.times + 1
		typeHasShowed[type] = true
		flag = true
	end
	
	AutoShowStorage.saveData()
	return flag
end