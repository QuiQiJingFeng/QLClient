local LogService = class("LogService")

-- 日志类型
local LOG_TYPE = {
    LOGINFO = 1,
    CUSTOMINFO = 2
}

-----------------------------点击事件跟踪--------------------------------------
local bindEventLog = function (sender, event)
	local wdt = sender:getName()
	local parent = sender:getParent()
	local last = parent
	while parent and parent:getParent() ~= cc.Director:getInstance():getRunningScene() and parent:getParent() ~= GameMain.getInstance() do
		last = parent
		parent = parent:getParent()
		if not parent then
			break
		end
		-- print("parent ", parent:getName())
	end

	local ui = (parent and parent:getName() and parent:getName() ~= "") and parent:getName() or last:getName()
	LogService:getInstance():dolog(ui, wdt, event)
end

local Widget = ccui.Widget
-- 重载c++函数，来插入统计
local cplus_Widget_AddTouchEventListener = ccui.Widget.addTouchEventListener
function Widget:addTouchEventListener(callback)
    cplus_Widget_AddTouchEventListener(self, function(sender, state)
        if state == 2 then
            bindEventLog(sender, 2)
        end
        callback(sender, state)
    end)
end
---------------------------------------------------------------------------------

-- log 路径，用来做路径检查
local FILE_PATH = cc.FileUtils:getInstance():getAppDataPath().."log/"
-- 输出日志的文件
local FILE_LOG = FILE_PATH.."log.txt"
-- 上传日志的文件
local FILE_UPLOAD = FILE_PATH.."upload.txt"
-- CACHE
local FILE_CACHE = FILE_PATH.."cache"
-- 上传日志的URL
-- local URL = "http://172.16.2.70:8081/upload?"
-- local URL = "http://172.16.2.126:9020/logcollector/logs?"
-- local URL = "https://test.outside.logcollector.majiang01.com/logcollector/logs?"
local URL = "https://outside.logcollector.majiang01.com/logcollector/logs?"

local TIME_LOG = 2
local TIME_UPLOAD = 300
local TIME_UPLOAD_NEW_PLAYER = 30
-- 3*24*60*60
local TIME_NEW_PLAYER = 259200

local _instance = nil
function LogService:getInstance()
    if not _instance then
        _instance = LogService.new()
    end
    return _instance
end

function LogService:ctor()
    self._cache = {}
    self._lastTime = os.time()
    self._lastUploadTime = os.time()

    self._areaID = -1
    self._playerID = -1

    self._url = nil
end

-- 初始化
--[[
    @param url 上传的连接
    @param method 压缩密码，现在无用
]]
function LogService:initialize()
    if not self:isEnabled() then
        return
    end

    if device.platform == 'android' and game.plugin.Runtime.getSDKVersion() <= 20 then
        release_print("version too low, log service initialize stop")
        return 
    end

    if not cc.FileUtils:getInstance():isDirectoryExist(FILE_PATH) then
        cc.FileUtils:getInstance():createDirectory(FILE_PATH)
    end
   
    self:_startPollEvent()
end

--[[
    在发送日志之前，必须要先赋值
    @param areaID 当前地区id
    @param playerID 玩家id
]]
function LogService:setUploadInfo(areaID, playerID)
    self._areaID = areaID
    self._playerID = playerID

    -- 重新拼装url
    self._url = string.format("%s&areaid=%d&playerid=%d&", URL, self._areaID, self._playerID)

    local startTime = os.time()
    -- 处理，如果app下载3天内，上报频率提高
    if not cc.FileUtils:getInstance():isFileExist(FILE_CACHE) then
        local file = io.open(FILE_CACHE, "ab+")
        if file then
            file:write(startTime)
            file:close()
        end
    else
        local file = io.open(FILE_CACHE, "rb+")
        if file then
            startTime = tonumber(file:read("*a"))
            file:close()
        end
    end

    -- 如果是在3天内，改变上报间隔
    if os.time() - startTime < TIME_NEW_PLAYER then
        TIME_UPLOAD = TIME_UPLOAD_NEW_PLAYER
    end

    -- 上传一份当前的设备信息
    self:log(LOG_TYPE.CUSTOMINFO, {
        deviceId=game.plugin.Runtime.getDeviceId(),
        deviceName=game.plugin.Runtime.getDeviceName(),
        systemName=game.plugin.Runtime.getSystemName(),
        systemVersion=game.plugin.Runtime.getSystemVersion(),
    })
