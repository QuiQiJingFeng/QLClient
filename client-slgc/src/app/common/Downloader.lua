local Downloader = class("Downloader")
local LUA_CALLBACK_TYPE = {
    PROCESS = 0,
    DOWNLOAD_FAILED = 1,
    DOWNLOAD_SUCCESS = 2,
}
function Downloader:ctor()

end

--阻塞式下载 savePath :a/b/xxx.xx
function Downloader:downloadSingleFile(url,savePath,processFunc)
    FYDC.excute("Downloader","createSimgleTask",url,savePath,function(type,info) 
        if type == LUA_CALLBACK_TYPE.PROCESS then
            print("FYD::process=",info.process)
        elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_FAILED then
            print("DOWNLOAD_FAILED::errormessage=",info)
        elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_SUCCESS then
            print("DOWNLOAD_SUCCESS====",info)
        end
    end)
end


return Downloader