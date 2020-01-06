local csbPath = "ui/csb/mengya/UIDownload.csb"
local super = game.UIBase
local UITableView = game.UITableView
local UIDownload = class("UIDownload", super, function () return game.Util:loadCSBNode(csbPath) end)
local MAX_THREAD = 5
local UIDownloadItem = import("items.UIDownloadItem")
local DOWNLOAD_STATE = game.UIConstant.DOWNLOAD_STATE 
local LUA_CALLBACK_TYPE = game.Downloader.LUA_CALLBACK_TYPE
local Util = game.Util
function UIDownload:ctor()
end

function UIDownload:init()
    self._btnCreateTask = Util:seekNodeByName(self,"btnCreateTask","ccui.Button")
    local listTask = Util:seekNodeByName(self,"listTask","ccui.ScrollView")
    self._listTask = UITableView.extend(listTask,UIDownloadItem)

    self._taskQueue = {}
    self._workingQueue = {}
end

function UIDownload:pushTask(task)
    task.state = DOWNLOAD_STATE.WAITE
    local list = string.split(task.url,"/")
    local fileName = list[#list]
    task.fileName = fileName
    local wirtePath = cc.FileUtils:getInstance():getWritablePath()
    wirtePath = string.gsub(wirtePath,"\\","/")
    task.savePath = wirtePath .."download/".. fileName
    table.insert(self._taskQueue,task)
end

function UIDownload:needBlackMask()
    return false
end

function UIDownload:isFullScreen()
    return true
end

function UIDownload:getGradeLayerId()
    return game.UIConstant.UILAYER_LEVEL.BOTTOM
end

function UIDownload:onShow()
    
    local storePath = cc.FileUtils:getInstance():getWritablePath()
    local url = "https://lsjgame.oss-cn-hongkong.aliyuncs.com/project.manifest"

    game.Util:sendXMLHTTPrequrest("GET",{}, url, {}, function(content)
        local manifestInfo = json.decode(content)
        local packageUrl = manifestInfo["packageUrl"]
        local assets = manifestInfo["assets"]
        for fileName, asset in pairs(assets) do
            local task = {
                url = packageUrl .. fileName,
                md5 = asset.md5,
            }
            self:pushTask(task)
        end
        for i = 1, MAX_THREAD do
            self:checkNextWorkTask()
        end
    
        self:sortTaskQueue()
        self._listTask:updateDatas(self._taskQueue)
    end)
end

function UIDownload:checkNextWorkTask()
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
        self:sortTaskQueue()
        self._listTask:refreshDatas(self._taskQueue)
        game.Downloader:downloadSingleFile(nextWorkTask.url,nextWorkTask.savePath,function(type,info) 
            if type == LUA_CALLBACK_TYPE.PROCESS then
                nextWorkTask.process = info.process
                nextWorkTask.totalToDownload = info.totalToDownload
                nextWorkTask.nowDownloaded = info.nowDownloaded
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
            self:sortTaskQueue()
            self._listTask:refreshDatas(self._taskQueue)
        end)
    end
end

function UIDownload:sortTaskQueue()
    if #self._taskQueue > 2 then
        table.sort(self._taskQueue,function(a,b) 
            local aValue = 1
            if a.state == DOWNLOAD_STATE.STARTING then
                aValue = aValue + 1000
            elseif a.state == DOWNLOAD_STATE.WAITE then
                aValue = aValue + 100
            elseif a.state == DOWNLOAD_STATE.STOPED then
                aValue = aValue + 10
            end

            local bValue = 2
            if b.state == DOWNLOAD_STATE.STARTING then
                bValue = bValue + 1000
            elseif b.state == DOWNLOAD_STATE.WAITE then
                bValue = bValue + 100
            elseif b.state == DOWNLOAD_STATE.STOPED then
                bValue = bValue + 10
            end
            return aValue > bValue
        end)
    end
end

return UIDownload