end

function LogService:dispose()
    self:_endPollEvent()
end

-- c++方面的调用，所以要提前判断当前是否支持
function LogService:isEnabled()
    return cc.XMLHttpRequest.uploadFile ~= nil
end

-- 开始事件回调更新
function LogService:_startPollEvent()
	if self._pollEventTask == nil then
        self._pollEventTask = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
            -- 帧更新事件
            self:_update()
		end, 1, false)
	end
end

-- 关闭事件回调更新
function LogService:_endPollEvent()
	if self._pollEventTask then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._pollEventTask)
		self._pollEventTask = nil
	end
end

-- UI log接口
--[[
    @param ui 当前的界面
    @param wdt 当前触发的控件
    @param event 当前控件触发的事件，现在应该只有点击，非按钮的相关事件也无法通过此方式处理
]]
function LogService:dolog(ui, wdt, event)
    if not self:isEnabled() then
        return
    end
    self:log(LOG_TYPE.LOGINFO, {ui=ui, widget=wdt,event=event})
end

--[[
    @param type 当前类型 日志，二维码
    -- @param areaID 当前地区id
    -- @param playerID 玩家id
    @param message 发送的实际内容，支持发送table
]]
function LogService:log(type, message)
    if not self:isEnabled() then
        return
    end
    table.insert(self._cache, {time=os.time(),type=type, message=message})
end

--[[
    TIME_LOG 到一定时间，然后写入本地文件
    TIME_UPLOAD 上传服务器
]]
function LogService:_update()
    if not self:isEnabled() then
        return
    end
    local time = os.time() - self._lastTime
    if time > TIME_LOG then
        self._lastTime = os.time()
        self:_writeToFile()
    end
    time = os.time() - self._lastUploadTime
    if time > TIME_UPLOAD then
        self._lastUploadTime = os.time()
        self:_upload()
    end
end

-- 缓存落地，将TIME_LOG时间内的log写到本地中
function LogService:_writeToFile()
    -- Logger.debug("LogService:_writeToFile")
    if not self:isEnabled() then
        return
    end

    if #self._cache == 0 then
        return
    end

    local file = io.open(FILE_LOG, "ab+")
    if file then
        local str = json.encode(self._cache)
        str = string.sub(str, 2,string.len(str)-1)
        file:write(str..",")
        file:close()

        -- 清除缓存
        self._cache = {}
    end
end

function LogService:_uploadR()
    local function remove()
        local res1, error1 = os.remove(FILE_UPLOAD)
        if not res1 then
            Logger.debug(error1)
        end
    end

    kod.util.Http.uploadFile(self._url, FILE_UPLOAD, 1, 2, function(xhr, event)
        -- 空文件，直接删除吧
        if event == "FILE_EMPTY" then
            Logger.debug("FILE_EMPTY")
            remove()
            return
        end
        if not xhr then
            return
        end
        -- 成功后删除对应文件
        if xhr.status == 200 then
            Logger.debug("logServiceUpload finished " .. tostring(xhr.status))
            -- 上传成功
            remove()
        end
    end, 30)
end

-- 上传服务器，先将文件重命名一下，然后再上传，上传完成删除
function LogService:_upload()
    if not self:isEnabled() then
        return
    end
    if self._areaID == -1 or self._playerID == -1 then
        return
    end

    -- 如果文件不存在那么就不要处理了
    if not cc.FileUtils:getInstance():isFileExist(FILE_LOG) then
        return
    end
    -- Logger.debug("LogService:_upload")

    -- 这里需要处理一下，如果文件已经存在了会怎么办？
    if cc.FileUtils:getInstance():isFileExist(FILE_UPLOAD) then
        -- 如果此时文件已经存在了，先上传这个文件
        self:_uploadR()
        return
    end
    local res, error = os.rename(FILE_LOG, FILE_UPLOAD)
    if res then
        self:_uploadR()
    else
        Logger.debug(error)
    end
end

return LogService