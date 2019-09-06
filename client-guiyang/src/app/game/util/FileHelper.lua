--[[
    文件助手
]]

local ns = namespace("kod.util.FileHelper")
--写文件
ns.writeFile = function(fileName, str, wType)
    local fullPath = cc.FileUtils:getInstance():getAppDataPath()..loho.md5(fileName)
    wType = wType or "wb"
    local file = io.open(fullPath, wType)
    file:write(str)
    file:close()
end
--读文件
ns.readFile = function(fileName)
    local fullPath = cc.FileUtils:getInstance():getAppDataPath()..loho.md5(fileName)
    if cc.FileUtils:getInstance():isFileExist(fullPath) then
        return cc.FileUtils:getInstance():getStringFromFile(fullPath)
    else
        return ""
    end
end
--获取文件md5
ns.getFileMd5 = function (fileName)
    local str = ns.readFile(fileName)
    return loho.md5(str)
end

