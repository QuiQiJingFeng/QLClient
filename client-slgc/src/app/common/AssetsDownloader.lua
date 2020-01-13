local AssetsDownloader = class("AssetsDownloader")
local MAX_THREAD = 5
local LUA_CALLBACK_TYPE = game.Downloader.LUA_CALLBACK_TYPE
local DOWNLOAD_STATE = {
    WAITE = 1,
    STARTING = 2,
    STOPED = 3,
    FINISHED = 4,
}
function AssetsDownloader:ctor(versionManifestPath,projectManifestPath)
    self._versionManifestPath = versionManifestPath
    self._projectManifestPath = projectManifestPath
    self:parseCurrentVersion()
    self:parseCurrentPorjectManifest()
    self:getRemoteVersion()
end

function AssetsDownloader:greatorVersion(version1,version2)
    local list1 = string.split(version1,"%.")
    local list2 = string.split(version2,"%.")
    for idx, value in ipairs(list1) do
        if tonumber(value) > tonumber(list2[idx]) then
            return true
        end
    end
end

function AssetsDownloader:start(finishFunc)
    if not self._isGreator then
        finishFunc()
        return
    end
    self._finishFunc = finishFunc
    self._taskQueue = {}
    self._workingQueue = {}
    --解析远程project文件
    self:parseProjectManifest()
end

function AssetsDownloader:pushTask(task)
    local fileUtil = cc.FileUtils:getInstance()
    local wirtePath = fileUtil:getWritablePath()
    wirtePath = string.gsub(wirtePath,"\\","/")
    local downloadPath = wirtePath .."download/"
    task.savePath = downloadPath .. task.fileName
    fileUtil:removeDirectory(downloadPath)
    task.state = DOWNLOAD_STATE.WAITE
    table.insert(self._taskQueue,task)
end

function AssetsDownloader:parseProjectManifest()
    local url = self._remoteProjectUrl
    game.Util:sendXMLHTTPrequrest("GET",{}, url, {}, function(content)
        local manifestInfo = json.decode(content)
        local packageUrl = manifestInfo["packageUrl"]
        local assets = manifestInfo["assets"]
        --本地资源
        local localAssets = self._localProjectInfo["assets"]
        local needUpdateAssets = {}
        for fileName, asset in pairs(assets) do
            if localAssets[fileName].md5 ~= asset.md5 then
                needUpdateAssets[fileName] = asset
            end
        end

        for fileName, asset in pairs(needUpdateAssets) do
            local task = {
                fileName = fileName,
                url = packageUrl .. fileName,
                md5 = asset.md5,
            }
            self._totalSize = self._totalSize + asset.size
            self:pushTask(task)
        end
        local strSize = game.Util:convertStrFileSize(self._totalSize)
        game.ui.UIMessageBoxMgr.getInstance():show("更新包大小"..strSize, { "确定","取消" },
            function()
                for i = 1, MAX_THREAD do
                    self:checkNextWorkTask()
                end
            end,
            function()
                print("退出游戏")
                os.exit(0)
            end
        ) 
    end)
end

function AssetsDownloader:checkNextWorkTask()
    local nextWorkTask
    for _, task in ipairs(self._taskQueue) do
        if task.state == DOWNLOAD_STATE.WAITE then
            nextWorkTask = task
            break
        end
    end
    if nextWorkTask then
        if #self._workingQueue >= MAX_THREAD then
            return
        end
        table.insert(self._workingQueue,nextWorkTask)
        nextWorkTask.state = DOWNLOAD_STATE.STARTING
        game.Downloader:downloadSingleFile(nextWorkTask.url,nextWorkTask.savePath,function(type,info) 
            if type == LUA_CALLBACK_TYPE.PROCESS then
                nextWorkTask.process = info.process
                nextWorkTask.totalToDownload = info.totalToDownload
                nextWorkTask.nowDownloaded = info.nowDownloaded
                self._nowSize = 0
                for _, task in ipairs(self._taskQueue) do
                    local now = task.nowDownloaded or 0
                    self._nowSize = self._nowSize + now
                end
            elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_FAILED then
                nextWorkTask.state = DOWNLOAD_STATE.STOPED
            elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_SUCCESS then
                nextWorkTask.state = DOWNLOAD_STATE.FINISHED
                local index = table.indexof(self._workingQueue,nextWorkTask)
                if index then
                    table.remove(self._workingQueue,index)
                    self:checkNextWorkTask()
                    print("finish:",info.url)
                else
                    assert(false,"NOT FIND WORKING TASK")
                end
            elseif type == LUA_CALLBACK_TYPE.FILE_EXIST then
                -- print("FILE_EXIST====",info)
                nextWorkTask.state = DOWNLOAD_STATE.STOPED
            end
        end)
    end
end

function AssetsDownloader:getRemoteVersion()
    local url = self._remoteVersionUrl
    game.Util:sendXMLHTTPrequrest("GET",{}, url, {}, function(content)
        local versionInfo = json.decode(content)
        local remoteVersion = versionInfo.version
        self._isGreator = self:greatorVersion(self._localVersion,remoteVersion)
    end)
end

function AssetsDownloader:parseCurrentVersion()
    local content = cc.FileUtils:getInstance():getStringFromFile(self._versionManifestPath)
    local versionInfo = json.decode(content)
    self._localVersion = versionInfo.version
    self._remoteVersionUrl = versionInfo.remoteVersionUrl
    self._remoteProjectUrl = versionInfo.remoteManifestUrl
end

function AssetsDownloader:parseCurrentPorjectManifest()
    local content = cc.FileUtils:getInstance():getStringFromFile(self._projectManifestPath)
    local projectInfo = json.decode(content)
    self._localProjectInfo = projectInfo
end

return AssetsDownloader