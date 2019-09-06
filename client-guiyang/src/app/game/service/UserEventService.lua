local UserEventService = class("UserEventService")
local UIConfig = require("app.define.UIConfig")
local ns = namespace("game.service")
local Version = require "app.kod.util.Version"
ns.UserEventService = UserEventService


local TIME_UPLOAD = 300
local _instance = nil

function UserEventService:ctor()
    self._file = nil
    self._runVersion = "0.0.0.0"

    self._lastUploadTime = os.time()
end

function UserEventService.getInstance()
    if _instance then
        return _instance
    end

    _instance = UserEventService.new()
    _instance:initialize()
    return _instance
end
--创建本地文件
function UserEventService:_createRecordFile()
    Logger.debug("_createRecordFile~~~~~~~~~~~~")
	local fileFolder = cc.FileUtils:getInstance():getAppDataPath().."UserEvent"
	if cc.FileUtils:getInstance():isDirectoryExist(fileFolder) == false then
		cc.FileUtils:getInstance():createDirectory(fileFolder)
    end
    
    local fileName = fileFolder.. "/Record.log"
    self._filePath = fileName
    local bExist = cc.FileUtils:getInstance():isFileExist(fileName)
    self._file = io.open(fileName, "a")
    if not bExist then
        self:_writeFileHeader()
    end
end
--将公共信息作为文件头写入
function UserEventService:_writeFileHeader()
    local header = {
        sub_area_id = game.service.LocalPlayerService.getInstance():getArea(),
        game_channel =  game.plugin.Runtime.getChannelId()
    }
    self:_writeOneRecord(header)
end

function UserEventService:initialize()
    self:_createRecordFile()  

    self._updateEvent = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        -- 帧更新事件
        self:_update()
    end, 1, false)
end

function UserEventService:dispose()
    if self._update ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateEvent)
    end
end
--获取version版本
function UserEventService:initVersion()
    local runversion = Version.new(game.plugin.Runtime.getBuildVersion())
    runversion._versions[4] = game.service.UpdateService.getInstance():getProductVersion():getVersions()[1]
    self._runVersion = runversion:toString()
end

function UserEventService:_writeOneRecord(data)
    -- Logger.debug("_writeOneRecord~~~~~~~~~~~~")
    local str = json.encode(data).."\n"
    if self._file ~= nil then
        self._file:write(str)
        self._file:flush()
    end
end

--界面显隐事件
function UserEventService:createLayerRecord(name, eType, level, lastLayer)
    
    local params = {
        log_time = kod.util.Time.nowMilliseconds(),
        game_version = self._runVersion,
        playerId = game.service.LocalPlayerService.getInstance():getRoleId(),
        event_type = eType,
        record_level = level,
        current_interface = name,
        last_interfase = lastLayer,
        c_name = UIConfig.getChineseName(name)
    }
    self:_writeOneRecord(params)
end

--按钮点击事件
function UserEventService:createButtonRecord(button)
    local params = {
        log_time = kod.util.Time.nowMilliseconds(),
        game_version = self._runVersion,
        playerId = game.service.LocalPlayerService.getInstance():getRoleId(),
        event_type = "button_click",
        record_level = config.UIRecordLevel.OtherButton,
        button = button:getName()
        -- button = button:getName(),
        -- last_interfase = lastLayer
    }

    local curUIName = UIManager:getInstance():getCurUIName()
    local ui = UIManager:getInstance():getUI(curUIName)
    params.current_interface = curUIName
    if ui ~= nil then
        local layerLevel = ui:getUIRecordLevel()
        if layerLevel == config.UIRecordLevel.MainLayer then
            params.record_level = config.UIRecordLevel.MainButton
        end
    end

    self:_writeOneRecord(params)
end

--update
function UserEventService:_update()

    local time = os.time() - self._lastUploadTime
    if time > TIME_UPLOAD then
        self._lastUploadTime = os.time()
        self:_uploadLog()
    end

end


-- local ZIPLOGFILE_UPLOAD_URL = "http://127.0.0.1:3456"
-- local ZIPLOGFILE_UPLOAD_URL = "http://172.16.2.126:9020/logcollector/logs?areaid=%s&playerid=%s&"
-- local ZIPLOGFILE_UPLOAD_URL = "http://172.16.2.126:9020/logcollector/compressFileUpload?areaid=%d&playerid=%d&table=client_action&"
function UserEventService:_uploadLog()
    if self._file ~= nil then
        self._file:close()
        self._file = nil
    end
    local zipFilePath = self._filePath
    local fileUtils = cc.FileUtils:getInstance()
    -- print("_uploadLog~~~~~~~~~~~~~~~~~~~~~~")
    if fileUtils:isFileExist(self._filePath) then
        local url = string.format(config.UrlConfig.getUserEventUrl(), 
            game.service.LocalPlayerService:getInstance():getArea(),
            game.service.LocalPlayerService:getInstance():getRoleId()
        )
        kod.util.Http.uploadFile(url, self._filePath, 1, 2, function(xhr, event)
            -- 空文件，直接删除吧
            if event == "FILE_EMPTY" then
                Logger.debug("FILE_EMPTY")
                return
            end
            if not xhr then
                return
            end
            -- 成功后删除对应文件
            if xhr.status == 200 then
                -- 上传成功
                Logger.debug("logServiceUpload finished " .. tostring(xhr.status))
                fileUtils:removeFile(zipFilePath)
                self:_createRecordFile()
               
            else
                Logger.debug("logServiceUpload failed ")
            end
        end, 30)

	end
end
return UserEventService