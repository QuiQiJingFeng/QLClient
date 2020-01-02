local Downloader = class("Downloader")

function Downloader:ctor()

end

--阻塞式下载 savePath :a/b/xxx.xx
function Downloader:downloadSingleFile(url,savePath,processFunc)
    if FYDC.excute("Downloader","checkFileExist",url) then
        FYDC.excute("Downloader","createSimgleTask",url,savePath,processFunc)
    end
    return false
end


return Downloader