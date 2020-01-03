local Downloader = class("Downloader")
local LUA_CALLBACK_TYPE = {
    PROCESS = 0,
    DOWNLOAD_FAILED = 1,
}
function Downloader:ctor()

end

--阻塞式下载 savePath :a/b/xxx.xx
function Downloader:downloadSingleFile(url,savePath,processFunc)
    FYDC.excute("Downloader","createSimgleTask",url,savePath,function(type,info) 
        -- print("FYD====",type,info)
        if type == LUA_CALLBACK_TYPE.PROCESS then
            print("FYD::process=",info.process)
        elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_FAILED then
            print("FYD::errormessage=",info.errormessage)
        end
    end)
    print("111111111111")
end


return Downloader