local ns = namespace("manager")

---------------------
-- 下载到本地的远程文件管理器
---------------------
local RemoteFileManager = class("RemoteFileManager")
ns.RemoteFileManager = RemoteFileManager

-------------------------
-- 单例支持
local _instance = nil

-- @return boolean
function RemoteFileManager.create()
    if RemoteFileManager.instance ~= nil then
        return false
    end

    _instance = RemoteFileManager.new()
	_instance:initialize()
    return true
end

function RemoteFileManager.destroy()
    if _instance == nil then
        return
    end

    _instance:dispose()
    _instance = nil
end

function RemoteFileManager.getInstance()
    return _instance
end

--------------------------
function RemoteFileManager:ctor()
    --[[
        任务列表
        key=fileType+fileUrl
        data={
            fileType, fileUrl, loadHandler, times(次数), processing(是否正在下载)
        }
    ]]
    self._tasks = {}
end

function RemoteFileManager:initialize()
end

function RemoteFileManager:dispose()
end

-- 查看一个远程文件是否在本地有存储
function RemoteFileManager:doesFileExist(fileType, fileUrl)
	return cc.FileUtils:getInstance():isFileExist(self:getFilePath(fileType, fileUrl))
end

-- 获取远程文件在本地的存储路径(包括文件名)
function RemoteFileManager:getFilePath(fileType, fileUrl)
	return self:getFileTypeDirectory(fileType) .. "/" .. self:getFileName(fileUrl)
end

-- 获取文件的保存目录
function RemoteFileManager:getFileTypeDirectory(fileType)
	return cc.FileUtils:getInstance():getAppDataPath() .. fileType
end

-- 获取文件的文件名
function RemoteFileManager:getFileName(fileUrl)
	return loho.md5(fileUrl)
end

-- 创建文件保存路径
function RemoteFileManager:_createDirectoryForFilType(fileType)
	local fileFolder = self:getFileTypeDirectory(fileType)
	if cc.FileUtils:getInstance():isDirectoryExist(fileFolder) == false then
		cc.FileUtils:getInstance():createDirectory(fileFolder)
	end
end


-- 从远程下载文件, 如果本地有这个文件, 直接调用loadHandler
-- @param fileType, 文件类型
-- @param fileUrl, 文件远程路径
-- @param loadHandler, 加载回调, function(tf, fileType, fileName)
-- @reset,不管有没有缓存，重新下载
function RemoteFileManager:getRemoteFile(fileType, fileUrl, loadHandler, reset)
	if self:doesFileExist(fileType, fileUrl) and not reset then
		-- 本地已经存在, 不用下载
		loadHandler(true, fileType, fileUrl)
		return
    end
    
    local task = self:_addNewTask(fileType, fileUrl, loadHandler)
    if not task.processing then
        self:_processTask(task)
    end
end

--[[
    @desc: 添加下载任务
    author:{author}
    time:2018-08-15 16:24:57
    --@fileType:
	--@fileUrl:
	--@loadHandler: 
    @return:
]]
function RemoteFileManager:_addNewTask(fileType, fileUrl, loadHandler)
    local key = fileType.."|||"..fileUrl
    local task = self._tasks[key]
    if task == nil then
        -- 新任务！
        task = {
            fileType = fileType,
            fileUrl = fileUrl,
            loadHandler = {loadHandler},
            times = 3,
            processing = false
        }
        self._tasks[key] = task
    else 
        -- 之前在下载了，那么增加到3次
        table.insert(task.loadHandler, loadHandler) 
        task.times = 3
    end
    return task
end

--[[
    @desc: 
    author:{author}
    time:2018-08-15 17:32:18
    --@task: 
    @return:
]]
function RemoteFileManager:_processTask(task)
    Logger.debug("_processTask task.fileUrl is:"..task.fileUrl.." task.times is: "..task.times)
    task.processing = true
    task.times = task.times - 1
	-- HTTP下载
	local xhr = cc.XMLHttpRequest:new()
	xhr._urlFileName = self:getFileName(task.fileUrl);
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", task.fileUrl)
    local function onDownloadImage(task)
        local _t = task

        local handler = function (tf, fileType, fileName)
            -- 移除task，并调用外部handler
            local key = _t.fileType.."|||".._t.fileUrl
            self._tasks[key] = nil
            if _t.loadHandler ~= nil and #_t.loadHandler ~= 0 then
                for k,v in ipairs(_t.loadHandler) do
                    v(tf, fileType, fileName)
                end
            end
        end

        return function ()
            _t.processing = false -- 回调到了，下载暂停
            Logger.debug("xhr.readyState is:"..xhr.readyState.." xhr.status is: "..xhr.status .. " url:" .. _t.fileUrl)
            if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                -- 下载成功, 保存本地文件
                if self:doesFileExist(_t.fileType, _t.fileUrl) then
                    -- 有可能同时发起了多次下载, 不用保存了
                    handler(true, _t.fileType, _t.fileUrl)
                else
                    -- 有可能同时发起了多次下载, 已经存在的文件就不用保存了
                    self:_createDirectoryForFilType(_t.fileType);
                    local file = io.open(self:getFilePath(_t.fileType, _t.fileUrl), "wb")
                    if file ~= nil then
                        file:write(xhr.response)
                        file:close()
                        handler(true, _t.fileType, _t.fileUrl)
                    else
                        Logger.error("Save file failed : %s", _t.fileUrl)
                        handler(false, _t.fileType, _t.fileUrl)
                    end
                end
            else
                -- 出现错误
                if _t.times > 0 then
                    self:_processTask(_t)
                else
                    handler(false, _t.fileType, _t.fileUrl)
                end
            end
        end
	end

	xhr:registerScriptHandler(onDownloadImage(task))
	xhr:send()
end