local Downloader = class("Downloader")
local LUA_CALLBACK_TYPE = {
    PROCESS = 0,
    DOWNLOAD_FAILED = 1, --用户取消也包含在这个里面
    DOWNLOAD_SUCCESS = 2,
    FILE_EXIST = 3,  --文件已经存在,提示用户改名或者其他操作
}
Downloader.LUA_CALLBACK_TYPE = LUA_CALLBACK_TYPE
function Downloader:ctor()

end

--阻塞式下载 savePath :a/b/xxx.xx
function Downloader:downloadSingleFile(url,savePath,processFunc)
    FYDC.excute("Downloader","createSimgleTask",url,savePath,processFunc)
end

--[[
function(type,info) 
        if type == LUA_CALLBACK_TYPE.PROCESS then
            -- print("FYD::process=",info.process)
            -- if info.process > 30 then
            --     return true
            -- end
            print("PROCESS====",info)
        elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_FAILED then
            print("DOWNLOAD_FAILED::errormessage=",info)
        elseif type == LUA_CALLBACK_TYPE.DOWNLOAD_SUCCESS then
            print("DOWNLOAD_SUCCESS====",info)
        elseif type == LUA_CALLBACK_TYPE.FILE_EXIST then
            print("FILE_EXIST====",info)
        end
    end
]]
return Downloader